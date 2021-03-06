#meetingroomhud

PowerShell, EWS and Javascript working together to show a timeline of meeting room appointments.

###Setup

First, change the variables in `meetingrooms.ps1` to match your environment. This will include:

- The meeting room names (this does not have to match the name in Exchange) and the email address (this does have to match)
- Which displays will have which calendars displayed
- The colour of the appointment bars
- The output directory for the generated JSON files

The script has to be run under an account that has access to the meeting room calendars. The easiest way to do this is by running the following:

`Get-Mailbox -RecipientTypeDetails "RoomMailbox" | Add-MailboxPermission -User "contoso\serviceaccount" -AccessRights "FullAccess"`

###What it looks like

<img src="http://i.imgur.com/vnA7hWV.png" />

###Accessing

Point your browser to http://webserver/index/htm?screen=room_id

###Questions?

Reach out to me on twitter, @jludriks