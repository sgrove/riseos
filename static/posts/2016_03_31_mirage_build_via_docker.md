As part of due diligence before introducing OCaml to our company, I've been building this site and exploring what OCaml has to offer on a lot of fronts. Now that I have a basic (sometimes terribly painful) flow in place, I've wanted to move on to slimming it down quite a bit. Especially the Mirage build + deploy process. Right now it looks like this:

1. Dev on OSX (for minutes, hours, days, weeks) until happy with the changes
1. Git push everything to master
1. Start up VirtualBox, ssh in
1. Type `history` to find the previous incantation
1. Build Xen artifacts
1. `scp` artifacts to an EC2 build machine
1. ssh into build machine.
1. Run a deploy script to turn the Xen artifacts into a running server
1. Clean up left over EC2 resources

As nice as the idea is that I can "just develop" Mirage apps on OSX, it's actually not quite true. _Particularly as a beginner_, it's easy to add a package as a dependency, and get stuck in a loop between steps 1 (which could be a long time depending on what I'm hacking on) and 3, as you find out that - aha! - the package isn't compatible with the Mirage stack (usually because of the dreaded `unix` transitive dependency).

Not only that, but I have quite a few pinned packages at this point, and I build everything in step 3 in a carefully hand-crafted virtualbox machine. The idea of manually keeping my own dev envs in sync (much less coworkers!) sounded tedious in the extreme.

At a friend's insistence I've tried out [Docker for OSX](https://blog.docker.com/2016/03/docker-for-mac-windows-beta/). I'm very dubious about this idea, but so far it seems like it could help a bit for providing a stable dev environment for a team.

To that end, I updated to `Version 1.10.3-beta5 (build: 5049)`, and went to work trying random commands. It didn't take too long thanks to a great overview by [Amir Chaudry](https://twitter.com/amirmc) that saved a ton of guesswork (thanks Amir!). I started with a Mirage Docker image, [unikernel / mirage](https://hub.docker.com/r/unikernel/mirage/), exported the opam switch config from my virtualbox side, imported it in the docker image, installed some system dependencies (openssl, dbm, etc.), and then committed the image. Seems to work a charm, and I'm relatively happy with sharing the file system across Docker/OSX (eliminates step 2 the dev iteration process). I may consider just running the server on the docker instance at this point, though that's sadly losing some of the appeal of the Mirage workflow.

Another problem with this workflow is that `mirage configure --xen` screws up the same makefile I use for OSX-side dev (due to the shared filesystem). So flipping back and forth isn't as seamless as I want.

So now the process is a bit shorter:

1. Dev on OSX/Docker until happy with the changes
1. Build Xen artifacts
1. `scp` artifacts to an EC2 build machine
1. ssh into build machine.
1. Run a deploy script to turn the Xen artifacts into a running server
1. Clean up left over EC2 resources

Already slimmed down! I'm in the process of converting the EC2 deploy script from bash to OCaml (via the previous [Install OCaml AWS and dbm on OSX](https://www.riseos.com/posts/2016_03_03_install_ocaml_aws_and_dbm_on_osx)), so soon I'd like it to look like:

1. Dev on OSX/Docker until happy with the changes
1. `git commit` code, push
1. CI system picks up the new code + artifact commit, tests that it boots and binds to a port, then runs the EC2 deploy script.

I'll be pretty close to happy once that's the loop, and the last step can happen within ~20 seconds.
