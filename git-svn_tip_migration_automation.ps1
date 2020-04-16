function trunk_master
{
    $path = Read-Host -Prompt "Enter the path where you want to clone the repo locally"
    if (Test-Path -Path "$path" -PathType Container) 
    {
        cd $path
    }
    else 
    {
        Write-Host "Please enter a valid path"
        exit
    }
    $repo = Read-Host -Prompt "Enter the repo url"
    #clone into any desired path
    git clone $repo 
    #$? Contains the execution status of the last operation. 
    #It contains TRUE if the last operation succeeded and FALSE if it failed.
    if(-not $?) {
    #throw "Error with git clone!"
    Write-Output "Possible chances for termination `n 1. Wrong url for Git repo `n 2. You are trying to clone again, i.e already a git repo exists with that nam `n Read the above error description for better details"
    exit
    #$repo = Read-Host -Prompt "Enter the repo url"
    #git clone $repo
    } 
    #to get the folder name from the github repo link, last part of the link is folder name basically 
    $folder_name = $repo.Split('/.')[-2]
    #cd $folder_name
    $svn_path = Read-Host -Prompt "Enter the path where the svn server repo is stored"

    if (Test-Path -Path "$svn_path" -PathType Container) 
    {
        #copy all the files in trunk into local git repo
    Copy-Item $svn_path\trunk\* -Destination $path\$folder_name -Recurse
    }
    else 
    {
        Write-Host "Please enter a valid path"
        exit
    }
    cd $path\$folder_name
    git status
    #add and commit the changes to local repo, also push it to remote repo
    git add .
    $msg = Read-Host -Prompt "Enter the commit message"
    git commit -m "$msg"
    git push

    #gets list of all the branches
    $folders = Get-ChildItem -Path $svn_path\branches
    #iterates through each branch
   foreach ($branch in $folders)
    {
    
    #Write-Output $_
    #create branch name with old branch name and checkout
    git checkout -b $branch
    #temove all the files in local repo
    Remove-Item $path\$folder_name\* -Recurse
    #replace them with branch files
    Copy-Item $svn_path\branches\$branch\* -Destination $path\$folder_name -Recurse
    cd $path\$folder_name
    git status
    #add commit and push changes
    git add .
    $msg = Read-Host -Prompt "Enter the commit message"
    git commit -m "$msg"
    #push to that particular branch only
    git push origin $branch
   }
}
#Entry point for Master
trunk_master
#Entry point for Branches
