# Elastic Beanstalk environment

Template file that builds an Elastic Beanstalk app with an environment in the Elastic Beanstalk service.

For this environment creation, this template assumes that:

1) **VPC** and **subnets** were previously created (just their IDs are needed)
2) A **S3 bucket** for Elatic Beanstalk environment's application versions was previously created
3) A **S3 bucket** for Load Balancer access logs was previously created
4) A **KMS key** to encrypt/decrypt CloudWatch logs was previously created
5) Some **secrets** were created and stored on Secrets Manager service
6) The app has a **health endpoint** 
7) The app is stored on a **GitHub repo** since the AWS CodeBuild example used here integrates with GitHub
8) The user who uploads this template with have Full Access permissions to all related AWS services