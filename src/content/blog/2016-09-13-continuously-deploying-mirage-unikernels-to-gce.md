---
title: Continuously Deploying Mirage Unikernels to Google Compute Engine using CircleCI
author: Sean Grove
authorURL: http://twitter.com/sgrove
date: 2016-09-13
description: A deep dive into deploying Mirage unikernels on Google Compute Engine with zero-downtime rolling updates
tags: [ocaml, mirage, unikernels, gce, devops, circleci]
---

Trying to blow the buzzword meter with that title...

## Note of Caution!

This never made it quite 100% of the way, it was blocked largely on account of me not being able to get the correct version of the dependencies to install in CI. Bits and pieces of this may still be useful for others though, so I'm putting this up in case it helps out.

Also, I really like the PIC bug, it tickles me how far down the stack that ended up being. It may be the closest I ever come to being vaguely involved (as in having stumbled across, not having diagnosed/fixed) in something as interesting as [Dave Baggett](https://news.ycombinator.com/threads?id=dmbaggett)'s [hardest bug ever](https://www.gamasutra.com/blogs/DaveBaggett/20131031/203788/My_Hardest_Bug_Ever.php)

Feel free to ping me on the [OCaml discourse](https://discuss.ocaml.org/), though I'll likely just point you at the more experienced and talented people who helped me put this all together (in particular [Martin Lucin](https://github.com/mato), an absurdly intelligent and capable OG hacker and a driving force behind [Solo5](https://github.com/Solo5/solo5)).

## What are unikernels?

> Unikernels are specialised, single-address-space machine images constructed by using library operating systems.

Easy! ...right?

The short, high-level idea is that unikernels are the equivalent of _opt-in_ operating systems, rather than _opt-out-if-you-can-possibly-figure-out-how_.

For example, when we build a virtual machine using a unikernel, we only include the code necessary for our _specific_ application. Don't use a block-storage device for your Heroku-like application? The code to interact with block-devices won't be run at all in your app - in fact, it won't even be included in the final virtual machine image.

And when your app is running, it's the _only_ thing running. No other processes vying for resources, threatening to push your server over in the middle of the night even though you didn't know a service was configured to run by default.

There are a few immediately obvious advantages to this approach:

- **Size**: Unikernels are typically microscopic as deployable artifacts
- **Efficiency**: When running, unikernels only use the bare minimum of what your code needs. Nothing else.
- **Security**: Removing millions of lines of code and eliminating the inter-process protection model from your app drastically reduces attack surface
- **Simplicity**: Knowing exactly what's in your application, and how it's all running considerably simplifies the mental model for both performance and correctness

### What's MirageOS?

> MirageOS is a library operating system that constructs unikernels for secure, high-performance network applications across a variety of cloud computing and mobile platforms

Mirage (which is a very clever name once you get it) is a library to build clean-slate unikernels using OCaml. That means to build a Mirage unikernel, you need to write your entire app (more or less) in OCaml. I've talked quite a bit now about why [OCaml is pretty solid](https://www.youtube.com/watch?v=QWfHrbSqnB0), but I understand if some of you run away screaming now. No worries, there are other approaches to unikernels that may work better for you. But as for me and my house, we will use Mirage.

## Public hosting for unikernels

Having written our app as a unikernel, how do we get it up and running in a production-like setting? I've used AWS fairly heavily in the past, so it was my initial go-to for this site.

AWS runs on the Xen hypervisor, which is the main non-unix target Mirage was developed for. In theory, it should be the smoothest option. Sadly, the primitives and API that AWS expose just don't match well.

### GCE to the rescue!

[GCE](https://cloud.google.com/compute/) is Google's public computing offering, and I currently can't recommend it highly enough. The per-minute pricing model is a much better match for instances that boot in less than 100ms, the interface is considerably nicer and offers the equivalent REST API call for most actions you take, and the primitives exposed in the API mean we can much more easily deploy a unikernel. Win, win, win!

#### GCE Challenges

##### Xen -> KVM

There is a big potential show-stopper though: GCE uses the KVM hypervisor instead of Xen, which is much, much nicer, but not supported by Mirage as of the beginning of this year. Luckily, some fairly crazy heroes ([Dan Williams](https://github.com/djwillia), [Ricardo Koller](https://github.com/ricarkol?tab=activity), and [Martin Lucina](lucina.net), specifically) stepped up and made it happen with [Solo5](https://mirage.io/blog/introducing-solo5)!

I highly recommend checking out a replay of the great webinar the authors gave on the topic https://developer.ibm.com/open/solo5-unikernel/

##### Virtio driver issues

Initially we had booting unikernels that printed to the serial console just fine, but didn't seem to get any DHCP lease. Nearly the _entire_ Mirage stack is in plain OCaml though, including the [TCP/IP stack](https://github.com/mirage/mirage-tcpip), so I was able to add in plenty of debug log statements and track everything down to problems with the Virtio implementation.

##### Position-independent Code Bug

This was a deep rabbit hole. The bug manifested as `Fatal error: exception (Invalid_argument "equal: abstract value")`. A simplified version seems to be that portions of the OCaml/Solo5 code were placed in between the bootloader and the entry point of the program, and the bootloader zero'd all the memory in-between before handing control over to our program.

## Deployment

With the help of the GCE support staff and the Solo5 authors, we're now able to run Mirage apps on GCE. The deployment process:

1. Compile our unikernel
2. Create a tar'd and gzipped bootable disk image locally with our unikernel
3. Upload said disk image (should be ~1-10MB, depending on contents)
4. Create an image from the disk image
5. Trigger a rolling update

The actual cli to do everything looks like this:

```bash
mirage configure -t virtio --dhcp=true \
        --show_errors=true --report_errors=true \
        --mailgun_api_key="<>" \
        --error_report_emails=sean@bushi.do
make clean
make
bin/unikernel-mkimage.sh tmp/disk.raw mir-riseos.virtio
cd tmp/
tar -czvf mir-riseos-01.tar.gz disk.raw
cd ..

# Upload the file to Google Compute Storage
gsutil cp tmp/mir-riseos-01.tar.gz gs://mir-riseos

# Create an image from the new latest file
gcloud compute images create mir-riseos-latest \
   --source-uri gs://mir-riseos/mir-riseos-latest.tar.gz

# Trigger rolling update
gcloud alpha compute rolling-updates start \
    --group mir-riseos-group \
    --template mir-riseos-1 \
    --zone us-west1-a
```

Not too shabby to **launch your unikernel-as-a-site with zero-downtime rolling updates, health-check monitors that'll restart any crashed instance every 30 seconds, and a load balancer that auto-scales based on CPU usage**!
