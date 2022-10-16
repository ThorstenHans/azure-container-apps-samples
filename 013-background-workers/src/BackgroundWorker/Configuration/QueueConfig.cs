namespace ThorstenHans.AzureContainerApps.BackgroundWorker.Configuration;

public class QueueConfig
{
    public const string SectionName = "QueueConfig";
    public string QueueName { get; set; }
    public string ConnectionString { get; set; }
}
