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
        $updatedBicepModule = $updatedFilesInModules.Where({ $_.Contains(".bicep") -or $_.Contains(".parameters.json") })
    } else {
        $updatedBicepModule = $updatedFilesInModules.Where({ $_.Contains(".bicep") })
    }

    $returnArray = @()
    $updatedBicepModule | ForEach-Object {
        $returnArray += ($_.Replace("$ModuleFolder/", "")).Split(".")[0]
    }

    $returnArray | Get-Unique
    
}
