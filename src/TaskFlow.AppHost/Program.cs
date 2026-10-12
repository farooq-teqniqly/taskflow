var builder = DistributedApplication.CreateBuilder(args);

// Add project resources here (see CLAUDE-aspire.md), e.g. an API project resource named "api".

await builder.Build().RunAsync().ConfigureAwait(false);
