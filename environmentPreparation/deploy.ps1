# Create a RG for testing the modules
$testRg = New-AzResourceGroup -Name 'HelpSantaWithBicep-TestModule-RG' -location 'westeurope'
# Create a RG for testing the Bicep Registry
$bcRg = New-AzResourceGroup -Name 'HelpSantaWithBicep-Registry-RG' -location 'westeurope'

# Create a new Bicep module registry
$reg = New-AzContainerRegistry -Name "acr$(Get-Random -Maximum 99999)" `
            -ResourceGroupName $bcRg.ResourceGroupName `
            -Location "westeurope" `
            -Sku "Basic" `
            -EnableAdminUser:$false

$reg.Name
$reg.Name | Set-Clipboard

# Paste the content of the clipboard as the value of the environment variable AZURE_BR_NAME in .github\workflows\CheckPR.yaml
# Example:
# - name: Publish Bicep files to the Bicep registry
#         if: ${{ success() }}
#         env:
#           AZURE_BR_NAME: '<paste the value here>'

# Create a service principal and grant it contributor access to the RGs
$azureContext = Get-AzContext
$servicePrincipal = New-AzADServicePrincipal `
    -DisplayName "HelpSantaWithBicep-TestModule" `
    -Role "Contributor" `
    -Scope $testRg.ResourceId

New-AzRoleAssignment -ApplicationId $servicePrincipal.ApplicationId `
    -ResourceGroupName $bcRg.ResourceGroupName `
    -RoleDefinitionName "Contributor"


$output = @{
   clientId = $($servicePrincipal.ApplicationId)
   clientSecret = $([System.Net.NetworkCredential]::new('', $servicePrincipal.Secret).Password)
   subscriptionId = $($azureContext.Subscription.Id)
   tenantId = $($azureContext.Tenant.Id)
}

$output | ConvertTo-Json
$output | ConvertTo-Json | Set-Clipboard
# Paste the content of the clipboard in a new GitHub secret called AzCred
