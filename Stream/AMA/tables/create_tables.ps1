# Variables
$resourceGroupName = ""
$workspaceName = ""
$logTypePrefix = "CustomLog"  # Prefix for custom table names; will be appended with file name
$folderPath = ".\"  # Path to the folder containing JSON files

# Azure Authentication
Connect-AzAccount

# Function to create and post the data
function Post-DataUsingAz ($resourceGroupName, $workspaceName, $body, $tableName) {
    $resourceId = (Get-AzOperationalInsightsWorkspace -ResourceGroupName $resourceGroupName -Name $workspaceName).ResourceId
    Write-Host "ResourceID is $($resourceId)"
    Write-Host "Table is $($tableName)"
    $uri = "$resourceId/tables/$tableName?api-version=2021-12-01-preview"

    Invoke-AzRestMethod -Path $uri -Method PUT -payload $body
    
    return
}

# Main script
try {
    $jsonFiles = Get-ChildItem -Path $folderPath -Filter *.json
    foreach ($file in $jsonFiles) {
        $jsonContent = Get-Content $file.FullName -Raw
        $tableName = $file.BaseName + "_CL" # Customize log type based on file name
        
        $resourceId = (Get-AzOperationalInsightsWorkspace -ResourceGroupName $resourceGroupName -Name $workspaceName).ResourceId
        Write-Host "ResourceID is $($resourceId)"
        Write-Host "Table is $($tableName)"
        $uri = "$resourceId/tables/$($tableName)?api-version=2021-12-01-preview"
        Write-Host "URI is $($uri)"
        Invoke-AzRestMethod -Path $uri -Method PUT -payload $jsonContent
    
        #$postResponse = Post-DataUsingAz $resourceGroupName $workspaceName $jsonContent $tableName
        Write-Host "Data from $($file.Name) posted successfully."
    }
} catch {
    Write-Error "Failed to post data: $_"
}
