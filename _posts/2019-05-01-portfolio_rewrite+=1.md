---
layout: post
title:  "portfolio_rewrite += 1"
description: >-
  I've rewritten my personal portfolio site once again. Would you like
  to know why?
---

Sometime around 2015, I launched the first version of my personal website. At
the time, I was learning React and MongoDB, so it seemed appropriate to apply
them. I had a Droplet on DigitalOcean running a Node.js server serving dynamic
content from MondoDB via Express, and rendered a single page application in React.
The site had an API and database for a few otherwise static pages. I even wrote
a custom SEO tool to dynamically add `meta` tags and descriptive content.

The page functioned well and looked nice, but was over-engineered. My portfolio
was a simple static site; There was no need for a full stack application. The
unnecessary complexity made it cumbersome and slow. It was too much. It needed
to go on a diet.

In the middle of 2016, I nuked the backend and database and rolled my content
straight into the single page app. While there was less server administration
overhead, adding content wasn't the easiest proposition. It required either a)
updates to a JSON file, or b) direct edits to components. It was kind of
annoying.

Again in 2018, I rewrote my portfolio. This time, I took a minimalist approach.
I used Pug to build reusable templates and Stylus for stylesheets. I replaced
my content with links to third-party sites like LinkedIn, GitHub and Medium.
This was the easiest setup yet- I could leverage the strengths of the respective
platforms instead of doing it all myself. It was a lazy approach. After a while,
I moved it to GitHub Pages. I didn't even have to administer a server. It was
fantastic. In the time since, I've made a few small edits here and there,
but it has remained largely unchanged for the past year or so.

Lately though, I've grown bored of my portfolio. I haven't added much content
or made any changes. I would love to be able to generate content regularly and
actually own it, instead of handing it off to third-parties like I do now. While 
studying for my MBA, I had to do a lot of writing. Now that I've completed the
program, I want to start writing more technical articles. And I want ownership.
Hence the new portfolio.

The new plan is to use Jekyll to serve a blog. I'll still host on GitHub Pages,
taking advantage of their seamless Jekyll integration. This way I'll still own
my content while having limited server administration overhead. Since I've grown
less interested in user interface development, I'll spend less time on styling
changes and more time writing.

Stay tuned to see if it works!