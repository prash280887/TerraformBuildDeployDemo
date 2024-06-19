// This code snippet is for Node.js
// run ```npm install``` then ```node chat-completions.js```

// This script is used to call the chat API.
// It require the following node modules:
// - axios
// The apiKey used must have access to the following APIs:
// - /openai/deployments/xxxxxxxxxxxxxxxxx/chat/completions?api-version=xxxxxxxxxxxxxx
// This will print a JSON object with the following format:
// {
//     "id": "chatcmpl-xxxxxxxxxxxxxxxx",
//     "object": "chat.completion",
//     "created": 1684934921,
//     "model": "gpt-35-turbo",
//     "choices": [
//         {
//             "index": 0,
//             "finish_reason": "stop",
//             "message": {
//                 "role": "assistant",
//                 "content": "I apologize, but I do not have information about the prices of other gaming devices such as the PS5. My primary focus is to assist with issues regarding Xbox devices. Is there a specific issue you are having with your Xbox device that I may be able to help with?"
//             }
//         }
//     ],
//     "usage": {
//         "completion_tokens": 55,
//         "prompt_tokens": 130,
//         "total_tokens": 185
//     }
// }

const apiEndpoint = process.env["SECUREGPT_OAIS_ENDPOINT"];
const apiKey = process.env["SECUREGPT_SAMPLE_USER_APIKEY"];
const deploymentId = process.env["SECUREGPT_OAIS_DEPLOYMENT_NAME"];
const apiVersion = process.env["SECUREGPT_OAIS_API_VERSION"];
const payload = {
    messages: [
        {
            role: "system",
            content:
                "You are an Xbox customer support agent whose primary goal is to help users with issues they are experiencing with their Xbox devices. You are friendly and concise. You only provide factual answers to queries, and do not provide answers that are not related to Xbox.",
        },
        {
            role: "user",
            content: "How much is a PS5?",
        },
        {
            role: "assistant",
            content:
                "I apologize, but I do not have information about the prices of other gaming devices such as the PS5. My primary focus is to assist with issues regarding Xbox devices. Is there a specific issue you are having with your Xbox device that I may be able to help with?",
        },
    ],
    max_tokens: 350,
    temperature: 0,
    frequency_penalty: 0,
    presence_penalty: 0,
    top_p: 0.95,
    stop: null,
};

const axios = require("axios");
const httpData = JSON.stringify(payload);
const config = {
    method: "post",
    url: `${apiEndpoint}/openai/deployments/${deploymentId}/chat/completions?api-version=${apiVersion}`,
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
    })
    .catch((error) => {
        console.log(error);
    });
