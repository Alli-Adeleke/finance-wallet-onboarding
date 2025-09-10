#!/usr/bin/env bash
set -euo pipefail

DOCS_DIR="docs"
NAV_FILE="$DOCS_DIR/_data/navigation.yml"
INDEX_FILE="$DOCS_DIR/index.md"
ADMIN_FILE="$DOCS_DIR/admin/index.md"

REPO="${REPO:-Alli-Adeleke/finance-wallet-onboarding}"
API_URL="https://api.github.com/repos/$REPO"

echo "🔧 Bootstrapping full Pages GUI + Admin Console (unified tabs) ..."

mkdir -p "$DOCS_DIR/_data" "$DOCS_DIR/admin" assets/impact-crests

# --- Live stats via GitHub API (if token available) ---
AUTH_ARGS=()
if [ -n "${GITHUB_TOKEN:-}" ]; then
  AUTH_ARGS=(-H "Authorization: token $GITHUB_TOKEN")
fi

REPO_JSON="$(curl -s "${AUTH_ARGS[@]}" "$API_URL" || echo "")"
OPEN_ISSUES="$(echo "$REPO_JSON" | grep -m1 '"open_issues_count":' | awk '{print $2}' | tr -d ',')"
STARS="$(echo "$REPO_JSON" | grep -m1 '"stargazers_count":' | awk '{print $2}' | tr -d ',')"
FORKS="$(echo "$REPO_JSON" | grep -m1 '"forks_count":' | awk '{print $2}' | tr -d ',')"
LAST_PUSH="$(echo "$REPO_JSON" | grep -m1 '"pushed_at":' | cut -d '"' -f4)"

OPEN_ISSUES="${OPEN_ISSUES:-N/A}"
STARS="${STARS:-N/A}"
FORKS="${FORKS:-N/A}"
LAST_PUSH="${LAST_PUSH:-N/A}"

# --- Navigation with ceremonial grouping + timestamps ---
echo "# Auto-generated navigation for Finance Wallet Onboarding™" > "$NAV_FILE"
echo "main:" >> "$NAV_FILE"

declare -A PHASES=(
  ["services"]="Services"
  ["apps"]="Applications"
  ["platform"]="Platform"
  ["docs"]="Documentation"
  ["scripts"]="Automation Scripts"
  ["assets"]="Assets & Crests"
  ["tools"]="Tools"
)

for dir in "${!PHASES[@]}"; do
  if [ -d "$dir" ]; then
    echo "  - title: \"${PHASES[$dir]}\"" >> "$NAV_FILE"
    echo "    children:" >> "$NAV_FILE"
    while IFS= read -r -d '' file; do
      rel_path="${file#./}"
      title="$(basename "$file")"
      last_updated="$(git log -1 --format="%Y-%m-%d" -- "$file" 2>/dev/null || echo "N/A")"
      echo "      - title: \"$title (updated $last_updated)\"" >> "$NAV_FILE"
      echo "        url: /$rel_path" >> "$NAV_FILE"
    done < <(find "$dir" -type f -print0 | sort -z)
  fi
done

# Admin link in nav (top-level)
echo "  - title: \"Admin Console\"" >> "$NAV_FILE"
echo "    url: /admin/index.html" >> "$NAV_FILE"

# --- Admin Console: tabbed with baked numbers ---
cat > "$ADMIN_FILE" <<EOF2
---
layout: default
title: Admin Console — Finance Wallet Codex
---

# 🛡️ Admin Console — Finance Wallet Codex

Welcome, Sovereign Operator.  
This console provides direct access to operational controls, crest management, and lineage oversight.

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
        <li><strong>Last commit (local):</strong> $(git log -1 --format="%Y-%m-%d %H:%M:%S UTC" || echo "N/A")</li>
        <li><strong>Total commits (local):</strong> $(git rev-list --count HEAD || echo "N/A")</li>
        <li><strong>Stars (live):</strong> $STARS</li>
        <li><strong>Forks (live):</strong> $FORKS</li>
        <li><strong>Open issues (live):</strong> $OPEN_ISSUES</li>
        <li><strong>Last push (live):</strong> $LAST_PUSH</li>
      </ul>
    </div>
    <div id="admin-tab2" class="tab">
      <h3>🖼 Crest Management</h3>
      <p><a href="../assets/impact-crests/">View all crests</a></p>
    </div>
    <div id="admin-tab3" class="tab">
      <h3>📜 Codex Index Controls</h3>
      <p><a href="../codex-index.md">Regenerate Codex Index</a> (auto-updates on push)</p>
    </div>
    <div id="admin-tab4" class="tab">
      <h3>⚙️ Workflow Console</h3>
      <ul>
        <li><a href="https://github.com/$REPO/actions">View Actions</a></li>
        <li><a href="https://github.com/$REPO/actions/workflows/pages.yml">Trigger Pages Deploy</a></li>
      </ul>
    </div>
    <div id="admin-tab5" class="tab">
      <h3>📄 Pages Deploy Log</h3>
      <p><a href="https://github.com/$REPO/actions/workflows/pages.yml">Latest Deploy Logs</a></p>
    </div>
  </div>
</div>

<style>
.tabs { margin-top: 15px; }
.tab-links { list-style: none; padding: 0; display: flex; flex-wrap: wrap; gap: 8px; border-bottom: 2px solid #ccc; }
.tab-links li { margin: 0; }
.tab-links a { display: block; padding: 8px 12px; background: #f4f4f4; color: #333; text-decoration: none; border-radius: 5px 5px 0 0; }
.tab-links li.active a { background: #0366d6; color: #fff; }
.tab-content .tab { display: none; padding: 15px; border: 1px solid #ccc; border-top: none; }
.tab-content .tab.active { display: block; }
</style>

<script>
document.addEventListener("DOMContentLoaded", function() {
  const tabs = document.querySelectorAll(".tab-links a");
  const contents = document.querySelectorAll(".tab");
  tabs.forEach(tab => {
    tab.addEventListener("click", function(e) {
      e.preventDefault();
      const target = this.getAttribute("href");
      tabs.forEach(t => t.parentElement.classList.remove("active"));
      contents.forEach(c => c.classList.remove("active"));
      this.parentElement.classList.add("active");
      document.querySelector(target).classList.add("active");
    });
  });
});
</script>
EOF2

# --- Unified index with master tabs (Public + Admin) ---
cat > "$INDEX_FILE" <<'EOF3'
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
            <p>See detailed stats in <a href="/admin/index.html">Admin Console</a>.</p>
          </div>
          <div id="admin-tab2" class="tab">
            <h3>🖼 Crest Management</h3>
            <p>Manage crests in <a href="/admin/index.html#admin-tab2">Admin Console</a>.</p>
          </div>
          <div id="admin-tab3" class="tab">
            <h3>📜 Codex Index Controls</h3>
            <p>Controls available in <a href="/admin/index.html#admin-tab3">Admin Console</a>.</p>
          </div>
          <div id="admin-tab4" class="tab">
            <h3>⚙️ Workflow Console</h3>
            <p>Triggers available in <a href="/admin/index.html#admin-tab4">Admin Console</a>.</p>
          </div>
          <div id="admin-tab5" class="tab">
            <h3>📄 Pages Deploy Log</h3>
            <p>Logs at <a href="/admin/index.html#admin-tab5">Admin Console</a>.</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>

<style>
.master-tabs { margin-top: 20px; }
.master-tab-links { list-style: none; padding: 0; display: flex; border-bottom: 3px solid #444; }
.master-tab-links li { margin-right: 10px; }
.master-tab-links a { display: block; padding: 10px 20px; background: #eee; color: #333; text-decoration: none; border-radius: 5px 5px 0 0; }
.master-tab-links li.active a { background: #0366d6; color: #fff; }
.master-tab-content .master-tab { display: none; }
.master-tab-content .master-tab.active { display: block; }

.tabs { margin-top: 15px; }
.tab-links { list-style: none; padding: 0; display: flex; flex-wrap: wrap; gap: 8px; border-bottom: 2px solid #ccc; }
.tab-links li { margin: 0; }
.tab-links a { display: block; padding: 8px 12px; background: #f4f4f4; color: #333; text-decoration: none; border-radius: 5px 5px 0 0; }
.tab-links li.active a { background: #0366d6; color: #fff; }
.tab-content .tab { display: none; padding: 15px; border: 1px solid #ccc; border-top: none; }
.tab-content .tab.active { display: block; }
</style>

<script>
document.addEventListener("DOMContentLoaded", function() {
  const masterTabs = document.querySelectorAll(".master-tab-links a");
  const masterContents = document.querySelectorAll(".master-tab");
  masterTabs.forEach(tab => {
    tab.addEventListener("click", function(e) {
      e.preventDefault();
      const target = this.getAttribute("href");
      masterTabs.forEach(t => t.parentElement.classList.remove("active"));
      masterContents.forEach(c => c.classList.remove("active"));
      this.parentElement.classList.add("active");
      document.querySelector(target).classList.add("active");
    });
  });

  document.querySelectorAll(".tabs").forEach(tabContainer => {
    const tabs = tabContainer.querySelectorAll(".tab-links a");
    const contents = tabContainer.querySelectorAll(".tab");
    tabs.forEach(tab => {
      tab.addEventListener("click", function(e) {
        e.preventDefault();
        const target = this.getAttribute("href");
        tabs.forEach(t => t.parentElement.classList.remove("active"));
        contents.forEach(c => c.classList.remove("active"));
        this.parentElement.classList.add("active");
        tabContainer.querySelector(target).classList.add("active");
      });
    });
  });
});
</script>
EOF3

echo "✅ Bootstrap generation complete."
