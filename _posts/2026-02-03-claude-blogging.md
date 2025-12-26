---
layout: post
title: "Writing with AI: My Process for Blog Posts"
description: >-
  I've been using Claude to help write blog posts the same way I use AI for programming. Clear
  prompts, iterative feedback, and treating output like code review.
tags: [ai, llm, writing, meta]
---

I've been using Claude to help me write blog posts for a few months now. The process feels
remarkably similar to how I use AI as a programming copilot. Same principles, different domain.

When I use Claude Code for coding, I don't just accept whatever it generates. I give it clear
requirements, review the output critically, and iterate until I get what I need. The AI is a junior
developer on my team. Smart, fast, but needs good direction and careful review.

Writing with Claude works the same way.

## Starting with Clear Requirements

Good AI output starts with good prompts, whether you're generating code or prose. When I ask Claude
to write a blog post, I don't just say "write about Docker." I give it specific requirements.

I'll tell it the target audience (developers, not beginners), the tone (educational,
conversational), and the scope (focus on practical usage, not theory). I'll specify what I want to
avoid (don't rehash basic concepts everyone knows) and what I want to emphasize (real-world problems
and solutions).

For this post, my prompt was specific. Write about using AI for writing, compare it to programming
copilots, explain my iterative process, match my voice from previous posts. I gave Claude access to
my entire blog archive so it could understand my style.

Just like with code, vague requirements get you vague output. "Make this function faster" produces
different results than "optimize this function for memory usage, target sub-100ms response time,
maintain thread safety." Same with writing prompts.

## Treating Output Like Code Review

When Copilot suggests a function, I don't just accept it. I read through the logic, check for edge
cases, consider maintainability, and test it. Same process with writing.

Claude's first draft of this post was decent, but it had issues. It referenced some technologies
that I don't use. This entire paragraph in particular contained some hallucinations. Instead of
starting over, we iterated. I treated it like a pull request review.

Each iteration gets closer to what I actually want. Sometimes Claude nails it on the first try.
Usually it takes three or four rounds of feedback. Occasionally I'll scrap a section entirely and
ask for a different approach.

The key is being specific about what's wrong and what I want instead. "Make it better" helps nobody.
"This paragraph buries the main point in the third sentence. Lead with that insight" gives Claude
something actionable.

## When AI Shines vs When It Struggles

AI copilots are great at generating boilerplate code, implementing well-understood patterns, and
handling repetitive tasks. They struggle with complex business logic, domain-specific requirements,
and architectural decisions.

Writing AI has similar strengths and weaknesses. Claude excels at structure, transitions, and
explaining technical concepts clearly. It's good at maintaining consistent tone once it understands
what you want. It can research topics and synthesize information from different sources.

But it struggles with personal experience and unique insights. The best parts of my blog posts are
usually stories from my career, lessons learned from specific projects, or contrarian takes on
conventional wisdom. Those have to come from me.

Claude can't tell the story about debugging a race condition at 2 AM or explain why I disagree with
popular opinion on microservices. It can help me structure those stories and make them more
readable, but the content has to be mine.

## The Iterative Loop

My writing process with Claude looks like this:

1. Give Claude a detailed prompt with requirements, context, and examples
2. Review the first draft like I'm doing code review
3. Give specific feedback on what to change, add, or remove
4. Repeat until it matches my standards
5. Do a final edit pass myself for personal touches and voice consistency

This usually takes 3-5 iterations. The first draft establishes structure and covers the main points.
Subsequent rounds refine tone, improve flow, and add depth. The final edit is where I add personal
examples and make sure it sounds like me.

Using Claude this way has definitely increased my writing output. I publish more consistently
because the initial draft happens faster. I can explore ideas that might not be worth a full manual
writing session. I can write about topics where I have opinions but need help with research and
structure.

The risk is that AI-assisted writing can feel generic if you're not careful about maintaining your
voice and perspective. The same risk exists with programming copilots. Over-reliance on generated
code can lead to applications that work but lack coherent architecture.

## Trust But Verify

The principle I use for both coding and writing AI is "trust but verify." The AI output is usually a
good starting point, but it needs human judgment and iteration to become something valuable.

With code, I verify by testing, reviewing, and considering edge cases. With writing, I verify by
reading it critically, checking that it makes the points I want to make, and ensuring it sounds like
something I would actually say.

Neither approach replaces human expertise. They're tools that augment it. Used well, they let you
focus on the high-value creative work while handling the mechanical aspects more efficiently.

The key is knowing when to trust the AI and when to override it. That judgment comes from experience
in the domain, whether it's software engineering or technical writing.
