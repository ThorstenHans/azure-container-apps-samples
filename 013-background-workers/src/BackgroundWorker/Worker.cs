using Azure.Messaging.ServiceBus;
using Azure.Storage.Blobs;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using ThorstenHans.AzureContainerApps.BackgroundWorker.Configuration;

namespace ThorstenHans.AzureContainerApps.BackgroundWorker;

public class Worker : BackgroundService
{
    private readonly BlobConfig _blobConfig;
    private readonly QueueConfig _queueConfig;
    private readonly ILogger<Worker> _logger;

    public Worker(IOptions<QueueConfig> queueConfig, IOptions<BlobConfig> blobConfig, ILogger<Worker> logger)
    {
        _queueConfig = queueConfig.Value;
        _blobConfig = blobConfig.Value;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        var processor = GetServiceBusProcessor();

        processor.ProcessMessageAsync += ProcessorOnProcessMessageAsync;
        processor.ProcessErrorAsync += ProcessorOnProcessErrorAsync;
        _logger.LogInformation("Start Queue processing for Azure Service Bus queue {QueueName}",
            _queueConfig.QueueName);
        await processor.StartProcessingAsync(stoppingToken);
        while (!stoppingToken.IsCancellationRequested)
        {
            await Task.Delay(TimeSpan.FromSeconds(1));
        }

        _logger.LogInformation("Stopping Queue processing for Queue {QueueName}", _queueConfig.QueueName);
        await processor.CloseAsync(stoppingToken);
    }

    private Task ProcessorOnProcessErrorAsync(ProcessErrorEventArgs arg)
    {
        _logger.LogError("Error while processing message {EventSource}: {Error}", arg.ErrorSource,
            arg.Exception!.ToString());
        _logger.LogError("Will not upload to to {TargetContainerName}", _blobConfig.ContainerName);
        return Task.CompletedTask;
    }

    private async Task ProcessorOnProcessMessageAsync(ProcessMessageEventArgs arg)
    {
        var fileName = $"{arg.Message!.MessageId}.json";
        var blobContainerClient = new BlobContainerClient(_blobConfig.ConnectionString, _blobConfig.ContainerName);
        _logger.LogInformation("Uploading message to blob: {BlobFileName} to container: {ContainerName}", fileName,
            _blobConfig.ContainerName);
        await blobContainerClient.UploadBlobAsync(fileName, arg.Message.Body!.ToStream())!;
        await arg.CompleteMessageAsync(arg.Message)!;
    }

    private ServiceBusProcessor GetServiceBusProcessor()
    {
        var client = new ServiceBusClient(_queueConfig.ConnectionString);
        return client.CreateProcessor(_queueConfig.QueueName);
    }
}
