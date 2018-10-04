Class CopyVm
{
    [string]$NameOfVm
    [string]$NameOfVsExternal
    [string]$NameOfVsInternal

    [int]$CountOfCores
    [bool]$AutomaticCheckpointsEnabled
    [bool]$AutoStart

    [string]$PathToVhdInitial
    [string]$PathToVhdNew
    [string]$PathToVhdFolder
}