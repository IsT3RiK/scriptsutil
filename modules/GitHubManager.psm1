# Module GitHubManager - Gestion des scripts sur GitHub

function Test-GitHubConnection {
    try {
        $response = Invoke-WebRequest -Uri "https://github.com" -UseBasicParsing -TimeoutSec 5
        return $true
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show("Impossible de se connecter à GitHub. Vérifiez votre connexion Internet.", "Erreur")
        exit
    }
}

function Update-ScriptList {
    try {
        $apiUrl = "https://api.github.com/repos/$($global:Config.GitHubUser)/$($global:Config.GitHubRepo)/contents"
        $response = Invoke-RestMethod -Uri $apiUrl
        
        # Nettoyer le cache
        Remove-Item -Path "$($global:Config.LocalCachePath)\*" -Recurse -Force -ErrorAction SilentlyContinue
        
        foreach ($item in $response) {
            if ($item.type -eq "file" -and $item.name -like "*.ps1") {
                $content = Invoke-RestMethod -Uri $item.download_url
                $localPath = Join-Path $global:Config.LocalCachePath $item.name
                $content | Out-File -FilePath $localPath -Force
            }
        }
        
        return $true
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show("Erreur lors de la mise à jour des scripts: $_", "Erreur")
        return $false
    }
}

function Get-ScriptsByCategory {
    param([string]$Category)
    
    $scripts = @()
    $metadataPath = "$($global:Config.LocalCachePath)\metadata.json"
    
    if (Test-Path $metadataPath) {
        $metadata = Get-Content $metadataPath | ConvertFrom-Json
        $scripts = $metadata | Where-Object { $_.Category -eq $Category }
    }
    else {
        # Si pas de metadata, on crée une liste basique
        $scriptFiles = Get-ChildItem -Path $global:Config.LocalCachePath -Filter "*.ps1"
        foreach ($file in $scriptFiles) {
            # On essaie d'extraire des infos du contenu du script
            $content = Get-Content $file.FullName -Raw
            $name = $file.BaseName
            $description = ""
            $version = "1.0"
            
            # Extraction basique des commentaires en haut du script
            if ($content -match "# Description:(.+)[\r\n]") {
                $description = $matches[1].Trim()
            }
            if ($content -match "# Version:(.+)[\r\n]") {
                $version = $matches[1].Trim()
            }
            
            # Assignation de catégorie basique - à améliorer selon vos besoins
            $scriptCategory = "Utilitaires" # Catégorie par défaut
            
            $scripts += @{
                Name = $name
                Description = $description
                Version = $version
                Path = $file.FullName
                Category = $scriptCategory
            }
        }
    }
    
    return $scripts
}

function Get-ScriptContent {
    param($ScriptPath)
    
    if (Test-Path $ScriptPath) {
        return Get-Content $ScriptPath -Raw
    }
    else {
        throw "Le script n'existe pas: $ScriptPath"
    }
}

Export-ModuleMember -Function Test-GitHubConnection, Update-ScriptList, Get-ScriptsByCategory, Get-ScriptContent