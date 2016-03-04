Early this morning I was able to get some very, very simple OCaml code running on my physical iPhone 6+, which was pretty exciting for me.

I had been excited about the idea since seeing a post on [Hacker News](https://news.ycombinator.com/item?id=10960753). Reading through, I actually expected the whole process to be beyond-terrible, difficult, and buggy - to the point where I didn't even want to start on it. Luckily, [Edgar Aroutiounian](https://twitter.com/edgararout) went *well* beyond the normal open-source author's limits and actually sat down with me and guided me through the process. Being in-person and able to quickly ask questions, explore ideas, and clear up confusion is so strikingly different to chatting over IRC/Slack. I'll write a bit more about the process later, but here's an example of the entire dev flow right now: edit OCaml (upper left), recompile and copy the object file, and hit play in XCode.

![](/images/posts/ocaml_on_ios.png)

The next goal is to incorporate the code into this site's codebase, to build a native iOS app for this site as an example (open source) iOS client with a unikernel backend. I'm very eager to try to use ReactNative, for:

 1. The fantastic state models available (just missing a pure-OCaml version of [DataScript](https://github.com/tonsky/datascript))
 1. Code sharing between the ReactJS and ReactNative portions
 1. [Hot-code loading](https://youtu.be/J4hBjleaG8w?t=6m33s)
 1. Tons of great packages, like [ReactMotion](https://github.com/chenglou/react-motion) that just seem like a blast to play with

# Acknowledgements

I'd *really* like to thank [Edgar Aroutiounian](https://twitter.com/edgararout) and [Gina Maini](https://twitter.com/wiredsis) for helping me out, and for being so thoughtful about what's necessary to smooth out the rough (or dangerously sharp) edges in the OCaml world. Given that tooling is a multiplicative force to make devs more productive, I often complain about the lack of thoughtful, long-term investment in it. Edgar (not me!) is stepping up to the challenge and actually making [very](https://github.com/fxfactorial/opam-ios) [impressive](https://github.com/fxfactorial/ocaml-nodejs) [progress](https://github.com/fxfactorial/ocaml-graphql) on that front, both in terms of code and in documenting/[blogging](http://hyegar.com/).

As a side note, he even has an example native OSX app built using OCaml, [tallgeese](https://github.com/fxfactorial/tallgeese).
