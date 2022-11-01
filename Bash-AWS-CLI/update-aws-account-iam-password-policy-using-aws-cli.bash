#!/bin/bash

aws iam get-account-password-policy --profile alpha

### Old Password Policy json ###

# {
#     "PasswordPolicy": {
#         "MinimumPasswordLength": 6,
#         "RequireSymbols": false,
#         "RequireNumbers": false,
#         "RequireUppercaseCharacters": false,
#         "RequireLowercaseCharacters": false,
#         "AllowUsersToChangePassword": false,
#         "ExpirePasswords": false
#     }
# }



aws iam update-account-password-policy --minimum-password-length 14 --require-symbols --require-numbers --require-uppercase-characters --require-lowercase-characters --allow-users-to-change-password --max-password-age 90 --password-reuse-prevention 12 --no-hard-expiry --profile alpha



aws iam get-account-password-policy --profile alpha                         

### New Password Policy json ###

# {
#     "PasswordPolicy": {
#         "MinimumPasswordLength": 14,
#         "RequireSymbols": true,
#         "RequireNumbers": true,
#         "RequireUppercaseCharacters": true,
#         "RequireLowercaseCharacters": true,
#         "AllowUsersToChangePassword": true,
#         "ExpirePasswords": true,
#         "MaxPasswordAge": 90,
#         "PasswordReusePrevention": 12,
#         "HardExpiry": false
#     }
# }
