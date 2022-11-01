#!/bin/bash

########################################################################################
#### To run decalare AWS profile and pass username as input argument to the script  ####
#### I.e. bash reset-aws-iam-user-credentials-using-aws-cli.bash test@test.com      ####
########################################################################################

# Take username as input
userName=$1

# Declare AWS profile below 
# E.g. dev uat prod
for profile in alpha beta gamma
do
    # AWS profile  
    echo -e "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx $profile xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    
    echo "Checking if IAM user already exist..."
    IAM_USER_RESPONSE=`aws iam get-user --user-name $userName --profile "$profile"`
    if [[ -z "$IAM_USER_RESPONSE" ]]
    then
        echo "IAM user does not exist!"
    else
        echo "IAM user = $userName exists!"
        echo "Deleting IAM user credentials!"

        # List user access keys
        user_access_keys=$(aws iam list-access-keys --user-name $userName --query 'AccessKeyMetadata[*].AccessKeyId' --output text --profile $profile)
        
        # Delete user access keys
        echo "Deleting user access keys: $user_access_keys"
        for key in $user_access_keys
        do
            aws iam delete-access-key --user-name $userName --access-key-id $key --profile $profile
        done

        # Uncomment below if you also want to reset MFA devices
        # # List user mfa devices
        # user_mfa_serial_number=$(aws iam list-mfa-devices --user-name $userName --query 'MFADevices[*].SerialNumber' --output text --profile $profile)
        
        # # Deactivate and delete user mfa devices
        # echo "Deactivating and deleting user mfa devices: $user_mfa_serial_number"
        # for s_no in $user_mfa_serial_number
        # do
        #    aws iam deactivate-mfa-device --user-name $userName --serial-number $s_no --profile $profile
        #    aws iam delete-virtual-mfa-device --serial-number $s_no --profile $profile
        # done
        
        echo "Creating IAM user credentials!"
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

        # update password -----> --password-reset-required | --no-password-reset-required
        updatePwdResult=`aws iam update-login-profile --user-name "$userName" --password "$passw0rd" --password-reset-required --profile "$profile"`

        # Create access keys for programmatic access
        # Parsing response using python
        # We can also use jq here
        aws iam create-access-key --user-name $userName  --profile $profile | \
            python -c 'import json,sys;response=json.load(sys.stdin);print( '"'"'Access Key ID: '"'"' + response["AccessKey"]["AccessKeyId"] + '"'"'\n'"'"' + '"'"'Secret Access Key: '"'"' + response["AccessKey"]["SecretAccessKey"] )' >> newIAMUserCredentials.txt
        
        echo -e "\n" >> newIAMUserCredentials.txt
        
        # Done message
        echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx Done xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    fi
done