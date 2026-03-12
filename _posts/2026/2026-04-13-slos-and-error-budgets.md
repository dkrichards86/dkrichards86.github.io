---
layout: post
title: "SLOs and Error Budgets"
description: >-
  Most alerting systems are built on arbitrary thresholds that generate noise and miss slow-burning
  problems. SLIs, SLOs, and burn rates give you a principled alternative.
tags: [observability, reliability, best-practices]
---

Your on-call rotation has a morale problem. Not because incidents are frequent, but because alerts
don't mean anything anymore. You've seen the pattern: an alert fires, someone investigates, nothing
looks wrong, alert resolves. Repeat until engineers start ignoring alerts entirely.

The problem isn't your engineers. It's the alerts themselves. Most alerting thresholds are set
arbitrarily—someone picked a number that felt reasonable, and it's been there ever since. There's no
anchor to what "good" actually looks like for users, and no way to know if you're silently failing
between the spikes.

SLIs, SLOs, and burn rates offer a different approach. Instead of asking "is anything broken right
now?", you ask "are we on track to meet our reliability goal?" That shift changes everything.

## What You're Actually Measuring (SLIs)

A Service Level Indicator is a specific, measurable metric expressed as a ratio of good events to
total events. Not a raw count, not an average—a proportion.

That distinction matters. A raw count of errors doesn't tell you much on its own. If you're handling
twice the traffic, twice the error count might still be fine. A ratio normalizes for volume and
makes your metric comparable across time.

Useful SLIs tend to measure things users actually experience: the proportion of requests returning
5xx errors, the proportion of requests completing under 500ms, the proportion of background jobs
finishing within their expected window. If a real user would never feel the impact of a metric going
bad, it's probably not a great SLI.

## Setting a Goal (SLOs)

A Service Level Objective is a target value for an SLI over a time window. It defines what "good"
means for your service.

Thirty days is the standard window, and for good reason. A one-hour SLO is too sensitive—a brief
spike dominates the whole window. A ninety-day SLO reacts too slowly. Thirty days balances signal
with recency. Bonus points, 30 days makes the math straightforward too.

If you're setting SLOs for an existing service, start with your current thirty-day baseline and add
about twenty percent headroom. This prevents you from immediately alerting on behavior that's
already normal. For a new service, start loose and tighten as you learn what normal looks like.

An SLO that never gets close to breaching is set too loosely—you're leaving reliability on the table
and signaling that you don't really care. An SLO that's always on fire is set too tightly. You want
occasional close calls. That's what calibration feels like.

## The Budget You're Spending (Error Budgets)

Your error budget is the complement of your SLO. A 99.5% availability target means you can afford
0.5% of requests to fail. That's the budget.

This reframing is subtle but powerful. Instead of asking whether anything is broken, you're asking
how much of your allowed failure you've already consumed. Error budgets turn reliability into a
shared resource. Engineering and product teams both have a stake in how it gets spent. An aggressive
feature rollout that destabilizes the service isn't just a technical problem—it's consuming budget
that could go toward other things.

When the error budget is healthy, you have room to take risks. When it's running low, that's a
signal to slow down and stabilize. The budget makes that trade-off concrete and legible.

## How Fast You're Spending It (Burn Rate)

Burn rate is where SLOs get operationally useful. It measures how quickly you're consuming your
error budget relative to the pace that would exhaust it exactly by the end of the window.

```text
burn rate = observed error rate / error budget
```

A burn rate under 1 means you're burning slower than expected—you'll be fine. A burn rate of exactly
1 means you'll just barely make it. Anything above 1 means you're on track to breach your SLO.

The useful property of burn rate is that it tells you how much time you have. A thirty-day window
with a burn rate of 6 means you'll exhaust the budget in five days. A burn rate of 14 means you have
about two days. A burn rate of 100 during a full outage means you have hours.

That time horizon is what lets you calibrate alert severity. Fast-burning situations require
immediate response. Slow burns are worth monitoring but don't require waking someone up.

## Alerting on Burn Rate

Traditional alerts fire when a metric crosses a threshold. Burn rate alerts fire when your SLO is at
risk within a meaningful time horizon.

A reasonable starting point for alert tiers looks like this: a burn rate above 14 measured over five
minutes indicates you'll exhaust your budget in roughly two days—page someone immediately. A burn
rate above 6 measured over thirty minutes means about five days to exhaustion—worth an alert during
business hours. A burn rate above 1 measured over six hours is worth a heads-up but doesn't require
urgent response.

| Severity | Burn Rate | Window     | Time to Exhaustion | Response              |
| -------- | --------- | ---------- | ------------------ | --------------------- |
| Minor    | > 1       | 6 hours    | Draining slowly    | Next business day     |
| Major    | > 6       | 30 minutes | ~5 days            | Within business hours |
| Critical | > 14      | 5 minutes  | ~2 days            | Immediate (page)      |

Notice the pattern: higher burn rates use shorter measurement windows. At burn rate 14, you need to
know fast. At burn rate 1, there's no rush, and a shorter window would just produce noise from
transient spikes.

This also solves the spike sensitivity problem with traditional alerting. A brief burst of errors
won't sustain a high burn rate across a five-minute window. A real incident will.

## The Math in Practice

The numbers are easier to reason about with concrete examples.

**Elevated error rate.** Your SLO says no more than 0.5% of requests return 5xx. Your error budget
is 0.005. Right now, 2% of requests are failing. Burn rate = 0.02 / 0.005 = 4. At that rate you'll
breach your SLO in 7.5 days. Not a five-alarm fire, but worth an alert during business hours.

**Slow latency degradation.** Your SLO says 90% of requests complete under 300ms—meaning no more
than 10% can exceed that threshold. Right now 20% are exceeding it. Burn rate = 0.2 / 0.1 = 2.
You'll exhaust the budget in 15 days. Low urgency, but worth watching.

**Full outage.** Same 0.5% SLO, but now 50% of requests are failing. Burn rate = 0.5 / 0.005 = 100.
You'll breach in 7.2 hours. Page immediately.

The escalation is automatic and principled. You don't need to argue about whether 2% errors is "bad
enough" to page someone. The burn rate tells you exactly how bad it is relative to your goal.

## Getting Started

If you're adopting this for the first time, you almost certainly already have the raw data you need.
Error rate and latency metrics exist in most observability stacks. The work is mostly framing.

Pick one or two services that matter. Identify the SLIs you care about—5xx rate and P90 latency are
good defaults. Measure your thirty-day baseline. Set your initial SLO targets with room to breathe.
Configure burn rate alerts using the severity tiers above. Then watch and adjust.

The goal isn't to get it perfect on day one. The goal is to replace arbitrary thresholds with
something principled—numbers that reflect what good looks like for your users, and alerts that fire
when you're actually at risk of falling short.

When alerts mean something, engineers pay attention to them again.
