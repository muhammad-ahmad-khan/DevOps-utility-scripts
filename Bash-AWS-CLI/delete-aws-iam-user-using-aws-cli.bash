#!/bin/bash

########################################################################################
#### To run decalare AWS profile and pass username as input argument to the script  ####
#### I.e. bash delete-aws-iam-user-using-aws-cli.bash test@test.com                 ####
########################################################################################

# Take username as input
userName=$1

# Declare AWS profile below 
# E.g. dev uat prod
for profile in alpha beta gamma
do
    # AWS profile  
    echo -e "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx $profile xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    
    # Check if IAM user already exist
    echo "Checking if IAM user already exist..."
    IAM_USER_RESPONSE=`aws iam get-user --user-name $userName --profile "$profile"`

    if [[ -z "$IAM_USER_RESPONSE" ]]
    then
        echo "IAM user does not exist!"
    else
        echo "IAM user = $userName exists!"
        echo "Deleting IAM user!"

        # List user policies
        user_policies=$(aws iam list-user-policies --user-name $userName --query 'PolicyNames[*]' --output text --profile $profile)
        
        # Delete user policies
        echo "Deleting user policies: $user_policies"
        for policy in $user_policies
        do
            aws iam delete-user-policy --user-name $userName --policy-name $policy --profile $profile
        done

        # List user attached policies
        user_attached_policies=$(aws iam list-attached-user-policies --user-name $userName --query 'AttachedPolicies[*].PolicyArn' --output text --profile $profile)
        
        # Detach user attached policies
        echo "Detaching user attached policies: $user_attached_policies"
        for policy_arn in $user_attached_policies
        do
            aws iam detach-user-policy --user-name $userName --policy-arn $policy_arn --profile $profile
        done
        
        # List user groups
        user_groups=$(aws iam list-groups-for-user --user-name $userName --query 'Groups[*].GroupName' --output text --profile $profile)
        
        # Detach user groups
        echo "Detaching user attached group: $user_groups"
        for group in $user_groups
        do
            aws iam remove-user-from-group --user-name $userName --group-name $group --profile $profile
        done

        # List user access keys
        user_access_keys=$(aws iam list-access-keys --user-name $userName --query 'AccessKeyMetadata[*].AccessKeyId' --output text --profile $profile)
        
        # # Deactivate user access keys
        # echo "Deactivating user access keys: $user_access_keys"
        # for key in $user_access_keys
        # do
        #     aws iam update-access-key --user-name $userName --access-key-id $key --status Inactive --profile $profile
        # done
        
        # Delete user access keys
        echo "Deleting user access keys: $user_access_keys"
        for key in $user_access_keys
        do
            aws iam delete-access-key --user-name $userName --access-key-id $key --profile $profile
        done

        # List user mfa devices
        user_mfa_serial_number=$(aws iam list-mfa-devices --user-name $userName --query 'MFADevices[*].SerialNumber' --output text --profile $profile)
        
        # Deactivate and delete user mfa devices
        echo "Deactivating and deleting user mfa devices: $user_mfa_serial_number"
        for s_no in $user_mfa_serial_number
        do
            aws iam deactivate-mfa-device --user-name $userName --serial-number $s_no --profile $profile
            aws iam delete-virtual-mfa-device --serial-number $s_no --profile $profile
        done
        
        # Delete user login profile
        echo "Deleting user login profile"
        aws iam delete-login-profile --user-name $userName --profile $profile
        
        # Delete user
        echo "Deleting user: $user"
        aws iam delete-user --user-name $userName --profile $profile
        
        # Done message
        echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx Done xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" 
    fi
done