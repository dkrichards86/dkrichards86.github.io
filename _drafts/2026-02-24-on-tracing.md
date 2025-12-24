---
layout: post
title: "Tracing: Following the Journey"
description: >-
  Tracing completes the observability trinity by showing you the path a request takes through your
  system. Understanding traces and spans helps you diagnose performance bottlenecks and complex
  distributed system issues.
---

In recent posts we've talked about logs and metrics as two pillars of observability. Logs tell you
what happened at specific moments. Metrics tell you what's happening in aggregate. Tracing completes
the picture by showing you the journey a request takes through your system.

When your API is slow, metrics tell you the P99 response time is high. Logs might show individual
errors or warnings. But tracing shows you exactly where time is being spent. It's the difference
between knowing there's traffic somewhere on your commute versus seeing that the backup starts at
the bridge and clears after the exit ramp.

## What Tracing Actually Shows

A trace follows a single request from start to finish, even when that request triggers work across
multiple services, databases, and external APIs. Think of it as a breadcrumb trail showing every
step the request took.

Each trace contains multiple spans. A span represents a unit of work within the trace, like a
function call, database query, or HTTP request to another service. Spans have start times, end
times, and metadata about what happened during that work.

For example, when a user loads their profile page, the trace might contain spans for:

- The initial HTTP request to your web server
- A database query to fetch user data
- A call to your image service to get the profile photo
- A call to your analytics service to log the page view
- The HTTP response back to the user

Each span shows how long it took and what happened. When you string them together, you see the
complete picture of how the request was handled.

## Spans: The Building Blocks

Spans are hierarchical. The top-level span represents the entire request. Child spans represent work
done as part of that request. Those child spans can have their own children, creating a tree
structure that maps to your system's call graph.

A span contains timing information, obviously, but also context. What service created it? What
operation was being performed? Were there any errors? You can add custom attributes to spans too,
like user IDs, feature flags, or business context that helps during debugging.

The power comes from connecting spans across service boundaries. When your web server calls your
user service, tracing libraries automatically propagate context so the user service's spans become
children of the web server's span. You get end-to-end visibility even in complex distributed
systems.

## How Tracing Differs From Logging

Logs and traces solve different problems. Logs are great for understanding what happened and when.
Traces are great for understanding why something took so long or where it failed.

Logs are point-in-time events. Something happened, you logged it, and now you have a record. Traces
show relationships and flow. They connect events across time and services.

When debugging, logs help you understand the sequence of events. "User logged in, then tried to load
their dashboard, then the database query failed." Traces help you understand the performance
characteristics. "The dashboard load took 2.3 seconds because the database query took 2.1 seconds,
and here's exactly which query was slow."

Logs are also structured differently. Each log line is independent and can be analyzed in isolation.
Traces require you to think about the relationships between spans. The child span that took 90% of
the parent span's time is probably your bottleneck.

Volume wise, traces generate more data than logs but store it differently. Instead of one log line
per event, you get one span per unit of work. A single request might generate dozens of spans. But
those spans are grouped together, making them easier to analyze as a cohesive story.

## Reading Traces Effectively

When you're looking at a trace, start with the overall timeline. How long did the entire request
take? Where are the biggest gaps? Traces usually visualize as a waterfall chart or timeline view
that makes bottlenecks obvious.

Look for spans that take disproportionate amounts of time. If your trace took 3 seconds and one span
took 2.8 seconds, that's your problem. Drill into that span and see if it has children that explain
the time.

Pay attention to parallelism. Spans that run concurrently show up at the same time level. Sequential
spans show up one after another. If you see work that could be parallelized but isn't, that's an
optimization opportunity.

Error spans are usually highlighted or marked differently. Follow the error trail to understand not
just that something failed, but where in the request flow it failed and what work was wasted as a
result.

## When Tracing Helps Most

Tracing shines when you're dealing with performance problems in distributed systems. "Why is this
endpoint slow sometimes?" becomes much easier to answer when you can see that it's slow when a
particular downstream service is slow.

It's also invaluable for understanding complex workflows. When a request triggers multiple
asynchronous jobs, spawns background tasks, or involves multiple external services, tracing shows
you the complete picture. Logs might show individual pieces, but traces show how they fit together.

Debugging cascading failures is another sweet spot. When one slow service makes everything else
slow, traces show you the dependency chain and help you identify the root cause versus the symptoms.

## The Cost of Tracing

Tracing isn't free. It adds overhead to every request, both in terms of CPU cycles and memory usage.
More significantly, it generates a lot of data. A busy service might produce millions of traces per
day.

Most tracing systems use sampling to manage costs. Instead of tracing every request, they trace a
percentage. 1% sampling means you trace one out of every hundred requests. This reduces overhead
while still giving you enough data to identify patterns and problems.

The sampling rate becomes a trade-off between cost and visibility. Higher sampling rates give you
more data but cost more. Lower sampling rates might miss intermittent issues or edge cases. Some
systems use adaptive sampling that traces more aggressively when errors are detected or performance
degrades.

## Making Traces Useful

Good tracing requires intentional instrumentation. Most frameworks can automatically create spans
for HTTP requests, database queries, and external service calls. But the most valuable spans are
often the ones you create manually for business logic.

Adding spans around critical functions, complex algorithms, or business operations helps you
understand where time is spent in your application logic, not just in infrastructure. A span around
"calculate shipping cost" or "validate user permissions" gives you insights that automatic
instrumentation misses.

Context is crucial. Adding attributes to spans like user ID, feature flags, request size, or
business entity IDs makes traces searchable and filterable. When you're debugging an issue that only
affects premium users, being able to filter traces by user tier saves hours of investigation.

## Completing the Picture

Tracing works best when combined with metrics and logs. Metrics help you identify when problems
occur. Traces help you understand what's causing them. Logs help you understand what the system was
thinking when things went wrong.

Modern observability platforms integrate all three. You can jump from a spike in your error rate
metric to the traces that show where the errors are happening to the logs that explain what went
wrong. Each tool provides a different lens on the same underlying system behavior.

Tracing completes observability by adding the narrative structure that metrics and logs can't
provide alone. When your system is misbehaving, traces tell you the story of what went wrong, step
by step.
