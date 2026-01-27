---
title: "Building Objects from Scratch in Lisp"
author: Sean Grove
authorURL: http://twitter.com/sgrove
date: 2010-11-17
description: Understanding OOP fundamentals by building an object system from closures in Scheme
tags: [lisp, scheme, oop, fundamentals]
---

I was interested in [a discussion on HN](http://news.ycombinator.com/item?id=1917917), and it reminded me of a few months ago when I ended up writing a make-shift object system in scheme, almost entirely by accident. It was eye-opening to understand the simple blocks that it was all built on. So to that end, I'd like to explore the fundamentals of object-oriented programming.

## Goal

Build a simple character model using the most basic building blocks available.

We'll give the character the following characteristics:

- **name** - The character's name
- **health** - Remaining health (can change)
- **agility** - The likelihood of dodging an attack
- **strength** - The amount of damage inflicted when attacking

Check out [this gist](https://gist.github.com/705935) if you'd like to jump straight to the source code.

## From the Basics

We'll start by making a list of these attributes:

```scheme
'("Musashi" 100 50 80)
```

That's a start. We have a list, and we can just remember (for now anyway), the order of attributes. For example, to get the character's health, we could grab the 2nd item in the list.

But it's really just a list of stuff. Not only is it unpleasant to type in all the time, it's impossible to access more than one element - each time we type in that list, a new list is created, completely unrelated to any earlier lists!

What we need is a way to refer to the *same* list in a convenient way. Lisp's LET will do just this:

```scheme
(let ((musashi '("Musashi" 100 50 80)))
  (list-ref musashi 1))
;; => 100
```

Much better. Now let's make some nice accessor functions:

```scheme
(define (get-name character) (list-ref character 0))
(define (get-health character) (list-ref character 1))
(define (get-agility character) (list-ref character 2))
(define (get-strength character) (list-ref character 3))
```

Now we can read the code a bit better:

```scheme
(get-health musashi)  ;; => 100
```

## Encapsulate!

Let's make a constructor:

```scheme
(define (make-character name health agility strength)
  (list name health agility strength))
```

MAKE-CHARACTER is a tiny, tiny wrapper around list, but we get two nice advantages: First, our code is much more readable. And second, we've completely removed any knowledge of how the internals of a character are handled from the code using it. We've encapsulated that functionality away into the few functions that have to know about it.

**Encapsulation is an important component of object-oriented programming.**

## Another Enters the Arena

Can we handle two characters?

```scheme
(let ((musashi (make-character "Musashi" 100 50 80))
      (kojiro (make-character "Kojiro" 100 40 90)))
  (display-status musashi)
  (display-status kojiro))
```

Can you feel the tensions growing already? I feel the need for an ATTACK function:

```scheme
(define (attack attacker defender)
  (let ((damage (get-strength attacker)))
    (set-health! defender (- (get-health defender) damage))))
```

## A Battle Brewing

Let's allow them their normal behavior with a few extra functions and watch them fight:

```scheme
(let ((musashi (make-character "Musashi" 100 50 80))
      (kojiro (make-character "Kojiro" 100 40 90)))
  (battle musashi kojiro))
```

Epic indeed! Looks like our old friend Kojiro faired a bit better in our simulation than he did in real life.

## Epilogue

But isn't this just a bunch of functions? Yes, and no. These are all just a bunch of functions, but still able to maintain state and interact with these states through an interface. **And that's the heart of OOP.**

This approach is very much "a lot of functions, few objects" which I prefer, but it takes some getting used to. It's also a bare-bones object system that can be expanded any which way (though probably shouldn't be for anything production-oriented) - polymorphism, inheritance, etc. There are hundreds of variations we could go into: sticking more state into the closures, sticking the functions into the closures, putting more into the functions and less into the closure, etc., but the first step is building *something* and seeing it grow. So give building your own object system a try!
