#!/bin/bash

export PROFILES=`cat ~/.aws/credentials | grep "\[" | tr -d "[]"`
for profile in $PROFILES; do echo -e "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx $profile xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"; account_alias=$(aws iam list-account-aliases --query 'AccountAliases' --output text --profile $profile); echo -e "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx $account_alias xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"; aws sts get-caller-identity --profile $profile; done
# for profile in alpha beta gamma delta; do echo -e "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx $profile xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"; account_alias=$(aws iam list-account-aliases --query 'AccountAliases' --output text --profile $profile); echo -e "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx $account_alias xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"; aws sts get-caller-identity --profile $profile; done
