param 
(
	[string] $octopusProjectName,
	[string] $environmentName,
	[string] $githubRepositoryName,
    [string] $newVersion
)

$ErrorActionPreference = "Stop";

try 
{
	$octupusServerUrl = "https://web-octopus.nordic.tuiad.org/";
	$octupusApiKey = "API-UXWRAHYJIJKUFXMHPUONGCKOPU";

    $githubServerUrl = "https://api.github.com/repos/Fritidsresor/";
	$githubAccessToken = "2b8646d33ba639c0de1e1bd8299c7599387510c5";

    function Github-GetCommitsAsText([string] $repo, [string] $currentVersion, [string] $newVersion)
	{
        $url = "${githubServerUrl}${repo}/compare/${currentVersion}...${newVersion}?access_token=${githubAccessToken}";
        Write-Host $url;
		try
		{
            $json = Invoke-RestMethod -Method Get -Uri $url;
            $result = "";

            foreach ($commit in $json.commits) {
                $result += "*";
                $result += " " + $commit.commit.committer.date.Substring(0, 16).Replace("T", " ");
                $result += ' <a href="' + $commit.html_url + '">' + $commit.commit.message + '</a>';
                $result += " by " + $commit.commit.committer.name;

                $result += "`n";
            }

            return $result;
            
		}
		finally
		{

		}
	}

	function Octupus-GetJsonResult([string] $url)
	{
		[System.Reflection.Assembly]::LoadWithPartialName("System.Web.Extensions") | Out-Null

		$webclient = $null;
		try
		{
			$apiUrl = $octupusServerUrl + $url;
			$webclient = New-Object System.Net.WebClient;
			$webclient.Headers.Add("X-Octopus-ApiKey", $octupusApiKey);
			$raw = $webclient.DownloadString($apiUrl);
			$ser = New-Object System.Web.Script.Serialization.JavaScriptSerializer;

			return $ser.DeserializeObject($raw);
		}
		finally
		{
			if($webclient -ne $null)
			{
				$webclient.Dispose();
			}
		}
	}

	function Octupus-GetProjectId([string] $projectName)
	{
		$json = Octupus-GetJsonResult "api/projects";
		$project = $json.Items | Where-Object {$_.Name -eq $projectName};	
		
		return $project.Id;
	}

	function Octupus-GetEnvironmentId([string] $environmentName)
	{
		$json = Octupus-GetJsonResult "api/environments";
		$environment = $json.Items | Where-Object {$_.Name -eq $environmentName};
		
		return $environment.Id;
	}

	function Octupus-GetLatestDeploymentId($projectId, $environmentId)
	{
		$url = "/api/deployments?projects=" + $projectId + "&environments=" + $environmentId;
		$json = Octupus-GetJsonResult $url;

		if( $json.Items.length -eq 0 )
		{
			Write-Error("Could not find any deployments for $projectId/$environmentId");
			exit 1;
		}
		
		return $json.Items[0].Id;
	}

	function Octopus-GetLatestVersionForDeployment($deploymentId)
	{
		$url = "/api/deployments/" + $deploymentId;
		$json = Octupus-GetJsonResult $url;	
		$url = "/api/releases/" + $json.ReleaseId;
		$json = Octupus-GetJsonResult $url;

		if( $json.SelectedPackages.length -eq 0 )
		{
			Write-Error("Could not find any packages for deployment $deploymentId");
			exit 1;
		}

		return $json.SelectedPackages[0].Version;
	}

	function Get-LatestVersionForReleaseNotes()
	{
		$projectId = Octupus-GetProjectId $octopusProjectName;
		$environmentId = Octupus-GetEnvironmentId $environmentName;
		$deploymentId = Octupus-GetLatestDeploymentId $projectId $environmentId;
		$lastDeployedVersion = Octopus-GetLatestVersionForDeployment $deploymentId;
		
		return $lastDeployedVersion;
	}

	function Add-ReleaseNotes()
	{
		$file = "release-note.txt";

		try
		{
			$lastDeployedVersion = Get-LatestVersionForReleaseNotes;
            Write-Host("Creating release notes for v$lastDeployedVersion to $newVersion");
            $commits = Github-GetCommitsAsText -repo $githubRepositoryName -currentVersion v$lastDeployedVersion -newVersion v$newVersion;
            
			Set-Content -Path $file -Value $commits.ToString();
            Write-Host $commits;	
		}
		catch
		{
			Set-Content $file "Could not create release-notes.";
			Write-Host("Could not create release-notes.");
            Write-Host $_.Exception.Message;
		}
	}

	Add-ReleaseNotes;
} 
catch 
{
	Write-Host $error[0]
    exit 1;
}