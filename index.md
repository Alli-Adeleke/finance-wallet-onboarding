---
layout: default
title: Finance Wallet Codex — Unified Console
---

# 🛡️ Finance Wallet Codex — Unified Console

Welcome to the sovereign control deck.  
Switch between the **Public Codex** and the **Admin Console** without leaving the page.

![First Crest](../assets/impact-crests/first-crest.svg)

<div class="master-tabs">
  <ul class="master-tab-links">
    <li class="active"><a href="#public-codex">🌐 Public Codex</a></li>
    <li><a href="#admin-console">🛡️ Admin Console</a></li>
  </ul>

  <div class="master-tab-content">
    <!-- Public Codex Panel -->
    <div id="public-codex" class="master-tab active">
      <div class="tabs">
        <ul class="tab-links">
          {% for section in site.data.navigation.main %}
            {% unless section.title == "Admin Console" %}
              <li{% if forloop.first %} class="active"{% endif %}>
                <a href="#pub-tab{{ forloop.index }}">{{ section.title }}</a>
              </li>
            {% endunless %}
          {% endfor %}
        </ul>
        <div class="tab-content">
          {% for section in site.data.navigation.main %}
            {% unless section.title == "Admin Console" %}
              <div id="pub-tab{{ forloop.index }}" class="tab{% if forloop.first %} active{% endif %}">
                {% if section.children %}
                  <ul>
                    {% for item in section.children %}
                      <li><a href="{{ item.url }}">{{ item.title }}</a></li>
                    {% endfor %}
                  </ul>
                {% else %}
                  <p>No items in this section.</p>
                {% endif %}
              </div>
            {% endunless %}
          {% endfor %}
        </div>
      </div>
    </div>

    <!-- Admin Console Panel -->
    <div id="admin-console" class="master-tab">
      <div class="tabs">
        <ul class="tab-links">
          <li class="active"><a href="#admin-tab1">📊 Repo Health</a></li>
          <li><a href="#admin-tab2">🖼 Crest Management</a></li>
          <li><a href="#admin-tab3">📜 Codex Controls</a></li>
          <li><a href="#admin-tab4">⚙️ Workflow Console</a></li>
          <li><a href="#admin-tab5">📄 Deploy Logs</a></li>
        </ul>
        <div class="tab-content">
          <div id="admin-tab1" class="tab active">
            <h3>📊 Repo Health & Lineage</h3>
            <ul>
              <li><strong>Current branch:</strong> main</li>
              <li><strong>Last commit:</strong> {{ site.time | date: "%Y-%m-%d %H:%M:%S UTC" }}</li>
              <li><strong>Total commits:</strong> {{ site.github.public_repositories }}</li>
              <li><strong>Stars:</strong> {{ site.github.stargazers_count }}</li>
              <li><strong>Forks:</strong> {{ site.github.forks_count }}</li>
              <li><strong>Open issues:</strong> {{ site.github.open_issues_count }}</li>
            </ul>
          </div>
          <div id="admin-tab2" class="tab">
            <h3>🖼 Crest Management</h3>
            <p><a href="../assets/impact-crests/">View all crests</a></p>
          </div>
          <div id="admin-tab3" class="tab">
            <h3>📜 Codex Index Controls</h3>
            <p><a href="../codex-index.md">Regenerate Codex Index</a></p>
          </div>
          <div id="admin-tab4" class="tab">
            <h3>⚙️ Workflow Console</h3>
            <ul>
              <li><a href="https://github.com/Alli-Adeleke/finance-wallet-onboarding/actions">