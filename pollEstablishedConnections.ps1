# This script documents the number of established connections to an ArcGIS Server machine's internal Tomcat.  
# This script has to be run on the machine of interest (it does not work remotely).

# Edit the "sleepSeconds" to establish how often the established connections will be counted (60 second default)
# The script will run in an infinite loop, writing the counts to the file you configure with the "establishedConnectionLogFile" variable
# If the count exceeds the "establishedConnectionThresholdForDetail" value, it will write a second file
# following the pattern established in the "localPort6443DetailPatternLogFile" variable to give you more detail.

# Run this PowerShell script via Windows Task Scheduler.
# Set the Trigger to begin the task at startup.
# Allow the task to be run on demand.  
# Then, manually start the task.  It will run until the machine restarts; at which point it will re-start when the machine comes up again.
# Stop the task when it is no longer needed.
# While the output does not use much space, you should not let this script run forever because it has no "clean-up" logic ...
# it will keep accumulating output until there is no more space on your system. 
# So, use this for troubleshooting.  And, when the trouble has been resolved, or this information is no longer useful, stop and disable or delete the task.


$sleepSeconds = 60
$establishedConnectionLogFile = "c:\temp\established_connection_count_to_6443.log"
$establishedConnectionThresholdForDetail = 300
$localPort6443DetailPatternLogFile = "c:\temp\localPort6443Detail_[TIMESTAMP].log"


while ($true)
{
    # Get a count of the established connections to 6443
    $d = Get-Date -Format "u"
    $cnt = [string]((Get-NetTCPConnection -State Established) | Where-Object { $_.LocalPort -eq "6443" }).Count

    # If the count exceeds a threshold of interest, collect more detail and write it out to a separate file
    if ($cnt -gt $establishedConnectionThresholdForDetail)
    {
        $localPort6443DetailContent = (Get-NetTCPConnection ) | Where-Object { $_.LocalPort -eq "6443" } | Out-String 
        $currentTimeString = Get-Date -Format "yyyy_MM_dd_hh_mm_ss"
        $currentFileName = $localPort6443DetailPatternLogFile.Replace("[TIMESTAMP]",$currentTimeString)
        Add-Content -Path $currentFileName -Value $localPort6443DetailContent
    }

    # Record the established connection count to an accumulating log file
    $logEntry = $d + ", " + $cnt

    Add-Content -Path $establishedConnectionLogFile -Value $logEntry

    # Wait for a configured period of time
    Start-Sleep -Seconds $sleepSeconds
}
