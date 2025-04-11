# ScriptManager - Gestionnaire de scripts personnalisés
# Auteur: Votre nom
# Version: 1.0

# Élévation des privilèges si nécessaire
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Importation des modules
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Module "$ScriptPath\modules\UI.psm1" -Force
Import-Module "$ScriptPath\modules\GitHubManager.psm1" -Force
Import-Module "$ScriptPath\modules\Config.psm1" -Force

# Configuration globale
$global:Config = @{
    GitHubUser = "VotreNomUtilisateur"
    GitHubRepo = "VotreRepo"
    Branch = "main"
    LocalCachePath = "$env:TEMP\ScriptManager"
    Categories = @("Système", "Réseau", "Utilitaires", "Maintenance")
}

# Initialisation
Initialize-ScriptManager

# Lancement de l'interface
Show-MainMenu