{{post.title}}
===

Mirage is going to have a ton of growing pains as it's used for real-world applications. I suspect that *most* of that will be spent on polish and glue (which is desperately missing right now), because the core is relatively solid (especially compared to e.g. one year ago).

Still, I have tons of Mirage questions, and would like answers/guides to them, or even better - code to completely obsolete them. I'll keep a list here, and update it with links as answers come in.

 * How to express pinned dependencies in the the mirage config.ml Apparently [this isn't possible right now](http://lists.xenproject.org/archives/html/mirageos-devel/2016-02/msg00080.html), which means others are going to have a hard time using my example repository.
 * Seamless, continuous, one-click deploy from any platform to AWS, GC, Linode, Digital Ocean, and prgrm
 * How to get stack traces from crashes in the unikernel in production (ideally we'd be able to combine with with e.g. [bugsnag](https://bugsnag.com/) at some point)
 * How to build a xen unikernel image from OSX (likely to be a big requirement)
 * If the above isn't feasible, how to tie into e.g. CircleCI to build the xen artifacts and upload them somewhere.
 * How to parameterize the ports for development (where I don't want to use sudo to start my binary) and for production (where I don't mind it, of course). Also applies to other things besides just ports (ssl certs, etc.).
