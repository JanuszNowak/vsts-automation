Param(
   [string]$vstsAccount = "",
   [string]$projectName = "",
   #[string]$buildNumber = "<BUILD-NUMBER>",
   [string]$keepForever = "true",
   [string]$user = "",
   [string]$token = ""
)

Write-Verbose "Parameter Values"
foreach($key in $PSBoundParameters.Keys)
{
     Write-Verbose ("  $($key)" + ' = ' + $PSBoundParameters[$key])
}
 
# Base64-encodes the Personal Access Token (PAT) appropriately
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $user,$token)))
 

 # Construct the REST URL to obtain all build definitions 
$uri = "https://$($vstsAccount).visualstudio.com/DefaultCollection/$($projectName)/_apis/build/definitions?api-version=2.0&buildNumber=$($buildNumber)"

# Invoke the REST call and capture the results
$result = Invoke-RestMethod -Uri $uri -Method Get -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}

Foreach ($i in $result.value)
{
 
 if($i.id -eq 1155)
 {
    $i.id
    $i.name
    Write-Output "my build"

     # Construct the REST URL to obtain specific build definiction details
     $uri = "https://$($vstsAccount).visualstudio.com/DefaultCollection/$($projectName)/_apis/build/definitions/$($i.id)?api-version=2.0"
       
    # Invoke the REST call and capture the results
    $resultBuild = Invoke-RestMethod -Uri $uri -Method Get -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}        

    $resultBuild.name = "jnno_buildName"

    $a=$resultBuild | ConvertTo-Json -Depth 100


    $uri ="https://$($vstsAccount).visualstudio.com/DefaultCollection/$($projectName)/_apis/build/definitions/$($i.id)?api-version=2.0"

    $resultBuildDefUpdate = Invoke-RestMethod -Uri $uri -Method Put -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -body $a
 }
}

#Get-ChildItem Env: