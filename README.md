# dkrichards.com

Personal website and blog built with Jekyll and hosted on GitHub Pages.

## About

This is the source code for [dkrichards.com](https://dkrichards.com), a personal portfolio and blog featuring articles on software engineering, authentication/authorization, and other technical topics.

## Prerequisites

- Ruby 3.1.4 (managed via rbenv)
- Bundler 2.4.12
- Node.js and npm (for linters)

## Setup

1. **Install Ruby via rbenv** (if not already installed):
   ```bash
   brew install rbenv ruby-build
   rbenv install 3.1.4
   rbenv local 3.1.4
   ```

2. **Install Ruby dependencies**:
   ```bash
   bundle install
   ```

3. **Install Node.js dependencies** (for linters):
   ```bash
   npm install
   ```

## Development

Start the local development server:

```bash
bundle exec jekyll serve
```

The site will be available at `http://localhost:4000`

Jekyll will automatically rebuild the site when you make changes to files. Refresh your browser to see the updates.

## Project Structure

- `_config.yml` - Site configuration and settings
- `index.html` - Homepage with profile and recent posts
- `_layouts/` - Page templates
- `_includes/` - Reusable components
- `_posts/` - Blog posts (format: `YYYY-MM-DD-title.md`)
- `_sass/` - Stylesheets
- `assets/` - Images, CSS, JavaScript
- `vendor/bundle/` - Bundler dependencies (git-ignored)

## Writing Posts

Create a new markdown file in the `_posts/` directory with the following naming convention:

```
_posts/YYYY-MM-DD-title-of-post.md
```

Add front matter at the top of the file:

```yaml
---
layout: post
title: "Your Post Title"
date: YYYY-MM-DD HH:MM:SS -0500
categories: [category1, category2]
---

Your content here...
```

## Linting

This project uses linters to maintain code quality:

- **markdownlint** - Markdown files
- **HTMLHint** - HTML files
- **js-yaml** - YAML files

### Run all linters

```bash
npm run lint
```

### Run individual linters

```bash
# Markdown only
npm run lint:markdown

# HTML only
npm run lint:html

# YAML only
npm run lint:yaml
```

### Configuration Files

- [.markdownlint.json](.markdownlint.json) - Markdown linting rules
- [.htmlhintrc](.htmlhintrc) - HTML linting rules
- [scripts/lint-yaml.js](scripts/lint-yaml.js) - YAML validation script

## Deployment

This site is automatically deployed to GitHub Pages when changes are pushed to the `master` branch.

## Features

- Jekyll 3.9.3
- GitHub Pages compatible
- Pagination (8 posts per page)
- RSS feed
- SEO optimized (jekyll-seo-tag)
- Sitemap generation
- Responsive design

## License

Copyright © Keith Richards. All rights reserved.
