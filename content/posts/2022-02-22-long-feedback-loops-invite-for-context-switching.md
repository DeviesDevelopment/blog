---
title: "Long feedback loops invite for context switching"
date: "2022-02-22T10:08:32+02:00"
tags:
  - Mindset
author:
  - Fredrik Mile
---
As a backend developer, there is especially one thing that I’m jealous of when it comes to frontend development. The short feedback loop, namely, the time and effort it takes to get feedback for your changes. Enable hot or live reloading while developing, and the results of your changes will be in front of you instantly, which is super nice. This is how it should be, even when you are developing the backend, infrastructure, CI/CD, or whatever. A long feedback loop can have a lot of hidden consequences, and it makes you ineffective. You and your team should spend time making sure that your feedback loop is short, and kept short.

Let’s say that your current task is to implement a new feature. The development goes smoothly, and you have added a few new unit tests to your test suite to cover the new code. You run the whole test suite to verify that you haven’t destroyed anything else. Running the tests suite takes around 20 minutes, meaning that you have 20 minutes to do something else, maybe you check Twitter, or maybe you start looking in the backlog to figure out what to do next.

...

It is now 20 minutes later, and you have run all the tests in the tests suite. All tests pass except for one, the last one, and you have no idea why because, during the last 20 minutes, you have scrolled Twitter and thought about why the opposite sides of a die will always add up to seven. You spend the next hour trying to fix the broken test, just to remember that during the implementation of the new feature, you changed the timestamp in the response body from local time to UNIX time, which caused the test to fail. Regardless of what you do during the 20 minutes while your tests are running, you will do a context switch, which hurts your productivity and effectiveness. Here are a few blogs about the consequences of context switching; *[Context Switching Is Hurting Your Productivity and Brain Health. Here’s What You Can Do About It](https://blog.pleexy.com/context-switching-is-hurting-your-productivity-and-brain-health-heres-what-you-can-do-about-it-5bdcebd1fd42), [Context switching: Why jumping between tasks is killing your productivity (and what you can do about it)](https://blog.rescuetime.com/context-switching/)* and *[How Context Switching Sabotages Your Productivity](https://blog.doist.com/context-switching/).* 

## Do we have long feedback loops?

Here follows a few warning signs that you and your team face too long feedback loops in your daily work:

- *“I can start this thing while I attend my next meeting and let it run in the background. We can check the result after the meeting, hopefully it is done by then!”.*
- *“F\*ck! I forgot to remove one white space at the end of this line! I’ll just remove it, and ```run git add .``` , `git commit -m “linting...”` and `git push` so all CI/CD checks can run AGAIN.”*
- *“Trust me, we should only need to set this up once, there is no need for automation here! Once it is set up, we can verify that everything works.”*
- “*I wish I could run this locally...”*

I’m not saying that long feedback loops are something that someone can just get rid of. Most often, they are long because of reasons. But, teams should be aware of the long feedback loops and treat them as technical debts. In the same way that teams work on technical debts from time to time, teams should also work on their feedback loops.

## Some tips on how to shorten the feedback loop

- **TDD** (Test Driven Development) Run the new tests and instantly get feedback regarding your changes. Set up the possibility to achieve feedback for your changes before implementing the changes.
- **Order matter!** The order in which the steps in your CI/CD pipeline matter. Place the small and fast steps in the beginning. For instance, you don’t want to build your whole project for 10 minutes and then fail the CI/CD pipeline because the style checker complains about a missing white space on row 12. Have a look at commit hooks for automatically running linters and style checkers locally before pushing a commit, Python example [here](https://ljvmiranda921.github.io/notebook/2018/06/21/precommits-using-black-and-flake8/).
- **Containerization** Simplifies the local development environment. Configurations and accesses need to be defined once. The difference between running locally and in production will be decreased.
- **Again, threat long feedback loops as technical debt.** Keep track of the duration of your feedback loops over time. Maybe you can identify a particular change that increased the feedback loop? Was that increase necessary? Can you fix it?
