# Cirun

The CI is powered by [cirun.io](https://cirun.io). Cirun is a service to spinup GitHub Actions Runners on a cloud provider (OpenStack in this case).

## Setup

Roughly:

1. Organizations need to install the Cirun app for Github, and enable it in the target repositories.
2. Add the cloud provider details in Cirun's configuration dashboard.
3. Add the runner configuration in the `.cirun.yml` file in the repository.
4. Modify the GitHub Actions workflow to use the self-hosted runners created by Cirun.

More details can be found in Cirun's documentation.

## How does it work

Cirun application is installed on a GitHub repository, which authorises it to listen to webhook events. Whenever there is a
GitHub Actions workflow job, cirun receives a webhook event, which contains the label for the requested runners. Cirun then
reads the cirun cofniguration file to find our the full runner configuration such as cloud, image, instance type, etc.

Cirun then makes a request to the given cloud provider (OpenStack in this case) to create a runner. The request full provisioning
configuration to spinup the runner and connect it to the github repository and run the requested job. OpenStack when recieved the API
request creates a VM for the job and deletes the VM when it recieves another request from Cirun when the job is completed.
