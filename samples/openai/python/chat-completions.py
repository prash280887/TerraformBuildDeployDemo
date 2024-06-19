import openai
import os

openai.api_key = os.environ["SECUREGPT_SAMPLE_USER_APIKEY"]
openai.api_type = "azure"
openai.api_base = os.environ["SECUREGPT_OAIS_ENDPOINT"]
openai.api_version = os.environ["SECUREGPT_OAIS_API_VERSION"]

deploymentName = os.environ["SECUREGPT_OAIS_DEPLOYMENT_NAME"]

print('Testing completion using the Python OpenAI SDK...')
start_phrase = 'You are helping in the marketing effort for a newly opened shop in the center of the city. Write a tagline for an ice cream shop. Tagline:'
response = openai.ChatCompletion.create(engine=deploymentName, messages=[
        {
            "role": "system",
            "content": "You are an Xbox customer support agent whose primary goal is to help users with issues they are experiencing with their Xbox devices. You are friendly and concise. You only provide factual answers to queries, and do not provide answers that are not related to Xbox.",
        },
        {
            "role": "user",
            "content": "How much is a PS5?",
        },
        {
            "role": "assistant",
            "content": "I apologize, but I do not have information about the prices of other gaming devices such as the PS5. My primary focus is to assist with issues regarding Xbox devices. Is there a specific issue you are having with your Xbox device that I may be able to help with?",
        }
   ]
)
print(response['choices'][0]['message']['content'])


