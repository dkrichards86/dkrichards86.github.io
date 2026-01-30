---
layout: post
title: "Understanding Log Levels"
description: >-
  Log levels are a foundational concept in observability. Understanding when to use each level,
  managing signal vs noise, and choosing the right structure helps build systems you can debug.
tags: [observability, logging, best-practices]
---

Logs are one of the three pillars of observability, alongside metrics and traces. They provide the
narrative of what your system is doing, but only if you use them correctly. Most developers learn to
log by copying patterns they see, without understanding the principles behind effective logging.

Good logging starts with understanding log levels. Each level serves a specific purpose and
audience. Using them correctly transforms logs from noise into valuable debugging tools.

## The Six Log Levels

`TRACE` captures the most granular details of program execution. Function entry and exit points,
loop iterations, and detailed state changes. `TRACE` logs are expensive and verbose, typically only
enabled when debugging specific issues in development.

`DEBUG` provides information useful for diagnosing problems. Variable values, decision points, and
operational details that help developers understand program flow. `DEBUG` logs should give you
enough context to understand what the code was thinking.

`INFO` records normal operational events. User actions, business transactions, and system state
changes that matter to operators and analysts. `INFO` logs tell the story of what your system
accomplished.

`WARNING` indicates something unexpected happened, but the system handled it gracefully. Degraded
performance, fallback mechanisms activating, or conditions that might lead to problems. `WARNING`
logs are your early warning system.

`ERROR` means something went wrong and requires attention. Failed operations, unhandled exceptions,
and conditions that affect functionality. `ERROR` logs should be actionable and relatively rare.

`FATAL` represents critical failures that might cause the application to terminate. Corrupt data,
exhausted resources, or unrecoverable errors. `FATAL` logs indicate serious problems that need
immediate intervention.

## Signal vs Noise

Every log line competes for attention. Too much logging overwhelms both systems and humans. Too
little leaves you blind when things go wrong. Log levels help you manage this trade-off by encoding
importance and urgency.

The fundamental challenge is that logging has multiple costs. Storage and processing overhead are
obvious, but the hidden cost is cognitive load. When something breaks in production, you're scanning
through thousands of log lines looking for clues. Every irrelevant line slows you down. Every
missing piece of context makes the problem harder to solve.

Different audiences need different signal-to-noise ratios. Developers debugging a specific issue
want all the detail they can get. They'll gladly wade through verbose `TRACE` logs if it helps them
understand a race condition or edge case. Operators monitoring system health need a much higher
signal-to-noise ratio. They're looking for patterns and anomalies across hundreds or thousands of
services. Incident responders need clear, actionable information without clutter. They're under
pressure and need to understand what's broken fast.

This creates tension in log level decisions. The same information that's invaluable during debugging
becomes noise during normal operations. `TRACE` and `DEBUG` logs are high-noise, high-value when you
need them. They should be disabled in production unless you're actively debugging. Leaving them
enabled creates log storms that overwhelm storage systems and make it harder to find real problems.

`INFO` logs are the hardest to get right. They need to be valuable enough to justify their cost but
sparse enough to scan effectively. A good `INFO` log tells you something meaningful happened without
overwhelming you with details. Bad `INFO` logs either say too little (generic "processing request"
messages) or too much (dumping internal state that's only useful for debugging).

`WARNING`, `ERROR`, and `FATAL` logs should always provide value. These levels interrupt people's
workflows and demand attention. If you're regularly ignoring `WARNING` logs, they're probably `INFO`
logs in disguise. If `ERROR` logs don't require action, they're creating alert fatigue. The
signal-to-noise ratio for higher severity levels needs to be nearly perfect.

Volume matters as much as content. A single `ERROR` log per hour gets attention. A hundred `ERROR`
logs per hour get ignored. Even legitimate errors lose their impact when they're buried in volume.
Sometimes the right solution is fixing the underlying issue. Other times it's changing the log level
or adding rate limiting to preserve the signal.

## Context Changes Everything

The same event can warrant different log levels depending on context and expectations. Consider a
database connection failure:

In a web scraper that expects some targets to be unreachable, a connection failure might be `DEBUG`.
It's operational detail that's only interesting when debugging connectivity issues.

In a batch job that processes data overnight, a connection failure could be `WARNING`. The job might
retry and eventually succeed, but the failure indicates potential infrastructure problems.

In a real-time payment system, a database connection failure is definitely `ERROR`. Payments are
failing, customers are affected, and someone needs to investigate immediately.

Same failure, different business impact, different log levels. The level should reflect the
significance of the event in context.

## Putting It Together

Effective logging combines appropriate log levels with contextual awareness. The same technical
event can have different business significance depending on where and when it occurs. A database
timeout during a health check is different from a database timeout during payment processing.

Start with your audience. Who will read these logs and in what context? Developers debugging locally
can handle verbose, detailed logs. Operators scanning for issues need concise, meaningful signals.
Incident responders need actionable information that helps them understand impact and next steps.

Consider the cost of both logging and not logging. Verbose logs slow down systems and create noise,
but missing logs leave you blind during outages. The right balance depends on your system's
criticality, complexity, and operational maturity.

Good logging is an investment in your future debugging sessions. When something goes wrong at 2 AM,
you'll be grateful for logs that tell a clear story at the right level of detail.
