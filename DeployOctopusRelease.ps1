param 
(
   [string] $environmentName,
   [string] $octopusProjectName,
   [string] $newVersion,
   [string] $githubRepository
)

$ErrorActionPreference = "Stop";

try 
{
	$octopus_api_key = "API-BMRU4DZZWIZL45ZWUHENMNKXYC";
	$octopus_server = "https://web-octopus.nordic.tuiad.org";

	function Octopus-DeployRelease()
	{
		$latestOctopusToolsVersion = Get-ChildItem ".\packages" -Name -Filter "OctopusTools*" | Sort-Object Name | Select-Object -First 1
		$octoToolsExe = "packages\$latestOctopusToolsVersion\Octo.exe"

		# Create project if it does not exist
		& .\$octoToolsExe create-project --server="$octopus_server/api" --apiKey="$octopus_api_key" --projectGroup="All projects" --name="$octopusProjectName" --ignoreIfExists

		#Create release and deploy
		& .\$octoToolsExe create-release --server="$octopus_server/api" --project="$octopusProjectName" --apiKey="$octopus_api_key" --deployto="$environmentName" --waitfordeployment --version $newVersion --releasenotesfile="release-note.txt";
	}

	Octopus-DeployRelease;
}
catch
{
	Write-Host $error[0]
	exit 1;
}
