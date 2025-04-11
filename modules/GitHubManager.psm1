# Module GitHubManager - Gestion des scripts sur GitHub

# Ajout pour permettre l'utilisation de System.Windows.Forms.MessageBox
Add-Type -AssemblyName System.Windows.Forms

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
        # Utilisation de l'API GitHub pour lister tous les fichiers du repo de façon récursive
        $branch = $global:Config.Branch
        $apiUrl = "https://api.github.com/repos/$($global:Config.GitHubUser)/$($global:Config.GitHubRepo)/git/trees/$branch?recursive=1"
        $response = Invoke-RestMethod -Uri $apiUrl

        # Nettoyer le cache
        Remove-Item -Path "$($global:Config.LocalCachePath)\*" -Recurse -Force -ErrorAction SilentlyContinue

        foreach ($item in $response.tree) {
            if ($item.type -eq "blob" -and $item.path -like "*.ps1") {
                $rawUrl = "https://raw.githubusercontent.com/$($global:Config.GitHubUser)/$($global:Config.GitHubRepo)/$branch/$($item.path)"
                $localPath = Join-Path $global:Config.LocalCachePath ($item.path -replace '/', '\')
                $localDir = Split-Path -Parent $localPath
                if (-not (Test-Path $localDir)) {
                    New-Item -ItemType Directory -Path $localDir -Force | Out-Null
                }
                Invoke-WebRequest -Uri $rawUrl -OutFile $localPath -UseBasicParsing
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
        $scriptFiles = Get-ChildItem -Path $global:Config.LocalCachePath -Filter "*.ps1" -Recurse
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