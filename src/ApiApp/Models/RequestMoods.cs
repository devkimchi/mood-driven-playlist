using Swashbuckle.AspNetCore.Filters;

namespace MoodDrivenPlaylist.ApiApp.Models;

public class RequestMoods(string? description = null)
{
    public string? Description { get; set; } = description;
}

public class RequestMoodsExample : IExamplesProvider<RequestMoods>
{
    public RequestMoods GetExamples()
    {
        var example = new RequestMoods(description: "This is my current mood");

        return example;
    }
}