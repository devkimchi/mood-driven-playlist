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
