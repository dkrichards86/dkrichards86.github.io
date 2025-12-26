---
layout: post
title: "Automating scheduled posts in Jekyll"
description: >-
  I wanted to write posts in advance and have them publish automatically. Here's how I built a
  scheduling system using GitHub Actions.
---

I've been writing blog posts whenever inspiration strikes, but I wanted more control over when they
go live. Write something on Sunday, publish it Tuesday morning. Queue up a few posts and maintain a
consistent schedule without babysitting the publish button.

The manual workflow was getting old. I'd write posts in `_drafts/`, then when I was ready to publish
I'd manually move them to `_posts/` and push to GitHub. This worked fine for immediate publishing,
but scheduling posts meant setting calendar reminders and hoping I remembered to push at the right
time.

Modern CMSs have scheduling built in. Jekyll doesn't, because it's a static site generator. Every
time you push to the repo, GitHub Pages rebuilds and deploys. There's no server-side scheduling, no
database keeping track of publication dates, no cron jobs. Just commits and builds.

I realized I could use GitHub Actions to bridge the gap.

## How it works

The solution is straightforward. I already use GitHub actions to build the site. Instead of manually
moving posts, I just extended the action to use a cron job! The new workflow looks like this:

1. I draft posts in `_drafts/`.
2. I move posts to `_posts_/` with future dates in the filename, like
   `2025-12-26-scheduled-jekyll.md`.
3. A GitHub Action runs every morning at 10:37 AM EDT. The workflow rebuilds content with dates on
   or before today. I had to update `_config.yml` to set `future: false` to accommodate this.

Why 10:37 AM EDT, you ask? Everyone runs their scheduled workflows at the top of the hour. 10:37 AM
was a random time. I'll have less compute to compete with.

## The new workflow

Now when I write a post, I give it a date and push to the repo. On the next Tuesday, the Action
picks it up automatically. No manual intervention required. I can write several posts throughout the
week, and they'll all publish together on Tuesday morning.

This approach has some limitations. The workflow runs once daily, so posts publish sometime after
10:37 AM EST, not at a specific minute. That's fine for my needs. If you need precise timing, you
could run the workflow more frequently or adjust the cron schedule.

GitHub Actions minutes are free for public repositories. Private repos have usage limits, but this
workflow is lightweight enough that it won't come close to hitting the threshold.

One thing to keep in mind: scheduled posts sitting in `_posts/` are visible in the repo. For my case
that's fine. I use this blog more like a public notebook than anything else. If you were to reuse
this Action, beware.

## Why this works for me

I wanted CMS-style scheduling without sacrificing the simplicity of a static site generator. This
solution leverages GitHub's infrastructure and integrates seamlessly with the GitHub Pages
deployment workflow. The entire setup is about 100 lines of shell script and YAML configuration.
It's a small investment, but a nice quality of life improvement.

If you're running a Jekyll blog on GitHub Pages, this approach might work for you too. The workflow
is straightforward and customizable. Adjust the schedule, tweak the timezone, add notifications if
you want. It's your workflow.

I'm happy with how this turned out. Write when I want, publish when I want, and let GitHub handle
the rest.
