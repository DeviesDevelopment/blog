---
title: "Implementing a design system - Choosing a way forward"
date: 2024-08-30T10:08:51+02:00
tags: ["web", "web components", "accessibility", "design system", "component library", "CSS"]
featured_image: "/design-system/header-building-design-system.jpg"
description: ""
slug: "implementing-a-design-system-choosing-a-way-forward"
author:
 - Simon Nielsen
---

For the last year one of my main projects at work has been to lead the implementation of a design system, building it together with my team. It's not a perfect implementation but I'm quite proud of what we have accomplished so far with small resources. I'd like to share some of our insights and experiences, about specific decisions we've made and why.

Let's begin with the needs expressed by the organization:

*"We want a great, consistent experience for all of our users in every channel, mainly on the web."*

That sounds great! Let's start to unpack what that means.

## "A great, consistent experience"
This need comes from the current state of their channels and I know the situation is similar for many organizations. Their public website(s) and different web apps have all been implemented at different times, with different technologies and with different designers. At best they share logos, some colors and fonts but otherwise the websites and apps does not look and behave great or consistently. The solution? A design system with shared styles, components and guidelines. And lots of time and effort of course.

## "for all of our users"
Accessibility is important for many different reasons. It enables more people to use our services in a more efficient way which makes sense both from a human as well as a business perspective. The laws for it are also affecting more and more organizations.
For the design system this means that we need to bake in as much accessibility best practices as possible to make it easier to craft great experiences with it.

## "in every channel, mainly on the web."
That's a tall task considering the state of web development. We can't pragmatically limit ourselves to one JavaScript framework and expect that to last. We should be able to use this design system on websites and apps built with different technologies.

This requirement made us consider the following options:
- Implement it using only one framework
- Implement it with pure CSS
- Implement it once for each framework, sharing styles
- Implement it with web components
- Base it on an existing component library

### Implement it using only one framework
Many organizations choose to build everything with one technology, the last few years it's usually React. This can work great for smaller organizations but of course it comes with limitations and risks. We lock ourselves into one framework that may turn out to not work well for every use case, go obsolete or turn into a direction we don't like to follow. The upsides are that it is easier and less time consuming, at least short/medium term. For us, this would mean having to also rewrite some big existing websites and apps into the same framework which was not feasible.

### Implement it with pure CSS
But what about skipping implementing it for a specific framework? Pure, modern CSS is very powerful. I've seen how a CSS implementation of a design system has used ARIA attributes etc in a clever way for their style selectors which kind of forces the user to write accessible code in order to access the right styling. We chose to not go this way because it would mean we can't bake in accessibility to the same extent that we would like since we can't package the html template itself. Also we can't really handle components requiring some state.

### Implement it once for each framework, sharing styles
If we implement it heavily around CSS we can share those CSS styles for each framework and then implement the state handling and template in each framework. This has the benefits of efficiency in development, since developers will work with a framework they are comfortable with, and it's easier to integrate with applications. But it comes with many downsides such as inconsistencies between implementations, maintaining multiple versions and probably more work building the same thing multiple times. It also doesn't solve the problem of using it on sites which don't rely on a framework.

### Implement it with web components
Are web components the golden solution then? They are a web standard for building encapsulated components, and we like web standards don't we? 
With these components we can bake in accessibility and have one consistent way of building UIs in all channels. Web components have great support in all major frameworks (soon also React) and can easily be used in plain websites as well. That sounds great but web components are not widely adopted yet in the same way that modern frameworks are which limits the community and support. They also come with a bunch of other caveats which I'll leave for a future post (stay tuned!).

### Base it on an existing component library
The final option is to just take an existing component library and base our implementation around that. This would save a lot of time spent on building basic but accessible components and ensures that we can focus our energy on delivering user value. 
The problem is that it limits us in many ways. Open source component libraries are almost always built using just one framework and/or are built around an existing design system like Material Design. You are also limited to the choices they made around which components to include and how they behave. And don't try to work against the library you choose, you have to build it in their way, otherwise you're going to paint yourself into the hacks and overrides corner.

Headless component libraries are an interesting alternative since they provide behaviour and accessibility but leave the styling to you, but I've only seen them built for React.

A notable open source component library built with web components is [Shoelace](https://shoelace.style/) by Cory LaViska. It's great but we did not feel comfortable basing our implementation around a project maintained by one person. Although I'm excited for how he together with Font Awesome is evolving it into [Web Awesome](https://blog.fontawesome.com/introducing-web-awesome/).

## Deciding on a way forward
We looked at how other organizations have decided to implement their design systems (Arbetsförmedlingen + Skolverket, Volvo Cars, Adobe, Designsystemet.no, Porsche Design system, Atlassian etc) and talked briefly to a couple of them to try to understand why they chose what they did. In parallel we did a bunch of research and extensive prototyping with web components.

After careful consideration we decided that web components was the right decision for us. The organization decided that having their own design system not heavily based on something else was important for their brand. We also decided that we did not want to be limited to the components and their behaviour of an existing component library despite the fact that it will take more time and effort to build it ourselves. Finally we decided that baking in behaviour and accessibility was important and we cannot limit ourselves to one framework.

**What about native mobile apps?**
Web components of course don't work in native mobile apps. Based on the current landscape of websites and web apps of the organization and its resources going forward we decided that it makes sense to focus on the web. The design system itself with the design tokens and guidelines could be implemented for native mobile apps in the future with everything we've learned along the way. Or we could be content with a less than ideal web view based app.

## Conclusion
I hope this was informative and useful for someone. I'd love to get feedback both on my writing and on the content itself, and I hope it sparks some discussions!

My plan is to turn this into a blog post series with the next posts containing:
- Challenges with web components and deciding to use Lit or Stencil
- Design tokens in a design system and how we implemented them with CSS variables
- Building accessible components and how to test them
- Documenting a design system
- ...and maybe more


> _Header <a href="https://www.freepik.com/free-vector/responsive-concept-illustration_13955753.htm#from_view=detail_alsolike">Image by storyset on Freepik</a>_