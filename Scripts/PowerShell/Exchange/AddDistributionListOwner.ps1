### Sets a Distrbution Group Owner ###

Set-DistributionGroup -Identity "Group" -ManagedBy @{Add="User"} -BypassSecurityGroupManagerCheck