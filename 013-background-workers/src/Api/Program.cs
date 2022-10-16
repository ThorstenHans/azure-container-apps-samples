using Microsoft.Extensions.Azure;
using ThorstenHans.AzureContainerApps.Api;
using ThorstenHans.AzureContainerApps.Api.Configuration;

var builder = WebApplication.CreateBuilder(args);

var sec = builder.Configuration.GetSection(QueueConfig.SectionName);
if (sec == null)
{
    throw new ApplicationException("Config: QueueConfig not found");
}

var queueConfig = new QueueConfig();
sec.Bind(queueConfig);
builder.Services.AddSingleton(queueConfig);


builder.Services.AddAzureClients(builder => { builder.AddServiceBusClient(queueConfig.ConnectionString); });
// Add services to the container.
builder.Services.AddHealthChecks();
builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseAuthorization();

app.MapControllers();
app.MapHealthChecks("/healthz/readiness");
app.MapHealthChecks("/healthz/liveness");
app.Run();
