<#
.SYNOPSIS
    Packages the AddOn with the BigWigs Packager and copies it to the WoW game directories.
    
    Requires https://github.com/BigWigsMods/packager to be installed in ~\source\repos\packager and https://github.com/Tuller/PublishAddon to be installed in ~\source\repos\PublishAddon.
#>

$global:WOW_HOME = 'C:\Program Files (x86)\World of Warcraft'
$global:WOW_PACKAGER = wsl wslpath $(Resolve-Path '~\source\repos\packager\release.sh').Path.Replace('\', '\\')

Import-Module '~\source\repos\PublishAddon\wow.psm1'

Publish-Addon
