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

It's ten o'clock in the morning and I've just configurated and bumped the dependencies for my client's android application which they hadn't touched for over two years. Everything looked decent and worked properly and I was now ready for their iOS application which also hadn't been developed on since early 2020. While trying to compile the application, an error message prompted saying:

```Swift
Command PhaseScriptExecution failed with a nonzero exit code.
```

Reading this, my first instinct was to search this up on the good old browser. I felt safe and relieved reading posts and threads about other developers who also had gotten the same error message thinking that this will be an easy fix. Confidently I looked for possible solutions and made sure to take my time to understand what caused this error message before applying the solution. The most common solution:

- Suggests that you remove files such as Podfile.lock, the workspace file, and the Pod folder so that you reinstall them and do a clean folder build before compiling the application.
- The next most common answer was that you should log in to your KeyChain and lock & unlock the login button, clean build the project and then re-compile the application.
- Another solution was to deintegrate the pod and pod files (the library dependency manager file and folder), to again later reinstall, clean the project via the command line, and re-compile the application.

All articles, blog posts, and videos I found mentioned either the solutions above or similar solutions. Each and everything I tried didn't show any progress during the compilation of the application. I was at the edge of closing down my browser and sending a slack post for guidance up until I decided to re-read a thread from Apple's developer page. There I read from a user who said:

```log
It seems like you have a Build Run Script in your Build Phases
that is failing. You might want to look at the build logs to see what is happening.
```

It was right there I realized that I did not only go too deep for a solution but I also got bamboozled by Xcode. The issue was never in the library dependency manager or using KeyChain access, rather **looking closely** at the log, I found something really interesting:

```log
AttributeError: 'dict' object has no attribute 'iteritems'
dict_items object has no attribute 'sort'
```

```log
AttributeError: 'dict' object has no attribute 'sort'
```

If you're not a python enthusiast this won't say much rather than that there is no method `iteritems()` and `sort()`, and as someone that has done some python coding, `iteritems()` and `sort()` are methods from python 2. This meant that Xcode right now was using python 3. After a short research, numerous articles pointed out that Apple upgraded to python 3 in early 2020 because python 2.7 was at its end-cycle. Now it all makes sense!

To solve my issue, I changed `sort()`to the new corresponding method`sorted()` and same with `ìteritems()` with `items()` on the custom script used during the compilation of my application.

## Key learnings:

- While debugging an error, don't hesitate to take a **good** look at your log. You never know what underlying issues you'll find.
- Don't be afraid of sending a slack message for help or asking your fellow colleagues.
