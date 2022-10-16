namespace ThorstenHans.AzureContainerApps.Api.Configuration;

public class QueueConfig
{
    public const string SectionName = "QueueConfig";
    public string ConnectionString { get; set; }
    public string QueueName { get; set; }
}
