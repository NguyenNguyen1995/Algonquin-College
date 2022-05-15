$logFile = "~\Documents\$(Get-Content Env:\COMPUTERNAME) $(Get-Date -Format "MM/dd/yyyy").log"
$currentUser = $env:USERNAME
$programName = "Lab7"

function Write-Log {
    param (
        [Parameter(ValueFromPipeline = $true)]
        $InputObject
    )

    Out-File -FilePath $logFile -Append -NoClobber -InputObject $("$(Get-Date) ${programName}--${currentUser}: $($InputObject | Out-String)" )
}

function Add-User {
    Write-Log "Calling function Add-User"

    while (1) {
        $local:user = Read-Host "Enter user name(To quit press Enter)"

        if (!$local:user) {
            break
        }        
        
        # Skip create user if user exists
        if (Get-LocalUser | Where-Object { $_.Name -eq $local:user }) {
            Write-Host -ForegroundColor Red "User exists"
            continue
        }

        $local:password = Read-Host "Enter user password" -AsSecureString
        $local:group = Read-Host "Add to custom group"
        $local:description = Read-Host "Enter user account description"
        $local:description = "$(Get-Date) $local:description"

        if ($local:group) {
            New-CustomUser -UserName $local:user -Password $local:password -Groups "Users", $local:group -Description $local:description
        }
        else {
            New-CustomUser -UserName $local:user -Password $local:password -Groups "Users" -Description $local:description
        }
    } 
}

function Remove-User {
    Write-Log "Calling function Remove-User"
    Write-Host "Users"
    
    while (1) {
        Get-LocalUser | Select-Object -Property Name | Format-Table
        
        $local:user = Read-Host "Enter user name(To quit press enter)"

        if (!$local:user) {
            break
        }

        # Remove user from local users
        if (!(Get-LocalUser | Where-Object { $_.Name -eq $local:user })) {
            Write-Host -ForegroundColor Red "User does not exist"
            continue
        }
        
        # Not in built-in and current user
        if ($local:user -in "Administrator", "DefaultAccount", "Guest", "WDAGUtilityAccount", $env:USERNAME) {
            Write-Host -ForegroundColor Red "Can not delete $local:user"
            continue
        }

        Remove-LocalUser -Name $local:user -ErrorVariable local:err -ErrorAction SilentlyContinue

        if ($local:err) {      
            Write-Log $local:err
            Write-Host -ForegroundColor Red "Can not delete $local:user"
            continue
        }
        
        Write-Host -ForegroundColor Green "Remove $local:user"
        
        # Check if user folder exists
        $local:userFolder = "C:\Users\$local:user"
        if (!(Get-Item -Path $local:userFolder -ErrorAction SilentlyContinue)) {
            Write-Host -ForegroundColor Yellow "$local:user's folder not found"
            continue
        }
        
        # if meet path access denied take ownership of that to admin group
        while ((Get-Item -Path $local:userFolder -ErrorAction SilentlyContinue)) {
            try {
                Remove-Item -Recurse "$local:userFolder" -Force -ErrorAction Stop
            }
            catch [System.UnauthorizedAccessException] {
                $local:a = $($_ | Out-String).IndexOf("'")
                $local:b = $($_ | Out-String).IndexOf("'", $local:a + 1)
                $local:pathDenied = $($_ | Out-String).SubString($local:a + 1, $local:b - $local:a - 1)
                Write-Log "Take ownership of $local:pathDenied to Admin group"
                takeown /f "$local:pathDenied" /a /r /d Y | Out-Null
            }
        }

        if (Get-Item -Path $local:userFolder -ErrorAction SilentlyContinue) {
            Write-Log "Failed to remove $local:user's folder"
            Write-Host -ForegroundColor Red "Failed to remove $local:user's folder"
        }
        else {
            Write-Log "Remove $local:user's folder"
            Write-Host -ForegroundColor Green "Remove $local:user's folder"
        }
    }
}

function New-100-Users {
    Write-Log "Calling function New-100-Users"

    for ($i = 0; $i -lt 100; $i++) {
        $local:user = "User$("{0:00}" -f $i)"

        if (Get-LocalUser | Where-Object { $_.Name -eq $local:user } ) {
            Write-Log "User $local:user exists"
            Write-Warning "User exists"
        }
        else {
            New-CustomUser -UserName $local:user -DefaultPass "123456" -Groups "Users" -MustChangePasswordNextLogon
        }
    }
}

function New-Users-From-File {
    Write-Log "Calling function New-Users-From-File"

    Add-Type -AssemblyName System.Windows.Forms

    $local:fileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 
        InitialDirectory = [Environment]::GetFolderPath('Desktop') 
        Filter           = 'CSV File (*.csv)|*.csv' 
    }

    $null = $fileBrowser.ShowDialog()
    if (!$local:fileBrowser) {
        return
    }

    $local:csvFileName = $local:fileBrowser.FileName
    Write-Log "CSV File: $local:csvFileName"

    Import-Csv $local:csvFileName | ForEach-Object {
        New-CustomUser -UserName $($_.Uname) -DefaultPass "123456" -Groups "Users", $($_.Group), $($_.Group2) -FullName "$($_.First) $($_.Last)" -MustChangePasswordNextLogon
    }
}

function New-CustomUser {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $UserName,
        [securestring]
        $Password,
        [string]
        $DefaultPassword,
        [string[]]
        $Groups,
        [string]
        $FullName = "",
        [string]
        $Description = "",
        [Parameter(Mandatory = $false)]
        [switch]
        $MustChangePasswordNextLogon = $false
    )

    # create new user
    if ($DefaultPassword -and $MustChangePasswordNextLogon) {
        New-LocalUser -Name $UserName -Password $(ConvertTo-SecureString $DefaultPassword -AsPlainText -Force) -FullName $FullName -Description $Description -AccountNeverExpires -ErrorAction SilentlyContinue -ErrorVariable local:err | Out-Null

        $local:WinNT_User = [adsi]"WinNT://localhost/$UserName"
        $local:WinNT_User.PasswordExpired = 1
        $local:WinNT_User.SetInfo()    

        Write-Log "Create user $UserName with default password $DefaultPassword"
        Write-Host -ForegroundColor Green "Create user $UserName with default password $DefaultPassword. Must change for next logon"
    }
    elseif ($Password) {
        New-LocalUser -Name $UserName -Password $Password -FullName $FullName -Description $Description -AccountNeverExpires -PasswordNeverExpires -ErrorAction SilentlyContinue -ErrorVariable local:err | Out-Null
        Write-Log "Create user $UserName"
        Write-Host -ForegroundColor Green "Create user $UserName successfully"
    }
    else {
        Write-Host -ForegroundColor Red "Failed to create user."
        Write-Host -ForegroundColor Red "Create account need password or default password with next logon option"
        return
    }

    if ($local:err) {
        Write-Log $local:err
        Write-Host -ForegroundColor Red "Failed to create account $UserName"
        return
    }

    # add user to group
    foreach ($group in $Groups) {

        if (Get-LocalGroup | Where-Object { $_.Name -eq $group }) {
            Write-Log "Group $group exists"
            Write-Host -ForegroundColor Yellow "Group $group exists"
        }
        else {
            New-LocalGroup $group | Out-Null
            Write-Log "Create group $group"
            Write-Host -ForegroundColor Green "Create group $group"
        }
        
        Add-LocalGroupMember -Group $group -Member $UserName -ErrorVariable local:err -ErrorAction SilentlyContinue | Out-Null

        if ($local:err) {
            Write-Log $local:err
            Write-Host -ForegroundColor Red "Failed to add user to group $group"
        }
        else {
            Write-Log "Add user $UserName to group $group"
            Write-Host -ForegroundColor Green "Add user to group $group"
        }
    }
}

function New-Banner {
    Write-Host "------------------------------------------------------"
    Write-Host "| 1. Create a new user                               |"
    Write-Host "| 2. Remove a user                                   |"
    Write-Host "| 3. Create 100 Users                                |"
    Write-Host "| 4. Create Users from File                          |"
    Write-Host "| 5. Exit                                            |"
    Write-Host "------------------------------------------------------"    
}

function New-Main {    
    # requires run as administrator
    if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
                [Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Warning "Require admininistrator mode to execute script"
        return
    }

    Write-Log "Start program"

    Clear-Host

    # main menu and option from user
    $local:option = "0"

    while ($local:option.Trim() -ne "5") {
        New-Banner

        $local:option = Read-Host "Enter option(1-5)"

        Write-Log "Menu option $local:option"
    
        switch ($local:option.Trim()) {
            "1" { Add-User }
            "2" { Remove-User }
            "3" { New-100-Users }
            "4" { New-Users-From-File }
            "5" { continue }
            Default { Write-Warning "Unknown Option. Please try again!" }
        }
    }

    Write-Log "Exit program"

    Write-Host -ForegroundColor Green "Good bye"
}

New-Main