### Removes an Owner for a Distribution Group ###

Set-DistributionGroup -Identity "Group" -ManagedBy @{Remove="User"} -BypassSecurityGroupManagerCheck