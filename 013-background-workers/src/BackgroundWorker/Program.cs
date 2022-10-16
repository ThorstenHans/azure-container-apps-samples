using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Logging.Console;
using ThorstenHans.AzureContainerApps.BackgroundWorker;
using ThorstenHans.AzureContainerApps.BackgroundWorker.Configuration;

var host = Host.CreateDefaultBuilder(args)
    .ConfigureLogging((ctx, logging) =>
    {
        logging.ClearProviders();
        logging.AddConsole(options => { options.FormatterName = ConsoleFormatterNames.Simple; });
    })
    .ConfigureServices((ctx, services) =>
    {
        services.Configure<BlobConfig>(options =>
            ctx.Configuration.GetRequiredSection(BlobConfig.SectionName).Bind(options));
        services.Configure<QueueConfig>(options =>
            ctx.Configuration.GetRequiredSection(QueueConfig.SectionName).Bind(options));
        services.AddHostedService<Worker>();
    }).Build();
await host.RunAsync();
