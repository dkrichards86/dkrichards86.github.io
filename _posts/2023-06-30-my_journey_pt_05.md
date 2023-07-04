---
layout: post
title: "My Journey part 5 - Senior Dev (2019 to present)"
description: >-
  In this article, I talk about my most recent roles.
---

In the summer of 2019, I left my position at a research institute and transitioned to a role with a company building
software products for public transit providers. I really enjoyed my time at the non-profit, but the consulting structure
and small team sizes really limited growth opportunities. The only position I could grow into was a manager role that
would have taken me away from software and made me more of a product manager.

The company I moved to worked in the mass transit management space. We provided SaaS tools to help transit administrators
run their lines. We were divided into two main focus areas- fixed route operations and on-demand transit. Fixed route is
the typical city bus approach- buses run along predefined routes and visit stops on a regular, predictable basis.
On-demand is similar to a subsidized ride sharing program- riders want to go from any location in the service area to any
other location.

When I joined, I was assigned to the algorithms team responsible for powering the on-demand tool. This was a giant
"traveling salesman" solver with a lot of constraints around capacity, wait time and ride time. Under the hood it used a
simulated annealing algorithm to find a reasonable route for the vehicle to take when servicing rides. Learning the ins
and outs of the scheduler was a lot of fun.

Shortly after I joined, the company announced a merger with another company. Both companies had competing products on
the market, so our first course of action was to consolidate products. The plan was to pick the more feature rich
product in each focus area, then close any feature parity gaps to ensure the needs of most existing clients were still
met.

The two products on the on-demand side had differing philosophies. One company tried to find the optimal solution for
all riders, even if it meant the experience for one rider may worsen. To achieve this, the scheduling algorithm would
continually readjust pickup and dropoff order for riders. The other company prioritized individual rider experience-
it tried to stay as close to original estimates as possible. This made for a predictable service for riders, but meant
long wait times for riders at high volume times.

Because we had two different philosophies, addressing feature parity was quite challenging. We eventually ran the two
algorithms and allowed clients to pick their preference.

After a while, the on-demand product stabilized and transitioned to adding new features. Around the same time, the
company began to focus primarily on fixed route products. We wanted to close feature gaps on the fixed route side too.
As part of this shift, I moved from on-demand to fixed route.

My stint on the fixed route focus area revolved around "Automatic Vehicle Location" (AVL). The AVL team was responsible
for consuming streaming GPS coordinates from buses, and interpreting those coordinates. We had to decide where the
vehicle was on its route, determine which stops it had visited, and predict its arrival at future stops. We set a budget
of 50ms to run each packet through the three pipelines.

After a few charming months, the company began to rearrange resources for an acquisition. There were a series of
questionable decisions made, followed by some churn. I grew more and more uncomfortable with the future of my product
(and role), so I began looking for other opportunities. Soon enough I landed a new role and submitted my resignation.

In August 2021 I joined a company focused on helping K-12 students access learning materials. I spent my first year
working on products that help school districts provision user accounts in third party services. We automatically created
Google or Azure accounts for students based on district roster information.

In Q4 2022 I moved to a new team that dealt with our Single Sign On (SSO) components. I also took on a new role as the
team's resiliency leader, meaning I became a champion of our SSO uptime goals in service of tens of millions of logins
each day.

That brings us to today- things are still going well with resiliency and uptime. I've learned a ton about SSO and
authentication/authorization. Helping kids access their learning apps is incredibly rewarding!
