var builder = DistributedApplication.CreateBuilder(args);

builder.AddProject<Projects.TaskFlow_Blazor>("web");

await builder.Build().RunAsync().ConfigureAwait(false);
