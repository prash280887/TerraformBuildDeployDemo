// This code snippet is for Node.js
// run ```npm install``` then ```node delete-user.js```

// This script is used to delete a user from the system.
// It require the following node modules:
// - axios

const apiEndpoint = process.env["SECUREGPT_OAIS_ENDPOINT"];
const userId = process.env["SECUREGPT_SAMPLE_USER_USERID"];
const apiKey = process.env["SECUREGPT_SAMPLE_USER_APIKEY"];


const axios = require("axios");

const config = {
    method: "delete",
    url: apiEndpoint + `/admin/users/${userId}`,
    headers: {
        "api-key": apiKey,
    },
};

axios
    .request(config)
    .then((response) => {
        console.log(JSON.stringify(response));
    })
    .catch((error) => {
        console.log(JSON.stringify(error));
    });
