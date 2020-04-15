function trunk_master
{
    $repo = Read-Host -Prompt "Enter the repo url"
    $path = Read-Host -Prompt "Enter the path where you want to clone the repo locally"
    cd $path
    #clone into any desired path
    git clone $repo
    #to get the folder name from the github repo link, last part of the link is folder name basically 
    $folder_name = $repo.Split('/.')[-2]
    #cd $folder_name
    $svn_path = Read-Host -Prompt "Enter the path where the svn server repo is stored"
    #copy all the files in trunk into local git repo
    Copy-Item $svn_path\trunk\* -Destination $path\$folder_name -Recurse
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
#Entry point
trunk_master