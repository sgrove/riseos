# Topics
 - What are unikernels?
   - What's MirageOS?
 - Public hosting for unikernels
   - AWS
   - GCE
   - DeferPanic
   - Why GCE?
 - Problems
   - Xen -> KVM (testing kernel output via QEMU)
   - Bootable disk image
   - Virtio problems
     - DHCP lease
     - TCP/IP stack
     - Crashes
 - Deployment
   - Compiling an artifact
   - Initial deploy script
   - Zero-downtime instance updates
   - Scaling based on CPU usage (how cool are the GCE suggestions to downsize an under-used image?)
   - Custom deployment/infrastructure with Jitsu [^2]

# Continuously Deploying Mirage Unikernels to Google Compute Engine using CircleCI

Or "Launch your unikernel-as-a-site with a zero-downtime rolling updates, health-check monitors that'll restart an instance if it crashes every 30 seconds, and a load balancer that'll auto-scale based on CPU usage with every git push"

*This post talks about achieving a production-like deploy pipeline for a publicly-available service built using Mirage, specifically using the fairly amazing Google Compute Engine infrastructure. I'll talk a bit about the progression to the current setup, and some future platforms that might be usable soon.*

## What are unikernels?

 > Unikernels are specialised, single-address-space machine images constructed by using library operating systems.

Easy! ...right?

The short, high-level idea is that unikernels are the equivalent of *opt-in* operating systems, rather than *opt-out-if-you-can-possible-figure-out-how*.

For example, when we build a virtual machine using a unikernel, we only include the code necessary for our *specific* application. Don't use a block-storage device for your Heroku-like application? The code to interact with block-devices won't be run at all in your app - in fact, it won't even be included in the final virtual machine image.

And when your app is running, it's the *only* thing running. No other processes vying for resources, threatening to push your server over in the middle of the night even though you didn't know a service was configured to run by default.

There are a few immediately obvious advantages to this approach:

 * __Size__: Unikernels are typically microscopic as deployable artifacts
 * __Efficiency__: When running, unikernels only use the bare minimum of what your code needs. Nothing else.
 * __Security__: Removing millions of lines of code and eliminating the inter-process protection model from your app drastically reduces attack surface
 * __Simplicity__: Knowing exactly what's in your application, and how it's all running considerably simplifies the mental model for both performance and correctness

### What's [MirageOS](https://mirage.io/)?

> MirageOS is a library operating system that constructs unikernels for secure, high-performance network applications across a variety of cloud computing and mobile platforms

Mirage (which is a very clever name once you get it) is a library to build clean-slate unikernels using OCaml. That means to build a Mirage unikernel, you need to write your entire app (more or less) in OCaml. I've talked quite a bit now about why [OCaml is pretty solid](https://www.youtube.com/watch?v=QWfHrbSqnB0), but I understand if some of you run away screaming now. No worries, there are other approaches to unikernels that may work better for you[^5]. But as for me and my house, we will use Mirage.

There are some great talks that go over some of the cool aspects of Mirage in much more detail [^1][^4], but it's unclear if they're actually *usable* in any major way. There are even companies that take out ads against unikernels, highlighting many of the ways in which they're (currently) unsuitable for production:

![https://pbs.twimg.com/media/CpR9xXPVYAAOYcy.jpg:small]()

Bit weird, that.

But I suspect that bit by bit this will change, assuming sufficient elbow grease and determination on our parts. So with that said, let's roll up our sleeves and figure out one of the biggest hurdles to using unikernels in production today: deploying them!

## Public hosting for unikernels

Having written our app as a unikernel, how do we get it up and running in a production-like setting? I've used AWS fairly heavily in the past, so it was my initial go-to for this site.

AWS runs on the Xen hypervisor, which is the main non-unix target Mirage was developed for. In theory, it should be the smoothest option. Sadly, the primitives and API that AWS expose just don't match well. The [process is something](https://mirage.io/wiki/xen-boot) like this:

 1. Download the AWS command line tools
 1. Start an instance
 1. Create, attach, and partition an EBS volume (we'll turn this into an AMI once we get our unikernel on it)
 1. Copy the Xen unikernel over to the volume
 1. Create the GRUB entries... blablabla
 1. Create a snapshot of the volume ohmygod
 1. Register your AMI using the `pv-grub` kernel id what was I doing again
 1. Start a new instance from the AMI

Unfortunately #3 means that we need to have a *build machine* that's on the AWS network so that we can attach the volume, and we need to SSH into the machine to do the heavy lifting. Also, we end up with a lot of left over detritus - the volume, the snapshot, and the AMI. It could be scripted at some point though.

### GCE to the rescue!

[GCE](https://cloud.google.com/compute/) is Google's public computing offering, and I currently can't recommend it highly enough. The per-minute pricing model is a much better match for instances that boot in less than 100ms, the interface is considerably nicer and offers the equivalent REST API call for most actions you take, and the primitives exposed in the API mean we can much more easily deploy a unikernel. Win, win, win!

#### GCE Challenges

##### Xen -> KVM

There is a big potential show-stopper though: GCE uses the KVM hypervisor instead of Xen, which is much, much nicer, but not supported by Mirage as of the beginning of this year. Luckily, some fairly crazy heroes ([Dan Williams](https://github.com/djwillia), [Ricardo Koller](https://github.com/ricarkol?tab=activity), and [Martin Lucina](lucina.net), specifically) stepped up and made it happen with [Solo5](https://mirage.io/blog/introducing-solo5)!

> Solo5 Unikernel implements a unikernel base, or the lowest layer of code inside a unikernel, which interacts with the hardware abstraction exposed by the hypervisor and forms a platform for building language runtimes and applications. Solo5 currently interfaces with the MirageOS ecosystem, enabling Mirage unikernels to run on either Linux KVM/QEMU

I highly recommend checking out a replay of the great webinar the authors gave on the topic https://developer.ibm.com/open/solo5-unikernel/ It'll give you a sense of how much room for optimization and cleanup there is as our hosting infrastructure evolves.

Now that we have KVM kernels, we can test them locally fairly easily using QEMU, which shortens the iterations while we dealt with teething on the new platform. The 

##### Bootable disk image

This was just on the other side of my experience/abilities, personally. Constructing a disk image that would boot a custom (non-Linux) kernel isn't something I've done before, and I struggled to remember how the pieces fit together. Once again, @mato came to the rescue with a [lovely little script](https://github.com/ricarkol/solo5/blob/gce/unikernel-mkimage-ubuntu.sh) that does exactly what we need, no muss, no fuss.

##### Virtio driver

Initially we had booting unikernels that printed to the serial console just fine, but didn't seem to get any DHCP lease. The unikernel was sending [DHCP discover broadcasts](https://gist.github.com/sgrove/61639cd51a7d18968ba504d1bb53de9f), but not getting anything in return, poor lil' fella. I then tried with a hard-coded IP literally configured at compile time, and booted an instance on GCE with a matching IP, and still nothing. Nearly the *entire* Mirage stack is in plain OCaml though, including the [TCP/IP stack](https://github.com/mirage/mirage-tcpip), so I was able to add in plenty of debug log statements and see [what](https://gist.github.com/sgrove/d24c46d92b60b74aeeab4d6915e87014) [was](https://gist.github.com/sgrove/4ce54a3fb367db4eb501ffdd3970db13) [happening](https://gist.github.com/sgrove/8435a902215e536f9621e42979d06db1). Finally tracked everything down to problems with the Virtio implementation, quoting @ricarkol:

> The issue was that the vring sizes were hardcoded (not the buffer length as I mentioned above). The issue with the vring sizes is kind of interesting, the thing is that the virtio spec allows for different sizes, but every single qemu we tried uses the same 256 len. The QEMU in GCE must be patched as it uses 4096 as the size, which is pretty big, I guess they do that for performance reasons. - @ricarkol

I tried out the fixes, and we had a booting, publicly accessible unikernel! However, it was extremely slow, with no obvious reason why. Looking at the logs however, I saw that I had forgotten to remove a ton of [logging *per-frame*](https://gist.github.com/sgrove/74af214bf611f8ba7932bf555340d132). Careful what you wish for with accessibility, I guess!

##### Position-independent Code

This was a deep rabbit hole. The [bug manifested](https://github.com/Solo5/solo5/issues/74) as `Fatal error: exception (Invalid_argument "equal: abstract value")`, which seemed strange since the site worked on Unix and Xen backends, so there shouldn't have been anything logically wrong with the OCaml types, despite what the exception message hinted at. Read [this comment](https://github.com/Solo5/solo5/issues/73#issuecomment-240424167) for the full, thrilling detective work and explanation, but a simplified version seems to be that portions of the OCaml/Solo5 code were placed in between the bootloader and the entry point of the program, and the bootloader zero'd all the memory in-between (as it should) before handing control over to our program. So eventually our program did some comparison of values, and a portion of the value had at compile/link time been relocated and destroyed, and OCaml threw the above error.

##### Crashes

Finally, we have a booting, non-slow, publicly-accessible Mirage instance running on GCE! Great! However, every ~50 http requests, it panics and dies:

    [11] serving //104.198.15.176/stylesheets/normalize.css.
    [12] serving //104.198.15.176/js/client.js.
    [13] serving //104.198.15.176/stylesheets/foundation.css.
    [10] serving //104.198.15.176/images/sofuji_black_30.png.
    [10] serving //104.198.15.176/images/posts/riseos_error_email.png.
    PANIC: virtio/virtio.c:369
    assertion failed: "e->len <= PKT_BUFFER_LEN"
    
Oh no! However, being a bit of a kludgy-hacker desperate to get a stable unikernel I can show to some friends, I figured out a terrible workaround: GCE offers fantastic health-check monitors that'll restart an instance if it crashes because of a virtio (or whatever) failure every 30 seconds. Problem solved, right? At least I don't have restart the instance personally...

And that was an acceptable temporary fix until @ricarkol was once again able to track down the cause of the crashes and fix things up that had to do with some GCE/Virtio IO buffer descriptor wrinkle:

> The second issue is that Virtio allows for dividing IO requests in multiple buffer descriptors. For some reason the QEMU in GCE didn't like that. While cleaning up stuff I simplified our Virtio layer to send a single buffer descriptor, and GCE liked it and let our IOs go through - @ricarkol

So now Solo5 unikernels seem fairly stable on GCE as well! Looks like it's time to wrap everything up into a nice deploy pipeline.

## Deployment

With the help of the GCE support staff and the Solo5 authors, we're now able to run Mirage apps on GCE. The process in this case looks like this:

 1. Compile our unikernel
 1. Create a tar'd and gzipped bootable disk image locally with our unikernel
 1. Upload said disk image (should be ~1-10MB, depending on our contents. Right now this site is ~6.6MB)
 1. Create an image from the disk image
 1. Trigger a rolling update

Importantly, because we can simply upload bootable disk images, we don't need any specialized build machine, and the entire process can be automated!

### One time setup

We'll create two abstract pieces that'll let us continually deploy and scale: An instance group, and a load balancer.

### Creating the template and instance group

First, two quick definitions...

Managed instance groups:

> A managed instance group uses an instance template to create identical instances. You control a managed instance group as a single entity. If you wanted to make changes to instances that are part of a managed instance group, you would apply the change to the whole instance group.

And templates:

> Instance templates define the machine type, image, zone, and other instance properties for the instances in a managed instance group. 


We'll can create a template that we'll use to update and scale:

    gcloud compute instance-templates create mir-riseos-1 --machine-type f1-micro --image mir-riseos-latest --boot-disk-size 1GB

(Note that while `1GB` is fantastically overkill for our tiny 6MB unikernel, it's the smallest allowed by GCE). Now we're almost there for our first deploy, we just need to set up the load balancer!

### Setting up the [load balancer](https://cloud.google.com/compute/docs/load-balancing/)

Overall there's not much to say here, GCE makes this trivial. We simply say what class of instances we want (vCPU, RAM, etc.), what the trigger/threshold to scale is (CPU usage or request amount), and the image we want to boot as we scale out.

We can set it all up in about three steps:

1. Create a basic health-check
1. Set up a backend service
1. Configure the frontend 

#### Health Check
GCE is kind enough to watch our instances for us and kill/restart them if they're unhealthy, we just need to provide it a way of checking. So the first step in our load balancer is to set up a health check:

    gcloud compute http-health-checks create riseos-basic-http-health --request-path "/healthy" --timeout 10 --interval 30 --protocol http --healthy-threshold 2 --unhealthy-threshold 6

We're configuring GCE to check our instances every 30 seconds at `/healthy`, and if a given instance fails to respond (or returns a non-200 response) within 10 seconds, it fails the check. Failing 6 consecutive checks marks an instances as unhealthy, and passing two marks it as healthy again (this is use later to decide to auto-kill/restart instances).

#### Backend service

So now we know the health of our instances so they can be auto-pruned, we need a backend service for our load balance to, erm, balance between.

    gcloud compute backend-services create mir-riseos-service --session-affinity none --http-health-check riseos-basic-http-health 
    gcloud compute backend-services add-backend mir-riseos-server --instance-group mir-riseos-group --balancing-mode utilization --max-utilization 0.8 --capacity 1.0
    gcloud compute instance-groups managed set-autoscaling mir-riseos-group --max-num-replicas 10 --target-cpu-utilization 0.80 --cool-down-period 5

In this case, I'm using a fairly small instance with the instance group we just created, and I want another instance whenever we sustained CPU usage over 80%, to a maximum of 10 instances.

### Subsequent deploys

The actual cli to do a full unikernel rebuild and deploy looks like this:

    mirage configure -t virtio --dhcp=true --show_errors=true --report_errors=true --mailgun_api_key="<>" --error_report_emails=sean@bushi.do
    make clean
    make
    bin/unikernel-mkimage.sh tmp/disk.raw mir-riseos.virtio
    cd tmp/
    tar -czvf mir-riseos-01.tar.gz disk.raw
    cd ..

    # Upload the file to Google Compute Storage as the original filename
    gsutil cp tmp/mir-riseos-01.tar.gz  gs://mir-riseos

    # Copy/Alias it as *-latest
    gsutil cp gs://mir-riseos/mir-riseos01.tar.gz gs://mir-riseos/mir-riseos-latest.tar.gz
    
    # Delete the image if it exists
    y | gcloud compute images delete mir-riseos-latest
    
    # Create an image from the new latest file
    gcloud compute images create mir-riseos-latest --source-uri gs://mir-riseos/mir-riseos-latest.tar.gz
    
    # Updating the mir-riseos-latest *image* in place will mutate the
    # *instance-template* that points to it.  To then update all of our
    # instances with zero downtime, we now just have to ask gcloud to do a
    # rolling update to a group using said *instance-template*.
    gcloud alpha compute rolling-updates start --group mir-riseos-group --template mir-riseos-1 --zone us-west1-a
    
Or, after splitting this up into two scripts:

    export NAME=mir-riseos-1 CANONICAL=mir-riseos GCS_FOLDER=mir-riseos
    bin/build_kvm.sh
    gce_deploy.sh

Not too shabby to - once again - __launch your unikernel-as-a-site with zero-downtime rolling updates, health-check monitors that'll restart any crashed instance every 30 seconds, and a load balancer that auto-scales based on CPU usage__. The next step is to hook up [CircleCI](https://circleci.com/) so we have continuous deploy of our unikernels on every push to master.

## CircleCI

The biggest blocker here, and one I haven't been able to solve yet, is the OPAM switch setup. My current docker image has (apparently) a hand-selected list of packages and pins that is nearly impossible to duplicate elsewhere.

[^1]: https://www.youtube.com/watch?v=UEIHfXLMtwA - Anil's Haskell 2014 Keynote

[^2]: https://www.youtube.com/watch?v=b6Rd4XZPxDA - Anil's talk on Jitsu

[^4]: https://www.youtube.com/watch?v=zi2TdMXs7Cc - Amir's Polyconf 2014 talk

[^5]: For an example of running existing applications (in this case nginx) as a unikernel, check out Madhuri Yechuri and Rean Griffith's talk http://www.slideshare.net/MadhuriYechuri1/metrics-towards-enterprise-readiness-of-unikernels-65242514?qid=fc9889bf-80ce-49e6-b22f-7001dacbd1b0
