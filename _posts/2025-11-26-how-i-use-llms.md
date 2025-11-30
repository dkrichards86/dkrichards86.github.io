---
layout: post
title: "How I use LLMs"
description: >-
  LLMs are a hot topic. In this post, I share my emerging philosophy on LLM usage in the software industry.
---

Large Language Models (LLMs) are all the rage these days. Companies like OpenAI and Anthropic are in an arms race to outmodel one another. A lot of companies are jumping onboard, pushing LLM use requirements on staff. It's kind of chaotic right now.

Big AI companies are insistent that LLMs will replace developers, resulting in a new wave of technical innovation. I just don't see that happening. I do see LLMs as a valuable tool in my toolbox, however. I doubt they will ever replace an experienced developer, but they can be an assistant to that developer.

Over the past few months, I've been using Claude and Claude Code to help shape my philosophy on LLMs. For the most part I've converged on a usage pattern that works pretty well for me.

I use Claude for two main things, researching ideas and implementing them. When it comes to research, I use LLMs as reference material. Claude gives me a starting point that I can investigate more on my own. Sometimes Claude's output is good enough that my own investigation is just due diligence. Other times it's way off-base or going down the wrong rabbit hole. Sometimes I can prompt away the latter cases, but once a bad seed is planted in context, it doesn't always go away.

On the implementation side, I treat the output of LLMs like I would that of a junior engineer. I prompt it with clear expectations and acceptance criteria, then scrutinize the output. Since I wrote the prompt and acceptance criteria I typically know what correct looks like. This becomes nothing more than a PR review or pairing session. Sometimes I'm impressed with the code and idioms. Other times I'm left prompting again and starting from scratch.

In both scenarios, I take a "trust, but verify" stance. I'm not about to vibe code a serious application or production change. I'll run it through the same design and review process that I would for a mentor.

So far this approach has worked for me. Subjectively I feel like my output has increased, but that may be placebo. We'll see in a few more months.