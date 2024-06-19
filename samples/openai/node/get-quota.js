const apiEndpoint = process.env["SECUREGPT_OAIS_ENDPOINT"];
const apiKey = process.env["SECUREGPT_SAMPLE_USER_APIKEY"];

const axios = require("axios");
const config = {
    method: "get",
    url: `${apiEndpoint}/openai/quota`,
    headers: {
        "api-key": apiKey,
    }
};

axios
    .request(config)
    .then((response) => {
        console.log(JSON.stringify(response.data));
    })
    .catch((error) => {
        console.log(error);
    });
