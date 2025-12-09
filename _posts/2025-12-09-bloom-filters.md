---
layout: post
title: "Bloom filters are cool"
description: >-
  A Bloom filter is a probabilistic data structure that answers a simple question: "Is this item in my set?". They provide really fast lookups with a minimal memory footprint. They're perfect for filtering out items that definitely aren't there.
---

A few months ago, I gave a presentation on Bloom filters. They're one of those elegant computer science concepts that solve a very specific problem remarkably well.

A Bloom filter is a probabilistic data structure that answers a simple question: "Is this item in my set?" It doesn't answer the question directly though. Instead it says the item is either definitely not in the set, or the item might be in the set. Bloom filters may give false positives (the item might be in the set), but will never have false negatives. If a Bloom filter says your data isn't present, it isn't present.

Bloom filters exist to solve a real problem. Traditional approaches to membership testing have real costs. Hash tables are memory intensive at high volume. Sorted arrays have slow lookups. Database queries require network round trips and disk I/O. Bloom filters give you really fast lookups (`O(k)`, where k is small) with a minimal memory footprint. They're perfect for filtering out items that definitely aren't there.

The mechanism is surprisingly simple. You need to create a bit array of size `n`, initially all zeros, and choose `k` independent hash functions.

When an item is inserted, it is run through all k hash functions. Each hash function returns an index in the bit array, and those `k` bits are set to 1. Checking for existence also runs the item through `k` hash functions. If any resulting bit is 0, the item is definitely not in the set. If all bits are 1, then the item may exist.

Let's walk through an example. For this example, we have a 16-bit array and 3 hash functions.

Our starting state is a bit array of length 16, with all indexes set to 0. It looks something like this:  `[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]`

Ok, so now it's time to insert some data. Our first item is “cat”, which hashes to positions 2, 5, 11. Our bit array now has 1 at indexes 2, 5, and 11. Our stats is now `[0,0,1,0,0,1,0,0,0,0,0,1,0,0,0,0]`

Then we insert “dog”. It hashes to 1, 5, and 7. 5 was updated by our previous insert, but that's ok. We just move along. The updated state is `[0,1,1,0,0,1,0,1,0,0,0,1,0,0,0,0]`

Now it's time to check membership. If we want to query “bird”, we'll check its hash values. “bird” hashes to 1, 5, 9. When we check bits, we see that indexes 1 and 5 are set, but 9 is not. We know that “bird” is definitely not in our set.

Let's query "snake" next, which hashes to positions 1, 5, 11. In this case, all three indexes are set to 1. We don't know for sure if the item does exist, but we know it might. This is a false positive, where bits just happened to overlap.

The beauty of Bloom filters is in their simplicity and effectiveness. They solve a specific problem with remarkable efficiency. It answers the question "Can I avoid looking at this data?" very well. And when you're working with large datasets, that's exactly the kind of problem worth solving.