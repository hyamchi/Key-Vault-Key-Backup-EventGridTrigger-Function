param($eventGridEvent, $TriggerMetadata)

# Extracting information from the event
$data = $eventGridEvent['data']
$primeKvName = $data['VaultName']
$keyName = $data['ObjectName']

# 2nd key vault name, normally this should be a tag in the 1st vault name.
$secKvName = 'yamchi-key-vault-2'

# A folder to keep backup file
$backupFolder = "$env:Temp\KeyVaultKeyBackup"

try {
    # Cleaning up any previous items
    If ((test-path $backupFolder)) {
        Remove-Item $backupFolder -Recurse -Force
    }
    # Create dir
    New-Item -ItemType Directory -Force -Path $backupFolder

    # Backup the key
    # To force an error: giving dummy name to the key
    $keyName = "dummy"
    Backup-AzKeyVaultKey -VaultName $primeKvName -Name $keyName -OutputFile "$backupFolder\$keyName.keybackup" -Force # to override the existing file

    # Restore to the 2nd vault
    # if rotation: key needs to be purged first, otherwise error will occur
    $key = Get-AzKeyVaultKey -VaultName $secKvName -Name $keyName

    if ($key){
        # To purge, first, we need to delete the key 
        Remove-AzKeyVaultKey -VaultName $secKvName -Name $keyName -Force -ErrorAction Stop

        # Wait 15 sec for delete to be completed
        Start-Sleep -s 15

        # Purge
        Remove-AzKeyVaultKey -VaultName $secKvName -Name $keyName -InRemovedState -Force -ErrorAction Stop # no need for user confirmation

        # Wait 15 sec for purge to be completed
        Start-Sleep -s 15
    }

    # Restore the key
    Restore-AzKeyVaultKey -VaultName $secKvName -InputFile "$backupFolder\$keyName.keybackup" -ErrorAction Stop

    If ((test-path $backupFolder)) {
        Remove-Item $backupFolder -Recurse -Force
    }
} catch {
    Write-Host "the following error occurred: $($PSItem.ToString())"
    $PSItem.InvocationInfo | Format-List *

    # email the error
    $funcError = $PSItem.ToString()
    $details = $PSItem.InvocationInfo
    $body = @{
        'error'= $funcError 
        'details'= $details
    } | ConvertTo-Json 

    #URI is the environment variable and needs to be stored in the "App Settings" of the function app
    Invoke-WebRequest -Uri $env:LogicAppPostURL -ContentType "application/json" -Method POST -Body $body
}


