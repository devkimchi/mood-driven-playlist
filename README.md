# Mood-driven Playlist

This is a sample app that catches moods and creates a playlist from Spotify based on the mood analysis.

## Prerequisites

- [.NET 8 SDK](https://dotnet.microsoft.com/download/dotnet/8.0?WT.mc_id=dotnet-107070-juyoo)
- [Visual Studio 2022](https://visualstudio.microsoft.com?WT.mc_id=dotnet-107070-juyoo) 17.9 or later, or [Visual Studio Code](https://code.visualstudio.com?WT.mc_id=dotnet-107070-juyoo) with [C# Dev Kit](https://marketplace.visualstudio.com/items?itemName=ms-dotnettools.csdevkit&WT.mc_id=dotnet-107070-juyoo)
- [Azure Developer CLI](https://learn.microsoft.com/azure/developer/azure-developer-cli/overview?WT.mc_id=dotnet-107070-juyoo)
- [Azure CLI](https://learn.microsoft.com/cli/azure/what-is-azure-cli?WT.mc_id=dotnet-107070-juyoo)
- [GitHub CLI](https://cli.github.com/)
- [PowerShell](https://learn.microsoft.com/powershell/scripting/overview?WT.mc_id=dotnet-107070-juyoo)
- [Azure subscription](https://azure.microsoft.com/free?WT.mc_id=dotnet-107070-juyoo)
- [Azure OpenAI Service subscription](https://aka.ms/oaiapply)

## Getting Started

1. Create an app on Spotify and get the `Client ID` and `Client Secret` from the [Spotify Developer Dashboard](https://developer.spotify.com/dashboard).

1. Run the following commands to provision and deploy apps to Azure.

   > **NOTE**:
   > 
   > - Since all the post-provisioning scripts are written in PowerShell, it is recommended to use PowerShell to run the `azd` commands.
   > - You can get the latest version of Azure OpenAI API spec from [here](https://github.com/Azure/azure-rest-api-specs/tree/main/specification/cognitiveservices/data-plane/AzureOpenAI/inference).

    ```bash
    # PowerShell
    $AZURE_ENV_NAME="playlist$(Get-Random -Min 1000 -Max 9999)"
    azd init -e $AZURE_ENV_NAME
    azd provision
    azd deploy
    ```

1. At the [Spotify Developer Dashboard](https://developer.spotify.com/dashboard), update the `Redirect URI` to the one from [Azure API Management Credential Manager](https://learn.microsoft.com/azure/api-management/credentials-overview?WT.mc_id=dotnet-107070-juyoo). It should look like `https://authorization-manager.consent.azure-apim.net/redirect/apim/apim-{{AZURE_ENV_NAME}}`.

1. Authorise the credentials on [Azure API Management](https://learn.microsoft.com/azure/api-management/api-management-key-concepts?WT.mc_id=dotnet-107070-juyoo).

## More information

### ASP.NET web app development

- [Blazor](https://learn.microsoft.com/aspnet/core/blazor/?WT.mc_id=dotnet-107070-juyoo)
- [ASP.NET Core Minimal API](https://learn.microsoft.com/aspnet/core/fundamentals/minimal-apis/overview?WT.mc_id=dotnet-107070-juyoo)

### Azure API Management

- [Azure API Management](https://learn.microsoft.com/azure/api-management/api-management-key-concepts?WT.mc_id=dotnet-107070-juyoo)
- [Azure API Management - Credential Manager](https://learn.microsoft.com/azure/api-management/credentials-overview?WT.mc_id=dotnet-107070-juyoo)
- [Azure API Management - Load Balancing](https://learn.microsoft.com/azure/api-management/backends?WT.mc_id=dotnet-107070-juyoo#load-balanced-pool-preview)

### Azure OpenAI Service

- [Azure OpenAI Service](https://learn.microsoft.com/azure/ai-services/openai/overview?WT.mc_id=dotnet-107070-juyoo)
- [Azure OpenAI Service - Chat Completions](https://learn.microsoft.com/azure/ai-services/openai/how-to/chatgpt?WT.mc_id=dotnet-107070-juyoo)
- [Azure OpenAI Service - REST API](https://learn.microsoft.com/azure/ai-services/openai/reference?WT.mc_id=dotnet-107070-juyoo)
