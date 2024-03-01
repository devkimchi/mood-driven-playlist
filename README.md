# Mood-driven Playlist

This is a sample app that catches moods and creates a playlist from Spotify based on the mood analysis

## Getting Started

```bash
# PowerShell
$AZURE_ENV_NAME="playlist$(Get-Random -Min 1000 -Max 9999)"
azd init -e $AZURE_ENV_NAME
azd provision
azd deploy
```

https://github.com/Azure-Samples/azure-openai-apim-load-balancing/blob/main/infra/main.bicep

https://raw.githubusercontent.com/Azure/azure-rest-api-specs/main/specification/cognitiveservices/data-plane/AzureOpenAI/inference/preview/2024-02-15-preview/inference.json