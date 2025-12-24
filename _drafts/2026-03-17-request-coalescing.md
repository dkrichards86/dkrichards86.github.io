---
layout: post
title: "What is request coalescing?"
description: >-
  Cache stampede happens when multiple requests all try to rebuild the same cache entry at once.
  Request coalescing is one elegant solution that prevents wasted work and reduces load on your backend.
---

I was working on a service that used local caching for expensive database queries. Cache hits were blazing fast at single digit milliseconds. But cache misses required network round trips to the database, and that's where things got ugly. During traffic spikes, we'd see hundreds of concurrent requests all hitting the same cache miss and flooding the database with identical queries. Response times would spike, and we'd have to run larger database instances to handle the surge, driving up costs significantly.

The pattern was always the same: cache miss on a popular key during peak traffic, followed by a stampede of duplicate database calls. All that redundant work meant we were paying for database capacity we shouldn't have needed.

This is cache stampede, and it's one of those problems that only surfaces under load.

## What Cache Stampede Looks Like

Cache stampede happens when multiple requests simultaneously encounter the same cache miss. Instead of one request rebuilding the cache while others wait, every request independently decides the cache is stale and tries to regenerate it.

Imagine you have a local cache that serves requests in 2ms, but cache misses require a 50ms database round trip. Under normal conditions, popular queries stay cached and everything runs smoothly. But when a popular cache entry expires during peak traffic, suddenly 200 concurrent requests all see the miss simultaneously. Instead of one 50ms database query, you get 200 of them.

Your database connections spike, query queue builds up, and response times degrade across the entire application. Worse, you're paying for database capacity to handle these artificial load spikes that shouldn't exist. The infrastructure costs compound because you need to size your database for worst-case stampede scenarios, not normal traffic patterns.

The worst part is that all this work is redundant. Those 50 requests will all get the same result, but 49 of them are doing completely unnecessary work. You're wasting CPU, database connections, and time.

Cache stampede is particularly brutal for expensive operations like complex aggregations, external API calls, or anything that involves I/O. The more expensive the cached operation, the more painful the stampede becomes.

## Traditional Solutions

The most common solution is cache locking. When a request encounters a cache miss, it acquires a lock before rebuilding the cache. Other requests see the lock and either wait for the rebuild to complete or serve stale data if available.

This works but creates new problems. Lock contention can become a bottleneck. If the rebuilding request fails or takes too long, other requests get stuck waiting. And you need to handle lock timeouts, which adds complexity.

Another approach is probabilistic cache expiration. Instead of having all cache entries expire at exactly the same time, you add randomness to expiration times. This spreads out cache misses over time, reducing the chance of simultaneous misses. It helps but doesn't eliminate the problem entirely.

Serving stale data while rebuilding in the background is another option. When the cache expires, immediately return the old cached value and trigger a background refresh. This maintains fast response times but means users might see outdated data temporarily.

## Request Coalescing

Request coalescing takes a different approach. Instead of preventing simultaneous cache rebuilds, it consolidates duplicate requests into a single operation. When multiple requests need the same data, only one actually executes while the others wait for and share the result.

The mechanism is elegant. When a request needs to rebuild a cache entry, it checks if anyone else is already working on the same key. If not, it starts the rebuild and registers itself as the "owner" of that operation. If someone else is already rebuilding that key, the request simply waits for their result instead of starting duplicate work.

In Go, the `singleflight` package implements this pattern. Here's the basic concept:

```go
// Multiple goroutines call this function simultaneously
func getExpensiveData(key string) (string, error) {
    // Only one goroutine per key will execute the expensive operation
    // Others will wait and get the same result
    result, err, _ := group.Do(key, func() (interface{}, error) {
        return fetchFromDatabase(key)
    })
    return result.(string), err
}
```

When ten concurrent requests all need the same cache entry, `singleflight` ensures only one database query executes. The other nine requests wait for that single query to complete and then all receive the same result. No wasted work, no database overload.

## Why Request Coalescing Works

Request coalescing addresses the root cause of cache stampede: duplicate work. Instead of trying to prevent simultaneous cache misses, it makes simultaneous misses harmless by consolidating the rebuild effort.

This approach has several advantages. There's no lock management complexity. Failed requests don't block others because each request coalescing group is independent. And it works naturally with existing cache infrastructure without requiring distributed coordination.

The cost implications are significant. Without coalescing, you need to provision database capacity for stampede scenarios that might be 10x or 20x normal load. With coalescing, your database only sees the legitimate load from actual cache rebuilds. This translates directly to smaller instance sizes and lower monthly bills.

The latency characteristics are good too. The first request to trigger rebuilding experiences the full database query time. Subsequent requests that arrive while rebuilding is in progress only wait for the remainder of that operation. And once rebuilding completes, all waiting requests get their results immediately.

Request coalescing also scales naturally. Whether you have 2 simultaneous requests or 200, only one database query executes. The memory and CPU overhead of coordinating requests is minimal compared to executing duplicate expensive operations.

## Trade-offs and Considerations

Request coalescing isn't a silver bullet. All requests for the same key experience the latency of a single rebuild operation. If the expensive operation fails, all waiting requests fail together. And there's a brief window where memory usage increases as requests accumulate waiting for the result.

The effectiveness depends on request patterns. If you have many requests for the same keys arriving close in time, coalescing provides huge benefits. If requests are spread out over time or for mostly unique keys, the benefits are minimal.

Implementation details matter. How long should requests wait for a coalesced result? What happens if the expensive operation hangs? Should you have separate coalescing groups for different types of operations? The answers depend on your specific requirements and failure tolerance.

## When to Use Request Coalescing

Request coalescing shines when you have expensive operations that multiple requests might trigger simultaneously. Database queries, external API calls, complex computations, and file system operations are all good candidates.

It's particularly valuable for read-heavy workloads where the same data gets requested frequently. Social media feeds, product catalogs, and reporting dashboards often have this pattern where popular content gets hit by many concurrent requests.

The technique works best when your expensive operations are idempotent. Multiple requests for the same data should logically return the same result, making it safe to share results between requests.

## Implementation Patterns

Different languages and frameworks provide different mechanisms for request coalescing. Go's `singleflight` package is probably the most well-known, but the pattern appears in many forms.

Some caching libraries build coalescing in automatically. Redis Cluster has similar behavior for certain operations. Application-level implementations might use promise/future patterns to coordinate duplicate requests.

The key insight is recognizing when you have this problem and understanding that consolidating duplicate work is often simpler and more effective than trying to prevent simultaneous requests entirely.

Cache stampede is one of those problems that's invisible until it isn't. When it hits, it can bring down systems that otherwise perform well. Request coalescing provides an elegant solution that eliminates wasted work without the complexity of distributed locking or the compromises of serving stale data.
