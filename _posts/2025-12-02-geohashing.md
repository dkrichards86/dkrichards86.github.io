---
layout: post
title: "Cool thing I used years ago and want to remember: geohashing."
description: >-
  Geohashing is a cool way to encode latitude and longitude into a single string for simplified proximity lookups.
---

A geohash converts lat/lon into a compact string. Instead of storing both lat and lon as independent fields, you can store a single, space efficient string to locate something. It's less specific than lat/lon but can still narrow down to a very small range. The string structure means you can use prefixes to convey proximity. The longer the shared prefix between two locals, the closer they are together.

Geohashes work by recursively dividing the world into a grid, with each division encoded as a character. The squares are labeled using a Z pattern so prefixes communicate closeness in two directions. Wikipedia has a good breakdown of [Z curves](https://en.wikipedia.org/wiki/Z-order_curve) if you're interested in learning more.

Geohashes get more precise as the string length increases. A 6 character geohash represents an area of roughly 1.2km by 600m, while a 9 character one narrows it down to about 5m by 5m.

For a concrete example, consider Duke University in Durham, NC. The square identified by geohash "dnrug" encompasses Duke University. Neighboring "dnruu" covers downtown Durham. They both fall under the prefix "dnru", so we know they're close. And because the prefix has 4 characters, we know they're quite close.

I don't know if I'll ever use geohashes again, but they were cool and I want to remember them.