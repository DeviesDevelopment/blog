---
title: "Introducing tower-oauth2-resource-server"
date: 2025-03-07T00:00:00Z
tags: ["rust", "tower", "OAuth", "jwt", "authorization"]
featured_image: "/cuddlyferris.png"
slug: "introducing-tower-oauth2-resource-server"
author:
 - Rickard Andersson
---

**TLDR:** I've built a middleware for handling JWT authorization.
It's written for the Rust ecosystem and supports many popular web frameworks such as [axum](https://crates.io/crates/axum), [salvo](https://crates.io/crates/salvo/) and [tonic](https://crates.io/crates/tonic).
It's called **tower-oauth2-resource-server** and you can find the source code on [github](https://github.com/Dunklas/tower-oauth2-resource-server).
Feel free to use and contribute!

---

Over the last few months, I've delved into the art of writing a REST API using Rust.
Specifically, I've used the [axum](https://crates.io/crates/axum) crate to do so.
Like most projects, mine eventually needed authorization.
A way to validate incoming JSON Web Tokens (JWTs) from an external identity provider.

In my daily job (where I work with Java and Spring) my go-to-solution for authorization is to use [Spring Security OAuth2 Resource Server](https://docs.spring.io/spring-security/reference/servlet/oauth2/resource-server).
That library makes things easy — you simply specify an issuer URL, and it takes care of discovering JSON Web Key Sets (JWKS), handling key rotation, and validating JWTs.
However, I couldn't find an equivalent Rust library that offered the same level of simplicity.
So, I decided to build one myself.

My objective was to write a middleware that intercepts incoming requests, validates their JWTs, and either allows or rejects them based on validity.
In the Rust ecosystem there is a crate called [tower](https://crates.io/crates/tower) which provides an abstraction for the concept of taking a request and returning a response.
It can be used for implementing middleware in both clients and servers, regardless of networking protocol.
Many web frameworks (including Axum) use Tower instead of implementing their own middleware systems.
With that in mind, I decided to write my middleware for Tower, ensuring it could be used across multiple web frameworks.

So, I hereby introduce **tower-oauth2-resource-server**!
The library is highly inspired by [Spring Security OAuth2 Resource Server](https://docs.spring.io/spring-security/reference/servlet/oauth2/resource-server) and some of its features include:

 - JWT validation for incoming HTTP requests
    - Signature matches public key from JWKS endpoint
    - Validity of `exp`, `nbf`, `iss` and `aud` claims
 - Automatic discovery and rotation of JWKS
 - Expose JWT claims to downstream services via a [Request extension](https://docs.rs/http/latest/http/struct.Extensions.html)

It should be possible to use the library together with any web framework built on top of [tower](https://crates.io/crates/tower).
However, I've only verified that it works together with [axum](https://crates.io/crates/axum), [salvo](https://crates.io/crates/salvo/) and [tonic](https://crates.io/crates/tonic).

The library is available on [crates.io](https://crates.io/crates/tower-oauth2-resource-server), and you can find the source code on [github](https://github.com/Dunklas/tower-oauth2-resource-server).
You can find **usage examples** for different web frameworks in the [examples](https://github.com/Dunklas/tower-oauth2-resource-server/tree/main/examples) folder of the repository.

Feel free to use and contribute!
