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
#include <math.h>

#define PI 3.14159265358979323846

void drawCircle(float cx, float cy, float r)
{
    glBegin(GL_TRIANGLE_FAN);
    glVertex2f(cx, cy);

    for (int i = 0; i <= 100; i++)
    {
        float angle = 2.0f * PI * i / 100.0f;
        glVertex2f(cx + cos(angle) * r, cy + sin(angle) * r);
    }

    glEnd();
}

void display()
{
    glClear(GL_COLOR_BUFFER_BIT);

    // Sky
    glColor3f(0.53f, 0.81f, 0.98f);
    glBegin(GL_QUADS);
        glVertex2f(0, 300);
        glVertex2f(600, 300);
        glVertex2f(600, 600);
        glVertex2f(0, 600);
    glEnd();

    // Grass
    glColor3f(0.2f, 0.7f, 0.2f);
    glBegin(GL_QUADS);
        glVertex2f(0, 0);
        glVertex2f(600, 0);
        glVertex2f(600, 300);
        glVertex2f(0, 300);
    glEnd();

    // Sun
    glColor3f(1.0f, 0.9f, 0.0f);
    drawCircle(500, 500, 45);

    // House body
    glColor3f(0.9f, 0.75f, 0.55f);
    glBegin(GL_QUADS);
        glVertex2f(180, 180);
        glVertex2f(420, 180);
        glVertex2f(420, 360);
        glVertex2f(180, 360);
    glEnd();

    // Roof
    glColor3f(0.8f, 0.1f, 0.1f);
    glBegin(GL_TRIANGLES);
        glVertex2f(150, 360);
        glVertex2f(450, 360);
        glVertex2f(300, 480);
    glEnd();

    // Door
    glColor3f(0.4f, 0.2f, 0.0f);
    glBegin(GL_QUADS);
        glVertex2f(270, 180);
        glVertex2f(330, 180);
        glVertex2f(330, 290);
        glVertex2f(270, 290);
    glEnd();

    // Door knob
    glColor3f(1.0f, 1.0f, 0.0f);
    drawCircle(320, 235, 4);

    // Left window
    glColor3f(0.5f, 0.8f, 1.0f);
    glBegin(GL_QUADS);
        glVertex2f(205, 245);
        glVertex2f(255, 245);
        glVertex2f(255, 295);
        glVertex2f(205, 295);
    glEnd();

    // Right window
    glBegin(GL_QUADS);
        glVertex2f(345, 245);
        glVertex2f(395, 245);
        glVertex2f(395, 295);
        glVertex2f(345, 295);
    glEnd();

    // Window lines
    glColor3f(0.0f, 0.0f, 0.0f);

    glBegin(GL_LINES);

        // Left window
        glVertex2f(230,245); glVertex2f(230,295);
        glVertex2f(205,270); glVertex2f(255,270);

        // Right window
        glVertex2f(370,245); glVertex2f(370,295);
        glVertex2f(345,270); glVertex2f(395,270);

    glEnd();

    glFlush();
}

void init()
{
    glClearColor(1, 1, 1, 1);

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluOrtho2D(0, 600, 0, 600);
}

int main(int argc, char **argv)
{
    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_SINGLE | GLUT_RGB);
    glutInitWindowSize(600, 600);
    glutInitWindowPosition(200, 100);
    glutCreateWindow("2D House - OpenGL");

    init();

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
