#!/bin/bash

########################################################################################
#### To run decalare AWS profile and pass username as input argument to the script  ####
#### I.e. bash create-aws-iam-user-using-aws-cli.bash test@test.com                 ####
########################################################################################

# Take username as input
userName=$1

# Declare AWS profile below 
# E.g. dev uat prod
# ninja ninja2 ninja3 ninja4 ninja5 ninja6 ninja7 ninja8 ninja9 ninja10 ninja11 dev dev2 uat uat2 dev-integration uat-integration demo baseline
for profile in alpha beta gamma
do 
    # Add AWS console url
    echo "AWS Console URL: https://console.aws.amazon.com/console/home" >> newIAMUserCredentials.txt

    # List AWS account alias 
    account_alias=$(aws iam list-account-aliases --query 'AccountAliases' --output text --profile $profile)
    echo "AWS Account Alias: $account_alias" >> newIAMUserCredentials.txt

    # Check if IAM user already exist
    echo "Checking if IAM user already exist..."
    IAM_USER_RESPONSE=`aws iam get-user --user-name $userName --profile "$profile"`

    if [[ -z "$IAM_USER_RESPONSE" ]]
    then
        echo "IAM user does not exist!"
        echo "Creating IAM user!"
        
        # Create user 
        user_name=$(aws iam create-user --user-name $userName --query 'User.UserName' --output text --profile $profile)  
        echo "Username: $user_name" >> newIAMUserCredentials.txt
        
        # Generate random password of 16 characters
        # Using constants including capital and small alphabets as well as special characters as per AWS console password policy requirement!
        chars='@#)$%&!(-+=\*^'
        charsCapitalLetter='QWERTYUIOPASDFGHJKLZXCVBNM'
        charsSmallLetter='qwertyuiopasdfghjklzxcvbnm'
        passw0rd=`openssl rand -base64 16 | tr -d "=+/" | cut -c1-5`
        passw0rd+="$((RANDOM % 9))"
        passw0rd+="${chars:$((RANDOM % ${#chars})):1}"
        passw0rd+="${charsSmallLetter:$((RANDOM % ${#charsSmallLetter})):1}"
        passw0rd+="$((RANDOM % 9))"
        passw0rd+=`openssl rand -base64 32 | tr -d "=+/" | cut -c1-5`
        passw0rd+="${chars:$((RANDOM % ${#chars})):1}"
        passw0rd+="${charsCapitalLetter:$((RANDOM % ${#charsCapitalLetter})):1}"
        echo "Password: $passw0rd" >> newIAMUserCredentials.txt

        # Enable AWS console access
        aws iam create-login-profile --user-name $userName --password $passw0rd --password-reset-required --profile $profile

        # Create access keys for programmatic access
        # Parsing response using python
        # We can also use jq here
        aws iam create-access-key --user-name $userName --profile $profile | \
            python -c 'import json,sys;response=json.load(sys.stdin);print( '"'"'Access Key ID: '"'"' + response["AccessKey"]["AccessKeyId"] + '"'"'\n'"'"' + '"'"'Secret Access Key: '"'"' + response["AccessKey"]["SecretAccessKey"] )' >> newIAMUserCredentials.txt
        
        # list groups
        _groups=$(aws iam list-groups --query 'Groups[].GroupName' --output text --profile $profile)
        
        # Add user to existing groups to provide permissions
        for group in $_groups
        do
            # Check the Admin group by finding substring 'Admin' in group name from groups list
            if [[ $group =~ "Admin" ]]
            then
                echo "Found Admin Group! $group"
                echo "Adding user to group: $group"
                aws iam add-user-to-group --user-name $userName --group-name $group --profile $profile
            fi
        done
        
    else
        echo "IAM user = $userName already exists!" >> newIAMUserCredentials.txt
    fi

    echo -e "\n" >> newIAMUserCredentials.txt
done
