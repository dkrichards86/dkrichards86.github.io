---
layout: post
title: "Categorizing data stores"
description: >-
  Understanding the different categories of data stores and their trade-offs helps you pick the
  right tool for the job.
---

A data store is any repository for persistently storing and managing collections of data. This
includes traditional databases, but also simpler systems like file storage and email archives. I've
worked with a bunch of different data stores over the years. Each one makes different design
choices, optimizing for specific use cases while accepting limitations in others. Understanding
these trade-offs helps you pick the right tool for the job.

## Relational databases

Relational databases store data in structured tables with predefined schemas, where rows represent
records and columns represent attributes, connected through foreign key relationships. Queries use
SQL to join tables, filter data, and perform complex operations across multiple related entities.

They excel at transactional workloads requiring ACID compliance, data integrity, and complex
relationships. The battle-tested reliability and strong consistency guarantees are hard to beat.
Limitations include rigid schemas that make structural changes difficult, performance degradation
with very large datasets, and scaling challenges for high-write workloads.

MySQL, PostgreSQL, and SQLite are all relational databases.

## Document databases

Document databases store data as flexible documents, typically in JSON-like formats. Each document
can have varying structures and nested fields without requiring a predefined schema. Queries operate
on document contents using native query languages that can traverse nested structures and filter on
any field.

They're well-suited for applications requiring rapid development with evolving data models. The
schema flexibility is great when you're iterating quickly. Limitations include lack of complex joins
across documents, potential data inconsistency without ACID guarantees, and difficulty maintaining
referential integrity in normalized data scenarios.

MongoDB is probably the most well-known example.

## Key-value databases

Key-value databases store data as simple pairs where each unique key maps to a value. The database
treats values as opaque blobs regardless of internal structure. Queries are limited to exact key
lookups, range scans on keys, and basic operations. You can't query value contents directly.

They excel in high-performance scenarios requiring extremely fast read/write operations with
predictable access patterns. If you know the key, lookups are blazing fast. Limitations include
inability to perform complex queries, lack of relationships between data items, and poor suitability
for analytical workloads or scenarios requiring data discovery across unknown keys.

DynamoDB is a solid example of a key-value database.

## Columnar databases

Columnar databases store data by columns rather than rows, keeping all values for a single attribute
together on disk with aggressive compression. Queries scan only the columns needed for analysis,
making aggregations and analytical operations extremely fast.

They're ideal for applications where read performance on large datasets is critical. When you're
running analytics over millions of rows but only need a handful of columns, columnar storage shines.
Limitations include poor performance for transactional operations, slower individual record lookups,
and complexity in handling frequently changing data or small datasets where the columnar advantage
is minimal.

ClickHouse is a good example.

## Search databases

Search databases store data optimized for full-text search and complex querying. They use inverted
indices that map terms to documents containing them, along with sophisticated tokenization,
stemming, and ranking algorithms. Queries use specialized search languages supporting fuzzy
matching, relevance scoring, faceted search, and complex boolean operations across text and
structured data.

They excel at powering search engines and applications requiring fast text retrieval with relevance
ranking. If you need to search across text content, this is the tool for the job. Limitations
include higher storage overhead due to indexing, complexity in maintaining consistency during
updates, and suboptimal performance for simple transactional operations or scenarios not involving
search functionality.

Elasticsearch is the one I've used most.

## Analytical databases

Analytical databases store data organized for complex aggregations and analytical workloads, often
using columnar storage, pre-computed summaries, and specialized compression techniques optimized for
read-heavy operations. Queries typically involve large-scale aggregations, time-series analysis, and
multi-dimensional operations using SQL or specialized analytical languages with support for window
functions and statistical operations.

They're designed for business intelligence, data warehousing, reporting dashboards, and scenarios
requiring fast analysis of large historical datasets. Limitations include poor performance for
individual record updates, high latency for small transactional queries, complexity in real-time
data ingestion, and inefficiency for workloads requiring frequent small reads or operational data
access patterns.

Redshift and Snowflake both fall into this category.

## Object/Blob Storage

Object storage stores data as discrete objects in flat namespaces (buckets), where each object
contains the data itself, metadata, and a unique identifier. Access is through REST APIs using
object keys. There's no ability to query or modify object contents directly. Objects must be
retrieved and replaced in full.

They excel at storing unstructured data like files, images, backups, and raw data lake inputs at
massive scale with high durability. The scalability is virtually unlimited. Limitations include no
native query capability on object contents without external compute, inability to perform partial
updates or appends, and latency unsuitable for transactional workloads requiring fast random access.

AWS S3 is the obvious example here.

## Picking the right tool

The right data store depends on your specific requirements. Need transactions and complex
relationships? Start with relational databases. Building something with an evolving schema? Consider
document databases. Optimizing for pure speed on simple operations? Look at key-value stores.
Running analytics on huge datasets? Columnar or analytical databases are your friends.

The best architecture often uses multiple data stores, each doing what it does best. Your user
profiles might live in a document database, your transactions in a relational database, your images
in object storage, and your search index in a search database. This polyglot persistence approach
lets you optimize each part of your system independently.

Understanding the trade-offs is what matters. There's no perfect database for everything.
