# Check for Administrator privileges
$currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())

if (-not $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Please run this script as Administrator."
    Pause
    exit
}

# Go to the Downloads folder
Set-Location "$env:USERPROFILE\Downloads"

# Download the ZIP
$url = "https://raw.githubusercontent.com/xjarifx/codeblocks-opengl-windows-setup-script/main/freeglut.zip"
$output = "freeglut.zip"

if (-not (Test-Path $output)) {
    Invoke-WebRequest -Uri $url -OutFile $output
    Write-Host "Downloaded freeglut.zip"
} else {
    Write-Host "freeglut.zip already exists. Skipping download."
}

# Extract the ZIP
if (-not (Test-Path ".\freeglut\freeglut")) {
    Expand-Archive -Path $output -DestinationPath ".\freeglut"
    Write-Host "Extraction complete!"
} else {
    Write-Host "Archive already extracted. Skipping."
}

# Copy freeglut.dll to System32
$sourceDll = "$env:USERPROFILE\Downloads\freeglut\freeglut\bin\x64\freeglut.dll"
$destinationDll = "C:\Windows\System32"

if (-not (Test-Path "$destinationDll\freeglut.dll")) {
    Copy-Item -Path $sourceDll -Destination $destinationDll
    Write-Host "freeglut.dll copied."
} else {
    Write-Host "freeglut.dll already exists. Skipping."
}

# Copy GL headers
$sourceGL = "$env:USERPROFILE\Downloads\freeglut\freeglut\include\GL"
$destinationGL = "C:\Program Files\CodeBlocks\MinGW\include\GL"

if (-not (Test-Path $destinationGL)) {
    New-Item -ItemType Directory -Path $destinationGL -Force | Out-Null
    Copy-Item "$sourceGL\*" -Destination $destinationGL -Recurse
    Write-Host "GL headers copied."
} else {
    Write-Host "GL headers already installed. Skipping."
}

# Copy libfreeglut.a
$sourceLib = "$env:USERPROFILE\Downloads\freeglut\freeglut\lib\x64\libfreeglut.a"
$destinationLib = "C:\Program Files\CodeBlocks\MinGW\lib"

if (-not (Test-Path "$destinationLib\libfreeglut.a")) {
    Copy-Item -Path $sourceLib -Destination $destinationLib
    Write-Host "libfreeglut.a copied."
} else {
    Write-Host "libfreeglut.a already exists. Skipping."
}

# Create Code::Blocks project
$projectDir = Join-Path $env:USERPROFILE "Downloads\qwerty"

if (-not (Test-Path "$projectDir\qwerty.cbp")) {

    New-Item -ItemType Directory -Path $projectDir -Force | Out-Null

@'
<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>
<CodeBlocks_project_file>
	<FileVersion major="1" minor="6" />
	<Project>
		<Option title="qwerty" />
		<Option pch_mode="2" />
		<Option compiler="gcc" />
		<Build>
			<Target title="Debug">
				<Option output="bin/Debug/qwerty" prefix_auto="1" extension_auto="1" />
				<Option object_output="obj/Debug/" />
				<Option type="1" />
				<Option compiler="gcc" />
				<Compiler>
					<Add option="-g" />
				</Compiler>
			</Target>
			<Target title="Release">
				<Option output="bin/Release/qwerty" prefix_auto="1" extension_auto="1" />
				<Option object_output="obj/Release/" />
				<Option type="1" />
				<Option compiler="gcc" />
				<Compiler>
					<Add option="-O2" />
				</Compiler>
				<Linker>
					<Add option="-s" />
				</Linker>
			</Target>
		</Build>
		<Compiler>
			<Add option="-Wall" />
		</Compiler>
		<Linker>
			<Add library="opengl32" />
			<Add library="glu32" />
			<Add library="freeglut" />
		</Linker>
		<Unit filename="Untitled1.c">
			<Option compilerVar="CC" />
		</Unit>
		<Extensions>
			<lib_finder disable_auto="1" />
		</Extensions>
	</Project>
</CodeBlocks_project_file>
'@ | Set-Content "$projectDir\qwerty.cbp"

@'
#include <GL/glut.h>

void display(void) {
    glClear(GL_COLOR_BUFFER_BIT);
    glFlush();
}

int main(int argc, char** argv) {
    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_SINGLE | GLUT_RGB);
    glutInitWindowSize(400, 400);
    glutCreateWindow("Minimal Window");
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    glutDisplayFunc(display);
    glutMainLoop();
    return 0;
}
'@ | Set-Content "$projectDir\Untitled1.c"

    Write-Host "Code::Blocks project created at: $projectDir"

} else {
    Write-Host "Project already exists. Skipping."
}

Write-Host ""
Write-Host "========================================"
Write-Host "OpenGL setup completed successfully!"
Write-Host "Project location: $projectDir"
Write-Host "========================================"

Pause