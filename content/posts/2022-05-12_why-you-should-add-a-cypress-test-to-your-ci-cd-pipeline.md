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
Cypress is a framework for testing web applications, primarily used for end-to-end testing. In an end-to-end test you test your application as a whole just as a real user would, by interacting with GUI components, without any mocked components. The goal of this post is to convince you to add a single simple cypress test to your CI/CD pipeline.

---

With end-to-end tests you can test a lot of aspects of your application with very little test code. Below is basically the simplest test you can write with cypress.

```javascript
it('should load main page', () => {
    cy.visit('/');
})
```

If a test like above passes while running in your CI/CD pipeline, you know that: (1) Your web server is up and running; (2) A successful HTTP status is returned when navigating to your main page; (3) There hasn't been any uncaught exceptions once the main page has loaded.

If you extend the test a little bit more, you can even know that communication with your backend is working. Let's say you have a web page showing a list of recipes, where the recipes are loaded from an API endpoint.

```javascript
it('should load list of recipes', () => {
    cy.visit('/');
    cy.get('[test-id="recipe-list"]')
        .should('be.visible');
})
```

By running a test like this in your CI/CD pipeline, you know that some critical issues, such as not being able to communicate with your backend at all, will never reach production. That's great!

There are a couple of downsides with end to end tests though. First, compared to other forms of tests they run really slow. Second, the tests may be expensive to maintain. This of course depends on how much changes that are introduced to your frontend, and of how the tests are designed. Third, if the tests fail, it might be hard to figure out what causes the tests to fail. In unit tests, you know exactly what software unit that is failing (since that's the scope of your test). In end to end tests, you know that some assertion fails, but get little help in finding out why.

For above reasons, you should not strive for "full coverage" in your end-to-end test suite. Stick with the most important user flows, without any obscure edge cases. The majority of your testing should be performed at a lower level, such as unit tests and integration tests. Your end-to-end test suite is your last "safety net".

---

When you're about to add your new cypress test to your CI/CD pipeline, you'll probably ask yourself at what stage in the pipeline that you should run the test. I think there are two answers to that question: (1) As early as possible; (2) All of them.

By running the test as early as possible (preferably after a pull request has been opened), you get quick feedback and can prevent critical issues from entering the main branch in your codebase. However, there's no reason to stop there. You can repeat the test towards each environment (e.g. dev, qa, prod) that you deploy your application to. This will let you to discover if anything in your infrastructure is causing the application to fail, and hopefully prevent the change from reaching production.

---

It's really easy to get started and have a simple test running in your CI/CD pipeline. Even if the test is simple, it may prevent critical issues from affecting end users. Additionally, it gives you a solid foundation from which you can extend the test suite with more important user flows. This (cheap) investment is worth it, really. If you want to get started with cypress, check out the [official documentation](https://docs.cypress.io/guides/getting-started/installing-cypress). Thanks for reading!
