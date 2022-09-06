---
title: "How Xcode Bamboozled Me"
date: 2022-09-01T16:49:22+02:00
tags: [Xcode, Apple, iOS, Python, Custom-script]
featured_image: ""
description: ""
slug: "how-xcode-bamboozled-me"
author:
  - Ömer Simsek
---

A common dilemma within the field of software development is traversing too deep within documentation to discover the solution to a bug.
This struggle can be represented and reflected in many aspects of life, however as developers we encounter this dilemma more often than not.
This post is about how I fell into this dilemma and got bamboozled by Apple's integrated development environment, Xcode.

It's ten o'clock in the morning and I've just configured and bumped the dependencies for my client's android application which they hadn't touched for over two years.
Everything looked decent and worked properly.
I was now ready to further develop their iOS application which also hadn't been developed on since early 2020. While trying to compile the application, an error message prompted from a custom script saying:

```Swift
Command PhaseScriptExecution failed with a nonzero exit code.
```

Reading this, my first instinct was to search this up on the browser.
I felt safe and relieved reading posts and threads about other developers who also had gotten the same error message thinking that this will be an easy fix.
Confidently I looked for possible solutions and made sure to take my time to understand what caused this error message before applying the solution.
This error message is shown when a dependecy is not updated and the most common solutions suggested:

- That you remove files such as Podfile.lock, the workspace file, and the Pod folder so that you reinstall them and do a clean folder build before compiling the application.
- That you should log in to your KeyChain and lock & unlock the login button, clean build the project, and then re-compile the application.
- To deintegrate the pod and pod files (the library dependency manager file and folder), to again later reinstall, clean the project via the command line, and then re-compile the application.

All articles, blog posts, and videos I found mentioned either the solutions above or similar solutions.
Everything I tried didn't show any progress during the compilation of the application.
I was at the edge of closing down my browser and sending a slack post for guidance until I decided to re-read a thread from Apple's developer page.
There I read from a user who said:

```log
It seems like you have a Build Run Script in your Build Phases
that is failing. You might want to look at the build logs to see what is happening.
```

It was right there I realized that I did not only go too deep for a solution but I also got bamboozled by Xcode. The issue was never in the library dependency manager or using KeyChain access.
I was literally focusing on the main error message `Command PhaseScriptExecution failed with a nonzero exit code.` rather then **looking closely** at the rest of the log.
While looking at the rest of the log I found something really interesting:

```log
AttributeError: 'dict' object has no attribute 'iteritems'
dict_items object has no attribute 'sort'
```

```log
AttributeError: 'dict' object has no attribute 'sort'
```

If you're not a python enthusiast this won't say much other than that there is no method `iteritems()` and `sort()`, and as someone that has done some python coding, `iteritems()` and `sort()` are methods existing in python 2 but has been removed in python 3.
This meant that the script was using python 2 while Xcode was using python 3.
After a short research, numerous articles pointed out that Apple depricated python 2.7 for iOS development in early 2020 because python 2.7 was at its [end-cycle](https://www.hexnode.com/blogs/apple-removing-python-2-7-on-mac-what-does-this-mean-for-it-admins/).
Now it all makes sense!

To solve my issue, I changed `sort()` to the new corresponding method `sorted()` and same with `iteritems()` with `items()` on the custom script used during the compilation of my application.

## Key learnings:

- While debugging an error, don't hesitate to take a **good** look at your log. You never know what underlying issues you'll find.
- Don't be afraid of sending a slack message for help or asking your fellow colleagues.
