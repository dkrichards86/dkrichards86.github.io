---
layout: post
title: "Understanding the Node.js Event Loop"
description:
  "Learn how the Node.js event loop works, its six phases, and best practices for writing efficient
  asynchronous applications without blocking performance."
---

I'm preparing for a refactor of some legacy Node code. This code is somewhat old, and has a mix of
older [async](https://caolan.github.io/async/v3/) callbacks and modern `async/await`. The mishmash
of approaches carries some cognitive overhead, so we're interested in unifying it all to the modern
format.

This service sees a fair amount of traffic. We handle close to 500M requests per day, with most
requests concentrated in a 10 hour window. A typical hour in that window sees 35M requests. It's at
the heart of our SSO operations too, so any latency or downtime is very disruptive. It needs to run
fast and be reliable.

Making changes to the service's asynchronous operations involves some risk. Changing the way we
handle asynchronous code will naturally change the way we populate and process our event loop
queues. Before I take on any work, I need to make sure our event loop monitoring and alerting is in
a good state. A precursor to playing around with event loop monitoring is revisiting the event
loop's process and refreshing my memory a bit. While I'm at it, I figured I'd write up a quick post
so future me doesn't have to dig as much.

So, without further ado...

## Node's Event Loop

The event loop is Node.js's execution model that handles asynchronous operations. While JavaScript
runs in a single thread, the event loop allows Node.js to offload operations like file I/O, network
requests, and timers to the system, freeing up the main thread to continue executing other code.
Think of it as a coordinator that manages when different pieces of code should run, ensuring that
long-running operations don't block the execution of other tasks.

The event loop has six distinct phases, each with a specific purpose and queue of callbacks to
execute. The six phases are "timer", "pending callbacks", "idle, prepare", "poll", "check" and
"close callbacks".

- "Timer" phase executes callbacks scheduled by `setTimeout()` and `setInterval()`, checking if any
  timer has reached its specified delay.
- The "Pending Callbacks" phase handles I/O callbacks that were deferred to the next loop iteration,
  including some system operations and error callbacks.
- The "Idle, Prepare" phases is used internally by Node.js for housekeeping tasks that applications
  typically don't interact with directly.
- The "Poll" phase is the most important for most applications. This is where new I/O events are
  fetched and executed, and where the event loop may block if there are no timers scheduled.
  Callbacks for network connections, file operations, and other I/O are processed here.
- The "Check" phase executes `setImmediate()` callbacks after the Poll phase completes, and
- The "Close Callbacks" phase handles close events like socket cleanup callbacks.

## Macrotasks and Microtasks

All of the phases listed above deal with "macrotasks". Macrotasks are events enqueued by APIs or by
completing I/O operations. Examples of macrotasks include `setTimeout()` and `setInterval()`
callbacks, `setImmediate()` callbacks, I/O operations, and UI events in browsers. These events have
special considerations in the event loop, and are processed in specific order. The "poll" phase
above works through these special events in order before moving onto the "check" phase. That all
makes sense.

But! Not all events processed by the event loop are these special events. The event loop also works
through a queue of events defined by the user's code. These are known as "microtasks".

Understanding the difference between microtasks and macrotasks is essential for predicting execution
order. Microtasks include Promise callbacks, `process.nextTick()` callbacks (which have the highest
priority in Node.js), and `queueMicrotask()` callbacks. Microtasks have higher priority than
macrotasks, so they can preempt macrotasks in the event loop. Microtasks always execute before
macrotasks, and between each phase of the event loop, all microtasks are drained before moving to
the next phase.

Node.js follows a specific priority order: `process.nextTick()` has the highest priority and
executes before any other asynchronous operation, followed by Promise microtasks from resolved
promises and async/await continuations, then `setImmediate()` which runs in the Check phase, and
finally `setTimeout()` and `setInterval()` which run in the Timer phase with specified delays.

## Bringing It Back to the Refactor

So why does all this matter for the refactoring project? Understanding the distinction between
macrotasks and microtasks is crucial when moving from callback-based `async` to `async/await`.

The execution model changes in subtle but important ways. The legacy code uses the `async` library
extensively - operations like `async.parallel` and `async.waterfall` that schedule callbacks as
macrotasks through their completion mechanisms. When I convert these to modern `Promise.all` or
sequential `await` statements, those completions become microtasks instead. This changes execution
order. The microtask-based code will complete before any pending macrotasks, potentially affecting
how operations interleave with I/O or timers elsewhere in the system.

At our scale even small changes to event loop behavior compound quickly. A refactor that
inadvertently creates excessive microtasks could starve the event loop, preventing timers and I/O
callbacks from executing promptly. Conversely, if I'm more efficient about when I yield control back
to the event loop, I might see improved throughput. Either way, the changes won't be neutral.

This is where monitoring becomes critical. Before touching any code, I need to establish baseline
metrics for event loop lag, understand our current task distribution, and set up alerts for
degradation. I need to know how long the event loop spends in each phase, how often I'm draining
large microtask queues, and whether any operations are consistently blocking. Testing locally is
fine, but production behavior at 500M requests per day is fundamentally different. Issues that don't
appear under light load can cripple performance at scale.

The stakes are high here. This service is at the heart of our SSO operations, and any latency
increase or availability issue cascades across our entire platform. Understanding how the event loop
processes tasks gives us the tools to refactor confidently. I can reason about whether a particular
code change will alter timing in meaningful ways. I can anticipate failure modes - like recursive
promise chains creating microtask storms. And I can design tests that actually stress the event loop
in realistic ways.

Now that I've got the event loop mechanics clear in my head again, I can move forward with the
refactor confidently. Wish me luck.
