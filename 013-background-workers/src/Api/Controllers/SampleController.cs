using Microsoft.AspNetCore.Mvc;
using System.Text.Json;
using Azure.Messaging.ServiceBus;
using ThorstenHans.AzureContainerApps.Api.Configuration;
using ThorstenHans.AzureContainerApps.Api.Models;

namespace ThorstenHans.AzureContainerApps.Api.Controllers;

[ApiController]
[Route("")]
public class SampleController : ControllerBase
{
    private readonly ILogger<SampleController> _logger;
    private readonly QueueConfig _config;
    private readonly ServiceBusClient _serviceBusClient;

    public SampleController(QueueConfig config, ServiceBusClient serviceBusClient, ILogger<SampleController> logger)
    {
        _config = config;
        _serviceBusClient = serviceBusClient;
        _logger = logger;
    }

    [HttpPost("store")]
    public async Task<IActionResult> StoreAsync([FromBody] Payload payload)
    {
        if (string.IsNullOrWhiteSpace(payload.Message))
        {
            return BadRequest();
        }

        try
        {
            var sender = _serviceBusClient.CreateSender(_config.QueueName);
            var message = new ServiceBusMessage(payload.Message);
            _logger.LogInformation("Sending Message to Azure Service Bus");
            await sender.SendMessageAsync(message);
            return Ok();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error storing message");
            return StatusCode(500);
        }
    }
}
