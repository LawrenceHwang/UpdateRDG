function AddNode
{
<#
.Synopsis
   Add XML server node.
.DESCRIPTION
   Add XML server node.
#>
    [CmdletBinding()]
    Param(
        $resultRDGFile
    )
    [xml]$rdg = Get-Content -Path $resultRDGFile
    
    try {
        Write-Verbose "Fetching base[0] to clone."
        $newNode = ($rdg.RDCMan.file.server)[0].Clone()
    }
    catch {
        Write-Verbose "Fetching base to clone."
        if ($newNode -eq $null){
            $newNode = ($rdg.RDCMan.file.server).Clone()
        }
    }
    
    Write-Verbose "$($v.VMName),$($v.ip) "

    $newNode.properties.displayName = "$($v.VMName)"
    $newNode.properties.name = "$($v.ip)"
    [void]$rdg.RDCMan.file.AppendChild($newNode)
    $rdg.Save($resultRDGFile)
}

[xml]$rdg = @"
<?xml version="1.0" encoding="utf-8"?>
<RDCMan programVersion="2.7" schemaVersion="3">
  <file>
    <credentialsProfiles />
    <properties>
      <expanded>True</expanded>
      <name>Demo</name>
    </properties>
    <remoteDesktop inherit="None">
      <sameSizeAsClientArea>True</sameSizeAsClientArea>
      <fullScreen>False</fullScreen>
      <colorDepth>24</colorDepth>
    </remoteDesktop>
    <localResources inherit="None">
      <audioRedirection>NoSound</audioRedirection>
      <audioRedirectionQuality>Dynamic</audioRedirectionQuality>
      <audioCaptureRedirection>DoNotRecord</audioCaptureRedirection>
      <keyboardHook>Remote</keyboardHook>
      <redirectClipboard>True</redirectClipboard>
      <redirectDrives>False</redirectDrives>
      <redirectDrivesList />
      <redirectPrinters>False</redirectPrinters>
      <redirectPorts>False</redirectPorts>
      <redirectSmartCards>False</redirectSmartCards>
      <redirectPnpDevices>False</redirectPnpDevices>
    </localResources>
    <server>
      <properties>
        <displayName>node_template</displayName>
        <name>10.255.255.255</name>
      </properties>
    </server>
  </file>
  <connected />
  <favorites />
  <recentlyUsed />
</RDCMan>
"@

$resultRDGFile = 'C:\temp\Demo.rdg'
$rdg.Save($resultRDGFile)

# Parsing the Hyper-V server information and getting the VM name and ip.
$vm = get-vm | where state -NotLike 'off' | Get-VMNetworkAdapter | select vmname, @{n='ip'; e ={$_.ipaddresses | where {$_ -match '^\d{1,3}.\d{1,3}.\d{1,3}.\d{1,3}'}}}

Foreach ($v in $vm){

    AddNode -resultRDGFile $resultRDGFile

}
