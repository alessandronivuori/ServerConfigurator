Sitecore Server Configurator
=============================
The Sitecore-PowerShell-Installer script enables you to enable/disable Sitecore instance role configuration files according to documentation


### How To Use
1. Download [script]
2. Run Powershell as Administrator and invoke ```. .\install.ps1```


Examples:
Enable/Disable config on a server
- .\install.ps1 C:\inetpub\wwwroot\CD81 ContentDelivery -solr 0 -check 0
- .\install.ps1 C:\inetpub\wwwroot\Cm81 ContentManagement -solr 0 -check 0
- .\install.ps1 C:\inetpub\wwwroot\Rp81 Reporting -solr 0 -check 0
- .\install.ps1 C:\inetpub\wwwroot\CP81 CMProcessing -solr 0 -check 0
- .\install.ps1 C:\inetpub\wwwroot\Pr81 Processing -solr 0 -check 0

Check Enabled/Disabled config on a server
- .\install.ps1 C:\inetpub\wwwroot\CD81 ContentDelivery -solr 0 -check 1
- .\install.ps1 C:\inetpub\wwwroot\Cm81 ContentManagement -solr 0 -check 1
- .\install.ps1 C:\inetpub\wwwroot\Rp81 Reporting -solr 0 -check 1
- .\install.ps1 C:\inetpub\wwwroot\CP81 CMProcessing -solr 0 -check 1
- .\install.ps1 C:\inetpub\wwwroot\Pr81 Processing -solr 0 -check 1

You can select the Sitecore version to use with the optional parameter 'version'. It must match the name of one of the xml files containing the configuration. 
Additionally, if your Sitecore instance has another name for the Website folder, you can tell the script to ignore the Website folder standard that Sitecore assumes and pass
the name of the Website folder you are using in the path parameter instead.

Ex:
- .\install.ps1 C:\inetpub\wwwroot\Pr81\Webroot Processing -solr 0 -check 1 -ignoreWebsitePrefix 1 -version 8.1rev3

You can see more information on the script's help 
- Get-Help .\install.ps1


### Troubleshooting
- If you see an error in PowerShell complaining that "the execution of scripts is disabled on this system." then you need to invoke ```Set-ExecutionPolicy -ExecutionPolicy unrestricted -Force```
- If you receive a security warning after invoking ```. .\install.ps1``` and want to make it go away permanently, then right-click on the install.ps1 file and "Unblock" it.

This script was inspired by Sitecore-PowerShell-Installer's script: https://github.com/patrickperrone/Sitecore-PowerShell-Installer

### XmlSchema.xml 
- For generating the xml files for future sitecore releases use this file. Use it in Excel via Developer tab (enable it first) -> XML -> Export. 
- You need to map the columns with the xml mappings first. Use Source on that same XML area, XML-Mappings-> Add and add the schema file. 
- Then for each mapping you do right click, 'Map Element' and select a cell in the column to be used. Do that for all, then you can export. 
- More information here: https://support.office.com/en-us/article/Export-XML-data-from-Excel-2016-c3cd6ade-7845-4b75-ba2e-fb9daad0567d