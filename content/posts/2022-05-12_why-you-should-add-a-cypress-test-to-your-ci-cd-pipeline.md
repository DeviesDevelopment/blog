---
title: "Why you should add a cypress test to your CI/CD pipeline"
date: 2022-05-12T08:29:15+02:00
tags: [ E2E test, Cypress, CI, CD ]
featured_image: ""
description: ""
slug: "why-you-should-add-a-cypress-test-to-your-ci-cd-pipeline"
author:
 - Rickard Andersson
---
Cypress is a framework for testing web applications, primarily used for end-to-end testing. In an end-to-end test you test your application as a whole just as a real user would, by interacting with GUI components, without any mocked components.

A simple cypress test is quick to write, and 
Since you test your application as a whole, you can test a lot of code with very few lines of test code.

Note that end-to-end tests does not in any way replace other forms of testing, such as unit testing and integration testing. You should strive for discovering bugs as early as possible, your end-to-end tests is your last "safety net"