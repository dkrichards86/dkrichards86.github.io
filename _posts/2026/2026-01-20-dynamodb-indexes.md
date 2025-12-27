---
layout: post
title: "Indexing DynamoDB"
description: >-
  Indexes are how you query DynamoDB data in different ways. Understanding when to use Local vs
  Global Secondary Indexes and their trade-offs is essential for flexible data access.
tags: [databases, dynamodb, aws, performance]
---

DynamoDB's primary key design forces a critical decision up front: how will you access your data?
Your partition key determines where items live physically and how they're distributed. Your sort key
(if you use one) defines how items are ordered within a partition. These choices enable fast,
predictable queries but lock you into specific access patterns.

What happens when you need to query data differently? Maybe you chose `user_id` as your partition
key to group a user's data together, but now you need to find users by email address. Or you
partitioned by `order_id` but need to query orders by customer or by date range. The base table
structure can't support these patterns efficiently.

That's where indexes come in. They provide alternative views of your data with different keys,
enabling queries that would be impossible or inefficient with the base table alone.

## Local Secondary Indexes

Local Secondary Indexes (LSIs) share the same partition key as the base table but use a different
sort key. They're "local" because items with the same partition key value stay together on the same
physical partition, just organized differently.

Imagine a base table with partition key `user_id` and sort key `timestamp`. You can query a user's
activity chronologically, which is great. But what if you also need to query that same user's
activity by activity type? An LSI with partition key `user_id` and sort key `activity_type` enables
both patterns.

The critical constraint is that LSIs must be defined at table creation time. You can't add them
later. This forces you to think about access patterns up front, which is both a blessing and a
curse. It encourages good design but punishes oversights.

LSIs have a 10 GB size limit per partition key value. All items with the same partition key across
the base table and all LSIs combined can't exceed 10 GB. This usually isn't a problem for
well-distributed keys, but it's a hard constraint that can bite you if your data is heavily skewed
toward certain keys.

## Global Secondary Indexes

Global Secondary Indexes (GSIs) provide complete flexibility. They can use any attributes as
partition and sort keys, completely independent of the base table. This means items can be
distributed across partitions differently in the GSI than in the base table.

A GSI is effectively a separate table that DynamoDB maintains automatically. When you write to the
base table, DynamoDB asynchronously updates any GSIs that include those attributes. This gives you
the flexibility to support entirely different query patterns without duplicating data management
logic in your application.

Unlike LSIs, you can add or remove GSIs at any time. Need a new access pattern? Create a GSI for it.
Access pattern no longer needed? Drop the GSI and stop paying for its storage and throughput.

The trade-off is eventual consistency. GSI updates are asynchronous, so there's a brief window where
a GSI might not reflect the most recent writes to the base table. For most applications this is
acceptable, but if you need strongly consistent reads, you're stuck with the base table or an LSI.

## Projection Matters

Both LSI and GSI definitions include a projection, which controls which attributes are copied into
the index. You have three options:

**Keys only** projects just the key attributes. This creates the smallest, cheapest index but
requires fetching items from the base table to get any other attributes. It's useful when you're
just checking existence or need to query by certain attributes but will fetch full items afterward.

**Include** lets you specify additional non-key attributes to project. This is the sweet spot for
many use cases. You include the attributes your queries need without copying the entire item.
Queries against the index can return data directly without touching the base table.

**All** projects every attribute from the base table. This makes the index largest and most
expensive, but queries never need to fetch from the base table. It's useful when you need complete
flexibility in what you return from index queries.

The projection choice directly impacts cost and performance. Larger projections mean more storage
and write costs, but faster queries that don't need to fetch additional data. Smaller projections
reduce costs but add latency when you need non-projected attributes.

## Capacity and Billing

GSIs have their own provisioned throughput separate from the base table. You need to provision read
and write capacity for each GSI independently. This can get expensive quickly if you have multiple
GSIs, since you're essentially paying for multiple copies of your data with separate throughput
allocation.

On-demand billing simplifies this. Both the table and GSIs scale automatically, and you pay per
request without worrying about capacity planning. For workloads with unpredictable traffic or many
GSIs, on-demand can actually be cheaper and eliminates the risk of under-provisioning.

LSIs share throughput with the base table, so they don't add separate capacity costs. But they do
consume write capacity when you write to the base table, and they increase storage costs.

## When to Use Each

Use LSIs when you need alternative sort orders for data within the same partition key. They're
perfect for time-series data where you might want to query by different attributes within a user,
account, or other grouping dimension. The strong consistency option and shared throughput make them
efficient for tightly related access patterns.

Use GSIs when you need to query across different partition keys or when you're not sure about access
patterns at table creation time. They provide maximum flexibility at the cost of eventual
consistency and separate capacity management.

A common pattern is to use your most important access pattern for the base table structure, then
create GSIs for secondary patterns. If you query by `user_id` 80% of the time but occasionally need
to find users by email, make `user_id` the base table partition key and create a GSI with `email` as
the partition key.

## Sparse Indexes

One clever trick is sparse indexes. If an item doesn't have a value for the GSI's partition or sort
key attribute, it won't appear in the GSI at all. This creates a filtered view of your data.

Imagine a table of all orders where only 10% are flagged for review. You could create a GSI with
partition key `needs_review` and only set that attribute on flagged orders. The GSI contains just
those 10% of items, making queries fast and cheap. You've essentially created a filtered index
without maintaining a separate table.

## Design Considerations

The key to effective index design is understanding your access patterns before you start. DynamoDB
isn't a relational database where you can add indexes freely after the fact. Every index has real
costs in storage, throughput, and write amplification.

Write amplification is worth considering. Every write to the base table that affects indexed
attributes requires writes to each GSI that includes those attributes. If you have three GSIs and
update an item, you're potentially doing four writes: one to the base table and one to each GSI.
This multiplies your write costs and can impact write performance.

Think about whether you really need an index or if your application can work around its absence. Can
you denormalize data? Can you use query parameters or filters differently? Sometimes it's better to
structure your data model differently than to add another index.

## Working with Indexes

Queries against indexes work just like queries against the base table. You specify the index name
and provide key conditions. The query returns items from the index with the projected attributes.

If you need attributes that aren't projected, DynamoDB automatically fetches them from the base
table. This is transparent but adds latency and consumes base table read capacity. Design your
projections to avoid this when possible.

Scans work on indexes too, though they have the same performance implications as scanning the base
table. Avoid scans in production code paths regardless of whether you're scanning a table or an
index.

## The Bigger Picture

Indexes are a tool for making DynamoDB work with multiple access patterns. They're not free, but
they're often essential. The trick is using them judiciously.

Start with your most important access pattern and design the base table around it. Add LSIs at
creation time if you're confident about related access patterns within the same partition key. Then
add GSIs as you discover additional needs or as your application evolves.

Monitor index usage. An unused index is wasted money. DynamoDB doesn't tell you which indexes are
being queried, so you need application-level tracking or CloudWatch metrics analysis to identify
unused indexes.

Understanding indexes deeply means understanding the trade-offs between flexibility, cost, and
consistency. Choose the right tool for each access pattern, and don't be afraid to redesign as your
needs evolve. That's the beauty of GSIs: they let you adapt without starting over.
