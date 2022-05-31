package main

import (
	"github.com/pulumi/pulumi-kubernetes/sdk/v3/go/kubernetes/yaml"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
)

func main() {
	pulumi.Run(func(ctx *pulumi.Context) error {
		_, err := yaml.NewConfigFile(ctx, "fluxComponents", &yaml.ConfigFileArgs{
			File: "infrastructure/flux-system/gotk-components.yaml",
		})
		if err != nil {
			return err
		}

		_, err = yaml.NewConfigFile(ctx, "fluxSync", &yaml.ConfigFileArgs{
			File: "infrastructure/flux-system/gotk-sync.yaml",
		})
		if err != nil {
			return err
		}

		return nil
	})
}
