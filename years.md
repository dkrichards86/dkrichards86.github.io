---
layout: default
---

<div class="box article">
    <div class="content-core">
        <h2>Archives by Year</h2>
        <hr />
        <ul class="archive-list">
            {% for archive in site.archives %}
                {% if archive.type == "year" %}
                    <li>
                        <a href="{{ archive.url | relative_url }}">{{ archive.date | date: "%Y" }}</a>
                        <span class="post-count">({{ archive.posts | size }} posts)</span>
                    </li>
                {% endif %}
            {% endfor %}
        </ul>
    </div>
</div>
