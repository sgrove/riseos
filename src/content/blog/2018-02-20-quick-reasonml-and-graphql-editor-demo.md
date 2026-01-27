---
title: Quick ReasonML and GraphQL Editor Demo
author: Sean Grove
authorURL: http://twitter.com/sgrove
date: 2018-02-20
description: A video demo showing the programming dream of immediate feedback with ReasonML and GraphQL
tags: [reasonml, graphql, developer-experience]
---

I wanted to show a quick glimpse of the programming dream (or my own, at least) - immediate feedback while programming, validated against a live server. Power, simplicity, reliability, and convenience, I want it all!

Here's an example video with narration on what it's like working with ReasonML + GraphQL in **emacs**:

[![Example of using ReasonML + GraphQL](https://img.youtube.com/vi/yMqE37LqRLA/0.jpg)](https://www.youtube.com/watch?v=yMqE37LqRLA "Example of using ReasonML + GraphQL")

## A few benefits of this approach:

- **Full-stack safety**: The server presents its entire known schema, so my Reason app won't even compile if it's trying to access a non-existent field (or trying to use it in a type-incorrect way, e.g. mistaking a string for an integer)
- **Long-term safety**: Because fields are never removed from a GraphQL (only deprecated), I never have to worry about shipping a client that might be broken by future server changes. This goes a long way towards ever-green clients.
- **No forgotten edge cases** - this one kills me continually outside of Reason. I forget to check if the response is still loading, or if it error'ed, or I try to access data on the wrong field. I can easily add a catch-all to throw an error and ignore all the edge cases if I'm prototyping, but once I have my happy-path, I want to make sure things are battened-down tightly.
- **In-editor completion**: When accessing fields
- **Editor-guidance**: Along the previous lines, with Reason the data structures guide me to handling each case and field access gracefully as I explore the response structure. As soon as I hit save, I'll know if I have a typo, or if I accessed a nullable field without checking, or if I used the type incorrectly.

## Some drawbacks:

The only drawback I can think of is I can't quite see a way to get auto-completion while writing the GraphQL in the PPX. I'd ideally like to have a GraphiQL-like experience with the fields auto-completing, and being able to read docs/types inline. Currently I tend to write the bulk of my queries in our fork of GraphiQL, then paste in the result. It's minor, but would be really nice if there was a way to do this (I know there's a way in Atom for example, but emacs may not make this easy).

## Closing notes:

This example is in **emacs**, but the experience should be the same (or better!) in vim, Atom, and especially vscode, thanks to the great Reason editor integrations there.
