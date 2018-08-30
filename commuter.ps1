$app = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'

[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] >$null 2>&1
$Template = [Windows.UI.Notifications.ToastTemplateType]::ToastImageAndText01

$myName     =    "Abhishek"
$myHome     =    "&destinations=MyHome"
$myWork     =    "&origins=MyWork"
$mapsKey    =    "&key=MyKey"
$departTime =    "&departure_time=now"
$mapApiUrl  =    "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial"
$finalUrl   =    "$mapApiUrl$myWork$myHome$departTime$mapsKey"
$shortUrl   =    "https://goo.gl/MyShortURL" # this is shortened URL of google maps route

$map_response   =   Invoke-WebRequest $final_url 
$mapObject      =   ConvertFrom-Json -InputObject $map_response
$ttime          = $mapObject.rows.elements.duration_in_traffic.text

#Gets the Template XML so we can manipulate the values
[xml]$ToastTemplate = ([Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent($Template).GetXml())

[xml]$ToastTemplate = @"
<toast launch="app-defined-string">
  <visual>
    <binding template="ToastGeneric">
      <text>Traffic Alert...</text>
      <text> $myName, Time to home: $ttime</text>
    </binding>
  </visual>
  <actions>
    <action activationType="foreground" content="Take me to maps" arguments=""/>
    <action activationType="background" content="Okay" arguments=""/>
    
  </actions>
</toast>
"@

$ToastXml = New-Object -TypeName Windows.Data.Xml.Dom.XmlDocument
$ToastXml.LoadXml($ToastTemplate.OuterXml)

$notify = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($app) 

$notify.Show($ToastXml) 
