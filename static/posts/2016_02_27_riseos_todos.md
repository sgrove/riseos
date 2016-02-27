This site is has been a very incremental process - lots and lots of hard-coding where you'd expect more data-oriented, generalized systems. For example, the post title, recent posts, etc. are all produced in OCaml, rather than liquid. I'd like to change that, and bit by bit I'm getting closer to that.

In fact there's a whole list of things I'd like to change:

  * Routing is hard-coded. I want to bring in [Opium](https://github.com/rgrinberg/opium) to be able to use the nice routing syntax, and middleware for auth, etc. However, its dependency on unix means that it can't be used with the Mirage backend. Definitely keeping an eye on [the open PRs here](https://github.com/rgrinberg/opium/pulls).
  * Every page is fully re-rendered on each request - Reading the index.html (template file), searching through it for the targets to replace, reading the markdown files, rendering them into html and inserting them into the html, and finally serving the page. For production, this should be memoized.
  * Posts can't specify their template file - everything is just inserted into index.html. Should be trivial to change.
  * The liquid parser mangles input html to the point where it significantly changes index.html. It needs to be fixed up.
  * Similarly, I want to move more (e.g. some) logic into the liquid templates, for things like conditionals, loops, etc.
  * Along those lines, the ReactJS bindings are very primitive, I need to come up with a small app in this site (perhaps logging in) to start exercising and building them out (with ppx extensions at some points, etc.)
  * An application I'm considering is to first expose an API to update posts in dev-mode, then building a ReactJS-based editor on the frontend ([draft.js](https://facebook.github.io/draft-js/) is obviously a very cool tool that could be used). That way editing is a live, in-app experience, and then rendering is memoized in production. Production could even have a flag to load the dev tools given the right credentials, and allow for a GitHub PR to be created off of the changes.
  * Possibly use Irmin as a storage interface for the posts.

Plenty of other things as well. I'll update this as I remember them.
  

  
