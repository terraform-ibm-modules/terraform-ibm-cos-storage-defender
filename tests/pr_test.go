package test

import (
	"os"
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testschematic"
)

const fullyConfigFlavorDir = "examples/advanced"
const resourceGroup = "log-mon"

func TestFullyConfigurable(t *testing.T) {
	t.Parallel()

	// Verify ibmcloud_api_key variable is set
	checkVariable := "TF_VAR_ibmcloud_api_key"
	val, present := os.LookupEnv(checkVariable)
	require.True(t, present, checkVariable+" environment variable not set")
	require.NotEqual(t, "", val, checkVariable+" environment variable is empty")

	prefix := "test-da"

	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing: t,
		Region:  "eu-de",
		Prefix:  prefix,
		TarIncludePatterns: []string{
			"examples/advanced/*.tf", // example code
			"*.tf",                   // root-level *.tf (main.tf, variables.tf, outputs.tf, provider.tf, version.tf)
			"modules/**/*.tf",        // all submodules
		},
		TemplateFolder:         fullyConfigFlavorDir, // still "examples/advanced"
		DeleteWorkspaceOnFail:  false,
		WaitJobCompleteMinutes: 120,
	})

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "resource_group", Value: resourceGroup, DataType: "string"},
		{Name: "region", Value: options.Region, DataType: "string"},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
	}

	err := options.RunSchematicTest()
	assert.Nil(t, err, "This should not have errored")
}
