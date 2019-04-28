---
title: "New Stable Release"
date: 2019-04-28T20:09:38+01:00
---

I'm very excited to announce that after many months of development and testing,
a new stable AutoSpotting build has just been released.

# What's new? #

This release contains many new features and under the hood reliability
improvements implemented since the previous stable release:

- Automated **handling of the spot termination notifications** by either
  immediately terminating the instances executing their lifecycle hooks or
  detaching them from the group (and thus load balancer) if there's no lifecycle
  hook configured. **Note**: this feature is **for now only implemented in the
  CloudFormation template**, Terraform support will hopefully be available in the
  next stable release.
- Integration with CloudFormation, **avoiding replacement for on-demand
  instances belonging to CloudFormation stacks in the process of being
  updated**.
- Automatically **terminate orphaned unattached spot instances** resulted by
  scaling-in actions on the AutoScaling group.
- Attempt **launching multiple spot instance types in case of launch failure**,
  in ascending order of the hourly price. This covers any sort of launch
  failures, such as caused by insufficient capacity, VPC/classic compatibility,
  missing support for ENA, unavailability for certain Availability Zones, etc.
  You'll just get the cheapest compatible instance we're able to launch in your
  Availability zone.
- **Use on-demand price of the original instance** as default spot bid price.
- **Support for newly released instance types**, including those based on ARM
  and AMD CPUs, and even experimental support for bare metal instance types.
- Automatically **ensure compatibility for ARM and Intel-compatible CPUs**
  without the need to manually whitelist any instance types or blacklist the
  instance types of the other architectures.

# How to install or update? #

The installation instructions are only available to
[Patreon](https://www.patreon.com/cristim) supporters and code contributors.

- If you're a Patron, [here](https://www.patreon.com/posts/26040159)
  you can get the installation instructions.
- If you're not yet a Patron, you can join
  [here](https://www.patreon.com/join/cristim) to get access to the stable
  build.
- Code contributors are allowed to use this stable build for a year after their
  latest contribution to the project. Please get in touch with me on Gitter to
  receive the installation instructions if you contributed a significant feature
  or non-trivial amount of code to the project, just send me a link to your
  latest merged pull request.

# Closing words #

 This release wouldn't be possible without all the people who contributed code
 or reported issues, and especially those who supported the development effort
 here on Patreon and kept me motivated enough to make it happen.

Huge thanks to you all!

As always, feel free to reach out on [Gitter](https://gitter.im/cristim) if you
have any feedback, questions or concerns about AutoSpotting or if you run into
any issues with this release. I'll do my best to help you get the most out of
AutoSpotting.

Thanks again,
Cristian