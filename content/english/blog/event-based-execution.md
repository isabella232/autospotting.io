---
title: "New AutoSpotting Alpha release - testers wanted"
date: 2020-10-22T10:50:38+01:00
image: images/blog/sky.jpg
author: Cristian Magherusan-Stanciu
---

# New AutoSpotting Alpha release - testers wanted

Hello,

I'm happy to announce that the massive code change that has been in development
since more than a year ago has been merged and after a few further improvements
it's now ready for Alpha/Beta testing by a wider audience.

## What's new

### **Event-based instance replacement**

In a nutshell, when deployed using the latest CloudFormation infrastructure
code, AutoSpotting is now reacting to all new instance launches, in addition to
the legacy cron-based execution mode that's still available as before. Under
normal circumstances **newly launched on-demand instances are now immediately replaced with spot clones**,
avoiding to run the spot clone in parallel to the
AutoScaling group they were launched for which has always been a quirky implementation detail of
AutoSpotting when compared to its alternatives.

In the relatively rare case that no spot instances could be launched or when
running the latest AutoSpotting version without the infrastructure required for
this event-based execution that we deploy from the current CloudFormation code
(maybe if you're running it as container on Kubernetes or the currently
incomplete Terraform support) the on-demand instances would keep running and a
spot instance is launched outside the group and will be replaced later by the
legacy cron execution mode.

### Other changes

To make this work, there were **massive under-the-hood changes** that will make
it easier to add further improvements going forward that could handle various
events from CloudTrail/CloudWatch Events. One such improvement already available
in this latest version is the implementation of emulated **instance startup lifecycle hooks for spot instances**.
This works by intercepting the API calls that fail
for instances not yet added to the group, so we can emulate them in
AutoSpotting. Similar handling would be possible in the future for other events,
such as maybe the event emitted when detaching EBS volumes on instance
termination could be handled by attaching the volume to a new spot instance
towards supporting stateful workloads, or maybe other interesting use cases.
Feel free to reach out or just create issues on Github if you have any such
improvement ideas.

## Main benefits

- The **spot clones are added immediately to the ASG**, booting up as part of
  the ASG so they can set up immediately. Previously, in certain
  situations(Beanstalk, cfn-init) they could only be fully bootstrapped after
  they were swapped into the ASG, which was problematic. Also if the ASG was
  deleted by infrastructure code while a not yet replaced spot instance was
  still running outside the ASG, the stack couldn't be deleted because of
  resources referenced by the still running spot instance(SGs, IAM roles, etc.).
  This should only happen when the spot instances failed to be launched
  immediately.
- **Handling of any number of concurrent instance launches**, such in case of
  new ASGs or when scaling out with multiple instances at once. In such cases
  the ASG is a bit "confused" by all the attach/detach action and briefly shows
  some strange numbers for the desired capacity, but when using CloudFormation
  we have code that helps it eventually converge to the previous capacity by
  temporarily suspending some of the AutoScaling processes that react in weird
  ways to this capacity churn. This code is not yet available when using the
  Terraform deployment method and may still be buggy but it seemed to work
  pretty well in our initial tests.
- Besides the obvious cost implications of only paying on-demand for the first
  minute, this change also makes AutoSpotting a decent option for relatively
  **short-lived AutoScaling groups** where the legacy instance replacement mode
  previously made it unusable.

- Emulated **handling of startup lifecycle hooks for spot instances** and
  significant under the hood improvements that will allow implementation of
  other interesting use cases, such as support for stateful workloads, etc.

## Known issues

- This code is relatively new and bugs are definitely still lurking around, so
  I'm looking for some brave people to try it out, report issues to help mature
  it further. As always, **anyone submitting issues on Github or contributing to the code base receive access to my commercially available stable builds for a year after their contribution, currently charged at $29/month/AWS account.**
- The Terraform/Kubernetes deployment methods weren't yet tested and don't
  implement the full support infrastructure currently available from the
  CloudFormation template, especially the part needed for handling the multiple
  simultaneous instance replacements by suspending the AutoScaling processes.
  This may have other consequences impacting the instance replacements, so I'd
  like to see some contributions from the community to help bring it up-to-speed
  with what we have in CloudFormation or at least ensure it works in legacy
  mode. Unfortunately I don't have enough bandwidth to support all deployment
  methods and need to focus my effort on CloudFormation.

## Next steps

For the near future I'm planning to focus on maturing this recent code towards
making it production-grade but once this is achieved, I'll try to look into the
following pieces of functionality:

- Handling of ICE situations on the ASG's main on-demand instance type -
  [#439](https://github.com/AutoSpotting/AutoSpotting/issues/439)
- Support for stateful workloads -
  [#440](https://github.com/AutoSpotting/AutoSpotting/issues/440)
- Use Dynamic instance type information instead of the current instance type
  database shipped within the Lambda payload -
  [#441](https://github.com/AutoSpotting/AutoSpotting/issues/441)
- Support for China and GovCloud regions -
  [#442](https://github.com/AutoSpotting/AutoSpotting/issues/442) and
  [#443](https://github.com/AutoSpotting/AutoSpotting/issues/443)

As I mentioned before to my mailing list, some of these advanced features
may only be made available commercially to my Patreon supporters, as a sort of
Premium package, but I'd like to get your feedback on this.

## Ways for you to help

- Install the latest nightly version from [here](https://bit.ly/AutoSpotting),
  and provide feedback about it. Keep in mind that this may be buggy, so please
  handle it with care.
- If you can't code and still want to contribute to the development effort, I'd
  love to get your support on [Patreon](https://www.patreon.com/cristim) through
  signing up for the stable builds or the other available support options, or on
  [Github Sponsors](https://github.com/sponsors/cristim) for no-strings-attached
  sponsorship. Any income I receive from these is helping me allocate more time
  to the development of AutoSpotting on a weekly basis.
- I'm always thinking about ways to improve AutoSpotting, the above roadmap is
  enough to keep me busy for a long time and you can always influence it by
  creating or voting on existing Github
  [issues](https://github.com/AutoSpotting/AutoSpotting/issues) . As always,
  Github issues created by Patreon supporters have higher priority, so if you
  are supporting the project and would like to see anything in particular, I'd
  love to hear from you.

## Acknowledgements

- Thanks to everyone who contributed code or feedback towards this release,
  especially [mello7tre](https://github.com/mello7tre),
  [Gabe Gorelick](https://github.com/gabegorelick) and
  [Christopher Farrenden](https://github.com/cfarrend), who helped me a lot over
  the last few months of getting this over the line.
- Also thanks to my former employer [Here Technologies](https://www.here.com/)
  who sponsored the initial development of this work.
- This version wouldn't be available if it wasn't for my supporters on [Patreon](https://www.patreon.com/cristim)
  and  [Github Sponsors](https://github.com/sponsors/cristim), who kept me motivated to keep working on it over the last
  year. Huge thanks to you all!
- Thank you for reading so far, this ended up much longer that I expected ;-)

As always, feel free to reach out to me by answering this email or on
[Gitter](https://gitter.im/cristim) if you have any feedback, questions or
concerns.

Best regards,
Cristian
