---
layout: default
title: Finance Wallet Codex GUI
---

# 🛡️ Finance Wallet Codex — Operational Dashboard

Welcome to the sovereign GUI for the entire codebase.  
Select a crest or module to explore its lineage.

![First Crest](../assets/impact-crests/first-crest.svg)

## 📂 Navigation by Ceremonial Phase
{% for section in site.data.navigation.main %}
### {{ section.title }}
{% if section.children %}
{% for item in section.children %}
- [{{ item.title }}]({{ item.url }})
{% endfor %}
{% endif %}
{% endfor %}
