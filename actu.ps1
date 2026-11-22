<#
.SYNOPSIS
    Genere le fichier files.json pour la page d'accueil index.html.

.DESCRIPTION
    Ce script scanne le dossier C:\serveur_web_fichier (y compris les
    sous-dossiers) et ecrit la liste des fichiers dans files.json, au
    format attendu par index.html. Relancez-le chaque fois que le
    contenu du dossier change.

    Fichiers ignores automatiquement : index.html, index.php,
    files.json et ce script.
#>

# ==== Parametres a ajuster si besoin ====
$DossierRacine = "C:\server_file_net"
$FichierSortie = Join-Path $DossierRacine "files.json"
$Exclusions    = @("index.html", "index.php", "files.json", "generer_fichiers.ps1")
# =======================================

if (-not (Test-Path -LiteralPath $DossierRacine)) {
    Write-Error "Le dossier '$DossierRacine' n'existe pas. Creez-le ou ajustez la variable `$DossierRacine."
    exit 1
}

$fichiers = @(Get-ChildItem -LiteralPath $DossierRacine -Recurse -File |
    Where-Object { $Exclusions -notcontains $_.Name } |
    ForEach-Object {
        # Chemin relatif avec des slashs (format URL)
        $relatif = $_.FullName.Substring($DossierRacine.Length).TrimStart('\') -replace '\\', '/'
        [ordered]@{
            nom     = $_.Name
            chemin  = $relatif
            taille  = $_.Length
            modifie = $_.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
        }
    })

$sortie = [ordered]@{
    dossier  = $DossierRacine
    generes  = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    fichiers = $fichiers
}

# Ecriture en UTF-8 sans BOM (indispensable pour que le navigateur
# puisse lire le JSON)
$json = $sortie | ConvertTo-Json -Depth 4
[System.IO.File]::WriteAllText($FichierSortie, $json, [System.Text.UTF8Encoding]::new($false))

Write-Host ("Termine : {0} fichier(s) listes dans {1}" -f $fichiers.Count, $FichierSortie) -ForegroundColor Green
Write-Host "Ouvrez ensuite http://localhost/ (ou l'adresse de votre serveur) dans un navigateur."
