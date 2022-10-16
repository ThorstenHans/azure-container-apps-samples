namespace ThorstenHans.AzureContainerApps.BackgroundWorker.Configuration;

public class BlobConfig
{
    public const string SectionName = "BlobConfig";
    public string ConnectionString { get; set; }
    public string ContainerName { get; set; }
}
