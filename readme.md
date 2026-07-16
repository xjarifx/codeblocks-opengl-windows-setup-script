# Code::Blocks + OpenGL (freeglut) Windows Setup Script

A PowerShell bootstrap script that automatically sets up a ready-to-build
OpenGL project using **Code::Blocks** (with the bundled **MinGW** toolchain)
on 64-bit Windows. It downloads freeglut from this repository, wires up the
include/library paths, generates a `.cbp` project, and copies the runtime DLL
so the project runs without administrator rights.

---

## System Assumptions

The script is designed for the following environment. Outside these
assumptions it may fail:

| Assumption | Detail |
| --- | --- |
| **OS** | Windows 10 / 11 (PowerShell 5.1+, ships with Windows) |
| **Architecture** | **64-bit (x64) only** — links `lib/x64` and copies `bin/x64/freeglut.dll` |
| **Code::Blocks** | Installed **with the bundled MinGW/GCC toolchain** (not the "no compiler" build) |
| **Compiler** | MinGW `gcc` available on `PATH` or under `CodeBlocks\MinGW\bin` |
| **Desktop / Documents** | Resolved via the Shell KnownFolder API, so **OneDrive-redirected** and **localized** (non-English) folder names both work. Falls back to `%USERPROFILE%\Desktop` and `%USERPROFILE%\Documents` if the API fails |
| **Permissions** | No administrator rights required; everything is written under the user profile |
| **Internet** | Required on first run to fetch `freeglut.zip` from GitHub |
| **PowerShell policy** | If blocked, the script instructs how to re-run with `Bypass` (see Using Guide) |

> **Note:** The script is intentionally x64-only. If you install a 32-bit
> Code::Blocks/MinGW, linking against the x64 freeglut will fail.

---

## Prerequisites

Install these **before** running the script:

1. **Code::Blocks with MinGW**
   - Download the **`codeblocks-<ver>-mingw-setup.exe`** bundle (it includes the GCC compiler):
     https://www.codeblocks.org/downloads/binaries/
   - During install, keep the default "MinGW" component selected.
   - Verify: open a terminal and run `gcc --version`. You should see a GCC version string.

2. **PowerShell**
   - Already present on Windows 10/11. No extra install needed.

3. **Internet connection**
   - Needed once, to download `freeglut.zip` from this repo.

The script **aborts with a clear message** if Code::Blocks or `gcc` is missing,
so you do not hit a confusing failure later.

---

## Using Guide

### Option A — Paste into PowerShell (simplest)

1. Open **PowerShell**: press `Win`, type `powershell`, press Enter.
2. If PowerShell refuses to run scripts (execution policy), first run:

   ```powershell
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
   ```

3. Copy the entire contents of **`setup.txt`** and paste it into the
   PowerShell window, then press Enter.

The script runs the verification, downloads freeglut to your Desktop, and
creates the project under your Documents folder.

### Option B — Save and run as a file

1. Save the script as `setup.ps1` (e.g. on your Desktop).
2. Right-click the file → **Run with PowerShell**, or from a PowerShell prompt:

   ```powershell
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
   .\setup.ps1
   ```

### What happens

1. **Verification** — checks Code::Blocks and MinGW `gcc` are present.
2. **Path resolution** — finds your Desktop/Documents (OneDrive-aware).
3. **freeglut setup** — downloads and extracts `freeglut` to your Desktop
   (skipped if it already exists).
4. **Project generation** — creates `Documents\OpenGLUniversalProject`
   containing:
   - `OpenGLUniversalProject.cbp` — the Code::Blocks project
   - `main.c` — a triangle-drawing boilerplate
   - `freeglut.dll` — copied locally so the build runs without admin rights

### Build and run

1. Open **Code::Blocks**.
2. `File` → `Open` → select
   `Documents\OpenGLUniversalProject\OpenGLUniversalProject.cbp`.
3. `Build` → `Build and run` (or press `F9`).
4. A 500×500 window with a colored triangle should appear.

> **Prefer the manual route?** The [Manual Setup](#manual-setup) section below
> explains each step the script performs, in case you want to set it up by hand
> or troubleshoot a specific piece.

---

## Manual Setup

If you would rather configure Code::Blocks yourself (or the script does not fit
your setup), perform these steps. Assume `freeglut` lives on your Desktop
(`%USERPROFILE%\Desktop\freeglut`).

**Step 01 — Runtime DLL**
Copy `freeglut\bin\x64\freeglut.dll` → `C:\Windows\System32`
*(The script instead copies it next to the executable, avoiding admin rights.)*

**Step 02 — Header**
Copy `freeglut\include\GL` → `C:\Program Files\CodeBlocks\MinGW\include\GL`
*(create the `GL` folder inside `include` if missing).*

**Step 03 — Library**
Copy `freeglut\lib\x64\libfreeglut.a` (or `freeglut.lib`) →
`C:\Program Files\CodeBlocks\MinGW\lib`

**Step 04 — Project link settings**
1. Create a new **Empty project** in Code::Blocks and add a `.c` source file.
2. From the top menu, choose **Project** → **Build options...**
3. Make sure the **project name** (not "Debug" or "Release") is selected.
4. Go to **Linker settings** → **Link libraries**.
5. Add `opengl32`, `glu32`, and `freeglut` one by one.

---

## Repository Layout

```
freeglut/        Extracted freeglut binaries (committed for reference)
freeglut.zip     Archive the script downloads (root contains freeglut/...)
setup.txt        The PowerShell script (paste into PowerShell)
readme.md        This file
```

## Troubleshooting

| Symptom | Fix |
| --- | --- |
| `[-] Code::Blocks not found` | Install Code::Blocks **with MinGW** from codeblocks.org, then re-run |
| `[-] MinGW gcc compiler not found` | Ensure the MinGW component was installed; `gcc --version` should work in a terminal |
| `[-] ... Failed to download dependencies` | Check internet access; the zip is served from this GitHub repo's `main` branch |
| Script blocked by policy | Run `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass` first |
| Link error / missing `freeglut` | Confirm you are on **64-bit** Windows and using the **64-bit** Code::Blocks/MinGW |
