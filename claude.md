# Claude Code Guide

This document provides guidance for working with this Jekyll blog repository using Claude Code.

## Project Overview

This is a Jekyll-based static site for dkrichards.com, built with:

- Jekyll 3.9.3 (GitHub Pages compatible)
- Ruby 3.1.4 (via rbenv)
- Node.js tooling for linters
- Pagination, RSS, SEO optimization

## Common Tasks

### Starting Development

```bash
bundle exec jekyll serve
```

The site runs at `http://localhost:4000` with auto-regeneration enabled.

### Creating a New Blog Post

1. Create a file in `_posts/` with format: `YYYY-MM-DD-title-slug.md`
2. Add front matter:

   ```yaml
   ---
   layout: post
   title: "Post Title"
   date: YYYY-MM-DD HH:MM:SS -0500
   categories: [category1, category2]
   ---
   ```

3. Write content in Markdown
4. Preview at `http://localhost:4000`

### Running Linters

```bash
npm run lint              # All linters
npm run lint:markdown     # Markdown only
npm run lint:html         # HTML only
npm run lint:yaml         # YAML only
```

### Building CSS

```bash
npm run build:css         # Build and compress Sass to CSS
```

The CSS is built using Dart Sass 2.0 and outputs to `assets/css/bundle.css`.

## Project Structure

```text
.
├── _config.yml           # Jekyll configuration
├── _includes/            # Reusable components
├── _layouts/             # Page templates
├── _posts/               # Blog posts (YYYY-MM-DD-title.md)
├── _drafts/              # Unpublished drafts
├── _sass/                # Sass stylesheets (Dart Sass 2.0)
│   ├── style.scss        # Main entry (uses @forward)
│   └── partials/
│       ├── _variables.scss      # Variables, mixins, color module
│       ├── _reset.scss          # CSS reset
│       ├── _layout.scss         # Layout & typography
│       ├── _header.scss         # Header & navigation
│       ├── _nav.scss            # Navigation styles
│       ├── _content.scss        # Content containers
│       └── _syntax-highlighting.scss  # Code syntax styles
├── assets/               # Images, CSS, JS
├── index.html            # Homepage
├── 404.html              # Error page
└── vendor/bundle/        # Ruby gems (git-ignored)
```

## Key Configuration

### Jekyll Config (\_config.yml)

- **Pagination**: 8 posts per page
- **Timezone**: America/New_York
- **Markdown**: Kramdown with GFM
- **Plugins**: feed, sitemap, seo-tag, paginate

### Linter Configs

- **Markdown**: `.markdownlint.json` - relaxed rules for blog content
- **HTML**: `.htmlhintrc` - allows Jekyll templates
- **YAML**: `scripts/lint-yaml.js` - validates syntax

## Dependencies

### Ruby (via rbenv)

```bash
bundle install            # Install gems
bundle update             # Update gems
bundle exec jekyll ...    # Run Jekyll commands
```

### Node.js (for linters)

```bash
npm install               # Install packages
npm update                # Update packages
```

## Git Workflow

### Ignored Files

- `_site/` - Built site
- `vendor/bundle/` - Ruby gems
- `node_modules/` - Node packages
- `.bundle/`, `.sass-cache/`, `.jekyll-metadata`

### Deployment

Changes pushed to `master` branch auto-deploy to GitHub Pages.

## Helpful Commands

### Jekyll

```bash
# Build site
bundle exec jekyll build

# Serve with drafts
bundle exec jekyll serve --drafts

# Serve on specific port
bundle exec jekyll serve --port 4001

# Build for production
JEKYLL_ENV=production bundle exec jekyll build
```

### Content Management

```bash
# Find all posts
ls -l _posts/

# Search post content
grep -r "search term" _posts/

# Count posts
ls -1 _posts/*.md | wc -l
```

## Sass/CSS Architecture

This project uses **Dart Sass 2.0** with the modern module system:

### Key Concepts

- **Main file**: `_sass/style.scss` uses `@forward` to re-export all partials
- **Variables**: Centralized in `_sass/partials/_variables.scss`
- **Module imports**: Each partial uses `@use "variables" as *;` to access variables
- **Color functions**: Uses `color.scale()` instead of deprecated `lighten()`/`darken()`

### Sass Structure

```scss
// _sass/style.scss
@forward "partials/variables"; // Must be first
@forward "partials/reset";
// ... other partials

// _sass/partials/_variables.scss
@use "sass:color"; // Import color module
$primary-color: #34495e;
$grey-color-light: color.scale($grey-color, $lightness: 40%);

// Other partials
@use "variables" as *; // Import variables into global namespace
```

### Important Rules

1. `@forward` and `@use` **must** appear before any other code
2. Variables and mixins are in `_variables.scss`, not `style.scss`
3. Use `color.scale()` for color manipulation, not `lighten()`/`darken()`
4. Build with `npm run build:css` to test Sass compilation

## Common Issues

### Ruby Version Mismatch

Ensure rbenv is initialized in your shell:

```bash
eval "$(rbenv init - zsh)"
```

Or add to `~/.zshrc`:

```bash
command -v rbenv 1>/dev/null 2>&1 && eval "$(rbenv init - zsh)"
```

### Bundle Install Fails

Set local bundle path:

```bash
bundle config set --local path 'vendor/bundle'
bundle install
```

### Jekyll Server Not Updating

Clear cache and restart:

```bash
bundle exec jekyll clean
bundle exec jekyll serve
```

### Sass Compilation Errors

If you get Dart Sass 2.0 errors:

1. Ensure `@use`/`@forward` are at the top of files
2. Use `color.scale()` instead of `lighten()`/`darken()`
3. Test with `npm run build:css` before running Jekyll

## Writing Tips

### Front Matter Variables

- `layout`: post, default
- `title`: Post title (required)
- `date`: Publication date (required)
- `categories`: Array of categories
- `image`: Override default social image
- Custom variables available in templates

### Markdown Features

- **Code blocks**: Use triple backticks with language
- **Tables**: GFM-style tables supported
- **Footnotes**: Kramdown syntax `[^1]`
- **Inline HTML**: Allowed for complex formatting
- **Liquid tags**: Jekyll template language
- **Image styling**: Use `{:class="img-embedded float-left"}` or `float-right` for styled images

Example:

```markdown
![Alt text](/path/to/image.png){:class="img-embedded float-right"}
```

### Draft Posts

1. Create in `_drafts/` without a date in the filename (e.g., `my-draft.md`)
2. Preview with `--drafts` flag: `bundle exec jekyll serve --drafts`
3. Move to `_posts/` with a date when ready to publish

## SEO & Metadata

The site uses `jekyll-seo-tag` plugin:

- Title, description from `_config.yml`
- Per-post overrides via front matter
- Social media meta tags
- Structured data (JSON-LD)

## Performance Notes

- Images in `assets/images/` should be optimized
- Sass compiled to CSS automatically
- GitHub Pages serves with CDN
- RSS feed auto-generated at `/feed.xml`

## Claude Code Workflows

### Suggested Prompts

- "Create a new blog post about [topic]"
- "Fix linting errors in [file]"
- "Update the homepage layout"
- "Add a new feature to [component]"
- "Optimize images in assets/"
- "Review and improve SEO tags"

### Best Practices

1. Run linters before committing
2. Test locally before pushing
3. Check responsive design
4. Validate YAML front matter
5. Preview posts with `--drafts` first

## Resources

- [Jekyll Documentation](https://jekyllrb.com/docs/)
- [GitHub Pages Docs](https://docs.github.com/en/pages)
- [Kramdown Syntax](https://kramdown.gettalong.org/syntax.html)
- [Liquid Templates](https://shopify.github.io/liquid/)
