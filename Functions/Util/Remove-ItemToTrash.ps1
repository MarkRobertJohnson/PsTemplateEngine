function Remove-ItemToTrash {
    [CmdletBinding()]
    param(
    [Parameter(Mandatory)][string]$Path)
    Add-Type -AssemblyName Microsoft.VisualBasic

    $item = Get-Item -LiteralPath $Path -ErrorAction SilentlyContinue
    if ($item -eq $null)
    {
        Write-Error("'{0}' not found" -f $Path)
    }
    else
    {
        $fullpath=$item.FullName
        Write-Verbose ("Moving '{0}' to the Recycle Bin" -f $fullpath)
        if (Test-Path -LiteralPath $fullpath -PathType Container)
        {
            [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteDirectory($fullpath,'OnlyErrorDialogs','SendToRecycleBin')
        }
        else
        {
           
            [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($fullpath,'OnlyErrorDialogs','SendToRecycleBin')
        }
    }
}