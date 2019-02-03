Set-ExecutionPolicy Unrestricted -Scope CurrentUser
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco feature enable -n allowGlobalConfirmation
choco install ../configs/base-host.config
choco install ../configs/vs-code.config