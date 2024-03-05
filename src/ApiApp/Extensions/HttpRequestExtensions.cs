namespace MoodDrivenPlaylist.ApiApp.Extensions;

// Reference: https://blog.elmah.io/how-to-get-base-url-in-asp-net-core/
public static class HttpRequestExtensions
{
    public static string? BaseUrl(this HttpRequest req)
    {
        if (req == null) return null;
        var uriBuilder = new UriBuilder(req.Scheme, req.Host.Host, req.Host.Port ?? -1);
        if (uriBuilder.Uri.IsDefaultPort)
        {
            uriBuilder.Port = -1;
        }

        return uriBuilder.Uri.AbsoluteUri;
    }

    public static bool GetFeatureFlag(this HttpRequest req, string key)
    {
        if (req == null) return false;

        return bool.TryParse(req.Query[key].ToString(), out var result) && result;
    }
}
