# Module Config - Gestion de la configuration

function Save-Configuration {
    $configPath = Join-Path $global:Config.LocalCachePath "config.json"
    $global:Config | ConvertTo-Json | Out-File -FilePath $configPath -Force
}

function Load-Configuration {
    $configPath = Join-Path $global:Config.LocalCachePath "config.json"
    if (Test-Path $configPath) {
        $loadedConfig = Get-Content $configPath | ConvertFrom-Json
        $loadedConfig.PSObject.Properties | ForEach-Object {
            $global:Config[$_.Name] = $_.Value
        }
    }
}

Export-ModuleMember -Function Save-Configuration, Load-Configuration