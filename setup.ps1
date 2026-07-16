# Go to the Downloads folder
Set-Location "$env:USERPROFILE\Downloads"

# Download the ZIP
$url = "https://web.cs.dal.ca/~sbrooks/csci3161/reference/FreeGLUTSetup/freeglut.zip"
$output = "freeglut.zip"

Invoke-WebRequest -Uri $url -OutFile $output

# Extract it
Expand-Archive -Path $output -DestinationPath ".\freeglut" -Force

Write-Host "Extraction complete!"

# Copy freeglut.dll to System32 (requires Administrator)
$source = "$env:USERPROFILE\Downloads\freeglut\freeglut\bin\x64\freeglut.dll"
$destination = "C:\Windows\System32"

Copy-Item -Path $source -Destination $destination -Force

Write-Host "freeglut.dll copied to C:\Windows\System32"

# Copy glut.h and other GL headers
$sourceGL = "$env:USERPROFILE\Downloads\freeglut\freeglut\include\GL"
$destinationGL = "C:\Program Files\CodeBlocks\MinGW\include\GL"

# Create the destination folder if it doesn't exist
New-Item -ItemType Directory -Path $destinationGL -Force | Out-Null

# Copy all header files
Copy-Item "$sourceGL\*" -Destination $destinationGL -Recurse -Force

Write-Host "GL headers copied to $destinationGL"