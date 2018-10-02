configuration TestProcess {
    node LVAGPLTP2642 {
        WindowsProcess CreateNotepad {
            Path = "%windir%\system32\notepad.exe"
            Arguments = ""
        }
    }
}

Start-DscConfiguration -ComputerName LVAGPLTP2642 -Path C:\Users\oleksandr.dubyna\Documents\GIT\SE\SeDevOps\DSC -Wait -Verbose -Force