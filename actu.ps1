<#
.SYNOPSIS
    Genere le fichier files.json pour la page d'accueil index.html.
#>

# ==== Parametres automatiques (dossier courant du script) ====
$DossierRacine = $PSScriptRoot
$FichierSortie = Join-Path $DossierRacine "files.json"
$Exclusions    = @("index.html", "index.php", "files.json", "generer_fichiers.ps1", "actu.ps1")
# ============================================================

if (-not (Test-Path -LiteralPath $DossierRacine)) {
    Write-Error "Le dossier '$DossierRacine' n'existe pas."
    exit 1
}

$fichiers = @(Get-ChildItem -LiteralPath $DossierRacine -Recurse -File |
    Where-Object { $Exclusions -notcontains $_.Name } |
    ForEach-Object {
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

# Ecriture en UTF-8 sans BOM
$json = $sortie | ConvertTo-Json -Depth 4
[System.IO.File]::WriteAllText($FichierSortie, $json, [System.Text.UTF8Encoding]::new($false))

Write-Host ("Termine : {0} fichier(s) listes dans {1}" -f $fichiers.Count, $FichierSortie) -ForegroundColor Green
