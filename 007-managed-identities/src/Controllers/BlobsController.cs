using Microsoft.AspNetCore.Mvc;
using ThorstenHans.AzureContainerApps.ManagedIdentities.Sample.Api.Services;

namespace ThorstenHans.AzureContainerApps.ManagedIdentities.Sample.Api.Controllers;

[ApiController]
[Route("blobs")]
public class BlobsController : ControllerBase
{
    private readonly ILogger<BlobsController> _logger;
    private readonly BlobService _blobService;

    public BlobsController(BlobService blobService, ILogger<BlobsController> logger)
    {
        _blobService = blobService;
        _logger = logger;
    }


    [HttpGet]
    public IActionResult Get()
    {
        return Ok(_blobService.GetBlobNames());
    }
}
