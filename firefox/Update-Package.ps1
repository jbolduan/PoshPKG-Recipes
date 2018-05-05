param(
    [ValidateSet("none", "sccm")]
    [string[]]$PackageTarget
)

Import-Module PoshPKG

# Dot source all tools files.
$Files = @(Get-ChildItem -Path .\tools\*.ps1 -ErrorAction SilentlyContinue)
foreach($File in $Files) {
    try {
        . $File.FullName
    } catch {
        Write-Error -Message "Failed to import $($File.FullName): $_"
    }
}



# Get x86 package

# Get x64 package