# Script d'installation du gestionnaire de scripts
$installDir = "$env:USERPROFILE\ScriptManager"

# Création du répertoire d'installation
if (-not (Test-Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir -Force | Out-Null
}

# Téléchargement des fichiers depuis GitHub
$baseUrl = "https://raw.githubusercontent.com/IsT3RiK/scriptsutil/main"
$files = @(
    "ScriptManager.ps1",
    "modules/UI.psm1",
    "modules/GitHubManager.psm1",
    "modules/Config.psm1"
)

foreach ($file in $files) {
    $localPath = Join-Path $installDir $file
    $localDir = Split-Path -Parent $localPath
    
    # Création du répertoire parent si nécessaire
    if (-not (Test-Path $localDir)) {
        New-Item -ItemType Directory -Path $localDir -Force | Out-Null
    }
    
    # Téléchargement du fichier
    $url = "$baseUrl/$file"
    Invoke-WebRequest -Uri $url -OutFile $localPath -UseBasicParsing
}

# Lancement direct de l'application ScriptManager
Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$installDir\ScriptManager.ps1`"" -Verb RunAs

Write-Host "Installation terminée ! ScriptManager est lancé." -ForegroundColor Green