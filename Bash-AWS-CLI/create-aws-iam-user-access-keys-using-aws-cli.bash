#!/bin/bash

########################################################################################
#### To run decalare AWS profile and pass username as input argument to the script  ####
#### I.e. bash create-aws-iam-user-access-keys-using-aws-cli.bash test@test.com     ####
########################################################################################

# Take username as input
userName=$1

# Declare AWS profile below 
# E.g. dev uat prod
for profile in ninja ninja2 ninja3 ninja4 ninja5 ninja6 ninja7 ninja8 ninja9 ninja10 ninja11 dev dev2 dev3 uat uat2
do 

    # List AWS account alias 
    account_alias=$(aws iam list-account-aliases --query 'AccountAliases' --output text --profile $profile)
    echo "AWS Account Alias: $account_alias" >> newIAMUserCredentials.txt

    # Create access keys for programmatic access
    # Parsing response using python
    # We can also use jq here
    aws iam create-access-key --user-name $userName --profile $profile | \
        python -c 'import json,sys;response=json.load(sys.stdin);print( '"'"'Access Key ID: '"'"' + response["AccessKey"]["AccessKeyId"] + '"'"'\n'"'"' + '"'"'Secret Access Key: '"'"' + response["AccessKey"]["SecretAccessKey"] )' >> newIAMUserCredentials.txt
        
    echo -e "\n" >> newIAMUserCredentials.txt
done
