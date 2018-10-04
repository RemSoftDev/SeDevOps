Class CopyVm
{
    [string]$NameOfVm
    [string]$NameOfVsExternal
    [string]$NameOfVsIternal

    [int]$CountOfCores
    [bool]$UseAuotCheckpoints
    [bool]$AutoStart

    [string]$PathToVhd
}