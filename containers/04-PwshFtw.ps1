## Example on how powerful parallel loops can be in Powershell Core




Write-Host "NOT Parallel:" # Execute in Windows Powershell
$start = Get-Date
$port = '443','80','22','30','50'
$port | ForEach-Object {
    Test-NetConnection -ComputerName "google.com" -Port $_ -WarningAction Ignore | select RemotePort,TcpTestSucceeded
}
$end = Get-Date
($end-$start).TotalSeconds
# should be slow. :-(



Write-Host "Parallel:" # Execute in Powershell Core 7.1.x
$start = Get-Date
$port = '443','80','22','30','50'
$port | ForEach-Object -Parallel {
    Test-NetConnection -ComputerName "google.com" -Port $_ -WarningAction Ignore | select RemotePort,TcpTestSucceeded
} -ThrottleLimit 100
$end = Get-Date
($end-$start).TotalSeconds
# so fast - such wow!

# another example - please not that variables can be a little different when you're using paralel loops
$prefix = "Number:"
1..100 | ForEach-Object -ThrottleLimit 50 -Parallel { Start-Sleep -Seconds 1; Write-host "$using:prefix $_" }


# for more advanced information, you can check out some links:
# using Powershell foreach parallel:
# https://argonsys.com/microsoft-cloud/library/powershell-foreach-object-parallel-feature/

# using a threadsafe variable to store variables:
# using a "Concurrent bag" - see: https://stackoverflow.com/a/60902322