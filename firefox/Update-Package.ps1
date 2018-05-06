param(
    [ValidateSet("none", "sccm")]
    [string[]]$PackageTarget
)

Import-Module C:\Users\jbolduan\GitHub\PoshPKG\modules\PoshPKG.psd1, C:\Users\jbolduan\GitHub\UMN-Github\UMN-Github.psd1

# Dot source all tools files.
$Files = @(Get-ChildItem -Path .\tools\*.ps1 -ErrorAction SilentlyContinue)
foreach($File in $Files) {
    try {
        . $File.FullName
    } catch {
        Write-Error -Message "Failed to import $($File.FullName): $_"
    }
}
# Setup GitHub Connection
$Config = Get-Content -Path C:\Users\jbolduan\GitHub\config.json -Raw | ConvertFrom-Json
$Config.GitHubKey

$GitHubHeaders = New-GitHubHeader -authToken $Config.GitHubKey
$FirefoxPackageDef = Get-GitHubRepoFileContent -headers $GitHubHeaders -File "firefox/firefox.json" -Repo "PoshPKG-Packages" -Org "jbolduan" | ConvertFrom-Json

# Check x86 package
$Current32Version = $FirefoxPackageDef.package.version32
$Firefox32VersionCheck = Compare-FirefoxVersion -PackagedVersion $Current32Version -x86

# Check x64 package
$Current64Version = $FirefoxPackageDef.package.version64
$Firefox64VersionCheck = Compare-FirefoxVersion -PackagedVersion $Current64Version

if( $Firefox64VersionCheck.Updated -or $Firefox32VersionCheck.Updated ) {
    # Update Package Info
    $FirefoxPackageDef.package[0].version32 = $Firefox32VersionCheck.Version
    $FirefoxPackageDef.package[0].version64 = $Firefox64VersionCheck.Version
    $FirefoxPackageDef.package[0].releaseNotes32 = $FirefoxPackageDef.package[0].releaseNotes32 -replace "$Current32Version", "$($Firefox32VersionCheck.Version)"
    $FirefoxPackageDef.package[0].releaseNotes64 = $FirefoxPackageDef.package[0].releaseNotes64 -replace "$Current64Version", "$($Firefox64VersionCheck.Version)"
    $FirefoxPackageDef.package[0].downloadUrl32 = $Firefox32VersionCheck.DownloadUrl
    $FirefoxPackageDef.package[0].downloadUrl64 = $Firefox64VersionCheck.DownloadUrl

    $FirefoxPackageDef | ConvertTo-Json | Set-Content -Path C:\Users\jbolduan\GitHub\PoshPKG-Packages\firefox\firefox.json

    Update-GitHubRepo -headers $GitHubHeaders -Repo "PoshPKG-Packages" -Org "jbolduan" -ref "refs/heads/testing" -message "New Firefox Version 64 is $($Firefox64VersionCheck.Version) and 32 is $($Firefox32VersionCheck.Version)" -path "firefox/firefox.json" -filePath C:\Users\jbolduan\GitHub\PoshPKG-Packages\firefox\firefox.json
}