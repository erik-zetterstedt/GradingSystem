param
(
    [string] $newVersion
)

$ErrorActionPreference = "Stop";

try 
{
    $nugetFeed = "http://nuget.octopus.tuinordic.insite";
    $nugetFeedApiKey = "FB9E36E5-B5EB-4628-A5D4-3CBE02C1CA3D";
	
	function Get-NUnitRunner()
	{
		$nunits = @(Get-ChildItem -Path (Resolve-Path .) -Include "nunit-console.exe" -Recurse);
		if($nunits.Length -eq 0 )
		{
			Write-Error "Could not find path to NUnit runner";
			exit 1;
		}

		return $nunits[0];
	}

    function Get-MSpecRunner()
    {
        $mspecs = @(Get-ChildItem -Path (Resolve-Path .) -Include "mspec-clr4.exe" -Recurse);
        if($mspecs.Length -eq 0 )
        {
            Write-Error "Could not find path to MSpec runner";
            exit 1;
        }

        return $mspecs[0];
    }

	function Get-NUnitTestAssemblies()
	{
		$assemblies = @(Get-ChildItem -Path (Resolve-Path .) -Include @("*NUnit.Tests.dll","*Specflow.Tests.dll") -Recurse) | Where-Object {$_.FullName.ToLower().Contains("\bin\release\") -eq $true};
	
		return $assemblies;
	}

    function Get-MSpecTestAssemblies()
    {
        $assemblies = @(Get-ChildItem -Path (Resolve-Path .) -Include "*MSpec.Tests.dll" -Recurse) | Where-Object {$_.FullName.ToLower().Contains("\bin\release\") -eq $true};
    
        return $assemblies;
    }
	
    function Get-DefaultTestAssemblies()
    {
        $assemblies = @(Get-ChildItem -Path (Resolve-Path .) -Include "*.Tests.dll" -Recurse) | Where-Object {$_.FullName.ToLower().Contains("\bin\release\") -eq $true};
    
        return $assemblies;
    }
    
	function Run-NUnitTest($path)
	{
		$pathToNUnit = Get-NUnitRunner;
		$pathToTestAssembly = """$path""";
		
		Write-Host("Running NUnit $pathToMSpec against $pathToTestAssembly");
		& $pathToNUnit $pathToTestAssembly;
		
		if ($LastExitCode -ne 0)
		{			
			exit $LastExitCode;
		}		
	}

    function Run-MSpecTest($path)
    {
        $pathToMSpec = Get-MSpecRunner;
        $pathToTestAssembly = """$path""";
        $ignoredTags = """RabbitMQ""";

        Write-Host("Running MSpec $pathToMSpec -x $ignoredTags $pathToTestAssembly");
        & $pathToMSpec -x $ignoredTags $pathToTestAssembly;
        if ($LastExitCode -ne 0)
        {
            exit $LastExitCode;
        }       
    }

	function Run-Tests()
	{
		Write-Host "Checking for test assemblies";
		$nunitTestAssemblies = Get-NUnitTestAssemblies;
		$mspecTestAssemblies = Get-MSpecTestAssemblies;
        $defaultTestAssemblies = Get-DefaultTestAssemblies;

		if($nunitTestAssemblies.length -gt 0)
		{
			Write-Host "NUnit assembly found";
			($nunitTestAssemblies) | ForEach-Object { Run-NUnitTest $_.FullName; };
		}
		else
		{
			Write-Host "No NUnit assembly found";
		}

		if($mspecTestAssemblies.length -gt 0)
		{
			Write-Host "MSpec assembly found";
			($mspecTestAssemblies) | ForEach-Object { Run-MSpecTest $_.FullName; };
		}
		else
		{
			Write-Host "No MSpec assembly found";
		}
        
        if($defaultTestAssemblies.length -gt 0)
		{
			Write-Host "Default test assembly found";
			($defaultTestAssemblies) | ForEach-Object { Run-MSpecTest $_.FullName; };
		}
		else
		{
			Write-Host "No default test assembly found";
		}
	}


    function Update-AssemblyInfoFiles ([string] $newVersion) 
	{
    	$assemblyVersionPattern = 'AssemblyVersion\(".*"\)';
    	$fileVersionPattern = 'AssemblyFileVersion\(".*"\)';
    	$assemblyVersion = 'AssemblyVersion("' + $newVersion + '")';
    	$fileVersion = 'AssemblyFileVersion("' + $newVersion + '")';
    	
    	Get-ChildItem -r -filter AssemblyInfo.cs | ForEach-Object {
    		$filename = $_.Directory.ToString() + '\' + $_.Name;
    	
    		(Get-Content $filename) | ForEach-Object {
    			% {$_ -replace $assemblyVersionPattern, $assemblyVersion } |
    			% {$_ -replace $fileVersionPattern, $fileVersion }
    		} | Set-Content $filename
    	}
    }

	function Get-SolutionFile()
	{
		$solutions = @(Get-ChildItem -Path (Resolve-Path .) "*.sln");
		if($solutions.Length -eq 0 )
		{
			Write-Error "Could not find a solution file to build";
			exit 1;
		}
		
		$solutionFile = $solutions[0];
		
		return """$solutionFile""";
	}

    function Build-Solution ([string] $configuration, [string] $newVersion) 
    {
		$solutionFile = Get-SolutionFile;
        Write-Host -ForegroundColor Green "<-- Building solution $solutionFile -->";

		$msBuild = Join-Path $env:systemroot "\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe";
		$arguments = "$solutionFile /p:OctoPackPublishApiKey=$nugetFeedApiKey /p:OctoPackPublishPackageToHttp=$nugetFeed /p:OctoPackPackageVersion=$newVersion /p:RunOctoPack=true /p:Configuration=$configuration";

		& $msBuild "$solutionFile /p:Configuration=$configuration /t:Rebuild /p:WebProjectOutputDir=publish /p:OutDir=publish\bin\ ";
		Run-Tests;

		Write-Host "Executing: $msbuild $arguments";
		& $msBuild $arguments;
        if ($LastExitCode -ne 0)
        {
        	exit $LastExitCode;
        }
    }

    Update-AssemblyInfoFiles -newVersion $newVersion;
    Build-Solution -Configuration "Release" -newVersion $newVersion;
}
catch
{
    Write-Host $error[0]
    exit 1;
}