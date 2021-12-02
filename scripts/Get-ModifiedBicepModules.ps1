[CmdletBinding()]
param (

    [Parameter(Mandatory)]
    [string]
    $FileList,

    [Parameter(Mandatory)]
    [string]
    $ModuleFolder,

    [Parameter(Mandatory=$false)]
    [switch]
    $IncludeParameterFiles

)

process {
    $updatedFilesInModules = ($FileList.split(" ")).Where({ $_.Contains("$ModuleFolder/") })
    if($IncludeParameterFiles) {
        $updatedBicepModule = $updatedFilesInModules.Where({ $_.Contains(".bicep") -or $_.Contains(".parameters.json") }) | Get-Unique
    } else {
        $updatedBicepModule = $updatedFilesInModules.Where({ $_.Contains(".bicep") })
    }

    $updatedBicepModule.Replace("$ModuleFolder/", "")
}
