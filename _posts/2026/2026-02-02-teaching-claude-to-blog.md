---
layout: post
title: "Teaching Claude to Write Like Me"
description: >-
  I built a custom Claude Code skill to codify my blog writing workflow. The irony? Claude didn't
  know how to create its own skill files.
tags: [ai, llm, tools, meta]
---

A few weeks ago, I wrote about [using Claude to help write blog posts]({% post_url
2026/2026-01-06-claude-blogging %}). The process worked well, but I kept repeating myself. Every
session started with the same context: here's my writing style, here's how to structure posts,
here's where to put the files. It felt like onboarding a new contractor every time.

Claude Code has a feature called skills - custom instructions that get loaded when you invoke a
slash command. Instead of explaining my workflow each time, I could document it once and reuse it
forever. So I decided to create a `/blog` skill.

## Starting with What I Knew

My first attempt was straightforward. I asked Claude to create a skill for writing blog posts. It
understood the concept but produced something generic - a basic template with placeholder
instructions that wouldn't actually capture my workflow.

This makes sense in hindsight. Claude knows about its skills system in the abstract, but it doesn't
have specific knowledge of the file format, metadata requirements, or best practices. It's like
asking someone to write a configuration file for software they've never used.

I needed to teach Claude about skills before it could create one for me.

## The Iteration Loop

I started researching. The
[Claude documentation](https://support.claude.com/en/articles/12512198-how-to-create-custom-skills)
explains that skills are just markdown files with YAML frontmatter. The frontmatter needs a name (64
characters max) and description (200 characters max) that Claude uses to decide when to invoke the
skill. The markdown body contains the actual instructions.

Armed with this knowledge, I tried again. This time I gave Claude some instructions to prompt for
topics. The outcome was better, but still missing key pieces. The instructions were too vague.
Claude initially prompted for a post title using a dropdown, and asked me to suggest tags before any
content.

The approach felt counterintuitive. I had to get more specific. I updated the skill to ask for a
free text topic and infer title and tags. This got much closer to my goal workflow. I had to revise
one more time to prompt for post date, but after that Claude was good to go.

## What Made It Click

For me, the breakthrough was treating the skill like documentation for a process I'd do manually.
Not "write a blog post" but the actual steps: ask clarifying questions, research the topic, analyze
existing posts for voice, generate appropriate tags, run linters.

I added specific guidance that emerged from experience. Don't use `categories` in front matter - use
`tags`. Include a `description` field for SEO. Match the timezone to Eastern. Run the markdown
linter before calling the post finished.

The skill also needed to handle the parts Claude does well versus the parts that need human input.
Claude can research topics and structure content. But the unique insights, personal anecdotes, and
contrarian takes have to come from me. The skill explicitly asks clarifying questions before writing
to extract that context.

## Why Bother?

Documenting workflows this way has two benefits.

First, it eliminates repetitive prompting. I no longer spend the first few minutes of each session
explaining my process. I type `/blog`, Claude asks what I want to write about, and we're off.

Second, it captures institutional knowledge. My blog workflow lives in a file that I can version
control, iterate on, and share. If I change my process, I update the skill. The documentation stays
current because it's the actual thing I use.

This mirrors how I think about other kinds of automation. The first time you do something, you
figure it out. The second time, you refine it. By the third time, you should be automating or
documenting it. Skills are documentation that executes.

## The Meta-Irony

The post you're reading was created using the skill I built. Claude asked me what I wanted to write
about. I said "creating a skill to write blog posts." It asked clarifying questions about angle,
audience, and key points. Then it researched Claude Code skills, analyzed my existing posts, and
produced a draft.

I still reviewed and edited. That's the point. The skill handles the mechanical parts - research,
structure, file creation - while I focus on the content that has to come from experience.

Claude couldn't create its own skill files without being taught. But once taught, it applied that
knowledge consistently. That's the promise of this approach: invest upfront in documenting your
workflow, and get compounding returns every time you use it.

The skill isn't perfect. I'll keep iterating as I notice gaps. But it's already better than starting
from scratch each session. And unlike mental notes about "how I like things done," it won't fade or
drift over time.
