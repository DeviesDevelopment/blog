---
title: "Learnings From Pragmatic Programmer"
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
Two of the topics discussed in the book are tracer bullets and prototypes.
The concepts are similar but addresses different problems.
A prototype is a cheap way to try out an idea, to answer questions about something unknown.
Details that are not required to answer the question are left out in favor of quick feedback at low cost.

Tracer bullets on the other hand is a tool to find out that an end-to-end solution is feasible.
The metaphor relates to [tracer ammunition](https://en.wikipedia.org/wiki/Tracer_ammunition), which enables visual inspection of the trajectory of a bullet, even in the dark.
Real-time feedback under actual conditions.
In the context of a software project, the target is a final system which provides value.
The path to the target is often full of unknowns, and we might not have any idea of where to aim.
Your bullet (preferably a small but important feature) is fired under actual conditions (such as frontend, backend, persistence, testing, error handling).
You develop a skeleton, or a framework, which you can easily adjust and extend with additional features.
Code is not written in isolation, and it's not disposable.
If you miss the target - Learn, adjust and evaluate.

It's important that both team and stakeholders are aligned in what's being developed.
Are we building something quick and dirty to see if an idea flies, or are we building a working system with a limited set of features?
The answer to that quesion will probably impact both how you prioritize and how you implement features.

# Purpose of testing
It is a common conception that the purpose of tests is to find bugs, to make sure that code works as intended.
In the book, it's stated that this is not the case - Instead, the benefits of tests occur while thinking about tests, and when you write them,.
It's a tool to get rapid feedback about aspects of your code, e.g. clarity of the public API and coupling to other components.
Testing drives good software design.
In addition, a mature test suite will make your life way easier while refactoring.

In some projects, it may be argued that there's no time to write tests because feature development needs to be prioritized.
If we accept the fact that testing drives good design, and that good design makes us deliver faster in the long run; you should find a way to write tests anyway, preferably in parallel with the feature development.
[Friday Facts #366 - The only way to go fast, is to go well!](https://factorio.com/blog/post/fff-366) is a nice blog post about the relationship between software design and delivery speed.

# Easy to change
As software developers, we often find ourselves working on projects that require frequent updates and changes.
Whether it's adding new features, fixing bugs, or adapting to changing requirements, the ability to make changes to our codebase quickly and easily is critical.
That's where the concept of an "Easy to Change" (ETC) mindset comes in.

The ETC mindset is all about designing software systems that are easy to modify and adapt as needed. This involves writing clean, readable, and well-structured coded while
keeping an open mind to new technologies and approaches that can make our systems more flexible and adaptable.

As you implement a new feature, consider the long-term maintainability of your code. How easy or difficult would it be to adapt this feature to new requirements in the future? Will you need to make changes in multiple files, or can you make the necessary updates in just one file? Always think ETC. 

# Broken Window
The "Broken Window" theory was introduced by James Q. Wilson and George L. Kelling in their article "Broken Windows" fron 1982.
They argued that small signs of disorder and neglect in a neighborhood, such as broken windows or graffiti, can lead to more serious crime and social problems.
The main idea is that if a broken window is left unrepaired, it sends a message that no one cares about the area.

In the context of software development, the "Broken Window" theory can be applied to the idea that small problems in our code can have a similar cascading effect. 
If we allow small issues, such as code that is difficult to read or maintain, to go unaddressed, it can lead to larger problems in the future.
These larger problems can include increased difficulty in making changes to the code, a higher risk of introducing bugs, and decreased overall quality and reliability of the code.

There is really only one defense against the consequences of broken windows, and that is to fix the broken windows as soon as they are identified.
