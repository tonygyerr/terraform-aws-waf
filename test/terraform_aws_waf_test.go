package test

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestTerraformAwsWaf(t *testing.T) {
	t.Parallel()

	awsRegion := "us-west-2"
	wafName := strings.ToLower(random.UniqueId())
	wafACLName := fmt.Sprintf("waf-%s", wafName)
	wafACLMetricName := fmt.Sprintf("waf%s", wafName)
	vpcAzs := aws.GetAvailabilityZones(t, awsRegion)[:2]

	terraformOptions := &terraform.Options{

		TerraformDir: "../examples/simple/",
		Vars: map[string]interface{}{
			"waf_acl_name":        wafACLName,
			"waf_acl_metric_name": wafACLMetricName,
			"vpc_azs":             vpcAzs,
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
}
