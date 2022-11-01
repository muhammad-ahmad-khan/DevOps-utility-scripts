#!/bin/bash

userName=test@test.com # $1

# Find authCode from any authenticator app like Authy or Google Authenticator or Microsoft Authenticator which you have used to scan the QR code generated in step1
authCode1=123456 # $2
authCode2=987654 # $3

for profile in alpha
do
    # If mfa device is non-u2f then we can directly use this arn: arn:aws:iam::$account_id:mfa/$userName
    # Get AWS account ID
    # account_id=$(aws sts get-caller-identity --query Account --output text --profile $profile)
    # mfa_device_serial_number=arn:aws:iam::$account_id:mfa/$userName
    
    # u2f device has some random key
    # mfa_device_serial_number=arn:aws:iam::$account_id:u2f/user/$userName/default-ABCDEFGHIJKLMNOPQRSTUVWXYZ
    
    mfa_device_serial_number=$(aws iam list-mfa-devices --user-name $userName --query MFADevices[].SerialNumber --output text --profile $profile)
    
    # Use proper serial number in below command
    echo "Attaching MFA Device to IAM user: $userName in profile: $profile..."
    aws iam enable-mfa-device \
        --user-name $userName \
        --serial-number mfa_device_serial_number \
        --authentication-code1 $authCode1 \
        --authentication-code2 $authCode2 \
        --profile $profile

    # Note: If the MFA is not working after the above command
    #       then try re-entering MFA code in the console until it gives the prompt like we do not have synced your MFA device
    #       then re-enter the consecutive MFA device code to sync it and that's it...

    aws iam list-mfa-devices --user-name "$user" --profile $profile
done