 <#
.SYNOPSIS
    Enable/disable Sitecore configuration files
.DESCRIPTION
    Enable/disables Sitecore configuration files depending on the role desired for the instance
.PARAMETER path
    The path to the Sitecore instance (Website folder)
.PARAMETER serverType
    The role the Sitecore instance should have. Must be one of "ContentDelivery", "ContentManagement", "Processing", "CMProcessing" or "Reporting"
.PARAMETER solr
    Use Solr as search provider, instead of Lucene
.PARAMETER version
    Use the Sitecore version specified. See available version xml files to know which versions are available. Use just the name of the file with no extension as name for the version. 
.PARAMETER check
    Check that the configuration on the instance matches the desired role
.PARAMETER ignoreWebsitePrefix
    Don't use the website folder in the path, as specified in the Sitecore excel. Use this is your Website root has some other name and you are already including it in the path parameter.
.EXAMPLE
    C:\PS> install.ps1 -path C:\inetpub\wwwroot\Sitecore -serverType CMProcessing -solr 0 -check 0 -version 8.1
.NOTES
    Author: Alessandro Nivuori
    Contributor: Diego Saavedra San Juan
    Date:   Many
#>

# Specify a path to the .config file if you do not wish to put the .config file in the same directory as the script
param(
  [Parameter(Mandatory=$true)]
  [string]$path, # The path to the Sitecore instance
  [Parameter(Mandatory=$true)]
  [string]$serverType, # The role for the Sitecore instance. Must be one of "ContentDelivery", "ContentManagement", "Processing", "CMProcessing" or "Reporting"
  [Parameter(Mandatory=$true)]
  [string]$version="8.1",
  [Parameter(Mandatory=$false)]
  [bool]$solr=$false, # Use Solr instead of Lucene as search provider for the instance
  [Parameter(Mandatory=$false)]
  [bool]$check=$false, # Check that the instance configuration matches the role desired
  [Parameter(Mandatory=$false)]
  [bool]$ignoreWebsitePrefix=$false # Don't use the website folder in the path, as specified in the Sitecore excel. Use this is your Website root has some other name and you are already including it in the path parameter.
)
[string]$configPath
$scriptDir = Split-Path (Resolve-Path $myInvocation.MyCommand.Path)
$configSettings = $null
# Assume there is no host console available until we can read the config file.
$hostScreenAvailable = $FALSE



function Read-InstallConfigFile([string]$configPath)
{
    if ([string]::IsNullOrEmpty($configPath))
    {
        [xml]$configXml = Get-Content ($scriptDir + "\" + $version + ".xml")
    }
    else
    {
        if (Test-Path $configPath)
        {
            [xml]$configXml = Get-Content ($configPath)
        }
        else
        {
            Write-Host "Could not find configuration file at specified path: $configPath" 
        }
    }

    return $configXml
}

function Disable-File([string]$file)
{
	$filename = Find-File $file

	if ($filename)
    {
		$extension = [System.IO.Path]::GetExtension($filename)
		if ($extension.equals(".config"))
		{
				
			if (![bool]($check))
			{
				Write-Host "Disabling Config File:"$filename
				Rename-Item $filename ($filename+".disabled")
			}
			else
			{
				Write-Host "Config File:"$filename" should be disabled" -ForegroundColor "Red"
			}
		}	

		if ($extension.equals(".disabled"))
		{
			Write-Host "ALREADY DISABLED:"$filename	-ForegroundColor "Green"
		}
	}
	else
	{
		Write-Host "File NOT FOUND:"$file
	}
		
}

function Enable-File([string]$file)
{
	$filename = Find-File $file
	
	if ($filename)
    {
		$extension = [System.IO.Path]::GetExtension($filename)
		if ($extension.equals(".config"))
		{
			Write-Host "ALREADY ENABLED:"$filename	-ForegroundColor "Green"
		}	

		if ($extension.equals(".disabled"))
		{

			if (![bool]($check))
			{
				Write-Host "Enabling Disabled File:"$file	
				$enabledFile = $file -replace ".disabled$", "" 
				Rename-Item $filename $enabledFile
			}
			else
			{
				Write-Host "Config File:"$filename" should be enabled" -ForegroundColor "Red"
			}
		}
		if ($extension.equals(".example"))
		{

			if (![bool]($check))
			{		
				Write-Host "Enabling Example File:"$file	
				$enabledFile = $file -replace ".example$", ""			
				Rename-Item $filename $enabledFile
			}
			else
			{
				Write-Host "Config File:"$filename" should be enabled" -ForegroundColor "Red"
			}
		}
	}
	else
	{
		Write-Host "Config File:"$file" should be enabled but is NOT FOUND" -ForegroundColor "Red" 
	}
	
}
function Find-File([string]$file)
{

		if (Test-Path $file)
		{
			return $file
		}
		$disabledFile = $file +".disabled"
		if (Test-Path $disabledFile)
		{
			return $disabledFile	
		}
		$enabledFile = $file -replace ".disabled$", "" 
		if (Test-Path $enabledFile)
		{
			return $enabledFile
		}
		$exampleFile = $file -replace ".example$", "" 
		if (Test-Path $exampleFile)
		{
			return $exampleFile
		}

		return ""
		

	
	
}


function Set-Config-File([string]$file)
{
	if ($serverConfig.equals("Enable"))
	{
		Enable-File $file
	}
	if ($serverConfig.equals("Disable"))
	{
		Disable-File $file
	}	
}

function Set-Config-File-Using-SearchProvider([string]$file, [string]$searchProviderUsed)
{
	if (!$config.SearchProviderUsed.equals($searchProviderUsed))
	{
		Set-Config-File $file
	}
	if ($config.SearchProviderUsed.equals($searchProviderUsed))
	{
		Disable-File $file
	}
}


function Configure-Server([string]$path, $serverType)
{
    [xml]$configXml = Read-InstallConfigFile $configPath

    if ( $configXml -eq $null -or $configXml.HasChildNodes -eq $false )
    {
        Write-Host 'No configuration file found or empty, quitting'
        exit 1
    }

    

	foreach($config in $configXml.Root.Config)
	{
        if ( $ignoreWebsitePrefix -eq $true )
        {
            $config.FilePath = $config.FilePath -replace "\\website", ""
        }
		$file = $path+"\"+$config.FilePath+"\"+$config.ConfigFileName
		$serverConfig = ($config | Select -ExpandProperty $serverType)
		if ([bool]($config.SearchProviderUsed))
		{
		
			if (![bool]($solr))
			{
				Set-Config-File-Using-SearchProvider $file "Solr is used"
				
			}
			if ([bool]($solr))
			{
				Set-Config-File-Using-SearchProvider $file "Lucene is used"
			}
		}
		else
		{
			Set-Config-File $file		
		}
	}
}



Configure-Server $path $serverType [bool]$solr [bool]$check 
