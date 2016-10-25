# Specify a path to the .config file if you do not wish to put the .config file in the same directory as the script
param(
  [string]$path,
  [string]$serverType,
  [bool]$solr,
  [bool]$check
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
        [xml]$configXml = Get-Content ($scriptDir + "\8.1.xml")
    }
    else
    {
        if (Test-Path $configPath)
        {
            [xml]$configXml = Get-Content ($configPath)
        }
        else
        {
            Write-Host "Could not find configuration file at specified path: $confgPath" 
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

	foreach($config in $configXml.Root.Configs.Config)
	{
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
