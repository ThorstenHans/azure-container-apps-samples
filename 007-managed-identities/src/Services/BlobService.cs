using Azure.Data.AppConfiguration;
using Azure.Identity;
using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;

namespace ThorstenHans.AzureContainerApps.ManagedIdentities.Sample.Api.Services
{
    public class BlobService
    {
        public BlobService(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        public IEnumerable<string> GetBlobNames()
        {
            string msiClientId = Configuration.GetValue<string>("MSI_CLIENT_ID");
            string appCfgEndpoint = Configuration.GetValue<string>("AZ_APPCFG_ENDPOINT");

            if (string.IsNullOrEmpty(msiClientId) || string.IsNullOrWhiteSpace(appCfgEndpoint))
            {
                throw new ApplicationException("Please specify MSI_CLIENT_ID and AZ_APPCFG_ENDPOINT");
            }


            var appConfig = new ConfigurationClient(new Uri(appCfgEndpoint), new ManagedIdentityCredential(msiClientId));

            var accountName = appConfig.GetConfigurationSetting("storage_account_name").Value.Value;
            var containerName = appConfig.GetConfigurationSetting("container_name").Value.Value;

            if (string.IsNullOrWhiteSpace(accountName) || string.IsNullOrWhiteSpace(containerName))
            {
                throw new ApplicationException("Could not locate Storage Account");
            }
            Uri accountUri = new Uri($"https://{accountName}.blob.core.windows.net/");

            var client = new BlobServiceClient(accountUri, new ManagedIdentityCredential(msiClientId));

            var containerClient = client.GetBlobContainerClient(containerName);
            var pager = containerClient.GetBlobs().AsPages(default, 10);

            var blobs = new List<string>();

            foreach (Azure.Page<BlobItem> blobPage in pager)
            {
                blobPage.Values.ToList().ForEach(b =>
                {
                    blobs.Add($"{b.Name} - {b.Properties.ContentType} ({b.Properties.ContentLength} bytes)");
                });
            }
            return blobs;
        }
    }
}
