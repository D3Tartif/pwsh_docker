################################################
# Docker manage admin console                  #
# Author: Cedric F                             #
# Creation data: 2/10/2020                     #
# Last change date: 9/10/2020                  #
# Version: 1                                   #
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
        # get names of all containers
        $docker_list = docker ps -a --format '{{.Names}}'

        # loop of each container
        foreach($elements in $docker_list)
        {
            # get ip of current container
            $ipaddress = docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$($elements)"
            # get status of current container
            $status = docker inspect -f '{{.State.Status}}' "$($elements)"
            # send to host the name, the ip and the status of  the current container
            write-host "$($elements) - $($ipaddress) - $($status)"
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
        # loop to display menu until a valid choice is made
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
       # get ip of container and display it to host
       $container_ip= docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$($name_container)"
       Clear-Host ""
       Write-Host "Container $($name_container) created with a $($container_image) image and with ip adress $($container_ip)"
       Write-Host "press enter to continue"
    }
    End
    {
        
    }
   
}

function remove-container {
    [CmdletBinding()]
    Param ()

    Begin
    {
        # loop to display menu until a valid choice is made
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
                2 { Clear-Host }
                0 { return }
                Default { 
                    # wrong entry of user
                    Write-Warning "Bad entry, please retry." 
                }
            }
        } while (($menu_choice -lt 1) -and ($menu_choice -gt 2))
        
        # depending of the choice made, assign a var the list of the containers to delete
        if ( $menu_choice -eq 1)
        {
            $name_container = docker ps -a --format '{{.Names}}'
        }
        elseif ($menuchoice -eq 2) {
            # name of the container
            Clear-Host
            # list containers
            docker ps -a --format '{{.Names}}'
            # user entry for the container to delete
            Write-Host ""
            Write-Host "Name of the container to delete: " -NoNewline
            $name_container = Read-Host  
        } 
       
    }
    Process
    {
       # remove of the containers in the var $name_container
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

function start-container {
    [CmdletBinding()]
    Param ()

    Begin
    {
        # loop to display menu until a valid choice is made
        do
        {
            # display of menu
            Clear-Host
            Write-Host "Start container menu"
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
                2 { Clear-Host }
                0 { return }
                Default { 
                    # wrong entry of user
                    Write-Warning "Bad entry, please retry." 
                }
            }
        } while (($menu_choice -lt 1) -and ($menu_choice -gt 2))

        Clear-Host
        # get names of all containers stopped
        $docker_list = docker ps -a --format '{{.Names}}'
    }
    Process
    {
        if( $menu_choice -eq 1)
        {
            # loop of each container
            foreach($elements in $docker_list)
            {
                # get status of current container
                $status = docker inspect -f '{{.State.Status}}' "$($elements)"
                if( $status -eq "exited")
                {
                    docker container start "$($elements)"
                    $ipaddress = docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$($elements)"
                    # send to host the name, the ip and the status of  the current container
                    write-host "$($elements) - $($ipaddress)"
                }
            }
        }
        elseif ( $menu_choice -eq 2 ) 
        {
            # loop of each container
            foreach($elements in $docker_list)
            {
                # get status of current container
                $status = docker inspect -f '{{.State.Status}}' "$($elements)"
                if( $status -eq "exited")
                {
                    write-host "$($elements) - $($status)"
                }
            }
            Write-Host ""
            Write-Host "Name of the container to delete: " -NoNewline
            $name_container = Read-Host
            Write-Host "Start of : " -NoNewline
            docker container start "$($name_container)"
            $ipaddress = docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$($name_container)"
            $status = docker inspect -f '{{.State.Status}}' "$($name_container)"
            Write-Host "Status: "
            write-host "$($name_container) - $($ipaddress) - $($status)"

        }
    }
    End
    {
        write-host "Press enter to continue"
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
    Write-Host "4: Start existing container"
    Write-Host "9: Install docker"
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
        4 { start-container }
        9 { install_docker }
        0 { "Quitting ..." }
        Default { 
            Write-Warning "Bad entry, please retry." 
            pause
        }
    }
    Read-Host

} until ( $menu_choice -eq 0)