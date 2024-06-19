# Sample calls node.js on Linux

These samples require [Axios](https://github.com/axios/axios) to make the http calls to the API.

## Initialization
The samples require defining the following environment variables

```bash
export SECUREGPT_ADMIN_API_KEY="42ffb5655e384921b4a24fb82a4347ea"
export SECUREGPT_SAMPLE_USER_FIRSTNAME="John"
export SECUREGPT_SAMPLE_USER_LASTNAME="Doe"
export SECUREGPT_SAMPLE_USER_EMAIL="luc.vovan@microsoft.com"
export SECUREGPT_SAMPLE_USER_SKU="eu"

export SECUREGPT_OAIS_ENDPOINT="https://aoais-guardian-apim.azure-api.net"
export SECUREGPT_OAIS_DEPLOYMENT_NAME="lvovan-gpt-35-turbo"
export SECUREGPT_OAIS_API_VERSION="2023-03-15-preview"
```

## Enroll a user
Enrolling a user creates a new APIM user, an associated a subscription and an API key based on the SAMPLE_USER information provided in the environment variables (see above).

```bash
npm install
npm run enroll-user
```

You can then copy and paste the suggested environment variables to run the other samples.

```bash
echo $SECUREGPT_SAMPLE_USER_USERID
echo $SECUREGPT_SAMPLE_USER_APIKEY
```



## Delete a user
This sample removes a user and subscription from APIM. The user removed is the one whose id defined in the `SECUREGPT_SAMPLE_USER_USERID` environment variable

```bash
npm install
npm run "delete-user"
```

## Perform a completion request
This sample leverages the `SECUREGPT_SAMPLE_USER_APIKEY` environment variable to perform a sample Competion request against APIM.

```bash
node chat-completions.js
```

or

```bash
# Load the virtual environment
python chat-completions.py
```

