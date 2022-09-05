---
title: "How Xcode Bamboozled Me"
date: 2022-09-01T16:49:22+02:00
tags: []
featured_image: ""
description: ""
slug: "how-xcode-bamboozled-me"
author:
  - Devie Deviesson
---

A common dilemma within the field of software development is traversing too deep within documentation to discover the solution to a bug. This struggle can be represented and reflected in many aspects of life, however as developers we encounter this dilemma more often than not. This article is about how I fell into this dilemma and got bamboozled by Apple's integrated development environment, Xcode.

It's ten o'clock in the morning and I've just configurated and bumped the dependencies for my client's android application which they hadn't touched for over two years. Everything looked decent and working properly and now I was ready for their iOS application which also had been laying since early 2020. While trying to compile the application, an error message prompted saying:

```Swift
Command PhaseScriptExecution failed with a nonzero exit code.
```

Reading this, my first instinct was to search this up on the good old browser. I felt safe and relieved reading posts and threads about other developers who also had gotten the same error message thinking that this will be an easy fix. Confidently I looked for possible solutions and made sure to take my time to understand what caused this error message before applying the solution. The most common solution:

- Suggests that you remove files such as Podfile.lock, the workspace file, and the Pod folder so that you reinstall them and do a clean folder build before compiling the application.
- The next most common answer was that you should log in to your KeyChain and lock & unlock the login button, clean build the project and then re-compile the application.
- Another solution was to make deintegrate my pod and pod files (library dependency manager file and folder), to again later reinstall, clean the project via the command line, and re-compile the application.
