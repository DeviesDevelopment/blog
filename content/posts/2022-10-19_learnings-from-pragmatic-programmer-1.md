---
title: "Learnings From Pragmatic Programmer (Part 1)"
date: 2022-10-19T12:44:05+02:00
tags: []
featured_image: ""
description: ""
slug: "learnings-from-pragmatic-programmer-1"
author:
 - Fredrik Mile
 - Jonathan Rhodin
 - Marcus Stigelid
 - Rickard Andersson
 - Simon Nielsen
---

At Devies we run a book club where we on a weekly basis discuss topics from a book that we are reading in a common pace.
Recently we finished [The Pragmatic Programmer, 20th Anniversary Edition](https://pragprog.com/titles/tpp20/the-pragmatic-programmer-20th-anniversary-edition/).
In this post, we'll share learnings around some of the topics we have discussed.

# Tracer bullets vs Prototypes
Two topics discussed in the book are tracler bullets and prototypes.
A prototype is a cheap way to try out an idea, to answer questions about something unknown.
Details that are not required to answer the question are left out in favor of quick feedback at low cost.
Tracer bullets on the other hand is a tool to find out that an end-to-end solution is feasible.
The metaphor relates to [tracer ammunition](https://en.wikipedia.org/wiki/Tracer_ammunition), which enables visual inspection of the trajectory of a bullet, even in the dark.
Real-time feedback under actual conditions.
In the context of a software project, the target is a final system which provides value.
The path to the target is often full of unknowns, and we might not have any idea of where to aim.
Your bullet (preferably a small but important feature) is fired under actual conditions (such as frontend, backend, persistence, testing, error handling).
Code is not written in isolation, and it's not disposable.
If you miss the target - Learn, adjust and evaluate.

It's important that both team and stakeholders are aligned in what's being developed.
Are we building something quick and dirty to see if an idea flies, or are we building a working system with a limited set of features?
