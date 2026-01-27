---
title: "Utterly Sensible HTML Templating in Common Lisp"
author: Sean Grove
authorURL: http://twitter.com/sgrove
date: 2010-11-16
description: Building a sexp-to-HTML templating system in Common Lisp, complete with HTML5 support
tags: [lisp, common-lisp, web, templating]
---

In that time-honored tradition of re-inventing things we don't understand, I ended up writing a templating system for vana that seems to work wonderfully. It's still being battle tested, but the results right now are very hopeful.

If you want to jump straight to the github repo, you can find it [here](https://github.com/sgrove/vana-templating).

## Background

I didn't originally set out to create a templating library. I had used common lisp a bit before, but felt happier with scheme ([gambit](http://www.iro.umontreal.ca/~gambit/) at first, later [chicken](http://wiki.call-cc.org/), both because I wanted to compile down to the iphone), and used it for the majority of my projects ([Tehila](https://github.com/sgrove/tehila) always give people a shock, "a 3d engine in scheme? That lisp thing?"), but eventually switched over to Clojure at the behest of a former coworker I very much respected, and developed in that for awhile. For a few reasons, I went back to Common Lisp, and worked at it with a much greater understanding of Lisp.

I wrote a bit to handle reading from sockets, and that turned into sending back a simple hard-coded html-header for curl to read, then into a tiny bit of makeshift routing, and finally, I was outputting hardcoded html... but that's no fun. So I took my fun little [clojure html](http://bitbucket.org/sgrove/clojure-fun/src/tip/html5.clj) project and went to town porting it.

## First Principles

The basic structure of an html tag is probably familiar to everyone reading my blog:

```html
<tag-name attribute-key="attribute-value">content</tag-name>
```

All of that can be output as a straight string from Lisp, no problem. Working from first principles, we could start very simple with:

```lisp
(defun tag-name (name content)
  (format nil "<~A>~A</~A>" name content name))
```

Let's give it a try:

```lisp
(tag-name "div" "Hello world")
;; => "<div>Hello world</div>"
```

Nice! How about nested tags?

```lisp
(tag-name "div" (tag-name "p" "Hello world"))
;; => "<div><p>Hello world</p></div>"
```

Oh, that's already pretty cool. But tags need attributes! There's no way around it, we'll have to find a way to implement it.

## HTML5

I really enjoy working with different HTML5 projects - `<audio>`, `<canvas>`, and especially webgl, so I want to make this library HTML5-centric. [w3schools](http://www.w3schools.com/html5/html5_reference.asp) says that all the tags can be listed as:

```lisp
(defparameter *html5-tags*
  '(a abbr address area article aside audio b base bdi bdo
    blockquote body br button canvas caption cite code col
    colgroup command datalist dd del details dfn div dl dt
    em embed fieldset figcaption figure footer form h1 h2
    h3 h4 h5 h6 head header hgroup hr html i iframe img
    input ins kbd keygen label legend li link map mark menu
    meta meter nav noscript object ol optgroup option output
    p param pre progress q rp rt ruby s samp script section
    select small source span strong style sub summary sup
    table tbody td textarea tfoot th thead time title tr
    track u ul var video wbr))
```

Wow, that was easy.

## The Functional Touch

Now that we have a nice function that makes other functions (doesn't that sound great?), we can pass in a list of the functions we want to make.

```lisp
(mapcar #'make-tag-function *html5-tags*)
```

Wow. We just made 106 functions with a few lines. Feelin' good about yourself yet?

Now we can do some really nice stuff... check it out:

```lisp
(html '()
  (head '()
    (title '() "My Page"))
  (body '()
    (div '(id "content")
      (h1 '() "Welcome!")
      (p '() "This is my page."))))
```

Very readable, succinct, and we're still working in pure, basic lisp - not even a single macro yet. But since we have a full language at our disposal, can we start to abstract away some of the repetitive parts?

## Abstractions

I notice a lot of repeated image tags:

```lisp
(defun image (src &optional alt)
  (img `(src ,src alt ,(or alt ""))))
```

Also, quite a few links in there:

```lisp
(defun link-to (url text)
  (a `(href ,url) text))
```

Now we can start writing some pretty cool templates:

```lisp
(html '()
  (standard-head "My Blog")
  (body '()
    (navigation)
    (main-content)))
```

Straight up awesomeness.

## Future

We can embed javascript via parenscript, but there are some macro/function lines to work over first. Also, there are some weird corners where we need to use reduce and string->list which are not apparent to a HTML/front-end designer. I'm in the process of writing webapps with some excellent front-end designers to make this template system battle-hardened, but it's already very convenient to work in. It acts like a very simple templating system, the same to write as HTML, until you want to branch out and start abstracting. One can even use the crazy capabilities of the reader macros etc. to take the system even further, while using a simple package system to prevent any logic from seeping into the presentation.
