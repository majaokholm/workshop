## Prerequisites for workshop.
Write-host 'Code should be run "line by line", not as one full script.' -ForegroundColor Black -BackgroundColor Yellow
Write-host 'So copy code into ISE or VS Code and use F8 to run code lines, one section at the time.' -ForegroundColor Black -BackgroundColor Yellow
Return

<#
-- below code should be in an ADMIN terminal
-- So open Powershell.exe as ADMINISTRATOR (hint: CTRL+SHIFT+ENTER shortcut will open as admin)
#>

##########################
#region step 1
# Step 1 -  Install choco (a windows package manager)
##########################
## NOTE: Requires ADMIN POWERSHELL!

## COPY BELOW CODE IN ADMIN Powershell Terminal
    Write-Host "Installing Chocolatey - a package manager"
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

#endregion step 1
#_________________________________________________________________________#

## copy below choco lines into new admin Powershell - sort out what you have already installed
choco install -y powershell-core

choco install -y git

choco install -y vscode 

choco install -y azure-cli

# you can also install powershell core if you want
## NOTE: Requires ADMIN POWERSHELL!
# - OPTIONAL!

# if you want azure powershell module: installed:
## copy below 
Install-PackageProvider -Name "NuGet" -MinimumVersion 2.8.5.201 -Force | Out-Null
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted | Out-null
Install-Module -Name "Az" -Scope AllUsers

#endregion step 2
#_________________________________________________________________________#




##########################
#region step 3
##########################
<# Step 3
-- OPTIONAL
-- if you want you can install a bunch of VS Code extensions for Azure
-- below cmds should be run inside a Windows Powershell Terminal
   (NOT as ADMIN)
#>

code --install-extension ms-vscode.vscode-node-azure-pack
code --install-extension ms-vscode.powershell
code --install-extension msazurermtools.azurerm-vscode-tools

code --install-extension ms-azure-devops.azure-pipelines
code --install-extension ms-azuretools.vscode-azureappservice     
code --install-extension ms-azuretools.vscode-azurefunctions      
code --install-extension ms-azuretools.vscode-azureresourcegroups 
code --install-extension ms-azuretools.vscode-azurestorage        
code --install-extension ms-azuretools.vscode-azurevirtualmachines
code --install-extension ms-azuretools.vscode-bicep
code --install-extension ms-azuretools.vscode-cosmosdb
code --install-extension ms-azuretools.vscode-docker
code --install-extension ms-dotnettools.vscode-dotnet-runtime
code --install-extension ms-vscode.azure-account
code --install-extension ms-vscode.azurecli

#endregion step 4
#_________________________________________________________________________#