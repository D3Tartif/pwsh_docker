################################################
# Docker manage admin console                  #
# Author: Cedric F                             #
# Creation data: 2/1/2020                      #
# Last change date: 2/1/2020                   #
# Version: 0.1                                 #
#                                              #
#                                              #
################################################

# variables
$menu_choice

$downloadlink_docker = "https://download.docker.com/win/stable/Docker%20Desktop%20Installer.exe"
$downloadlink_wsl2 = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"

# Functions

function create_container {
   
}

function delete_container {
   
}

function list_container {

    
}

function install_docker {
    Write-Host "install of hyper-v feature"
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart
    
    Write-Host "download and launch of docker desktop"
    (New-Object System.Net.WebClient).DownloadFile($downloadlink_docker,"$env:APPDATA\installdocker.exe")
    Start-Process ("$env:APPDATA\installdocker.exe")

    Write-Host "install wsl2"
    (New-Object System.Net.WebClient).DownloadFile($downloadlink_wsl2,"$env:APPDATA\installwsl.msi")
    Start-Process ("$env:APPDATA\installwsl.msi")
    
    Write-Host "Please, follow the install wizard and then save all your works as the machine will restart after a keypress!"
    Read-Host
    Restart-Computer
}

# main
do 
{
    # display of menu
    Clear-Host
    Write-Host "Docker's Admin console"
    Write-Host ""
    Write-Host "#####################"
    Write-Host ""
    Write-Host "1: Create containers"
    Write-Host "2: Delete containers"
    Write-Host "3: List containers"
    Write-Host "4: Install docker"
    Write-Host "0: Quit console"
    Write-Host ""
    Write-Host "######################"
    Write-Host ""
    Write-Host "Please, choose an option: " -NoNewline
    
    # storage of user entry
    $menu_choice = Read-Host
    
    # launch a function depending of the user choice
    switch ($menu_choice) {
        1 { create_container }
        2 { delete_container }
        3 { list_container }
        4 { install_docker }
        0 { "Quitting" }
        Default { "Bad entry, please retry." }
    }
    Read-Host

} until ( $menu_choice -eq 0)