# Module UI - Interface utilisateur pour ScriptManager

function Initialize-ScriptManager {
    # Création du dossier cache si nécessaire
    if (-not (Test-Path $global:Config.LocalCachePath)) {
        New-Item -ItemType Directory -Path $global:Config.LocalCachePath -Force | Out-Null
    }
    
    # Vérification de la connexion internet
    Test-GitHubConnection
    
    # Récupération de la liste des scripts
    Update-ScriptList
}

function Show-MainMenu {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Gestionnaire de Scripts"
    $form.Size = New-Object System.Drawing.Size(800, 600)
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
    $form.MaximizeBox = $false

    # Création des onglets par catégorie
    $tabControl = New-Object System.Windows.Forms.TabControl
    $tabControl.Dock = [System.Windows.Forms.DockStyle]::Fill
    
    foreach ($category in $global:Config.Categories) {
        $tabPage = New-Object System.Windows.Forms.TabPage
        $tabPage.Text = $category
        
        # Liste des scripts pour cette catégorie
        $scriptListView = New-Object System.Windows.Forms.ListView
        $scriptListView.View = [System.Windows.Forms.View]::Details
        $scriptListView.Dock = [System.Windows.Forms.DockStyle]::Fill
        $scriptListView.FullRowSelect = $true
        
        $scriptListView.Columns.Add("Nom", 150)
        $scriptListView.Columns.Add("Description", 350)
        $scriptListView.Columns.Add("Version", 70)
        
        # Remplir avec les scripts de cette catégorie
        $scripts = Get-ScriptsByCategory -Category $category
        foreach ($script in $scripts) {
            $item = New-Object System.Windows.Forms.ListViewItem($script.Name)
            $item.SubItems.Add($script.Description)
            $item.SubItems.Add($script.Version)
            $item.Tag = $script.Path
            $scriptListView.Items.Add($item)
        }
        
        # Boutons d'action
        $buttonPanel = New-Object System.Windows.Forms.Panel
        $buttonPanel.Dock = [System.Windows.Forms.DockStyle]::Bottom
        $buttonPanel.Height = 50
        
        $executeButton = New-Object System.Windows.Forms.Button
        $executeButton.Text = "Exécuter"
        $executeButton.Location = New-Object System.Drawing.Point(10, 10)
        $executeButton.Add_Click({
            $selectedItem = $scriptListView.SelectedItems[0]
            if ($selectedItem) {
                Invoke-ScriptExecution -ScriptPath $selectedItem.Tag
            }
        })
        
        $updateButton = New-Object System.Windows.Forms.Button
        $updateButton.Text = "Mettre à jour"
        $updateButton.Location = New-Object System.Drawing.Point(120, 10)
        $updateButton.Add_Click({ Update-ScriptList })
        
        $buttonPanel.Controls.Add($executeButton)
        $buttonPanel.Controls.Add($updateButton)
        
        $tabPage.Controls.Add($scriptListView)
        $tabPage.Controls.Add($buttonPanel)
        $tabControl.Controls.Add($tabPage)
    }
    
    $form.Controls.Add($tabControl)
    $form.ShowDialog() | Out-Null
}

function Invoke-ScriptExecution {
    param($ScriptPath)
    
    $result = [System.Windows.Forms.MessageBox]::Show("Voulez-vous exécuter ce script?", "Confirmation", [System.Windows.Forms.MessageBoxButtons]::YesNo)
    if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
        try {
            $scriptContent = Get-ScriptContent -ScriptPath $ScriptPath
            Invoke-Expression $scriptContent
            [System.Windows.Forms.MessageBox]::Show("Script exécuté avec succès!", "Information")
        }
        catch {
            [System.Windows.Forms.MessageBox]::Show("Erreur lors de l'exécution: $_", "Erreur")
        }
    }
}

Export-ModuleMember -Function Initialize-ScriptManager, Show-MainMenu, Invoke-ScriptExecution