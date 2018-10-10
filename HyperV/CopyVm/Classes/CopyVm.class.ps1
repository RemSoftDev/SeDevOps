Class CopyVm
{
    [string]$NameOfVm
    [string]$NameOfVsExternal
    [string]$NameOfVsInternal

    [string]$PcUserLogin
    [string]$PcUserPassword
    [string]$PcTimeZone
    
    [int]$CountOfCores
    [bool]$AutomaticCheckpointsEnabled
    [bool]$AutoStart

    [string]$PathToVhdInitial
    [string]$PathToVhdNew
    [string]$PathToVhdFolder
}