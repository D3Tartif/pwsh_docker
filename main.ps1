################################################
# Docker manage admin console                  #
# Author: Cedric F                             #
# Creation data: 2/10/2020                     #
# Last change date: 7/10/2020                  #
# Version: 1                                 #
#                                              #
#                                              #
################################################

############
# variables
############
    # main variables
$menu_choice
    # install docker variables
$downloadlink_docker = "https://download.docker.com/win/stable/Docker%20Desktop%20Installer.exe"
$downloadlink_wsl2 = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"

###########
# Functions
###########

function get-container {
    [CmdletBinding()]
    Param ()

    Begin
    {
    }
    Process
    {
        Clear-Host
        $docker_list = docker ps -a --format '{{.Names}}'
        foreach($elements in $docker_list)
        {
            write-host "$($elements) - " -NoNewline
            docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$($elements)"
        }
    }
    End
    {
        write-host "Press enter to continue"
    }
    
}

function new-container {
    [CmdletBinding()]
    Param ()

    Begin
    {
        do
        {
            # display of menu
            Clear-Host
            Write-Host "Add container menu"
            Write-Host ""
            Write-Host "#####################"
            Write-Host ""
            Write-Host "1: CentOs"
            Write-Host "2: Ubuntu"
            Write-Host "3: Alpine"
            Write-Host "4: Debian"
            Write-Host "0: Return Main menu"
            Write-Host ""
            Write-Host "######################"
            Write-Host ""
            Write-Host "Please, choose an option: " -NoNewline
            
            # storage of user entry
            $menu_choice = Read-Host

            switch ($menu_choice) {
                1 { $container_image = "centos" }
                2 { $container_image = "ubuntu" }
                3 { $container_image = "alpine" }
                4 { $container_image = "debian" }
                0 { return }
                Default { 
                    Write-Warning "Bad entry, please retry." 
                }
            }
        } while (($menu_choice -lt 1) -and ($menu_choice -gt 4))
        
        # name of the container
        Clear-Host
        Write-Host "Name of the container : " -NoNewline
        $name_container = Read-Host
    }
    Process
    {
       # launch of container
       docker run -tid --name "$($name_container)" "$($container_image)"
    }
    End
    {
        $container_ip= docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$($name_container)"
        Clear-Host ""
        Write-Host "Container $($name_container) created with a $($container_image) image and with ip adress $($container_ip)"
        Write-Host "press enter to continue"
    }
   
}

function remove-container {
    [CmdletBinding()]
    Param ()

    Begin
    {
        do
        {
            # display of menu
            Clear-Host
            Write-Host "Remove container menu"
            Write-Host ""
            Write-Host "#####################"
            Write-Host ""
            Write-Host "1: All"
            Write-Host "2: One"
            Write-Host "0: Return Main menu"
            Write-Host ""
            Write-Host "######################"
            Write-Host ""
            Write-Host "Please, choose an option: " -NoNewline
            
            # storage of user entry
            $menu_choice = Read-Host

            switch ($menu_choice) {
                1 { Clear-Host }
                2 { 
                    Clear-Host
                    docker ps -a --format '{{.Names}}'
                    Write-Host "Name of the container to delete: " -NoNewline
                    $name_container = Read-Host
                  }
                0 { return }
                Default { 
                    Write-Warning "Bad entry, please retry." 
                }
            }
        } while (($menu_choice -lt 1) -and ($menu_choice -gt 2))
        
        if ( $menu_choice -eq 1)
        {
            $name_container = docker ps -a --format '{{.Names}}'
        }
        elseif ($menuchoice -eq 2) {
            # name of the container
            Clear-Host
            docker ps -a --format '{{.Names}}'
            Write-Host ""
            Write-Host "Name of the container to delete: " -NoNewline
            $name_container = Read-Host  
        } 
       
    }
    Process
    {
       foreach ($elements in $name_container)
       {
           docker rm -f "$($elements)"
       }
       write-host "Delete of containers successful"
       Write-Host "Press enter to continue"
    }
    End
    {
    }
}


function install_docker {
    Clear-Host
    # install of optional windows features needed by docker
    Write-Host "install of hyper-v requirements features"
    Enable-WindowsOptionalFeature -Online -FeatureName ("Microsoft-Hyper-V", "Containers", "VirtualMachinePlatform") -All -NoRestart
    
    # download of wsl 2 and add it to hklm to launch install at next restart
    (New-Object System.Net.WebClient).DownloadFile($downloadlink_wsl2,"$($home)\Downloads\wsl.msi")
    New-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce -Name wsl -PropertyType string -Value "$($home)\Downloads\wsl.msi"

    # download and install of docker
    Write-Host "download and launch of docker desktop then reboot"
    (New-Object System.Net.WebClient).DownloadFile($downloadlink_docker,"$env:APPDATA\installdocker.exe")
    Start-Process ("$env:APPDATA\installdocker.exe")
    
    Write-Host "once docker installed, reboot then wsl install will pop up and once done, reboot again"
    Read-Host
    
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
        1 { new-container }
        2 { remove-container }
        3 { get-container }
        4 { install_docker }
        0 { "Quitting ..." }
        Default { 
            Write-Warning "Bad entry, please retry." 
            pause
        }
    }
    Read-Host

} until ( $menu_choice -eq 0)