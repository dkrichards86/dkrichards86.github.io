---
layout: post
title: "Upstream and Downstream Services"
description: >-
  The terms upstream and downstream confuse everyone at first. A clear mental model for
  understanding service dependencies in microservices architecture.
tags: [microservices, architecture, terminology]
---

Which is which? Every single time someone says "upstream service" in a meeting, I have to
pause and reconstruct the mental model. Is upstream the service I'm calling, or the one calling me?
I should know this, but I always forget.

This isn't just me. I've watched senior engineers stumble over this terminology. The terms come from
manufacturing and logistics where they make intuitive sense. In software, especially microservices,
they're backwards from what your brain expects. But they're everywhere, so it's worth getting
straight.

## The River Model

Imagine data flowing like water. The source of the river is upstream. Everything downstream from the
source receives water that originated upstream.

In microservices, an upstream service is the source. It provides data or functionality. A downstream
service is the consumer. It receives data or calls functionality from upstream services.

When Service A calls Service B, Service B is upstream to Service A. Service A is downstream from
Service B. The data flows from B (upstream source) to A (downstream consumer).

That's it. That's the whole model. Everything else builds on this.

## Why It Feels Backwards

Your intuition wants to treat the calling service as upstream because it initiates the request. That
makes sense from a control flow perspective. You make a call, it goes "up" to another service, comes
back "down" to you.

But the terminology follows data flow, not control flow. The service that provides the data is the
source (upstream). The service that consumes the data is downstream. It's the same mental model as
rivers or supply chains. The manufacturer is upstream. The customer is downstream.

Once you internalize that it's about data provision rather than request initiation, it stops being
confusing. But it takes conscious effort to rewire that intuition.

## Practical Examples

Consider an e-commerce system. Your Order Service needs product details to create an order. It calls
Product Service to get pricing and availability. Product Service is upstream to Order Service
because it's the source of product data. Order Service is downstream because it consumes that data.

Now add Payment Service. Order Service calls Payment Service to charge the customer. From this
perspective, Payment Service is upstream to Order Service. But Order Service is upstream to the
frontend that displays order confirmation. Any service can be both upstream and downstream depending
on which relationship you're examining.

The terms are relational and directional. They describe a specific dependency between two services,
not an absolute position in your architecture.

## When Teams Disagree

Here's where it gets messy: not everyone uses these terms the same way. Some teams flip the
definitions, treating the caller as upstream because that's where control originates. Others use
upstream to mean "earlier in the request path" which might align with data flow or might not
depending on the architecture.

This ambiguity isn't hypothetical. I've been in triaging sessions where inverted terminology across
different systems undermined our investigation. We were tracking in the wrong direction because the
terms were flipped. The terminology was sabotaging our troubleshooting.

When you join a new team or start a new project, clarify what upstream and downstream mean in that
context. Don't assume. Ask explicitly: "When we say Service A is upstream to Service B, do we mean A
calls B or B calls A?" Get everyone aligned on the definition before using it in design docs or
postmortems.

## Dependencies and Impact

Beyond terminology, understanding upstream and downstream relationships helps you reason about
system reliability and dependencies.

If an upstream service fails, all its downstream consumers are affected. When your authentication
service goes down, every service that depends on it for user validation is impacted. The failure
cascades downstream like a river being dammed.

This matters for SLA planning and incident response. You need to know your upstream dependencies so
you can plan for their failure modes. You need to know your downstream consumers so you can assess
blast radius when you have an outage.

Mapping these relationships explicitly helps. Draw your services with arrows showing data flow.
Identify single points of failure where one upstream service blocks many downstream consumers.
Consider what happens when upstream services are slow, not just when they're down. Latency cascades
downstream just like outages do.

## Making It Stick

The river model works because it's visual and consistent. Data flows from source to consumer.
Upstream services are sources. Downstream services are consumers. When you're in a meeting and
someone mentions an upstream service, picture the data flowing from there toward your service.

If you still get confused, fall back to the basic question: who provides the data? That service is
upstream. Who consumes the data? That service is downstream.

And when you're writing documentation or discussing architecture, be explicit. Don't just say "the
upstream service." Say "the Product Service, which is upstream to Order Service." Make the
relationship clear. Your future self (and your teammates) will appreciate it.

The terminology is frustrating because it's counterintuitive at first, but it's not going anywhere.
Microservices architectures depend on clear mental models of service relationships. Upstream and
downstream are the vocabulary we've settled on. Understanding them clearly makes architecture
discussions more precise and helps you reason about failures and dependencies in distributed
systems.

Just remember the river. Data flows downstream. The rest follows from there.
