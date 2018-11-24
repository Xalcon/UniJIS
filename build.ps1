$ErrorActionPreference = "stop"

$shiftJis = Get-Content "$PSScriptRoot/mapping/SHIFTJIS.TXT"

$groups = @{ }

foreach($line in $shiftJis)
{
    $line = $line.Substring(0, $line.IndexOf('#')).Trim()
    if($line.Length -eq 0) { continue; }
    $shiftJisCode, $utf16 = $line.Split("`t") | % { [uint32]$_ }
    $shiftJisGroup = [int](($shiftJisCode -band [uint32]0xF000) -shr 12)
    if(!$groups.ContainsKey($shiftJisGroup))
    {
        $groups.Add($shiftJisGroup, @{})
    }
    $groups[$shiftJisGroup].Add($shiftJisCode, $utf16);
}

$sb = [System.Text.StringBuilder]::new()
foreach($group in $groups.Keys | Sort-Object { $_ })
{
    $sb.Append("char16_t shiftJisUtf16Group$group[] = { ") | Out-Null
    for($i = 0; $i -lt 0x0FFF; $i++)
    {
        $index = [uint32](($group -shl 12) -bor $i)
        if($groups[$group].ContainsKey($index))
        {
            $v = '{0:x4}' -f $groups[$group][$index]
            $sb.Append("0x$v, ") | Out-Null
        }
        else
        {
            $sb.Append("0x0020, ") | Out-Null
        }
    }
    $sb.Append(" };`n") | Out-Null
}

$sb2 = [System.Text.StringBuilder]::new()
$sb2.Append("`t") | Out-Null
for($i = 0; $i -lt 16; $i++)
{
    if($groups.ContainsKey($i))
    {
        $sb2.Append("shiftJisUtf16Group$i, ") | Out-Null
    }
    else
    {
        $sb2.Append("0, ") | Out-Null
    }
}

$file = Get-Content  "$PSScriptRoot\template.h.tpl"
if(!(Test-Path "$PSScriptRoot/out"))
{
    mkdir out
}
$file.Replace("/*%SHIFT_JIS_UTF8_GROUPS%*/", $sb.ToString()).Replace("/*%SHIFT_JIS_UTF8_GROUP_MAP%*/", $sb2.ToString()) | Out-File "$PSScriptRoot/out/ShiftJisUtf16.h" -Force
Write-Host "Wrote file to $PSScriptRoot/out/ShiftJisUtf16.h"