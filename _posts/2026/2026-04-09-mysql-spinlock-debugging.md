---
layout: post
title: "Debugging MySQL Spinlock Contention"
description: >-
  How we diagnosed and fixed mysterious MySQL performance issues during periodic data syncs by
  disabling the adaptive hash index and switching to atomic table swaps.
tags: [databases, mysql, performance]
---

A few years ago, I worked on a system that served transit data from MySQL. We would collect spatial
data from our customers and store routes and stops as polylines and geographic points in our
database. Transit data is fairly static, so we would refresh the data periodically, roughly once an\
hour, pulling updates from upstream sources.

Everything worked fine until it didn't. During syncs, the database would enter a spinlock state and
requests would grind to a halt. API responses that normally took milliseconds were timing out. The
entire system would freeze for minutes at a time. Our on-call engineers would get paged, and the
fastest way to resolution was to completely restart our database.

It was the hardest bug I ever faced. This is the story of how we debugged it.

## The Symptoms

The pattern was consistent and predictable. Every hour, like clockwork, performance would crater.
CPU would spike, queries would pile up, and the application would become slow. If the service was
under heavy load at the time, requests would become so slow that the entire database would collapse.
Everything would stop, and our on-call engineers would get paged. Sometimes the system would
sel;f-heal. Other times it required a database restart to get us operational once again.

The timing pointed to our data sync process. We were running bulk upserts to refresh route and stop
data. Nothing exotic - just standard `INSERT ... ON DUPLICATE KEY UPDATE` operations hitting InnoDB
tables. The sync itself wasn't particularly large, maybe a few thousand routes and stops. But it was
enough to bring the database to its knees.

The obvious culprits didn't pan out. We had adequate hardware resources. CPU and memory weren't
exhausted. We weren't running out of connections or hitting query limits. The database configuration
looked reasonable. Nothing in the slow query log suggested a smoking gun.

Something more fundamental was wrong.

## Performance Schema Reveals Contention

MySQL's performance schema gave us our first real clue. During the sync operations, we were seeing
massive contention on internal InnoDB mutexes. Threads were spinning, waiting for locks that weren't
being released. The database wasn't frozen because of I/O or resource exhaustion. It was frozen
because threads were stuck waiting for each other.

The contention centered around specific InnoDB subsystems. The adaptive hash index was showing up
repeatedly in the mutex wait statistics. So were the data structures involved in B-tree
modifications during bulk inserts.

We had a direction now, but understanding what was actually happening required going deeper. The
performance schema told us _what_ was contending, but not _why_ or _how_ to fix it.

## Reading the C Code

I ended up digging into the InnoDB source code to understand what was happening under the hood. Not
exactly a common debugging technique, but we were out of obvious options.

The adaptive hash index (AHI) is an InnoDB optimization for read-heavy workloads with stable data.
It builds an in-memory hash index on top of frequently accessed B-tree pages, bypassing the B-tree
traversal for hot records. In theory, this speeds up point lookups by avoiding repeated tree
searches.

The problem is that AHI is optimized for reads on stable data, not for write-heavy workloads with
frequent modifications. During bulk updates, the AHI was being constantly invalidated and rebuilt.
Every batch of inserts would trigger AHI maintenance operations, which required acquiring internal
mutexes to protect the hash index structures.

Under heavy write load, threads were contending for these AHI mutexes. Some threads were trying to
update the hash index while others were trying to read from it. Some were trying to invalidate
entries while others were trying to insert new ones. The AHI, intended to optimize performance, was
creating a bottleneck.

The B-tree contention was a separate but related issue. Our bulk upserts were directly modifying
live tables while serving production traffic. Every insert required acquiring locks on the target
B-tree pages, and those locks were blocking concurrent reads. The combination of AHI contention and
B-tree lock contention was creating a perfect storm of spinlock behavior.

## Building a Reproduction Framework

Debugging this in production was slow and risky. We needed a way to reproduce the issue reliably
without impacting users. A colleague built a framework that could replay production-like sync
patterns against a test database while simulating concurrent read traffic.

This was invaluable. It let us test hypotheses quickly and measure the impact of potential fixes. We
could see the spinlock contention manifest in the test environment, confirm our understanding of the
problem, and validate solutions before touching production.

## Fix One: Disabling Adaptive Hash Index

The first fix was straightforward: disable the adaptive hash index globally. We were using Google
Cloud SQL for MySQL, so this meant flipping a flag in the console. One setting change, no code
modifications required.

The improvement was immediate and dramatic. The spinlock contention on AHI mutexes disappeared. Sync
operations still caused some performance degradation - you can't avoid that with bulk
modifications - but the complete freezes were gone.

Disabling AHI is a common pattern for write-heavy or periodic refresh workloads. If your data isn't
stable, or if you're doing frequent bulk modifications, AHI often creates more problems than it
solves. The overhead of maintaining the hash index outweighs the benefit of faster lookups.

## Fix Two: Atomic Table Swaps

Disabling AHI solved the hash index contention, but we still had B-tree lock contention from
modifying live tables during heavy read traffic. The second fix addressed this by changing how we
loaded data.

Instead of running bulk upserts directly into production tables, we switched to an atomic update
pattern. We'd create temporary tables with the same schema, load all the updated data into those
temporary tables, then use `RENAME TABLE` to atomically swap them into place.

```sql
-- Load data into temporary tables
CREATE TABLE routes_temp LIKE routes;
CREATE TABLE stops_temp LIKE stops;

-- Bulk load new data (no locking on live tables)
INSERT INTO routes_temp ...
INSERT INTO stops_temp ...

-- Atomic swap
RENAME TABLE
  routes TO routes_old,
  routes_temp TO routes,
  stops TO stops_old,
  stops_temp TO stops;

-- Clean up old tables
DROP TABLE routes_old;
DROP TABLE stops_old;
```

This pattern gives you an atomic swap with minimal lock time on the live tables. The expensive
work - loading and indexing data - happens on temporary tables that aren't serving production
traffic. The only point where live tables are locked is the brief `RENAME TABLE` operation, which is
metadata-only and extremely fast.

The trade-off is that you're replacing entire tables rather than selectively updating rows. This
works well for periodic refresh workloads where you're replacing all the data anyway. It doesn't
work if you need to merge new data with existing records or preserve historical data.

## Common Patterns in Write-Heavy Workloads

Both of these fixes - disabling AHI and using atomic table swaps - are common patterns for
write-heavy or periodic refresh workloads in MySQL. They're not exotic techniques. They're standard
approaches for managing bulk updates without disrupting concurrent reads.

The AHI issue in particular is well-documented but not widely understood. The default MySQL
configuration enables AHI, and it genuinely helps in read-heavy scenarios with stable data. But it
can be catastrophically bad in other scenarios. Understanding when to disable it requires
understanding what it's actually doing and how it interacts with your workload.

The atomic table swap pattern is equally standard. It's the same technique used by tools like
pt-online-schema-change for zero-downtime schema migrations. The core insight is that you can often
avoid lock contention by doing expensive operations on shadow copies and atomically swapping them
into place.

## What I Learned

This debugging process reinforced a few lessons that have stuck with me.

First, default configurations aren't always optimal. MySQL ships with AHI enabled because it helps
in common cases, but "common" doesn't mean "all." Understanding your specific workload and access
patterns matters more than following defaults.

Second, contention issues can be invisible until they're catastrophic. Our system handled normal
traffic fine. It only broke during bulk updates when multiple subsystems - AHI maintenance, B-tree
modifications, concurrent reads - all contended for the same resources simultaneously.

Third, sometimes you need to read the implementation to understand the behavior. The performance
schema pointed us toward AHI contention, but understanding _why_ it was contentious required reading
the C code to see how AHI maintenance actually worked. Documentation describes what features do, but
source code shows you how they do it.

Finally, having a reliable reproduction framework was essential. We couldn't have debugged this
effectively in production. Being able to recreate the issue in a controlled environment, test
hypotheses, and validate fixes made the difference between flailing around and systematically
solving the problem.

## Looking Back

Years later, both the AHI issue and the atomic table swap pattern seem obvious in hindsight. Of
course you should disable optimizations that don't fit your workload. Of course you should avoid
locking production tables during bulk updates.

But in the moment, debugging this was anything but obvious. It took performance schema analysis,
source code reading, reproduction frameworks, and systematic hypothesis testing to understand what
was happening and how to fix it.

That's usually how debugging goes. The solution is simple once you understand the problem. The hard
part is getting to that understanding.
