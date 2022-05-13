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
Cypress is a framework for testing web applications, primarily used for end-to-end testing. In an end-to-end test you test your application as a whole just as a real user would, by interacting with GUI components, without any mocked components. The goal for this post is to convince you that you should add a single simple cypress test to your CI/CD pipeline.

---

With end-to-end tests you can test a lot of aspects of your application with very little test code. Below is basically the simplest test you can write with Cypress.

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

By running a test like this in your pipeline, you know that critical issues (such as not being able to communicate with your backend) will never reach production.

The downside of end to end tests is that they are slow to run, and may be expensive to maintain (depending on how much changes that are introduced to your frontend). For these reasons, you should not strive for "full coverage" in your end-to-end test suite. Stick with the most important user flows without obscure edge cases. The majority of your testing should be performed on a lower level, such as unit tests and integration tests. Your end-to-end test suite is your last "safety net".
