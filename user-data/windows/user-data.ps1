Start-Transcript -Path "C:\adjoin-transcript.txt" -NoClobber
## Getting the server name and the domain name from the EC2 tags
$instanceId = (Invoke-RestMethod -Method Get -Uri http://169.254.169.254/latest/meta-data/instance-id)
$instance = ((Get-EC2Instance -Instance $instanceId).RunningInstance)
$Instance = $instance | Where-Object { $_.InstanceId -eq $instanceId }
$domainname = $Instance.Tags | Where-Object { $_.Key -eq "Domain" }
$domainname = $domainname | select Value | ft -HideTableHeaders | Out-String
$domainname = $domainname.trim()
$domainname
$servername = $Instance.Tags | Where-Object { $_.Key -eq "Name" }
$servername = $servername | select Value | ft -HideTableHeaders | Out-String
$servername = $servername.trim()
$servername
$agency = $Instance.Tags | Where-Object { $_.Key -eq "Agency" }
$agency = $agency | select Value | ft -HideTableHeaders | Out-String
$agency = $agency.trim()
$agency

if ($domainname -eq "ENGR")
{
$ADName = "ADJoin"
$ou = "OU=$agency,OU=MDT-SERVERS,DC=engr,DC=mdcloud,DC=local"
#Set DNS needed for engr domain join
Set-ExecutionPolicy unrestricted -Force
New-Item c:/temp -ItemType Directory -Force
set-location c:/temp
$Eth = Get-NetAdapter | where {$_.ifDesc -notlike "TAP*"} | foreach InterfaceAlias | select -First 1
Set-DNSClientServerAddress -interfaceAlias $Eth -ServerAddresses ("10.88.248.220")
Start-Sleep -s 5
}
elseif ($domainname -eq "MDCLOUD.LOCAL")
{
$ADName = "ADJoin"
$ou = "OU=$agency,OU=MDT-SERVERS,DC=mdcloud,DC=local"
}
else
{
$domainenv = $domainname.Split(".")[-1]
$domainenv
if ($domainname -eq "MDT."+$domainenv)
{
$ADName = $domainenv+"-ADJoin"
$ou = "OU=SERVERS,OU=$agency,DC=mdt,DC=$domainenv"
}
$ADName
}

## use Systems manager and convert the credentials to user format

$systems_manager=(Get-SSMParameterValue -Name $ADName -WithDecryption $true).Parameters

## Retrieving the password from the secret manager
$username = $domainname.ToUpper() + "\domain.join"
$password = $systems_manager.Value | ConvertTo-SecureString -AsPlainText -Force
#$credential = New-Object System.Management.Automation.PSCredential($username,$PlainPassword)
$credential = [PSCredential]::new($username,$password)

## Output of current hostname
$computername = get-content env:computername
$ou
## Do the domain join and rename the server based on EC2 tags
if ($computername -ne $servername)
{
Rename-computer -NewName "$servername"
}
else
{
write-Output "rename is successful"
}

$domain = (Get-WmiObject win32_computersystem).Domain
if ($domain -ne $domainname)
{
Add-Computer -DomainName "$domainname" -OUPath $ou -NewName "$servername" -Credential $credential -Options "JoinWithNewName,AccountCreate" -Passthru -Verbose -Force
## Restart the computer after domain join
restart-computer -force
}
Stop-Transcript