# AI Utility

## 🧐 About <a name = "about"></a>
This project is an advanced, customizable implementation of the [Implement logging and monitoring for Azure OpenAI models](https://learn.microsoft.com/en-us/azure/architecture/example-scenario/ai/log-monitor-azure-openai) ([github](https://github.com/Azure-Samples/openai-python-enterprise-logging)) architecture from Microsoft. This brings:
- The detailed logging and auditing capabilities proposed in the original architecture
- Per region logging (a central Log Analytics Workspace is still used in a transitive manner)
- **Token**-based consumption-based quotas
- API to enroll/remove users
- Compatible with the OpenAI SDK, and transparent
