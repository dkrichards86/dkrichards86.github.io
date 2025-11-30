---
layout: post
title: "A thing to remember: Linear referencing"
description: >-
  Linear referencing is an intuitive way to communicate distance along a fixed path. It's one of those cool ideas I learned a few years ago and don't want to forget.

---

I first encountered linear referencing at a previous job and thought it was such a clever idea. It's one of those concepts that feels obvious once you understand it, but changes how you think about location data.

Linear referencing stores locations along routes as a single distance measurement instead of lat/lon coordinates. Rather than saying "the waterfall is at (35.9940, -78.8986)," you say "the waterfall is 0.7 miles from the trailhead on the Riverside Trail."

This matches how we naturally describe locations on set paths. When you tell someone where to find a scenic overlook, you don't pull out coordinates. You say "half a mile past the wooden bridge."

The concept is simple. Pick a starting point on your route and measure distance from there. Every location gets a single number representing how far along it sits.

The catch is you need a well-defined route with consistent measurements. If the path gets rerouted significantly, your references need updating. And it only works for things actually on the linear feature. Nearby landmarks don't fit naturally.

Still, "1.2 miles on Lakeside Loop" immediately tells hikers where to find the waterfall. No GPS lookup needed. The whole system just makes sense for things that exist along a line.

I probably won't build anything with linear referencing soon, but it's an elegant solution to a specific problem.
