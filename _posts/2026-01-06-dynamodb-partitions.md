---
layout: post
title: "DynamoDB Hot Partitions"
description: >-
  Hot partitions can cripple DynamoDB performance even when you have adequate provisioned capacity.
  Understanding how they form and how to prevent them is crucial for scalable applications.
tags: [databases, dynamodb, aws, performance, scalability]
---

I've been playing around with a prototype system that needs to store something like 2 billion
records in DynamoDB. The service that could use this system handles around 30 million reads per day,
in a mission critical code path. At peak load the service handles 2,000 reads per second. At this
scale, getting key design wrong can really impact application performance.

The nature of our reads means one of our biggest risks is hot partitions. Even with adequate total
capacity, poor key design can concentrate traffic on individual partitions, creating bottlenecks
that cripple performance. You might provision plenty of read and write capacity, see healthy metrics
at the table level, but still get throttled requests and increased latency.

Understanding hot partitions—what they are, how they form, and how to prevent them—is crucial for
any application running at scale on DynamoDB.

## How DynamoDB Partitions Work

DynamoDB stores your table's data across multiple physical storage partitions. When you create a
table, DynamoDB starts with a single partition. As your data grows or your throughput requirements
increase, DynamoDB automatically adds more partitions to handle the load.

The partition count is determined by two factors: storage and throughput. DynamoDB creates enough
partitions to ensure that each partition stores no more than 10 GB of data and can handle the
required read/write capacity. The formula is roughly:

```
Partitions needed = MAX(
  Table size in GB / 10,
  (RCU needed / 3000) + (WCU needed / 1000)
)
```

So if you have 100 GB of data requiring 6,000 RCU and 2,000 WCU, you'd need at least 10 partitions
for storage (100/10) and 4 partitions for throughput ((6000/3000) + (2000/1000)). DynamoDB would
create 10 partitions. Once created, partitions are never deleted or merged, even if your data
shrinks or throughput requirements decrease. This is important—if you had a traffic spike that
forced DynamoDB to create more partitions, you're stuck with them.

## Partition Key Placement

Each item gets placed on a specific partition based on a hash of its partition key value. DynamoDB
uses a consistent hashing algorithm that ensures the same partition key always maps to the same
partition. You can't see or control this mapping. It's completely opaque. The hash function is
designed to distribute keys uniformly across partitions assuming your partition key values are
randomly distributed. If your keys aren't random, the hash won't save you. You'll still end up with
uneven distribution.

This is where hot partitions come from. Even though DynamoDB creates enough partitions to handle
your total throughput, that capacity is only useful if your traffic distributes evenly across all
partitions. When traffic concentrates on specific partition key values, those items all live on the
same partition, and that partition becomes a bottleneck.

## What Hot Partitions Look Like

Hot partitions manifest in several ways. You'll see throttled requests
(`ProvisionedThroughputExceededException`) despite having unused capacity according to your
table-level metrics. Latency increases for operations hitting the hot partition while other
operations remain fast. CloudWatch metrics might show `SystemErrors` or `UserErrors` that don't
correlate with your total traffic volume. The frustrating part is that these problems can appear
suddenly. Your application might work fine at low traffic, then break when volume increases—not
because you don't have enough capacity, but because that capacity isn't evenly distributed.

For example, imagine you have a table with 10 partitions, each capable of 3,000 RCU. Your table can
theoretically handle 30,000 reads per second. But if 80% of your traffic hits partition key values
that all hash to the same partition, that partition gets overwhelmed at just 3,750 reads per second
while the other 9 partitions sit mostly idle.

## Common Patterns That Create Hot Partitions

Several key design patterns almost guarantee hot partitions:

**Sequential keys** like auto-incrementing IDs or timestamps funnel all new activity to the same
partition. If you use the current timestamp as a partition key, every new write hits whichever
partition holds "now." Auto-incrementing user IDs have the same problem—the highest ID values
(newest users) all cluster on one partition.

**Low-cardinality keys** don't provide enough buckets for traffic to spread across. Partition keys
like `status` (with values like "active," "inactive," "pending") or `region` (with a handful of
geographic areas) create too few partitions for your traffic volume. If most of your users are
"active" or live in one region, that partition becomes a bottleneck.

**Predictable access patterns** create hot spots even with high-cardinality keys. If your
application consistently hits certain key patterns more than others, those partitions will be
overloaded. For example, using `user_id` as a partition key works great if all users are equally
active. But if power users generate 100x more traffic than typical users, their partitions become
hot.

**Time-based access** concentrates load on recent data. Even with well-distributed keys, if your
application primarily accesses recent items, you're effectively creating temporal hot partitions.
News articles, social media posts, or transaction logs often have this problem.

## Effective Distribution Strategies

The goal is high cardinality with unpredictable, evenly distributed access patterns. Several
strategies can help achieve this:

**Hash prefixes** take a meaningful identifier and prepend a hash value. For example, instead of
using `user_12345` as your partition key, use `a1b2_user_12345` where `a1b2` is derived from hashing
the full key. This distributes similar keys across partitions while keeping the meaningful
identifier.

**UUID partition keys** provide natural randomness and high cardinality. If your application can
work with UUIDs instead of sequential IDs, they're nearly ideal for distribution. The trade-off is
losing any meaningful ordering or the ability to construct keys predictably.

**Composite prefixes** combine multiple attributes to create distribution. Instead of partitioning
on `user_id` alone, you might use `user_id + activity_type` or `user_id + date_bucket` to spread a
single user's data across multiple partitions.

**Write sharding** artificially adds randomness to distribute writes. Append a random suffix to your
logical key, like `actual_key_0` through `actual_key_9`. This spreads writes for the same logical
entity across multiple partitions. The cost is that reads need to query all shards and aggregate
results.

## Balancing Distribution with Access Patterns

Designing keys purely for even distribution might solve hot partitions but break your application's
query patterns. The trick is balancing distribution with your actual access needs.

If your application needs to query ranges of related data efficiently, grouping those items on the
same partition makes sense, even if it creates some imbalance. For example, storing all of a user's
orders with the same partition key enables efficient single-partition queries, but might create hot
spots for very active users.

If your queries are mostly individual item lookups, prioritize distribution. Random UUIDs as
partition keys provide excellent distribution but make it impossible to query related items together
efficiently.

Many applications need both patterns. Secondary indexes can help by providing alternative access
paths. You might use a distributed partition key for your main table and create a GSI with a
different key that groups related items for range queries.

## Detecting and Monitoring Hot Partitions

Hot partitions are often invisible until they cause problems. DynamoDB's table-level metrics can
show healthy utilization while individual partitions are overwhelmed. CloudWatch provides some
clues. The `ThrottleEvents` metric indicates when requests are being throttled. If you see
throttling despite low overall utilization, suspect hot partitions. The `SystemErrors` and
`UserErrors` metrics can also spike when partitions are overloaded.

DynamoDB's Contributor Insights feature provides more detailed visibility. It can show you which
partition keys are receiving the most traffic, helping identify hot spots before they cause
widespread problems.

Load testing is crucial, but it needs to simulate realistic access patterns. Uniform random traffic
won't reveal hot partitions that emerge from skewed real-world usage. Test with access patterns that
match production—if certain users or time periods drive more traffic, include that in your tests.

## Working Within Constraints

Sometimes business requirements limit your key design options. If you must support efficient queries
by timestamp or customer ID, you might be stuck with partition keys that create some imbalance.
DynamoDB's on-demand billing mode can help in these situations. It automatically scales to handle
traffic spikes and doesn't require you to predict capacity needs. The per-request pricing is higher,
but it can absorb sudden hot partition traffic better than provisioned capacity.

Application-level solutions can also help. Client-side caching reduces load on hot partitions. Read
replicas or secondary indexes can distribute read traffic. Breaking large tables into smaller,
purpose-built ones can isolate hot partitions to specific workloads.

Hot partitions are a fundamental constraint of DynamoDB's architecture. Understanding how they form
and designing around them is essential for building scalable applications. The goal isn't perfect
distribution. It's sufficient distribution for your specific access patterns and traffic volumes.

The main takeaway here is that DynamoDB performance depends not just on total capacity, but on how
that capacity is distributed across partitions. Design with distribution in mind from the start,
monitor for hot spots, and be prepared to adapt as your access patterns evolve.
