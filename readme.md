# Code::Blocks + OpenGL (freeglut) Setup Script

A PowerShell script that sets up a ready-to-build OpenGL project on 64-bit
Windows with **Code::Blocks + MinGW**. It downloads freeglut from the web,
installs it system-wide, and creates a Code::Blocks project in your OneDrive
Documents folder.

## Requirements

- **64-bit Windows** with Code::Blocks installed **with the MinGW toolchain**
  (`codeblocks-*-mingw-setup.exe` from https://www.codeblocks.org/downloads/binaries/)
- **Run PowerShell as Administrator** (the script writes to `C:\Windows\System32`)
- Internet access (to download `freeglut.zip` on first run)

## Usage

1. Open **PowerShell as Administrator**.
2. If scripts are blocked, run: `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass`
3. Paste the contents of `setup.txt` and press Enter.

The script will:
1. Download `freeglut.zip` into your **OneDrive Downloads** folder (kept, not deleted).
2. Copy `freeglut.dll` → `C:\Windows\System32`, headers → MinGW `include\GL`, lib → MinGW `lib`.
3. Create `Documents\OpenGLUniversalProject` with `OpenGLUniversalProject.cbp` and `main.c`.

## Build and run

Open Code::Blocks → `File` → `Open` →
`Documents\OpenGLUniversalProject\OpenGLUniversalProject.cbp` → press **F9**.

## What the script does (manual equivalent)

| Step | Action |
| --- | --- |
| 1 | Copy `freeglut\bin\x64\freeglut.dll` → `C:\Windows\System32` |
| 2 | Copy `freeglut\include\GL` → `CodeBlocks\MinGW\include\GL` |
| 3 | Copy `freeglut\lib\x64` → `CodeBlocks\MinGW\lib` |
| 4 | In Code::Blocks: Project → Build options → Linker settings → add `opengl32`, `glu32`, `freeglut` |

## Troubleshooting

| Problem | Fix |
| --- | --- |
| MinGW not found | Install the `mingw-setup` bundle, then re-run |
| Cannot copy to System32 | Run PowerShell **as Administrator** |
| Download failed | Check internet access to `web.cs.dal.ca` |
| Link error / missing freeglut | Use **64-bit** Windows and **64-bit** Code::Blocks/MinGW |
