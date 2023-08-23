---
title: "Takeaways from Modern Software Engineering"
date: 2023-04-28T12:55:42+02:00
tags: []
featured_image: ""
description: ""
slug: "modern-software-engineering"
author:
 - Jakob Larsson
 - Johan Iversen
 - Rickard Andersson
 - Sandra Ekholm
 - Simon Nielsen
---
In the Devies book club we recently finished Modern Software Engineering by David Farley.

In Modern Software Engineering, Farley want to reclaim the meaning of engineering in “software engineering”.
It’s not just about coding, it’s about doing what works to build better software faster - This involves processes, tools and culture.

The software industry is not like the manufacturing.
The process of building software can’t be reduced to a production line; it’s rather a process of exploration and discovery.
In this context, Farley suggests that there are two critical core competencies that software engineers must master: *learning* and *managing complexity*.

Science has proven to be a good approach to learning.
Throughout the book Farley relates to techniques and strategies from the [scientific method](https://en.wikipedia.org/wiki/Scientific_method) and show how we can apply ideas from science to solve practical problems in our everyday work.

In this post, we'll share some takeaways from the book.

### Feedback loops

Feedback loops comes in many forms.
Compilation, unit tests and static code analysis provides feedback on your local development.
Continuous integration (CI) provides feedback on how well your change works together with other changes.
Continuous delivery (CD) provides feedback on how well your change works in production.
Metrics on how features are used provides feedback on how valuable your features are.

Regardless of what kind of feedback loop; the speed and quality of feedback constitutes your rate and quality of learning.
Be aware of your feedback loops and strive to improve them.

### Deployability vs Releasability

To ensure quick iteration times and speedy CI/CD it's helpful to separate
Deployability and Releasability.

Deployability means that the change is ready to merge and send to produciton.
But that does not mean that the feature has to be enabled or availible for the
end user just yet. This means that the change passes the tests and the build
system. It's possible to merge into the main branch.

Releaseability is then that the feature of fix is ready to enable for the end
user.

This separation helps us develop larger features while still maintaining
a short time from code writing to deploy. This has a few advantages over long
running feature branches. It is much easier to merge since we only ever merge
to the main branch. And the individual merges are smaller. And therefore easier
to review. And the parallel development always has a reference to the new
feature under development, so the branches won't diverge.

This separation is also a good stepping stone to more advanced
release-strategies like A/B testing and staged/gradual roll out.
It's usually achived with feature flags.
But there are some drawbacks as always.
A feature flag system can become very
complex and it's hard to test all different combinations of flags.



### Don't trust your assumptions: Formulate a hypothesis and test it

Assumptions are a dangerous thing in development. You could arguge that most
bugs are caused by faulty assumptions. Either a wrong assumption about how the
computer, language or the code work. Or a mistaken assumption about the
product, industry or the users needs.

How do you avoid this? One way is described in the book:
Formulate a hypothesis, then construct a test or experiment that can prove
or disprove it. The result is very valuable feedback. Then you know if the
assumption holds or not, without guessing or debate. Separating myth and
reality.

Then you forumlate a better hypothesis, and test that. And then you iterate the
hypothesis-test cycle again. And again. As we do with a continous improvement
culture.

But it is important to control the variables so that the experiment is
accurate and reproducible. How you do this is the hard part, it very much
depends on the conditions of the system under test and the hypothesis.

A related concept is self deception.
It is really easy to invent a reality that suits the argument you are trying
to make, regardless if it's true or not.
Sometimes you really want to belive certain things about your software systems.
The Hypothesis-test cycle is a effective way to guard against self deception as
well.


### Measuring team performance

It’s hard to measure performance of software development teams.
Will we deliver more if we start to use this other programming language?
Do we decrease the number of bugs and incidents by requiring manager approval prior to production deployments?

Farley refer a lot to the four DevOps metrics that relatively recently has been proposed in the _State of DevOps report_, and in the book _Accelerate_.
This is a set of metrics which aim to measure the **throughput** and **stability** of software delivery.
Throughput refers to how quick and how often the team can move ideas into production.
Stability refer to the quality and robustness of changes, and how quick the team is able to recover from failed changes.
An interesting fact about these metrics is that high performers in throughput also tend to be high performers in stability, and vice versa (contrary to the traditional [project management triangle](https://en.wikipedia.org/wiki/Project_management_triangle)).

Of course, the metrics alone doesn't tell us everything; e.g. the actual value of changes are not represented in the metrics.
Regardless, the four DevOps metrics are important.
We finally have an objective tool that can reinforce or invalidate our subjective judgement.
We can measure the impact of changes to organization, process, culture and technology.
Pretty epic.
