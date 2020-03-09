#!/bin/bash

set -e
ARG=$1

if [ "$ARG" = "create" ]
then
    echo "Deploying Terraform Infrastructure"
    cd terraform && terraform init > /dev/null
    terraform apply -auto-approve > /dev/null

    # Assign variables based on TF output
    echo "Getting variables"
    repo_url=$(terraform output ecr_repo_url)
    cluster_name=$(terraform output ecs_cluster_name)
    service_name=$(terraform output ecs_service_name)
    public_url=$(terraform output load_balancer_address)

    # Build image and login to ECR
    echo "Logging in to ECR"
    login_cmd=$(aws ecr get-login --no-include-email)
    echo "Building Dockerfile"
    cd .. && docker build --rm -f "Dockerfile" -t "$repo_url" . > /dev/null
    eval $login_cmd > /dev/null
    # Push image
    docker push $repo_url > /dev/null

    # Trigger a new deployment of the fargat containers.
    echo "Triggering app deployment!"
    aws ecs update-service --cluster $cluster_name --service $service_name --force-new-deployment > /dev/null
    echo "Deployment complete!"

    # Echo important info
    echo ""
    echo "Details:"
    echo "Public URL: ${public_url}"
    echo ""
elif [ "$ARG" = "destroy" ]
then
    echo "Destroying ALL Terraform Infrastructure. This cannot be undone. You can 5 seconds to cancel (CTRL-C)!"
    sleep 5
    cd terraform && terraform destroy -auto-approve > /dev/null
    echo "Destroy completed."
fi