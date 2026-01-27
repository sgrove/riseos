---
title: "Porting the Rails Inflector to Common Lisp"
author: Sean Grove
authorURL: http://twitter.com/sgrove
date: 2010-11-15
description: Building an English pluralization/singularization library for Common Lisp, ported from Rails
tags: [lisp, common-lisp, rails, nlp]
---

While building out [Vana](https://github.com/sgrove/vana), a new Common Lisp web framework loosely based on rails, I ran into the usual problem that somehow the Common Lisp ecosystem is a hodgepodge of functionality. Even though there are [great](http://common-lisp.net/project/elephant/) [packages](http://weitz.de/cl-ppcre/) available, there are so many gaping holes it feels like lisp must have just come out last year. In this case, I ended up needing Rail's inflector, and there wasn't anything quite like it (sidenote: Before you got telling me about FORMAT, yes I realize is has a plural directive, and no it's not the same damn thing).

Well, nothing gets better unless people pitch in, so I went into the Rails source and ended up porting the pluralization/singularization bits to vana-inflector. It's written to be immediately understandable to a programmer of another language with only a few days/weeks training lisp.

If you want to jump in right away, check it out on [github](https://github.com/sgrove/vana-inflector). If you're interested in the porting experience, read along.

## Porting

Coming mostly from rails, I wanted the syntax to be intuitive for others making that jump. That means we can take a look at what the rails' interface offers:

- `plural(rule, replacement)` - adds in a new rule for making singular->plural. Rule can be a regex or a string.
- `singular(rule, replacement)` - same for plural->singular.
- `irregular(singular, plural)` - adds in a rule for a specific singular-plural set (e.g. no regexes)
- `uncountable(*words)` - adds in any number of words as uncountable

And the big ones:

- `pluralize(word)` - e.g. `"octopus".pluralize` => `"octopuses"`
- `singularize(word)` - e.g. `"octopuses".singularize` => `"octopus"`

Also, in the action_view text_helper.rb, there's this gem:

- `pluralize(count, singular, plural = nil)` - e.g. `pluralize(2, 'person')` => `"2 people"`

That just about covers the gamut of what I wanted. So all that's left is to implement these!

## Implementation

First things first, let's encapsulate all of this in a package, and export the above interface:

```lisp
(defpackage :vana-inflector
  (:use :cl :cl-ppcre)
  (:export :pluralize
           :singularize
           :plural
           :singular
           :irregular
           :uncountable))
```

A quick look into the inflector source shows that the rules are just arrays of regular expressions. Fair enough, I think we can handle that.

English is a nice language made even more colorful by all its uncountable nouns, and we shouldn't bother trying to pluralize these. We'll start with a basic list that we'll let the user modify via our exported interface.

And then there's every language student's nightmare: the irregularities. In this case, general rules won't help, we have to keep track of them individually.

## Usage

Let's make it so all this is actually useful:

```lisp
(pluralize "octopus")   ;; => "octopuses"
(pluralize "person")    ;; => "people"
(pluralize "ox")        ;; => "oxen"
(singularize "mice")    ;; => "mouse"
```

## Thoughts

It could be cleaned up here and there, but it was a side project I did on a late Friday night while working on other things, and for that it's not half bad.

However, it does highlight one of the dangers of working in lisp that I mentioned before - there are a ton of things you take for granted in a modern language's ecosystem that you'll have to hack at and reinvent on your own when working in Lisp. It's not true of everything, and in some cases it's really a great opportunity to re-invent and improve while better understanding the original, but it's a really critical issue to be aware of if you're on a time-sensitive deadline and are wavering between lisp and some other language.

## TODO

- It should handle things like CamelCase to camel_case (or camel-case), and vice-versa. I'll add this when I actually need it (probably will soon for the parenscript bits), but feel free to jump in.
