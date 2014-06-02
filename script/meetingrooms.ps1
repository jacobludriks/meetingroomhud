$mailboxlist = @{}
#List of mailboxes to get, along with screen name
$mailboxlist["room1"] = @("room1";"room2")
$mailboxlist["room2"] = @("boardroom","conferenceroom")
#meeting bar colour
$colour = "#274A80"
#web server directory
$webdir = "C:\gitprojects\meetingrooms\site"
#multidimensional array
$mailboxes = @{}
$mailboxes["room1"] = @{"Name"="Meeting Room 1";"Email"="amucommroom@sanitarium.co.nz"}
$mailboxes["room2"] = @{"Name"="Meeting Room 2";"Email"="resakr03@sanitarium.co.nz"}
$mailboxes["boardroom"] = @{"Name"="Board Room";"Email"="amutasmanroom@sanitarium.co.nz"}
$mailboxes["conferenceroom"] = @{"Name"="Conference Room";"Email"="resakr07@sanitarium.co.nz"}
#main script
$StartDate = get-date -Date "$(get-date -format d) 8:00am"
$EndDate = get-date -Date "$(get-date -format d) 5:00pm"
$dllpath = "$((Get-Location).path)`\Microsoft.Exchange.WebServices.dll"
[void][Reflection.Assembly]::LoadFile($dllpath)
$windowsIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$sidbind = "LDAP://<SID=" + $windowsIdentity.user.Value.ToString() + ">"
$aceuser = [ADSI]$sidbind
$mailboxlist.Keys | % {
	$jsonarray = @()
	$timesarray = @()
	foreach ($mailbox in $mailboxlist[$_]) {
		$service = New-Object Microsoft.Exchange.WebServices.Data.ExchangeService([Microsoft.Exchange.WebServices.Data.ExchangeVersion]::Exchange2007_SP1)
		$service.AutodiscoverUrl($aceuser.mail.ToString())
		$email = $mailboxes[$mailbox]["Email"]
		$folderid = new-object  Microsoft.Exchange.WebServices.Data.FolderId([Microsoft.Exchange.WebServices.Data.WellKnownFolderName]::Calendar,$email)
		$CalendarFolder = [Microsoft.Exchange.WebServices.Data.CalendarFolder]::Bind($service,$folderid)
		$cvCalendarview = new-object Microsoft.Exchange.WebServices.Data.CalendarView($StartDate,$EndDate,2000)
		$cvCalendarview.PropertySet = new-object Microsoft.Exchange.WebServices.Data.PropertySet([Microsoft.Exchange.WebServices.Data.BasePropertySet]::FirstClassProperties)
		$frCalendarResult = $CalendarFolder.FindAppointments($cvCalendarview)
		foreach ($apApointment in $frCalendarResult.Items){
			$psPropset = new-object Microsoft.Exchange.WebServices.Data.PropertySet([Microsoft.Exchange.WebServices.Data.BasePropertySet]::FirstClassProperties)
			$apApointment.load($psPropset)
			$appointmentname = $apApointment.Subject.ToString()
			$start = [int](get-date ($apApointment.Start.ToUniversalTime()) -uformat %s) * 1000
			$end = [int](get-date ($apApointment.End.ToUniversalTime()) -uformat %s) * 1000
			$organizer = $apApointment.Organizer.ToString() -replace "\s<.*",""
			$duration = $apApointment.Duration.ToString()
			$cancelled = $apApointment.IsCancelled.ToString()
			$timesarray += [PSCustomObject]@{"color"=$colour;"label"=$organizer;"starting_time"=$start;"ending_time"=$end}
		}
		$jsonarray += [Ordered]@{"label"=$mailboxes[$mailbox]["Name"];"times"=$timesarray}
	}
	$jsonfinal = convertto-json -depth 3 $jsonarray
	$jsonfinal | Out-File "$webdir\json\$($_)`.json"
}