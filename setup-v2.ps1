# ============================================
# Code::Blocks + FreeGLUT Setup Script (Updated)
# ============================================

# Check for Administrator privileges
$currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())

if (-not $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Please run this script as Administrator."
    Pause
    exit
}

# Go to the Downloads folder
Set-Location "$env:USERPROFILE\Downloads"

# Download freeglut.zip
$url = "https://raw.githubusercontent.com/xjarifx/codeblocks-opengl-windows-setup-script/main/freeglut.zip"
$output = "freeglut.zip"

if (Test-Path $output) {
    Remove-Item $output -Force
}

Invoke-WebRequest -Uri $url -OutFile $output
Write-Host "Downloaded freeglut.zip"

# Remove previous extraction if it exists
if (Test-Path ".\freeglut") {
    Remove-Item ".\freeglut" -Recurse -Force
}

# Extract the archive
Expand-Archive -Path $output -DestinationPath ".\freeglut"
Write-Host "Extraction complete!"

# ============================================
# Copy freeglut.dll to System folders
# ============================================
$sourceDll64 = "$env:USERPROFILE\Downloads\freeglut\freeglut\bin\x64\freeglut.dll"
$sourceDll32 = "$env:USERPROFILE\Downloads\freeglut\freeglut\bin\freeglut.dll"

# Install 64-bit DLL
$destinationDll64 = "C:\Windows\System32\freeglut.dll"
if (Test-Path $destinationDll64) { Remove-Item $destinationDll64 -Force }
Copy-Item $sourceDll64 $destinationDll64

# Install 32-bit DLL (just in case Code::Blocks uses a 32-bit toolchain)
$destinationDll32 = "C:\Windows\SysWOW64\freeglut.dll"
if (Test-Path "C:\Windows\SysWOW64") {
    if (Test-Path $destinationDll32) { Remove-Item $destinationDll32 -Force }
    Copy-Item $sourceDll32 $destinationDll32
}
Write-Host "freeglut.dll installed globally."

# ============================================
# Setup Sample Project Directories
# ============================================
$projectDir = Join-Path $env:USERPROFILE "Downloads\qwerty"

if (Test-Path $projectDir) {
    Remove-Item $projectDir -Recurse -Force
}
New-Item -ItemType Directory -Path $projectDir | Out-Null

# Create local GL folder inside the project directory
$localGL = Join-Path $projectDir "GL"
New-Item -ItemType Directory -Path $localGL | Out-Null

# ============================================
# Copy GL Headers & Libs LOCALLY to the project
# ============================================
$sourceGL = "$env:USERPROFILE\Downloads\freeglut\freeglut\include\GL"
Copy-Item "$sourceGL\*" $localGL -Recurse
Write-Host "GL headers copied directly to project folder."

# Copy both 32-bit and 64-bit library files locally to prevent mismatch errors
Copy-Item "$env:USERPROFILE\Downloads\freeglut\freeglut\lib\x64\libfreeglut.a" "$projectDir\libfreeglut.a"
Copy-Item "$env:USERPROFILE\Downloads\freeglut\freeglut\lib\libfreeglut.a" "$projectDir\libfreeglut_32.a"
Write-Host "Library static files copied directly to project folder."

# ============================================
# Create Sample Project Configuration (.cbp)
# ============================================
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
   <Add directory="."
/>
  </Compiler>
  <Linker>
   <Add directory="." />
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

# ============================================
# Create Source File (Untitled1.c)
# ============================================
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
        glVertex2f(230,245); glVertex2f(230,295);
        glVertex2f(205,270); glVertex2f(255,270);

        glVertex2f(370,245); glVertex2f(370,295);
        glVertex2f(345,270); glVertex2f(395,270);
    glEnd();

    glFlush();
}

void init()
{
    glClearColor(1,1,1,1);

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluOrtho2D(0,600,0,600);
}

int main(int argc,char **argv)
{
    glutInit(&argc,argv);
    glutInitDisplayMode(GLUT_SINGLE | GLUT_RGB);
    glutInitWindowSize(600,600);
    glutInitWindowPosition(200,100);
    glutCreateWindow("2D House - OpenGL");

    init();

    glutDisplayFunc(display);
    glutMainLoop();

    return 0;
}
'@ | Set-Content "$projectDir\Untitled1.c"

Write-Host "Sample project created successfully."
Write-Host ""
Write-Host "========================================"
Write-Host "OpenGL Setup complete!"
Write-Host "Open project at: $projectDir\qwerty.cbp"
Write-Host "========================================"