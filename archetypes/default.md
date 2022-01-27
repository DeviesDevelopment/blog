---
title: "{{ replace (index (split .File.ContentBaseName "_") 1) "-"  " " | title }}"
date: {{ .Date }}
tags: []
featured_image: ""
description: ""
slug: "{{ index (split .File.ContentBaseName "_") 1 }}"
---
