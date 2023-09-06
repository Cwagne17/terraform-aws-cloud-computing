# Lab 1 - EC2

## Question 2

The region us-east-1 is located in North Virginia.
It is the region closest to me and the one I deploy
to most often.

An AWS region is a physical geographic location in the
world that contains a cluster of AWS data centers.

An AWS Availability Zone (AZ) is a distinct location
within an AWS Region that are engineered to be isolated
from failures in other Availability Zones. A single
AWS Region contains multiple Availability Zones.

The us-east-1 region contains the following AZs:
us-east-1a, us-east-1b, us-east-1c, us-east-1d, us-east-1e

## Question 3

An Amazon Machine Image (AMI) is a supported and 
maintained image provided by AWS that provides the 
information required to launch an instance.
An AMI can be selected based on many criteria.
The AMI can be selected based on the operating system,
virtualization type, architecture, and storage for example.
A full list of criteria can be found at the following link:
https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-images.html
I chose the Amazon Linux 2 AMI because it was built specifically
for running on AWS Cloud. In many ways it is optimized for security
and performance. It is also free tier eligible.
Under the Quickstart tab, there are three options for where to find AMIs:
My AMIs is a list of AMIs that you have created or have been shared with you.
AWS Marketplace is a list of AMIs that have been created by third parties
that are verified by AWS.
Community AMIs is a list of AMIs that are available for use that have been
released for public use. These AMIs are not nessecarily verified by AWS.

## Question 4

The different instance types represent different combinations of CPU, memory, storage, and networking capacity. Each instance type includes one or more instance sizes, allowing you to scale your resources to the requirements of your target workload. Additionally, the instance types are grouped into families based on their general purpose. For example, the t2 family is designed for general purpose computing, while the c5 family is designed for compute-intensive workloads.

## Question 5

## Question 6

## Question 7

## Question 8

A security group acts as a virtual firewall for your instance to control inbound (ingress) and outbound (egress) traffic. A security group is stateful, meaning if you allow inbound traffic, return traffic is automatically allowed and vice versa.

## Question 9

## Question 10

A key pair is created an used to connect to the EC2 instance. If you lose the key pair, you will not be able to connect to the EC2 instance with SSH. However, there is an alternative method to connect to the EC2 instance through the AWS console.
