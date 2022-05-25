package main

import (
	"fmt"

	"github.com/pulumi/pulumi-azure-native/sdk/go/azure/app"
	"github.com/pulumi/pulumi-azure-native/sdk/go/azure/operationalinsights"
	"github.com/pulumi/pulumi-azure-native/sdk/go/azure/resources"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
)

const (
	dockerImage = "thorstenhans/gopher:devil"
)

func main() {
	pulumi.Run(func(ctx *pulumi.Context) error {

		rg, err := resources.NewResourceGroup(ctx, addStackSuffix(ctx, "rg-aca-pulumi", true), nil)
		if err != nil {
			return err
		}
		rgName := rg.Name

		law, err := operationalinsights.NewWorkspace(ctx, addStackSuffix(ctx, "law-aca-pulumi", true), &operationalinsights.WorkspaceArgs{
			ResourceGroupName: rgName,
			RetentionInDays:   pulumi.Int(31),
			Sku: operationalinsights.WorkspaceSkuArgs{
				Name: pulumi.String("PerGB2018"),
			},
		})
		if err != nil {
			return err
		}

		sharedKey := pulumi.All(rgName, law.Name).ApplyT(
			func(args []interface{}) (string, error) {
				r := args[0].(string)
				l := args[1].(string)
				accountKeys, err := operationalinsights.GetSharedKeys(ctx, &operationalinsights.GetSharedKeysArgs{
					ResourceGroupName: r,
					WorkspaceName:     l,
				})
				if err != nil {
					return "", err
				}

				return *accountKeys.PrimarySharedKey, nil
			},
		).(pulumi.StringOutput)

		env, err := app.NewManagedEnvironment(ctx, addStackSuffix(ctx, "aca-env-pulumi", true), &app.ManagedEnvironmentArgs{
			ResourceGroupName: rgName,
			AppLogsConfiguration: app.AppLogsConfigurationArgs{
				Destination: pulumi.String("log-analytics"),
				LogAnalyticsConfiguration: app.LogAnalyticsConfigurationArgs{
					CustomerId: law.CustomerId,
					SharedKey:  sharedKey,
				},
			},
		})

		if err != nil {
			return err
		}

		capp, err := app.NewContainerApp(ctx, addStackSuffix(ctx, "hello", true), &app.ContainerAppArgs{
			ResourceGroupName:    rgName,
			ManagedEnvironmentId: env.ID(),
			Configuration: app.ConfigurationArgs{
				Ingress: app.IngressArgs{
					External:   pulumi.Bool(true),
					TargetPort: pulumi.Int(80),
				},
			},
			Template: app.TemplateArgs{
				Containers: app.ContainerArray{
					app.ContainerArgs{
						Name:  pulumi.String("main"),
						Image: pulumi.String(dockerImage),
					},
				},
			},
		})
		if err != nil {
			return err
		}
		ctx.Export("url", pulumi.Sprintf("https://%s", capp.LatestRevisionFqdn))

		return nil
	})
}

func addStackSuffix(ctx *pulumi.Context, name string, dash bool) string {
	mask := "%s%s"
	if dash {
		mask = "%s-%s"
	}
	return fmt.Sprintf(mask, name, ctx.Stack())
}
