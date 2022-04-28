---
title: "Introducing Workflow Timer" 
date: "2022-04-28T10:08:32+02:00"
tags:
  - Actions
  - Announcements
slug: "introducing-workflow-timer"
author:
  - Fredrik Mile
  - Rikard Andersson
---

[Workflow-timer](https://github.com/DeviesDevelopment/workflow-timer) is a Github action that measures the duration of the workflow and compares it to historical runs.

The purpose of this action is to make the developer aware of when feedbacks loops get longer. Let's say that you are running unit tests as part of your current workflow. If merging your changes (your PR) would increase the time it takes to run the unit tests by 50%, your changes probably have unwanted side effects. It's about creating awareness for the developer.


Feel free to check out the [source code](https://github.com/DeviesDevelopment/workflow-timer) or view it on the [marketplace](https://github.com/marketplace/actions/workflow-timer).
