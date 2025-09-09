---
layout: default
title: Finance Wallet Codex GUI
---

# 🛡️ Finance Wallet Codex — GUI Navigation

Welcome to the sovereign GUI for the entire codebase.  
Select a crest or module to explore its lineage.

![First Crest](../assets/impact-crests/first-crest.svg)

## 📂 Navigation
{% for item in site.data.navigation.main %}
- [{{ item.title }}]({{ item.url }})
{% endfor %}
