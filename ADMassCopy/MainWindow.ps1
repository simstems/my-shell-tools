# Add dependencies
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

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

# Button Settings Below

$var_BrowseBtn.Add_Click( {
    $FilePath = Get-FilePath
    $var_BrowseTxt.Text = $FilePath
})

$var_LocationBtn.Add_Click( {
    $FolderPath = Get-FolderPath
    $var_LocationTxt.Text = $FolderPath
})

# Textbox Settings Below

$Null = $window.ShowDialog()