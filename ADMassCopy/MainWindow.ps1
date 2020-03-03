# Add dependencies
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

Function Find-Computer {

    Param($NameStart)

    [System.Collections.ArrayList]$ComputerArray = (Get-ADComputer -Filter "Name -like '$NameStart*'" -Properties DNSHostName | Select-Object DNSHostName).DNSHostName
    $ToNatural = { [regex]::Replace($_, '\d+', { $args[0].Value.PadLeft(20) }) }
    $ComputerArray = $ComputerArray | Sort-Object $ToNatural

    return $ComputerArray
    
}

Function Show-Data {

    Param($DataObject, $DataItems, $DataStatus)
    for ($i=0; $i -le $DataItems.Length; $i++) {
        $DataObject.AddChild([pscustomobject]@{HostName="$($DataItems[$i])";HostStatus="$($DataStatus[$i])"})
    }
}

#Check whether computer is powered on or not
function Get-Status {
    param ($Computer)

    $Status = Test-Connection -BufferSize 32 -Count 1 -ComputerName $Computer -Quiet
    
    return $Status
}

function Get-IsChecked {
    param ($CheckStatus)
    
}

# Get the the path of the file to copy
Function Get-FilePath($initialDirectory) {

    $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog
    $FileBrowser.InitialDirectory = "Desktop"
    $FileBrowser.RestoreDirectory = "True" 

    if($FileBrowser.ShowDialog() -eq "OK")
    {
        $FilePath += $FileBrowser.FileName
    }
    return $FilePath
}

# Get the path of folder where file needs to be saved
Function Get-FolderPath($initialDirectory) {

    $FolderPath = New-Object System.Windows.Forms.FolderBrowserDialog
    $FolderPath.Description = "Select a folder"
    $FolderPath.rootfolder = "MyComputer"

    if($FolderPath.ShowDialog() -eq "OK")
    {
        $folder += $FolderPath.SelectedPath
    }
    return $folder
}

function Copy-File {
    param ($File, $Location)
    
}

# XAML file location
$xamlFile = "MainWindow.xaml"

#create window
$inputXML = Get-Content $xamlFile -Raw
$inputXML = $inputXML -replace 'mc:Ignorable="d"', '' -replace "x:N", 'N' -replace '^<Win.*', '<Window'
[XML]$XAML = $inputXML

#Read XAML
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
try {
    $window = [Windows.Markup.XamlReader]::Load( $reader )
} catch {
    Write-Warning $_.Exception
    throw
}

# Create variables based on form control names.
# Variable will be named as 'var_<control name>'
$xaml.SelectNodes("//*[@Name]") | ForEach-Object {
    #"trying item $($_.Name)"
    try {
        Set-Variable -Name "var_$($_.Name)" -Value $window.FindName($_.Name) -ErrorAction Stop
    } catch {
        throw
    }
}
Get-Variable var_*

# Click find to start searching for computers
$var_FindBtn.Add_Click( {
   $SearchTxt = $var_SearchTxt.Text
   $data = Find-Computer -NameStart $SearchTxt
   $status = Get-Status -Computer $data
   Show-Data -DataObject $var_DataG1 -DataItems $data -DataStatus $status
})
# Click add to add more computers to the list 
# of computers being displayed
$var_AddBtn.Add_Click( {
    
})
# Click remove to remove computers from the list 
# of computers being displayed
$var_RemoveBtn.Add_Click( {
    
})
# Click browse to get the file that needs to be copied and display the path in a textbox
$var_BrowseBtn.Add_Click( {
    $FilePath = Get-FilePath
    $var_BrowseTxt.Text = $FilePath
})
# Click location to set the location that the file needs to be copied to and display the path in a textbox
$var_LocationBtn.Add_Click( {
    $FolderPath = Get-FolderPath
    $var_LocationTxt.Text = $FolderPath
})
# Click send to start copying the file to the location
$var_SendBtn.Add_Click( {
    Copy-File -File $var_BrowseTxt.Text -Location $var_LocationTxt.Text
})
#  Press the enter key to perform operation
$var_SearchTxt.Add_KeyDown({
    if ($_.KeyCode -eq "Enter") {
        #logic
        $var_FindBtn.PerformClick()
    }
})

$Null = $window.ShowDialog()