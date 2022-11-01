#!/bin/bash

userName=test@test.com

DIR="$PWD/MFA-QRCode/"
[ -d "${DIR}" ] &&  echo "Directory $DIR found." || mkdir MFA-QRCode

for profile in alpha
do
    echo "Enabling MFA for profile: $profile..." >> MFA-QRCode/IAMUserMFADeviceSerialNo.txt
    aws iam create-virtual-mfa-device --virtual-mfa-device-name $userName --outfile $PWD/MFA-QRCode/QRCode-$profile.png --bootstrap-method QRCodePNG --query VirtualMFADevice --output text --profile $profile >> MFA-QRCode/IAMUserMFADeviceSerialNo.txt
done

# Output will be like:
# Enabling MFA for profile: alpha...
# {
#     "VirtualMFADevice": {
#         "SerialNumber": "arn:aws:iam::1234567890:mfa/test@test.com"
#     }
# }