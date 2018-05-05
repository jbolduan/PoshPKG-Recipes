function Compare-FirefoxVersion {
    [CmdletBinding()]
    <#
    .SYNOPSIS
        Short description
    .DESCRIPTION
        Long description
    .EXAMPLE
        PS C:\> <example usage>
        Explanation of what the example does
    .INPUTS
        Inputs (if any)
    .OUTPUTS
        Output (if any)
    .NOTES
        General notes
    #>
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [version]$PackagedVersion,

        [Parameter(Mandatory = $false)]
        [ValidateSet("en-US")]
        [string]$Localization = "en-US",

        [Parameter(Mandatory = $false)]
        [switch]$x86
    )

    $Firefox86Url = "https://download.mozilla.org/?product=firefox-latest&os=win&lang=$Localization"
    $Firefox64Url = "https://download.mozilla.org/?product=firefox-latest&os=win64&lang=$Localization"
    
    if ($x86) {
        $FirefoxUrl = Get-RedirectedUri -Uri $Firefox86Url
    }
    else {
        $FirefoxUrl = Get-RedirectedUri -Uri $Firefox64Url
    }

    $FirefoxUrl = $FirefoxUrl -replace "%20", " "
    $Filename = $FirefoxUrl.SubString($FirefoxUrl.LastIndexOf("/") + 1)
    $Version = [version]($Filename.Split(" ")[2] -replace ".exe", "")
    if($PackagedVersion -lt $Version) {
        return $true
    } else {
        return $false
    }
}