#Checks Licenses for the Environment
Connect-MgGraph

Get-MgSubscribedSku | ft SkuPartnumber,CapabilityStatus,@{n='Licenses';e={$_.PrepaidUnits.Enabled}}