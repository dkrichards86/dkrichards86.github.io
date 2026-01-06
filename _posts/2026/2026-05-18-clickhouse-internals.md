---
layout: post
title: "Understanding Clickhouse Architecture"
description: >-
  Clickhouse's column-oriented design makes it blazing fast for analytics, but only if you
  understand how partitions, parts, and granules work together. Here's what you need to know.
tags: [databases, clickhouse, architecture]
---

Clickhouse is a column-oriented database designed for analytical workloads. When you need to run
aggregations over billions of rows, it's incredibly fast. But it achieves that speed through
architectural decisions that make it fundamentally different from relational databases.

Understanding how Clickhouse actually stores and retrieves data helps you use it effectively. The
design has specific trade-offs that make it excellent for some use cases and terrible for others.

## When Clickhouse Makes Sense

Clickhouse excels at analytical queries over large datasets. If you're aggregating metrics, running
reports, or analyzing time-series data, it's probably a good fit. The column-oriented storage means
queries that touch a few columns across millions of rows are fast.

But Clickhouse isn't a general-purpose database. It's built for specific patterns. If you need
row-based access, frequent updates, or low-volume inserts, you're fighting against the design.

Row-based access is slow because Clickhouse's design forces you to scan chunks of data even when you
only want a single record. There's no efficient way to fetch one row by ID like you would in
Postgres.

Frequent updates or deletes are problematic because updating a single record impacts all data within
a physical storage unit. You can't efficiently modify individual rows without touching surrounding
data.

Low-volume inserts create operational problems. Each insert creates a new physical storage unit on
disk, and too many units slow down queries while increasing CPU strain during background merging.
Clickhouse is optimized for batch inserts, not individual row operations.

If your access pattern doesn't match these constraints, you'll spend more time working around
Clickhouse's design than benefiting from its speed.

## Column-Oriented Storage

The foundation of Clickhouse's performance is column-oriented storage. Instead of storing entire
rows together, Clickhouse stores each column separately. This means a query that needs three columns
out of fifty only reads those three columns from disk.

For analytical queries that aggregate or filter on specific attributes, this is massively more
efficient than scanning entire rows. You're reading less data, which means faster I/O and better
cache utilization.

The trade-off is that reconstructing full rows requires reading from multiple column files. This
makes row-oriented access patterns slow and expensive.

## Immutable Writes

Clickhouse writes are immutable. Once data is written, it never changes in place. This design choice
enables high write throughput because there's no locking or coordination needed during writes.
You're always appending new data rather than modifying existing data.

Updates and deletes are implemented as separate operations that mark records for exclusion rather
than actually removing them. The physical removal happens later during background merging. This is
why frequent updates are inefficient - they create overhead without immediate benefit.

## The Hierarchy: Partitions, Parts, and Granules

Clickhouse organizes data in a three-level hierarchy: partitions contain parts, parts contain
granules. Understanding this structure is essential for effective Clickhouse usage.

### Partitions

Partitions are logical groupings of data, typically by time period. You might partition by day,
week, or month depending on your data volume and query patterns.

Partitions enable parallel processing. Queries can run across multiple partitions simultaneously,
leveraging all available CPU cores. They also enable efficient pruning - if your query filters to a
specific date range, Clickhouse can skip entire partitions that don't match.

The recommended partition count is between 10 and 100. Too few partitions limit parallelism. Too
many create management overhead and slow down metadata operations.

Choose partition boundaries that match your query patterns. If you typically query by day, partition
by day. If you query by month, partition by month. The goal is to minimize the number of partitions
each query needs to scan.

### Parts

Parts are physical storage units - individual directories on disk. Each part contains one file for
the primary index, one file per column in your schema, and one file per secondary index you've
defined.

Every INSERT operation creates a new part. This is important. Even a small insert creates a full
directory structure on disk. This is why low-volume inserts cause problems - you end up with
thousands of tiny parts that slow down queries.

Clickhouse runs background merging to consolidate parts into larger parts. This reduces the number
of directories that need to be scanned during queries. The merge process is automatic but consumes
CPU and I/O resources.

The more parts you have, the slower your queries become and the more CPU you spend merging. Batch
your inserts to minimize part creation.

### Granules

Granules are the minimal selectable unit of data - consecutive rows grouped together, 8,192 rows by
default. The primary index points to the start of each granule, not to individual rows.

This is fundamentally different from traditional B-tree indexes. Instead of indexing every row,
Clickhouse indexes every Nth row. When you query, Clickhouse uses the index to identify which
granules might contain matching data, then scans those granules.

Granules enable efficient skipping. If the primary index shows that a granule's first row doesn't
match your query, the entire granule can be skipped. This dramatically reduces the amount of data
that needs to be scanned.

The granule design also keeps memory footprint stable. You're always working with consistent chunk
sizes rather than variable-length records. This makes performance more predictable.

## Primary Keys Work Differently

If you're coming from relational databases, Clickhouse primary keys will feel wrong. They don't
enforce uniqueness. They don't identify individual rows. They serve a completely different purpose.

Clickhouse primary keys determine how data is sorted within parts and how granules are indexed. The
primary key answers "how should I organize data for analytical queries?" not "how do I uniquely
identify a row?"

The first column in your primary key gets special treatment. Clickhouse performs binary search on it
to find matching granules. This is fast - logarithmic complexity.

All other columns in the primary key perform generic search, which means scanning every mark in the
primary index for matches. This is slower - linear complexity.

Column order matters enormously. Put your most selective column first - the one that filters out the
most data. Include commonly filtered columns in your primary key. But limit the primary key to 3-4
columns to minimize index scanning overhead.

A common mistake is including too many columns in the primary key. Each additional column makes the
index larger and slower to scan. Focus on the columns that provide the most filtering power for your
typical queries.

## Putting It Together

Clickhouse's architecture is a set of deliberate trade-offs. Column-oriented storage, immutable
writes, and granule-based indexing all optimize for analytical queries over large datasets. They
make certain patterns blazing fast while making other patterns impossible or impractical.

Understanding the partition-part-granule hierarchy helps you work with Clickhouse's design rather
than against it. Partition by time periods that match your queries. Batch inserts to minimize parts.
Design primary keys around your most selective filters.

The key is recognizing when Clickhouse's strengths align with your needs. If you're running
aggregations over billions of rows and can structure your writes in batches, it's incredibly fast.
If you need transactional updates or row-level access, look elsewhere.

Clickhouse is a specialized tool built for analytical workloads. Used correctly, it's remarkably
effective. Used incorrectly, you'll spend more time fighting the architecture than benefiting from
it.
