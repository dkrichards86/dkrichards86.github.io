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

The solution is straightforward. I write posts in `_drafts/` with future dates in the filename, like
`2025-12-28-scheduled-jekyll.md`. A GitHub Action runs every morning at 10 AM EST. The workflow
checks for drafts with dates on or before today, moves matching posts from `_drafts/` to `_posts/`,
commits the changes, and pushes. GitHub Pages sees the commit and rebuilds the site. The post goes
live.

With the help of Claude, I created `.github/workflows/scheduled-posts.yml` with a cron schedule and
some bash to handle the date parsing and file moving. The workflow uses `git mv` to preserve file
history. It only commits if there are actually posts to publish, so the commit log stays clean. For
local testing, I wrote a companion script at `scripts/publish-scheduled-posts.sh`. Same logic, but
it just moves files without committing. Useful for checking which posts are ready or manually
triggering a publish.

I also updated `_config.yml` to set `future: true`, which lets me preview scheduled posts locally
with `jekyll serve`. In production, future-dated posts in `_drafts/` won't appear until the Action
moves them.

## The new workflow

Now when I write a post, I give it a future date and push to the repo. On that date, the Action
picks it up automatically. No manual intervention required. I can write three posts on Sunday
afternoon, schedule them for Tuesday, Thursday, and the following Monday, and they'll publish on
schedule.

This approach has some limitations. The workflow runs once daily, so posts publish sometime after 10
AM EST, not at a specific minute. That's fine for my needs. If you need precise timing, you could
run the workflow more frequently or adjust the cron schedule.

GitHub Actions minutes are free for public repositories. Private repos have usage limits, but this
workflow is lightweight enough that it won't come close to hitting the threshold.

One thing to keep in mind: scheduled posts sitting in `_drafts/` are visible in the repo. For my
case that's fine. I use this blog more like a public notebook than anything else. If you were to
reuse this Action, beware.

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
