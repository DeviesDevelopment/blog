---
title: "How We Chose to Implement Our Design System With Web Components"
date: 2024-09-24T09:08:49+02:00
tags: ["web", "web components", "accessibility", "design system", "component library", "CSS", "Shadow DOM", "Lit", "Stencil"]
featured_image: ""
description: ""
slug: "how-we-chose-to-implement-our-design-system-with-web-components"
author:
 - Simon Nielsen
---

In case you missed my first post ["Implementing a design system"](/posts/implementing-a-design-system-choosing-a-way-forward), we chose to implement our design system with web components. This post will be about our thought process and the tradeoffs we considered when deciding on how we would implement with web components.

It is possible to write a web component using only native JavaScript and HTML, but it is challenging. It is much more common to use a library like Lit or Stencil. The library helps with registration of the web component and change management as well as interoperability with popular frameworks.
In our case, in addition to Lit and Stencil, we also considered Mitosis, and compiling to web components with Solid or Angular.

But to understand the tradeoffs of using Shadow DOM and the different approaches of Lit and Stencil we first need to go through some basics of web components.

## Web components

Web components or custom elements can be created with or without the use of the Shadow DOM. The Shadow DOM is a tree of elements that is rendered separately from the rest of the DOM (which is sometimes referred to as the light DOM). This means contents of the elements can be scripted and styled without fear of colliding with other things in the document. For example, a CSS selector for all paragraphs outside the Shadow DOM will not affect a paragraph in the Shadow DOM, and vice versa.
Another powerful part of the Shadow DOM are slots. They enable us to slot in content inside the template which is very useful for composable components. Take for example an accordion element where we slot in the title, subtitle and content:

```
<mosaik-accordion size="large">
  <h2 slot="title">Main Title</h2>
  <p slot="subtitle">Sub Title</p>
  <p> Lorem ipsum dolor sit amet, consectetur adipiscing elit... </p>
</mosaik-accordion>
```
![Accordion component](/design-system/accordion-component.png)

### The downsides of the Shadow DOM
Since the Shadow DOM is isolated from the rest of the document, elements in the document cannot be connected to elements inside the Shadow DOM within the web component. This is an issue for accessibility reasons if we for example need to connect an input-element inside a web component to a label outside, or if we need an aria-attribute to connect a button to a menu.

Another issue is with form participation. If a submit button inside the shadow DOM is clicked it will not trigger a form submission. Input elements inside the shadow DOM will not be included in the form in a regular form submission either. You can get around this in different ways but it's not simple. For example when a submit button inside the shadow DOM is clicked you can add a dummy submit button to the light/regular DOM and click that programmatically to trigger a form submission.

In conclusion, the most important decision is really whether to use the Shadow DOM or not.
### Choosing a library - Lit vs Stencil
Lit is just a wrapper around standard web components, removing boilerplate and making it easier to write reactive and declarative code. This means it comes with the same issues and quirks that standard web components have. But it also means that it's simpler than other libraries, there is no compilation magic.

Stencil on the other hand compiles to web components and framework wrappers. This allows it to add some extra functionality, with Stencil it is possible to use scoped styles and slots without using Shadow DOM. Although scoped styling in this way only means styles inside the components will not leak out, styles from the document can still leak in (which can be both a good and a bad thing).
### Deciding
At first we chose Lit because:
- It seems to be the most popular library for building web components, having double the amount of NPM downloads compared to Stencil at the time
- There are some excellent component libraries built with Lit that can be used for guidance and inspiration, for example Adobe Spectrum and Shoelace
- It is simpler than Stencil, no magic compilation is needed

But after prototyping with it some more we ran in to more and more issues. Both the issues mentioned above but also regarding integrating it with Angular and React, and developer experience with things like hot module reloading.

In conclusion, to make development easier and not get stuck in the problems with web components we chose Stencil. We are not a big team so it's important to use something that just works, even though it has some downsides. Also, we didn't miss the irony of using a library/framework to build something framework agnostic.
### Mitigating the downsides
Since one of the greatest downsides of Stencil is that we get locked into a library that might go obsolete, we're trying to mitigate it by writing the components in a way that it will be easy to switch to something like Lit. For example by controlling as much as we can with pure CSS.

Switching from Lit to Stencil was pretty easy, at least with a few components. A lot of it is CSS which stays the same and the features and syntax are similar.
The main issue will be accessibility, if we go over to Lit in the future and use the shadow DOM we'll have issues with tying things with IDs in the light DOM etc. But that switch should be possible without breaking the API towards users of the components.

## A year later
Stencil is still working well for us and if I could go back in time I would probably choose it again. Although if we had more resources I would probably pick Lit instead because it stays closer to web standards and seems to grow in popularity much quicker than Stencil meaning it will have a larger community.

But, choosing a library is only the beginning of implementing a design system, there are lots of other decisions to be made. The next post will be about design tokens in a design system and how we implemented them with CSS variables.