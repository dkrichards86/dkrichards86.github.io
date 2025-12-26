---
layout: default
---

<div class="box article">
    <div class="content-core">
        <h2>Archives by Tag</h2>
        <hr />
        <ul class="archive-list">
            {% assign tag_archives = site.archives | where: "type", "tag" %}
            {% assign tags_with_counts = "" | split: "" %}

            {% comment %}Build array with counts{% endcomment %}
            {% for archive in tag_archives %}
                {% assign count = archive.posts | size %}
                {% assign tag_data = archive | append: "|" | append: count %}
                {% assign tags_with_counts = tags_with_counts | push: tag_data %}
            {% endfor %}

            {% comment %}Sort by iterating from highest to lowest expected count{% endcomment %}
            {% for i in (0..50) reversed %}
                {% assign target_count = i %}
                {% for archive in tag_archives %}
                    {% assign count = archive.posts | size %}
                    {% if count == target_count %}
                        <li>
                            <a href="{{ archive.url | relative_url }}">{{ archive.title }}</a>
                            <span class="post-count">({{ count }} posts)</span>
                        </li>
                    {% endif %}
                {% endfor %}
            {% endfor %}
        </ul>
    </div>

</div>
