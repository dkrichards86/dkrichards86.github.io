---
layout: post
title: "Interpreting Metrics"
description: >-
  Metrics are everywhere, but understanding what P90 vs P99 actually tells you about your system -
  and how aggregation windows can hide or reveal problems - makes the difference between useful
  monitoring and just pretty dashboards.
tags: [observability, metrics, best-practices]
---

Metrics are the foundation of observability, but they're also one of the most misunderstood parts of
monitoring. I see teams collect tons of data, build beautiful dashboards, then make terrible
decisions because they don't understand what their numbers actually mean.

The problem isn't collecting metrics. Modern systems make that easy. The problem is interpretation.
What does a P90 of 200ms actually tell you? How is that different from a P99 of 500ms? Why does your
5-minute aggregation window show everything looks fine while your 1-minute window reveals serious
problems?

Understanding metrics isn't just about math. It's about translating numbers into actionable insights
about your system's health and your users' experience.

## Percentiles: Beyond the Average

Most people start with averages because they're intuitive. Average response time, average
throughput, average error rate. But averages lie, especially when it comes to user experience.

Imagine your API has response times of 50ms, 60ms, 55ms, 58ms, and 2000ms. The average is 444ms.
That suggests a pretty slow API. But four out of five requests were blazing fast. One outlier skewed
everything. Your users experienced mostly fast responses with one really slow one. The average
doesn't capture that reality.

This is where percentiles shine. They tell you what percentage of requests fall below a certain
threshold. P50 (the median) tells you that 50% of requests were faster than this value. P90 means
90% were faster. P99 means 99% were faster.

Using our example, the P50 might be 57ms, P90 could be 58ms, and P99 would be 2000ms. Now you have a
clearer picture. Most requests are fast, but your worst 1% of users are having a terrible
experience.

The choice of percentile matters depending on what you're measuring. P50 gives you a sense of the
typical user experience. It's stable and won't be thrown off by a few outliers. But it also hides
problems that affect real users.

P90 is often the sweet spot for SLAs and alerting. It captures the experience of most users while
still being sensitive to degradation. If your P90 response time starts climbing, you know
something's affecting a meaningful portion of your traffic, not just a few edge cases.

P99 reveals the worst-case scenario. These are your most frustrated users, the ones likely to
complain or churn. P99 is great for understanding tail latency but terrible for alerting because
it's so sensitive to outliers. A single slow database query can spike your P99 while leaving P90
unchanged.

Higher percentiles like P99.9 or P99.99 become increasingly noisy and less actionable. They're
useful for understanding your absolute worst case, but they're not reliable for day-to-day
monitoring.

## Aggregation Windows: Time Matters

How you slice time dramatically affects what your metrics show. The same data can look completely
different depending on whether you aggregate over 1 minute, 5 minutes, or 1 hour.

Shorter windows reveal spikes and brief outages but can be noisy. Longer windows smooth out
variations but can hide problems entirely. The trick is matching your aggregation window to what
you're trying to understand.

For alerting, you typically want short windows. If your API is throwing 500 errors, you want to know
immediately, not after they've been averaged away over an hour-long window. A 1-minute or 5-minute
window lets you catch problems while they're happening.

For capacity planning, longer windows are more useful. Daily or weekly aggregations help you
understand traffic patterns and growth trends. You don't care about the brief spike at 2 PM
yesterday. You care about whether your overall traffic is growing and whether your infrastructure
can handle it.

The aggregation window also affects percentile calculations in subtle ways. A 1-minute P99 tells you
the worst 1% of requests in that specific minute. A 1-hour P99 tells you the worst 1% across the
entire hour. Here's the counterintuitive part: the hour-long window will typically be _lower_
because brief spikes get diluted across more data points. A 2-minute outage that spikes your
1-minute P99 to 2000ms might barely register in the hourly P99 because those bad requests represent
a tiny fraction of the total hour's traffic.

This creates a paradox. To catch problems quickly, you want short windows. But short windows can be
noisy and prone to false alarms. The solution is usually layering. Use short windows for alerting on
acute problems, medium windows for operational dashboards, and long windows for strategic planning.

## Rate vs Count: Getting the Denominator Right

One of the most common mistakes I see is confusing rates and counts. Error count might be
increasing, but if your traffic is increasing even faster, your error rate could actually be
improving. Always consider the denominator.

Error rate (errors per second divided by total requests per second) tells you about system health.
Error count tells you about absolute impact. Both matter, but for different reasons.

If your error rate is steady but your error count is increasing, that usually means more traffic,
not a worse system. If your error count is steady but your error rate is increasing, that suggests
your system is degrading under normal load.

The same principle applies to any metric where volume matters. Response time counts don't mean much
without request volume. Memory usage counts don't mean much without understanding total capacity.

## Dealing with Seasonality and Trends

Metrics exist in context. A 20% increase in response time might be alarming on Tuesday afternoon or
completely normal on Black Friday. Understanding your baseline is crucial for interpreting changes.

Seasonal patterns are everywhere. Traffic might spike every Monday morning as people return to work.
Database performance might degrade every night during batch jobs. CPU utilization might be higher
during business hours.

Good monitoring systems help you separate signal from noise by comparing current metrics to
historical patterns. Week-over-week comparisons often work better than hour-over-hour for business
applications because they account for weekly cycles.

## What Actually Matters

The best metrics tell you something actionable about user experience or system health. Response time
percentiles matter because slow requests frustrate users. Error rates matter because broken
functionality drives users away. CPU utilization matters because it predicts when you'll need more
capacity.

But not all metrics are created equal. Vanity metrics might look impressive on dashboards but don't
drive decisions. Server count doesn't matter if your application is running fine. Lines of code
doesn't predict anything useful about system health.

Focus on metrics that correlate with outcomes you care about. If user retention is important, track
metrics that predict churn. If reliability is the goal, focus on error rates and availability. If
performance matters, watch response times and throughput.

The magic happens when you start connecting these metrics to business outcomes. Response time isn't
just a technical metric. It's a predictor of conversion rates, user satisfaction, and revenue. Error
rates aren't just operational concerns. They're leading indicators of support load and user
complaints.

Understanding what your metrics actually mean - not just how to calculate them - turns monitoring
from a necessary chore into a powerful tool for building better systems.
