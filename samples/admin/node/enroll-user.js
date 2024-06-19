// This code snippet is for Node.js
// run ```npm install``` then ```node enroll-user.js```

// This script is used to enroll a user in the system.
// It require the following node modules:
// - axios
// The apiKey used must have access to the following APIs:
// - /admin/users/enroll
// This will print a JSON object with the following format:
// {
//     "apiKey": "000000000000000000000000000000000",
//     "userId": "0000000000-000000000000-00000000000"
// }

const apiEndpoint = process.env["SECUREGPT_OAIS_ENDPOINT"];
const apiKey = process.env["SECUREGPT_ADMIN_API_KEY"];
const userData = {
    firstName: process.env["SECUREGPT_SAMPLE_USER_FIRSTNAME"],
    lastName: process.env["SECUREGPT_SAMPLE_USER_LASTNAME"],
    email: process.env["SECUREGPT_SAMPLE_USER_EMAIL"],
    sku: process.env["SECUREGPT_SAMPLE_USER_SKU"],
    // notify: false, // optional: default is true. If set to false, the user will not receive an email.
    // password: null // optional: if not set, a random password will be generated.
};

const axios = require("axios");
const httpData = JSON.stringify(userData);

const config = {
    method: "post",
    url: apiEndpoint + "/admin/users/enroll",
    headers: {
        "Content-Type": "application/json",
        "api-key": apiKey,
    },
    data: httpData,
};

axios
    .request(config)
    .then((response) => {
        console.log(JSON.stringify(response.data));
        process.env["SECUREGPT_SAMPLE_USER_USERID"] = response.data.userId;
        process.env["SECUREGPT_SAMPLE_USER_APIKEY"] = response.data.apiKey;
        console.log()
        console.log("Now use the following commands to try out the client API (bash):")
        console.log("export SECUREGPT_SAMPLE_USER_USERID=" + response.data.userId)
        console.log("export SECUREGPT_SAMPLE_USER_APIKEY=" + response.data.apiKey)
    })
    .catch((error) => {
        console.log(error);
    });
