# ScriptManager.ps1 - Gestionnaire de scripts à la WinUtil (tout-en-un)
# Auteur : IsT3RiK
# Version : 1.0

param(
    [string]$ScriptsJsonUrl = "https://raw.githubusercontent.com/IsT3RiK/scriptsutil/main/scripts.json"
)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Get-ScriptsList {
    param($url)
    try {
        $json = Invoke-WebRequest -Uri $url -UseBasicParsing | Select-Object -ExpandProperty Content
        return $json | ConvertFrom-Json
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Impossible de récupérer la liste des scripts.`nVérifiez votre connexion Internet ou l'URL du fichier scripts.json.", "Erreur", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        exit
    }
}

function Download-And-RunScript {
    param($script)
    try {
        $tempFile = [System.IO.Path]::Combine($env:TEMP, "$($script.Name)_$([System.Guid]::NewGuid().ToString('N')).ps1")
        Invoke-WebRequest -Uri $script.RawUrl -OutFile $tempFile -UseBasicParsing
        powershell.exe -NoProfile -ExecutionPolicy Bypass -File $tempFile
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Erreur lors du téléchargement ou de l'exécution du script : $_", "Erreur", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
}

function Show-ScriptManager {
    $scripts = Get-ScriptsList -url $ScriptsJsonUrl

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "ScriptManager - by IsT3RiK"
    $form.Size = New-Object System.Drawing.Size(900, 600)
    $form.StartPosition = "CenterScreen"
    $form.BackColor = [System.Drawing.Color]::FromArgb(36, 37, 38)
    $form.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Regular)
    $form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
    $form.MaximizeBox = $false

    $label = New-Object System.Windows.Forms.Label
    $label.Text = "Sélectionnez un script à exécuter :"
    $label.ForeColor = [System.Drawing.Color]::White
    $label.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
    $label.AutoSize = $true
    $label.Location = New-Object System.Drawing.Point(30, 20)
    $form.Controls.Add($label)

    $listView = New-Object System.Windows.Forms.ListView
    $listView.View = [System.Windows.Forms.View]::Details
    $listView.FullRowSelect = $true
    $listView.GridLines = $true
    $listView.Size = New-Object System.Drawing.Size(820, 400)
    $listView.Location = New-Object System.Drawing.Point(30, 60)
    $listView.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $listView.BackColor = [System.Drawing.Color]::FromArgb(54, 57, 63)
    $listView.ForeColor = [System.Drawing.Color]::White
    $listView.Columns.Add("Nom", 180)
    $listView.Columns.Add("Description", 420)
    $listView.Columns.Add("Catégorie", 120)
    $listView.Columns.Add("Version", 80)

    foreach ($script in $scripts) {
        $item = New-Object System.Windows.Forms.ListViewItem($script.Name)
        $item.SubItems.Add($script.Description)
        $item.SubItems.Add($script.Category)
        $item.SubItems.Add($script.Version)
        $item.Tag = $script
        $listView.Items.Add($item)
    }

    $form.Controls.Add($listView)

    $runButton = New-Object System.Windows.Forms.Button
    $runButton.Text = "Exécuter le script sélectionné"
    $runButton.Size = New-Object System.Drawing.Size(300, 40)
    $runButton.Location = New-Object System.Drawing.Point(30, 480)
    $runButton.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
    $runButton.BackColor = [System.Drawing.Color]::FromArgb(0, 123, 255)
    $runButton.ForeColor = [System.Drawing.Color]::White
    $runButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $runButton.FlatAppearance.BorderSize = 0
    $runButton.Add_Click({
        if ($listView.SelectedItems.Count -eq 0) {
            [System.Windows.Forms.MessageBox]::Show("Veuillez sélectionner un script.", "Information", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
            return
        }
        $script = $listView.SelectedItems[0].Tag
        $confirm = [System.Windows.Forms.MessageBox]::Show("Exécuter le script : $($script.Name) ?", "Confirmation", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
        if ($confirm -eq [System.Windows.Forms.DialogResult]::Yes) {
            Download-And-RunScript -script $script
        }
    })
    $form.Controls.Add($runButton)

    $form.ShowDialog() | Out-Null
}

Show-ScriptManager