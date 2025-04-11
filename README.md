# ScriptManager

Gestionnaire de scripts PowerShell personnalisés avec interface graphique et intégration GitHub, inspiré de WinUtil.

## Fonctionnalités

- Téléchargement automatique de scripts depuis un dépôt GitHub.
- Interface graphique Windows Forms avec classement par catégories.
- Exécution sécurisée des scripts PowerShell.
- Gestion de la configuration et du cache local.
- Installation rapide via un script unique.

## Structure du projet

```
/ScriptManager
├── ScriptManager.ps1       # Script principal
├── install.ps1             # Script d'installation rapide
├── README.md               # Documentation
└── modules/
    ├── UI.psm1             # Module interface utilisateur
    ├── GitHubManager.psm1  # Module gestion GitHub
    ├── Config.psm1         # Module configuration
    └── scripts/            # Dossier contenant les scripts téléchargés
```

## Installation rapide

1. Modifiez les valeurs `GitHubUser` et `GitHubRepo` dans ScriptManager.ps1 selon votre dépôt.
2. Déposez tous les fichiers sur votre dépôt GitHub.
3. Sur un poste client, exécutez la commande suivante dans PowerShell :

```powershell
iwr -useb https://raw.githubusercontent.com/IsT3RiK/scriptsutil/main/install.ps1 | iex
```

Un raccourci sera créé sur le bureau pour lancer le gestionnaire.

## Format des scripts gérés

Chaque script PowerShell doit commencer par un en-tête :

```
# Titre: Nom du script
# Description: Description détaillée du script
# Auteur: Votre nom
# Version: 1.0
# Catégorie: Système

# Votre code ici...
```

## Personnalisation

- Ajoutez vos propres catégories dans `$global:Config.Categories` (ScriptManager.ps1).
- Ajoutez des scripts dans le dossier GitHub du dépôt, ils seront automatiquement récupérés.

## Dépendances

- PowerShell 5.1 ou supérieur
- Accès Internet pour la synchronisation GitHub
- Windows (interface graphique via Windows Forms)

## Auteur

Votre nom