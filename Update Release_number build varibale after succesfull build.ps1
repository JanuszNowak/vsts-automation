# Update Release_number build varibale after succesfull build
# Using Personal Access Token (PAT)
# To generate PAT go to personal Security on VSTS and generate new Personal Access Token - max Expire time is 1 year.
# 

Write-Host "Updating Release_number ..."

[int]$ReleaseNumber = $Env:Release_number
Write-Host "Current Release_number: $ReleaseNumber"

$ReleaseNumber++
Write-Host "New Release_number: $ReleaseNumber"

$projecturi = $env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI
$projectID = $env:SYSTEM_TEAMPROJECTID
$project = $env:SYSTEM_TEAMPROJECT
$buildID = $env:BUILD_BUILDID
$buildurl= $projecturi + $project + "/_apis/build/builds/" + $buildID + "?api-version=2.0"
$jsonDepth = 100

#Write-Host "projecturi: $projecturi"
#Write-Host "projectID: $projectID"
#Write-Host "project: $project"
#Write-Host "buildID: $buildID"
#Write-Host "buildurl: $buildurl"

# Using Personal Access Token (PAT)
$user = ""
$token = ""

# Base64-encodes the Personal Access Token (PAT) appropriately
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $user,$token)))

$headers= @{Authorization=("Basic {0}" -f $base64AuthInfo)}

Write-Host "Getting build definition id ..."
$getbuild = Invoke-RestMethod -Uri $buildurl -headers $headers -Method Get |select definition
$defurl = $projecturi + $project + "/_apis/build/definitions/" + $getbuild.definition.id + "?api-version=2.0"
#Write-Host "defurl: $defurl"

Write-Host "Getting build definition ..."
$definition = Invoke-RestMethod -Uri $defurl -headers $headers -Method Get
$json = @($definition) | ConvertTo-Json -Depth $jsonDepth
#Write-Host "definition = $json"

Write-Host "Updating Release_number ..."
$definition.variables.Release_number.value = $ReleaseNumber
$json = @($definition) | ConvertTo-Json -Depth $jsonDepth
#Write-Host "updated definition = $json"

Write-Host "Saving updated build definition ..."
$updatedef = Invoke-RestMethod  -Uri $defurl -headers $headers -Method Put -Body $json -ContentType "application/json"
$json = @($updatedef) | ConvertTo-Json -Depth $jsonDepth
#Write-Host "updated definition = $json"

Write-Host "Release_number updated"
