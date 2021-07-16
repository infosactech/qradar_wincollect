#############################
# Copyright ITSec. All Rights Reserved.
# For troubleshooting please contact: 
#        <info@sactech.dev>
# Creation date: 17/12/2020
#Parameters
# Installation Stand alone WinCollect agent for Servers

$fd='https://Path_to_sharing_folder/wincollect-7.3.0-41.x64.exe' # Change sharing folder 
$fs=$env:windir+'\Temp\wincollect-7.3.1-16.x64.exe'
$InstallPath= 'C:\Program Files\IBM\WinCollect\'
(new-object System.Net.WebClient -ErrorAction SilentlyContinue).DownloadFile($fd,$fs)

# Delete and stop the service if it already exists.
if (Get-Service -Name 'wincollect' -ErrorAction SilentlyContinue) {
    $servWincollect = Get-WmiObject -Class Win32_Service -Filter "name='wincollect'"
    $servWincollect.StopService()
    Start-Sleep -Seconds 1
    Start-Process msiexec.exe -Wait -ArgumentList '/x {1E933549-2407-4A06-8EC5-83313513AE4B} REMOVE_ALL_FILES=True /qn'
    Start-Sleep -Seconds 5
}
    
#Clean-up folders
if ( Test-Path -Path $InstallPath -PathType Container ) { 
    "Remove-Item $InstallPath -Force  -Recurse -ErrorAction SilentlyContinue"
}

#Component for Server
function Component ($x) {
    $x="Component1."
    $LogSourceIdentifier=(Get-NetIPConfiguration).IPv4Address.IPAddress
    $LogSourceName=$env:COMPUTERNAME
    $DestName='siem.sactech.dev' # Change Hostname
    $DestHostname='IP_addr' #Set IP addr
    $DestPort=514
    $Protocol='UDP'
    $LogTypeSecurity='true'
    $LogTypeSystem='true'
    $LogTypeApplication='true'
    $LogTypeDNSsvr='false'
    $LogTypeFileReplicationsvr='false'
    $LogTypeDirectorysvr='false'
    $CustomQuery='PFF1ZXJ5TGlzdD4KPFF1ZXJ5IElkPSIwIiBQYXRoPSJNaWNyb3NvZnQtV2luZG93cy1TeXNtb24vT3BlcmF0aW9uYWwiPgo8U2VsZWN0IFBhdGg9Ik1pY3Jvc29mdC1XaW5kb3dzLVN5c21vbi9PcGVyYXRpb25hbCI+KjwvU2VsZWN0Pgo8L1F1ZXJ5Pgo8L1F1ZXJ5TGlzdD4='
    $EventRateTuningProfile='Typical+Server'
    $RemoteMachinePollInterval=3000
    $MinLogsToProcessPerPass=500
    $MaxLogsToProcessPerPass=750

    $x+"AgentDevice=DeviceWindowsLog"+'&'+$x+"Action=create"+'&'+$x+"LogSourceName=$LogSourceName"+'&'+$x+"LogSourceIdentifier=$LogSourceIdentifier"+'&'+$x+"Dest.Name=$DestName"+'&'+$x+"Dest.Hostname=$DestHostname"+'&'+$x+"Dest.Port=$destPort"+'&'+$x+"Dest.Protocol=$Protocol"+'&'+$x+"Log.Security=$LogTypeSecurity"+'&'+$x+"Log.System=$LogTypeSystem"+'&'+$x+"Log.Application=$LogTypeApplication"+'&'+$x+"Log.DNS+Server=$LogTypeDNSsvr"+'&'+$x+"Log.File+Replication+Service=$LogTypeFileReplicationsvr"+'&'+$x+"Log.Directory+Service=$LogTypeDirectorysvr"+'&'+$x+"RemoteMachinePollInterval=$RemoteMachinePollInterval"+'&'+$x+"EventRateTuningProfile=$EventRateTuningProfile"+'&'+$x+"MinLogsToProcessPerPass=$MinLogsToProcessPerPass"+'&'+$x+"MaxLogsToProcessPerPass=$MaxLogsToProcessPerPass"+'&'+$x+"CustomQuery.Base64=$CustomQuery"
    
    } 
$ComponentList=Component
$Argument = '/s /v"/qn INSTALLDIR=\"' + $InstallPath +'" LOG_SOURCE_AUTO_CREATION_ENABLED=True LOG_SOURCE_AUTO_CREATION_PARAMETERS=' + $ComponentList + '"'

if (Test-Path -Path $fs) {
    Start-Process -FilePath $fs -ArgumentList $Argument -Wait -Verb runAs} else {exit 1}

Start-Sleep -Seconds 5
