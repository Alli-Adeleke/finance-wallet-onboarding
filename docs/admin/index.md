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
        <li><strong>Last commit (local):</strong> %Y->- (grafted, HEAD -> main, origin/main) 58dffa0984fa66c6bf2ec79f1698bf2d4d17e60a:%M:HEAD UTC</li>
        <li><strong>Total commits (local):</strong> 1</li>
        <li><strong>Stars (live):</strong> 0</li>
        <li><strong>Forks (live):</strong> 0</li>
        <li><strong>Open issues (live):</strong> 2</li>
        <li><strong>Last push (live):</strong> 2025-09-11T20:51:44Z</li>
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
        <li><a href="https://github.com/Alli-Adeleke/finance-wallet-onboarding/actions">View Actions</a></li>
        <li><a href="https://github.com/Alli-Adeleke/finance-wallet-onboarding/actions/workflows/pages.yml">Trigger Pages Deploy</a></li>
      </ul>
    </div>
    <div id="admin-tab5" class="tab">
      <h3>📄 Pages Deploy Log</h3>
      <p><a href="https://github.com/Alli-Adeleke/finance-wallet-onboarding/actions/workflows/pages.yml">Latest Deploy Logs</a></p>
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
