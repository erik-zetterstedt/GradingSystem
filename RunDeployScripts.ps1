param 
(
   [string] $environmentName,
   [string] $octopusProjectName,
   [string] $createNewGitTag,
   [string] $githubRepository,
   [string] $githubRepositoryName
)

$ErrorActionPreference = "Stop";

try 
{
  function Get-DefaultVersion()
  {
      return Get-Date -f '0.yyyy.Mdd.Hmm';
  }

  function Get-LatestVersionFromGithub()
  {
      Write-Host "Fetching latest git version";
      git fetch;
      $gitVersion = git describe;
      $isMatch = $gitVersion -match "(\d+.\d+.\d+.\d+)";
      
      if($isMatch -eq $true)
      {
          Write-Host "Latest git version is $matches[0]";
          return $matches[0];
      }

      return Get-DefaultVersion;
  }

  function Get-Version()
  {
      if($createNewGitTag -eq "1")
      {
          return Get-DefaultVersion;
      }

      return Get-LatestVersionFromGithub;
  }

  function Git-UpdateWithNewTagVersion()
  {
      if($createNewGitTag -ne "1"){
        return;
      }

      git remote rm github;
      
      if ($LastExitCode -eq 1 -Or $LastExitCode -eq 0)
      {
        Write-Host("Adding github as remote if missing");
        git remote add github $githubRepository;
      }
      elseif ($LastExitCode -ne 0)
      {
        Write-Host("remote rm github failed with <Git Exit Code>: $LastExitCode");
        exit $LastExitCode;
      } 
      
      Write-Host("Git tag with release number");  
      git tag -m "Package Version $newVersion" v$newVersion;
      
      Write-Host("Git local commit for changed files");
      git commit -am "Updated to Assembly version $newVersion";
      
      Write-Host("Git push to origin master");
      git push github origin:master;

      git push github --tags;
  }


  $newVersion = Get-Version;
  Write-Host "New version: $newVersion";

  Git-UpdateWithNewTagVersion;

  . ".\DeployToNuget.ps1" -newVersion $newVersion;
	if ($LastExitCode -ne 0)
	{
		exit $LastExitCode;
	}
  . ".\ReleaseNotes.ps1" -octopusProjectName $octopusProjectName -environmentName $environmentName -githubRepositoryName $githubRepositoryName -newVersion $newVersion;
	if ($LastExitCode -ne 0)
	{
		exit $LastExitCode;
	}
  . ".\DeployOctopusRelease.ps1" -environmentName $environmentName -octopusProjectName $octopusProjectName -newVersion $newVersion -githubRepository $githubRepository;
	if ($LastExitCode -ne 0)
	{
		exit $LastExitCode;
	}  
}
catch
{
  Write-Host $error[0];
  exit 1;
}
