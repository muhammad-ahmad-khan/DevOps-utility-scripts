#!/bin/bash

# Take username as input
userName=$1

# Declare AWS profile below 
# E.g. dev uat prod
for profile in alpha
do 
    # list aws account alias 
    account_alias=$(aws iam list-account-aliases --query 'AccountAliases' --output text --profile $profile)
    echo "AWS Account Alias: $account_alias" >> IAMResetUserCredentials.txt

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
    echo "Password: $passw0rd" >> IAMResetUserCredentials.txt
    
    # Update password -----> --password-reset-required | --no-password-reset-required
    updatePwdResult=`aws iam update-login-profile --user-name "$userName" --password "$passw0rd" --no-password-reset-required --profile "$profile"`
    
    echo -e "\n" >> IAMResetUserCredentials.txt
done