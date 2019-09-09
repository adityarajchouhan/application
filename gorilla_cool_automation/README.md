# Timeoff App on AWS!

Let's talk about how to setup a timeoff app in aws in a super automated way. You won't believe it :)

First, let's clone this git repository to our local machine, like this:
```sh
$ git clone https://github.com/ricardoandre97/application ~/timeoff-app-local
$ cd ~/timeoff-app-local/gorilla_cool_automation
```
>Once you have the repo in your machine, the magic comes in! 
>You will see, that in the `gorilla_cool_automation` directory (your current directory) there are a couple of files. Let's see what they are for:
* `magic.sh` -> This script will deploy all the needed infrastructure in AWS for you
* `cfn/master.yaml` -> This is the master template, which call some child templates. So, we will play with nested templates!
* `cfn/templates` -> These are the templates used by the master.yaml file

# Let's start!
>Before starting, please install `aws-cli` and configure your aws credentials to connect to aws through the CLI. You can use `aws configure` to do this.

Now that you know a bit about the setup, take a look at the `magic.sh` file. There are some paramaters that you might want to change:

* You can set `AWS_DEFAULT_REGION` to any region. This will override the region that you set using `aws_configure`.
* You can set `CFN_BUCKET` to any valid name for buckets in s3. This bucket will be created if it's not found in your account, so no worries.
* You can set `STACK_NAME` to any valid name for cfn stacks. The master stack will have this name, and the child stacks will inherit this as a prefix.
* You can set `REPO_NAME` to any valid name for codecommit repos. This will be the name of the codecommit repo that will be created.
* You can set `KEY_NAME` to any valid name for aws keypairs. If the key doesn't exist in your account, one will be created in aws. The private key file will be available on your current directory.

>If you don't need to modify anything, it's completely ok! The default values should work.

Now, just run the script!
```
$ chmod +x magic.sh
$ ./magic.sh
```

This will do some validations, upload the templates file to s3, and deploy a cloudformation stack with a couple of things:
* 1 Vpc
* 2 Public Subnets in different AZ's
* 1 ECR
* 1 CodeCommit
* 1 CodePipeline
* 1 EFS
* 1 ECS Cluster
* 1 AutoScalingGroup with 2 instances (by default)
* 1 ALB

Just wait till it finishes. You can go to the cloudformation console and check what's being created. (This might take a few minutes)
# After creation!
You are ready to go!
>in order to connect to CodeCommit, please, go and manually create a user in IAM, and give it git credentials. You can check this for help:
https://aws.amazon.com/blogs/devops/introducing-git-credentials-a-simple-way-to-connect-to-aws-codecommit-repositories-using-a-static-user-name-and-password/
The user was not created in Cloudformation to avoid conflicts if you use any kind of  external users' db. So, please create it manually.

Go to the cloudformation console, look for the CodeCommit Stack/Outputs, grab the Clone Url, clone it locally using the user that you created, and it should be good!
```
$ git clone https://my-codecommit-aws/repo ~/timeoff-app-aws
```
Cool! From here, you are pretty much done.
Now, just copy the code from the github repo, to the codecommit repo and push it!

```
cp -r ~/timeoff-app-local/* ~/timeoff-app-aws # Copy the code from the local github repo to the codecommit
git add .
git commit -m "My first commit"
git push origin master
```

You are all set! Now, the pipeline should be running and building stuff! (You can go to the cloudformation console, look for the pipeline stack, go to the outputs and you will see the URL)

Once the pipeline finishes, the app should be working fine using the loadbalancer DNS! (You can check the LB DNS by going to CloudFormation, look for the ALB stack, outputs, and copy and paste the DNS name!)

That's it!

# Summary
* Clone the GitHub repo locally and run the magic script
* Upload the same code to the codecommit repo
* Wait for the pipeline to finish, and go to the LB's Dns, and the app should be fine.


# Architecture

This is a simple diagram of the overwall architecture

![TimeOff.Arch Screenshot](https://raw.githubusercontent.com/ricardoandre97/application/master/public/img/timeoff-arch.jpg)
