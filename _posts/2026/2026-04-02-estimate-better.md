---
layout: post
title: "Estimation Is Broken, But We Still Need It"
description: >-
  Every engineer struggles with estimation. After years of getting it wrong, I've learned that
  structured approaches like PERT plus generous buffering help bridge the gap between what we can
  predict and what actually happens.
tags: ["project-management", "estimation", "software-engineering"]
---

Every engineer I know struggles with estimation. I certainly do. You look at a ticket, think through
the work, and give your best guess. Then reality hits. That "simple" feature takes three times
longer than expected. A bug you thought would be quick turns into a two-day rabbit hole. The
estimate was wrong, the deadline slips, and everyone's frustrated.

This isn't unique to any team or company. It's a fundamental problem with software development.
Estimation is broken. But it's also unavoidable. Cross-functional teams need to plan. Marketing
wants launch dates. Sales forecasts delivery. Leadership allocates resources. They all depend on
engineers giving them numbers, even when those numbers are built on shaky ground.

The question isn't whether to estimate. It's how to get less wrong.

## Why Estimates Always Miss

After years of fine-tuning my approach, I've realized the core issue: there's always something you
didn't account for. Always.

Maybe it's interruptions. Your teammate needs help debugging production. A customer escalation pulls
you into meetings. Oncall rotation eats your afternoon. These aren't exceptional circumstances.
They're normal operating conditions that we consistently forget to factor in.

Or maybe it's unclear requirements. The ticket seemed straightforward until you started implementing
and realized three edge cases nobody discussed. Now you're in Slack threads clarifying scope while
your estimate clock keeps ticking.

Sometimes it's tech debt. That "quick change" requires touching a gnarly legacy system. You thought
you'd update one function. Turns out you need to refactor half a module just to make your change
fit.

The problem isn't that we're bad at estimation. It's that software development is fundamentally
unpredictable. We're building complex systems where changing one thing can cascade in unexpected
ways. The uncertainty is inherent.

But we still need to try.

## PERT: Accounting for Uncertainty

Most estimation approaches ask for a single number. "How long will this take?" You pick a number
that feels reasonable and hope for the best. When it's wrong, you beat yourself up and vow to be
more careful next time.

PERT (Program Evaluation and Review Technique) takes a different approach. Instead of one estimate,
you give three:

- **Optimistic**: Everything goes perfectly. No surprises, no blockers, straight-line execution.
- **Most Likely**: Normal circumstances. Some small issues but nothing major.
- **Pessimistic**: Things go wrong. You hit unexpected problems and have to backtrack.

Then you calculate the expected time using a weighted formula:

`Expected Time = (Optimistic + 4×Most Likely + Pessimistic) / 6`

The formula weights the most likely case heavily while accounting for both extremes. It's
essentially creating a probability distribution for your estimate. Since PERT is just simple
arithmetic, it's completely unit agnostic. You estimate in time? Great, PERT will handle days. You
use story points? Go for it. PERT away then round to the nearest point.

Say you're adding an export button that kicks off an async workflow. Your optimistic estimate is 4
days (everything's straightforward, the API exists, you just wire it up). Most likely is 6 days
(some edge cases to handle, maybe some UI polish). Pessimistic is 14 days (the async system needs
changes, there are race conditions, email delivery is flaky).

Using PERT: (4 + 4×6 + 14) / 6 = 7 days.

That's very different from just saying "6 days" and hoping for the best. PERT forces you to think
about what could go wrong and builds that into the estimate. It acknowledges uncertainty rather than
pretending it doesn't exist.

## Buffer Everything

PERT helps, but I've learned it's not enough. Even with PERT's built-in pessimism, estimates still
run long. There's always something you didn't account for.

My solution: buffer everything by 1.25x. Every 4 days of work gets represented as 5 days in
planning. Every week becomes a week and a day. This feels wrong at first. It feels like you're
padding estimates or being lazy. But it's the opposite. It's being realistic about how work actually
happens.

You don't spend 40 hours a week writing code. You spend time in meetings. You help teammates. You
review PRs. You fix production issues. You take breaks. You context switch. All of that is real work
that supports delivery, but it doesn't show up in your feature estimate. The buffer accounts for
this reality. It creates breathing room for the inevitable interruptions and surprises. It means
when something unexpected happens (and it will), you're not immediately behind schedule.

## Historical Data: Learning from the Past

The most powerful estimation tool is looking at what actually happened on previous projects. When
you finish a ticket, rescore it based on actual effort. Then compare that to your original estimate.

If you estimated 3 and it took 5, why? Was it unclear requirements? Unexpected tech debt?
Interruptions? Understanding the gap helps you estimate better next time.

Over time, patterns emerge. You might notice that anything touching the legacy authentication system
takes twice as long as expected. Or that UI work always has more edge cases than you think. These
patterns inform future estimates.

I recently ran through this exercise with my team. We reviewed recent tickets and found a recurring
theme. We had several tickets for one particular service, all estimated at 3 story points. They
consistently scored 5 points in our review. That's not a coincidence. That's a pattern that says our
"3 point" estimates are systematically low.

Historical data doesn't make estimation perfect. But it does make it less wrong.

## Structure Helps, Even When It's Imperfect

Some people argue estimation is so broken that we should abandon it entirely. Just work on the most
important thing and ship when it's ready. No estimates, no deadlines, no pressure.

That sounds nice, but it doesn't match reality. Organizations need to plan. Cross-functional teams
need coordination. Customers need visibility into when features will ship. Pretending you can avoid
estimation is just shifting the problem elsewhere.

Structure helps. PERT forces you to think about uncertainty. Buffering accounts for reality.
Historical data lets you learn and improve. None of this makes estimation easy or perfectly
accurate. But it makes it less wrong.

Estimation is broken, but we still need it. The goal isn't perfection. It's building in enough
cushion that when reality diverges from your plan (and it will), you're prepared for it rather than
scrambling.

After years of getting estimates wrong, I've learned that acknowledging uncertainty is more valuable
than pretending you can predict the future. PERT helps you do that. So does generous buffering. So
does learning from your mistakes.

The estimates will still be wrong sometimes. But at least they'll be less wrong.
