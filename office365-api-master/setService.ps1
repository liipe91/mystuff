
$users = Get-AzureADUser -All:$true | ? {$_.AssignedLicenses}
$SKUs = Get-AzureADSubscribedSku

$plansToEnable = @("9aaf7827-d63c-4b61-89c3-182f06f82e5c", "0feaeb32-d00e-4d66-bd5a-43b5b83db82c")

foreach ($user in $users) {
    $userLicenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
    foreach ($license in $user.AssignedLicenses) {
        $SKU =  $SKUs | ? {$_.SkuId -eq $license.SkuId}
        foreach ($planToEnable in $plansToEnable) {
            if ($planToEnable -notmatch "^[{(]?[0-9A-F]{8}[-]?([0-9A-F]{4}[-]?){3}[0-9A-F]{12}[)}]?$") { $planToEnable = ($SKU.ServicePlans | ? {$_.ServicePlanName -eq "$planToEnable"}).ServicePlanId }
            if (($planToEnable -in $SKU.ServicePlans.ServicePlanId) -and ($planToEnable -in $license.DisabledPlans)) {
                $license.DisabledPlans = ($license.DisabledPlans | ? {$_ -ne $planToEnable}| sort -Unique)
                Write-Host "Added plan $planToEnable from license $($license.SkuId) to user $($user.UserPrincipalName)"
            }
        }
        $userLicenses.AddLicenses += $license
    }
    Set-AzureADUserLicense -ObjectId $user.ObjectId -AssignedLicenses $userLicenses
}
