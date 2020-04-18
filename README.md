# kaggle-terraform-starter

![](https://github.com/zach-churchill/kaggle-terraform-starter/workflows/Continuous%20Integration/badge.svg)

This repository contains a Terraform module that can be used to set up your AWS account with various
services that are need for participating in a Kaggle competition.


## Motivation

### Problem Motivation

When getting started with a Kaggle competition it's usually a good idea to use a cloud provider
like AWS so that cheap compute can be utilized. Unfortunately, unless a global IAM role, SageMaker
notebook, etc are used for all competitions, it can be a bit messy with keeping track of all of
the resources used during the competition. The goal of this Terraform module is to provide some
basic services that will make it easier to get started with the competition and clean up afterwards.

### Personal Motivation

After using Terraform a bit at Root Insurance, I have become very interested in the idea of Infrastructure
as Code. Furthermore, given my background of working in the data science space, I wanted to think about
how I would be able to utilize this concept with a data-related activity and thought about how it would
be nice to have a way to set myself up at the start of a Kaggle competition. Naturally, after thinking
through this, I realized that this would also be an amazing way to remove all of the resources after
the competition so money is not being wasted on stale resources.


## Implementation and Use

This module is heavily inspired by the modules provided by [Gruntwork](https://www.gruntwork.io) both in
the code style and spirit of the module.

### Use

First, before utilizing this module to create the services for a competition, be sure to create a secret
with your [Kaggle API credentials](https://github.com/Kaggle/kaggle-api#api-credentials) in
[AWS Secrets Manager](https://aws.amazon.com/secrets-manager/). The name of your secret is important because
it will allow the [SageMaker lifecycle configuration](https://docs.aws.amazon.com/sagemaker/latest/dg/notebook-lifecycle-config.html)
to set up each Notebook with the correct credentials for downloading the Kaggle data from within the notebook.

### Inputs

<dl>
  <dt>competition</dt>
  <dd>- Name of the Kaggle competition used by the `kaggle` API, e.g. house-prices-advanced-regression-techniques</dd>
  <dt>secret\_name</dt>
  <dd>- Name of the secret created in Secrets Manager for your API credentials</dd>
</dl>

