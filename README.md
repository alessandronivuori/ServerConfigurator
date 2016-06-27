Server Configurator
=============================
The Sitecore-PowerShell-Installer script enables you to enable/disable file according the documentation 


### How To Use
1. Download [script]
2. Run Powershell as Administrator and invoke ```. .\install.ps1```
Examples:

.\install.ps1 C:\inetpub\wwwroot\CD81 ContentDelivery
.\install.ps1 C:\inetpub\wwwroot\Cm81 ContentManager
.\install.ps1 C:\inetpub\wwwroot\Rp81 Reporting
.\install.ps1 C:\inetpub\wwwroot\CP81 CMProcessing
.\install.ps1 C:\inetpub\wwwroot\Pr81 Processing


### Troubleshooting
- If you see an error in PowerShell complaining that "the execution of scripts is disabled on this system." then you need to invoke ```Set-ExecutionPolicy -ExecutionPolicy unrestricted -Force```
- If you receive a security warning after invoking ```. .\install.ps1``` and want to make it go away permanently, then right-click on the install.ps1 file and "Unblock" it.

This script was inspired by Sitecore-PowerShell-Installer's script: https://github.com/patrickperrone/Sitecore-PowerShell-Installer
