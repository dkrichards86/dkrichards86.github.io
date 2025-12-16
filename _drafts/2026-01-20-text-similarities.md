---
layout: post
title: "Text Similarity Measures: Finding the Right Tool"
description: >-
  Working on a hackathon project forced me to revisit different text similarity measures. Here's
  what I learned about picking the right approach.
---

I've been hacking on a small project that needs to compare text documents and find similar ones. It
sounds simple enough, but there are surprisingly many ways to measure text similarity, each with
different trade-offs.

When you're comparing texts, you're really asking "how alike are these?" But that question has
multiple interpretations. Do you care about exact word matches? Meaning? Structure? The answer
shapes which similarity measure you should use.

## Edit Distance

Edit distance (Levenshtein distance) counts the minimum number of single-character edits needed to
transform one string into another. You can substitute, insert, or delete characters. For example,
transforming "kitten" to "sitting" takes 3 edits: substitute 'k' with 's', substitute 'e' with 'i',
and insert 'g' at the end. The edit distance is 3.

This works well for catching typos and small variations. Intuitively, strings that require fewer
changes are more similar. The catch is it treats all changes equally. Swapping one letter for
another costs the same as inserting or deleting. And it operates purely on characters, ignoring word
boundaries or meaning.

Edit distance shines when you're comparing short strings where character-level precision matters,
like matching product names with typos or finding near-duplicate usernames.

## Hamming Distance

Hamming distance counts positions where two strings differ. You compare character by character and
count the mismatches. This only works on strings of equal length. "karolin" and "kathrin" differ in
three positions, so the Hamming distance is 3.

The equal-length requirement is both a strength and a limitation. It makes computation trivial
because you can just zip through both strings once. But it can't handle insertions or deletions at
all. Add or remove a character and the entire comparison breaks down.

Hamming distance is perfect for fixed-length encodings like error-correcting codes, DNA sequences,
or binary data. When you know strings are the same length and you need blazing fast comparison,
Hamming distance is hard to beat.

## Jaro-Winkler Similarity

Jaro-Winkler similarity is designed specifically for short strings like names. It considers both
matching characters and transpositions (characters that are swapped). The Winkler modification adds
a bonus for strings that match at the beginning, reflecting how people typically make errors in
names.

The formula is complex, but the intuition is simple. Two strings are similar if they share
characters in roughly the same positions, even if some are transposed. And matching prefixes boost
the score because "Smith" vs "Smyth" should score higher than "Smith" vs "Thmis" even though both
have the same character differences.

This makes Jaro-Winkler excellent for record linkage and fuzzy name matching. When you're comparing
"Jon" to "John" or "Dwayne" to "Duane", it captures the similarity better than raw edit distance.
The catch is it's optimized for short strings. On longer texts the benefits diminish and simpler
measures often work as well.

## Jaccard Similarity

Jaccard similarity treats texts as sets of tokens (usually words) and compares how much they
overlap. It's the size of the intersection divided by the size of the union. If two documents share
half their unique words, the Jaccard similarity is 0.5.

The set-based approach is elegant. It ignores word order and frequency, focusing purely on
vocabulary overlap. This makes it fast and simple to compute. But those same properties are
limitations. "The cat sat on the mat" and "The mat sat on the cat" are identical by Jaccard's
measure, even though they mean different things.

Jaccard works best when you care about shared vocabulary but not about order or emphasis, like
comparing tag sets or finding documents covering similar topics.

## Cosine Similarity

Cosine similarity represents documents as vectors in high-dimensional space and measures the angle
between them. Documents are typically converted to term frequency vectors (or `TF-IDF` vectors),
where each dimension represents a word and the value represents how often it appears.

The genius of cosine similarity is that it captures both presence and emphasis. Documents that use
the same words with similar frequency patterns have vectors pointing in similar directions, yielding
high similarity scores. The calculation normalizes for document length, so a short paragraph and a
long essay can still be similar if they emphasize the same terms.

Limitations include sensitivity to vocabulary differences - "car" and "automobile" are treated as
completely different despite being synonyms. And the bag-of-words model still ignores order, so "dog
bites man" and "man bites dog" look identical.

Cosine similarity is the workhorse for many text applications. It's what powers basic document
search and recommendation systems.

## Semantic Embeddings

Modern approaches use neural networks to create dense vector representations (embeddings) that
capture semantic meaning. Models like sentence transformers map texts to vectors where semantically
similar texts cluster together, even if they use different words.

This is powerful. "The car is red" and "The automobile is crimson" will have high similarity despite
sharing no words. The model learned that cars and automobiles are related, as are red and crimson.
It captures meaning in a way traditional methods can't.

The trade-off is complexity. You need a pre-trained model, the compute to run inference, and careful
thought about which model fits your domain. Different models excel at different tasks - sentence
similarity, question-answer matching, code similarity. And embeddings are black boxes. You can
measure similarity but can't easily explain why two texts are similar.

Semantic embeddings are the go-to when you need to understand meaning, not just match words. They're
essential for semantic search, question answering, and any task where paraphrase detection matters.

## Picking the Right Measure

For my hackathon project, I needed to match user input against a database of school names. Users
would search for their school, but they'd make typos or remember the name slightly wrong. "Lincoln
High School" might come in as "Lincon High" or "Lincoln Highschool". I needed to find the closest
match from thousands of valid school names.

I started with edit distance since it handles typos naturally. It worked reasonably well for
catching single-character mistakes. But it struggled with transpositions - when users swapped
adjacent characters, the edit distance penalty was higher than it felt like it should be. And school
names are often similar to each other, making it hard to pick the right one.

That's when I tried Jaro-Winkler. School names are typically short to medium length strings, and
users often get the beginning right even when they mess up the rest. "Springfield Elementary" might
become "Springfiled Elementary" or "Springfield Elementry", but that critical "Springfield" prefix
is usually correct. Jaro-Winkler's prefix bonus aligned perfectly with this pattern. It also handled
transpositions better than plain edit distance.

I ended up using Jaro-Winkler with a threshold. If the similarity score was high enough, I'd suggest
the match to the user. If multiple schools scored above the threshold, I'd show them all and let
them pick. The approach felt natural. Users got helpful suggestions rather than an empty list or
wild guesses.

The lesson? There's no single best similarity measure. Each one makes different assumptions about
what "similar" means. Understanding those assumptions helps you pick the right tool for your
specific problem. For fuzzy matching school names with typos, Jaro-Winkler won. For finding semantic
duplicates in documents, embeddings would win. For detecting exact near-duplicates, Jaccard would be
faster. Match the tool to the task.
