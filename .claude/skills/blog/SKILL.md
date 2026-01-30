---
name: blog
description: Create a researched Jekyll blog post that matches the blog's voice and style. Use when the user wants to write a new blog post.
argument-hint: "[topic]"
---

# Blog Post Creator

Create a researched Jekyll blog post that matches the blog's voice and style.

## Workflow

1. **Ask for post topic and clarify** (ALWAYS DO THIS):
   - Ask: "What topic do you want to write about?"
   - Wait for the user's response (free-form text input)
   - Then ask clarifying questions:
     - What specific angle or aspect should the post focus on?
     - Are there particular points or concepts that must be covered?
     - Who is the target audience? (beginners, intermediate, experts?)
     - Any examples or scenarios you want included?
     - What problem is the reader trying to solve?
     - What publish date? (default: today, or specify a date like "2026-02-15")
   - Use regular text conversation, not AskUserQuestion tool
   - Don't skip clarifying questions - better understanding leads to better posts

2. **Research the topic**:
   - Use WebSearch to gather 2026-relevant information about the topic
   - Look for technical details, best practices, and real-world examples
   - Identify key concepts, trade-offs, and practical applications
   - Focus on actionable information, not just theory

3. **Analyze existing voice**:
   - Read 2-3 recent posts from `_posts/2026/` to understand the writing style
   - Note the tone, structure, paragraph length, and how examples are used
   - Key characteristics to match:
     - Direct, conversational tone using "you"
     - Starts with relatable problem or question
     - Short paragraphs (2-4 sentences typically)
     - Technical but accessible explanations
     - Real-world examples and scenarios
     - Honest about trade-offs and limitations
     - Personal experience woven in naturally
     - Strong section headers that tell a story

4. **Generate filename**:
   - Format: `YYYY/YYYY-MM-DD-title-slug.md`
   - Use the publish date from step 1 (default: today)
   - Slugify the title (lowercase, hyphens, no special chars)
   - Example: `2026/2026-02-15-understanding-redis-persistence.md`

5. **Write the post content**:
   - Opening: Start with a relatable problem, question, or observation (2-3 paragraphs)
   - Structure: Use clear H2 headers that guide the narrative
   - Style: Match the conversational but technical voice from existing posts
   - Content: Integrate researched information naturally
   - Examples: Include concrete scenarios and code where appropriate
   - Length: Aim for 800-1500 words (substantial but focused)
   - Conclusion: Tie back to main theme, acknowledge trade-offs

6. **Generate title dynamically**:
   - Create a title based on the post content
   - Check existing titles with `grep -h "^title:" _posts/**/*.md` for style reference
   - Title patterns that work well:
     - Short and punchy (2-5 words): "Caching Strategies", "DynamoDB Hot Partitions"
     - "Understanding X": "Understanding the Node.js Event Loop"
     - "How X works": "How One-Time Passwords work"
   - Keep it clear, specific, and searchable

7. **Generate tags dynamically**:
   - Analyze the post content to identify key topics and technologies
   - Run `grep -h "^tags:" _posts/**/*.md | sort | uniq -c | sort -rn` to see existing tag patterns
   - Choose 2-4 tags that:
     - Are lowercase, single words or hyphenated (e.g., "best-practices")
     - Match existing blog taxonomy when possible (reuse existing tags)
     - Cover the main technology/concept and broader category
   - Common tag patterns: [technology, category, theme] like [databases, dynamodb, performance]

8. **Create the post file** in `_posts/{year}/` with this front matter:

   ```yaml
   ---
   layout: post
   title: "Generated Title Here"
   description: >-
     One to two sentence summary of the post.
   tags: [generated, tags]
   ---
   ```

9. **Run linters automatically**:
    - Execute: `npm run lint:markdown`
    - Execute: `npm run lint:yaml`
    - If linting fails, fix issues and re-run
    - Don't report completion until linting passes

10. **Report completion**:
   - Show the file path as a clickable link
   - Briefly mention the researched topics covered
   - Confirm linting passed
   - Note that the post is ready for review and editing

## Critical Requirements

- Use Write tool to create the file (never use bash)
- Posts go in `_posts/{year}/` subdirectory, not `_posts/` root
- Use "tags" not "categories" in front matter
- Include "description" field in front matter (1-2 sentences)
- Match the conversational, practical voice from existing posts
- Integrate researched information naturally (don't just list facts)
- Write complete, substantial content (not just an outline)
- Ensure timezone is -0500 (America/New_York)
- Don't report completion until linting passes
