{{post.title}}
===

The goal is to get a good portion of this down to a static site generator, along the lines of jekyll. I have a super hacky implementation of [Liquid Templating](http://liquidmarkup.org/) working - it mangles input html, but it works enough to write this post!

In fact, this post is powered by:

 * OCaml
 * Mirage
 * Markdown via (the quite nice) [Omd](https://github.com/ocaml/omd)
 * A custom Liquid templating parser built using [Menhir](http://gallium.inria.fr/~fpottier/menhir/).
 * Super unsafe Reactjs js bindings written in OCaml and compiled down via [js_of_ocaml](https://github.com/ocsigen/js_of_ocaml)
 * Xen hypervisor

Example of template being filled in: `post.author` -> {{post.author}} <- Filled in by the usual liquid templating `[[post.author]]` (not actually `[`, but I can not escape the curly brace yet)

The workflow is that context (the data that fills in holds like the above `[[post.author]]`) is hardcoded in OCaml. While running locally, everything is completely re-rendered on every load. In production (or in unikernel mode), the page is rendered on the first load, and then cached indefinitely for performance. At some point I would like to be able to enumerate over the Opium routes and generate a final html output for each possible route, so that the artifacts themselves could be deployed to e.g. AWS S3. Any non-resource/dynamic routes could still fallback to hitting the unikernel in order to get the best of both worlds for free - as much pre-generated (cacheable) static output as possible, with the ability to make portions dynamic at will, all while writing in the same OCaml way.

I also would like to have a JSON (or perhaps [EDN](https://en.wikipedia.org/wiki/Extensible_Data_Notation)) header so that context could be provided by the post for use elsewhere in the template (e.g. have the sidebar title/tags defined by the blog post markdown file) - move as much out of OCaml as possible, while still keeping type safety, etc.

Still missing:

 * Support for `liquid` control structures, e.g. `if`, `|`, etc.
 * Full support for existing jekyll templates - importing them should eventually be possible
 * HTTP/JSON endpoints. I am hoping to use Opium, but it has some transitive dependency on Unix (through Core), and looks like it may take more effort to port off of (in order to use with a Xen backend).
 * Safe and convenient Reactjs bindings - it is hellish writing them right now

Below, you can see the Reactjs app written in OCaml running and creating clickable buttons. I have a custom watcher that recompiles the entire OCaml dependency change into js whenever a relevant file is changed - it happens fairly quickly right now, so it is not *too* painful, but I certainly hope something like incremental compilation is possible in the near future.
