---
title: "Better Terminal Experience for Git and Kubernetes"
date: 2022-05-11T21:04:31+02:00
tags: [terminal, git, kubernetes]
featured_image: ""
description: "A Tip for Improving the Terminal Experience When Working With Git and Kubernetes"
author:
  - Fredrik Mile
slug: "a-tip-for-improving-the-terminal-experience-when-working-with-git-and-kubernetes"
---

When working on a project that uses **git**, it is essential to checkout the correct branch. You don't want to realize after a few hours of work that you worked on the wrong branch and have a few messy merges and rebases in front of you. Of course, the easiest way to show the current branch is to run `git status` but that requires an action from you, Instead, I recommend you to include the git branch as part of your prompt string. The prompt string is the string that marks your command line and is set by the shell variable `PS1`. 

You could configure the shell variable `PS1` yourself, but it is much simpler to use the `zsh` terminal and an appropriate theme. [Instructions for installing zsh](https://github.com/ohmyzsh/ohmyzsh/wiki/Installing-ZSH) and [here is a list of zsh themes](https://zshthem.es/all/).

---

When working on a project that uses **Kubernetes**, it is essential to be connected to the correct cluster and namespace. For instance, if you have one cluster per environment (qa/dev/prod), you want to be certain that you currently manage the correct cluster. You don't want to "try" a thing in the prod cluster, that's for qa!

Similarly, as we could include the current git branch in the command string, we can include the current Kubernetes cluster and namespace. 

Have a look at [kube-ps1](https://github.com/jonmosco/kube-ps1) to get started. 

---

Here is an example of how it could look when showing Kubernetes and git info as part of the terminal string.

In this example, we are working on the `new-cool-feature` branch, we are connected to the `aks-qa` cluster and the `backend` namespace.

![Here is an example of how it could look](https://user-images.githubusercontent.com/8545435/167999888-ed3054ec-ef44-4dab-8637-fcd026a316fa.png)
