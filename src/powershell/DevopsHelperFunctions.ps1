# example of use:
<# 
    Find-ReplaceTokenInFiles -Path .\src\yaml\azure-vote_replaceMe.yaml
    Find-ReplaceTokenInFiles -Path C:\files:\azure*
    Find-ReplaceTokenInFiles  -path .\* -Extensions "*.yaml"
#>
function Find-ReplaceToken {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$String, #String that you want to replace tokens in
        [string]$TokenPrefix = '${{',
        [string]$TokenSuffix = '}}'
    )
    $ret = [System.Text.StringBuilder]::new($String)
    $found = New-Object 'System.Collections.Stack'
    $charArr = $String.ToCharArray() 
    $start = -1
    $stop = -1
    $token = [System.Text.StringBuilder]::new()
    For ($i = 0; $i -le $charArr.Length; $i++) {
        if ($start -ne -1) {
            $null = $token.Append($charArr[$i])
        }
        if ($charArr[$i] -eq "`n") {
            $start = -1
            $stop = -1
            $null = $token.Clear()
        }
        elseif ($start -ne -1 -and $String.Substring($i - $TokenPrefix.Length, $TokenPrefix.Length) -eq $TokenPrefix -and $charArr[$i - $TokenPrefix.Length] -eq $TokenPrefix[$TokenPrefix.Length - 1]) {
            $start = -1
            $stop = -1
            $null = $token.Clear()
            $i--
        }
        elseif ($start -ne -1 -and $i -lt $String.Length - $TokenPrefix.Length -and $String.Substring($i - $TokenSuffix.Length + 1, $TokenSuffix.Length) -eq $TokenSuffix) {
            $stop = $i + 1
            $found.Push([System.Tuple]::Create($start, $stop, $token.ToString()))
            Write-Host "REPLACE TOKENS: TOKEN FOUND - $($token.ToString())"
            $i--
            $start = -1
            $stop = -1
            $null = $token.Clear()
        }
        elseif ($i -ge $TokenPrefix.Length -and $String.Substring($i - $TokenPrefix.Length, $TokenPrefix.Length) -eq $TokenPrefix) {
            if ($start -eq -1) {
                $start = $i - $TokenPrefix.Length
                $null = $token.Append($TokenPrefix)
                $null = $token.Append($charArr[$i])
            }
        }
    }
    $replacedTokens = $false
    while ($found.Count -gt 0) {
        $t = $found.Pop()
        $var = $t.Item3.TrimStart($TokenPrefix).TrimEnd($TokenSuffix)
        if ($null -ne [System.Environment]::GetEnvironmentVariable($var)) {
            write-host "REPLACING $($t.Item3) with $([System.Environment]::GetEnvironmentVariable($var))"
            $replacedTokens = $true
            $null = $ret.Remove($t.Item1, $t.Item2 - $t.Item1)
            $null = $ret.Insert($t.Item1, [System.Environment]::GetEnvironmentVariable($var), 1)
        }
        else {
            Write-Host "REPLACE TOKENS: Environment Variable $var not found."
        }
    }
    if ($replacedTokens) {
        return $ret.ToString()
    }
    return [string]::Empty
}# Function Find-ReplaceToken

function Find-ReplaceTokenInFiles {
    [CmdletBinding()]
    param(
        [string]$Path, # ".\azure-vote_replaceMe.yaml" or "C:\files\azure-*"
        [string[]]$Extensions = $null, # "*.yaml"
        [bool]$Recurse = $true
    )
 
    [hashtable]$Arguments = @{
        Path = $path
        File = $true
    }

    if ( !([string]::IsNullOrEmpty($Extensions)) ) {
        $Arguments.Add('Include', $Extensions)
    }
    
    if ( !([string]::IsNullOrEmpty($Recurse)) ) {
        $Arguments.Add('Recurse', $Recurse)
    }

    Get-ChildItem @Arguments | foreach {
        Write-Host "REPLACE TOKENS: Processing.. : $($_.FullName)"
        $contents = Find-ReplaceToken -String "$(Get-Content $_.FullName -Raw)"
        if (-not [string]::IsNullOrWhiteSpace($contents)) {
            Write-Host "REPLACE TOKENS: Done. Replacing tokens in file: $($_.FullName)"
            Set-Content -Path $_.FullName -Value $contents
        }
        else {
            Write-host "REPLACE TOKENS: Nothing to replace in file: $($_.FullName)"
        }
    }
} # function Find-ReplaceTokenInFile