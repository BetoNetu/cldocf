<img src=logo.png height=120px> <br>
# Clean Document Files
#### A Shell (bash) Script that uses native zip and unzip UNIX commands to edit ODT's and DOCX's metadata

**Cl**ear **Doc**ument **f**iles (aka **cldocf**) is a (stupidly) symple Shell (bash) Script that uses native zip and unzip UNIX commands to edit ODT's and DOCX's metadata by replacing the content of some XML files and repacking the docs. It is meant for  simple use: like sending a "fully anonimized" copy of a file to a Journal that asks for clean metadata. It also has a "native" port for Windows devices with a compiled exe and/or

Developed by: [_betor_](https://github.com/BetoNetu) <br>
License: [GNU/AGPL-V3](https://www.gnu.org/licenses/agpl-3.0.en.html)

---

## Instalation

### Linux
0. **Requirements**

    - **Git**;  
    - **Bash** or a Bash compatible shell;
    - **Zip** and **Unzip**

1. Clone the repository
    ```bash
    git clone https://github.com/BetoNetu/cldocf
    ```

2. Execute `cldocf/install.sh`

    ```bash
    cd cldocf #go into created dir
    chmod +x install.sh
    ./install.sh
    ```

### Windows (WIP)

0. **Requirements**

    - **Windows 10 or 11** (the script uses built‑in `Expand-Archive` and `Compress-Archive`).  
    - No additional software, drivers, or UNIX tools are needed – everything is native to Windows.

1. **Download the repository**  
   Click the green **"Code"** button on GitHub and select **"Download ZIP"**.  
   *(Or use [this direct link](https://github.com/BetoNetu/cldocf/archive/refs/heads/main.zip).)*

2. **Extract the ZIP folder**  
   Right‑click the downloaded `cldocf-main.zip` file and choose **"Extract All..."**.  
   Select a permanent location, for example:  
   `C:\cldocf` or `Documents\cldocf`.  
   *(Do not extract to a temporary folder – you'll want to keep these files.)*

3. **Choose your preferred method**

   - **Option A – Using the `.bat` wrapper (no installation required)**  
     - Open the extracted folder and double‑click `cldocf.bat`.  
     - The script will show a banner and prompt you to enter or drag a file path.  
     - You can also **drag and drop** any `.docx` or `.odt` file directly onto `cldocf.bat` – it will process the file immediately and create a `_clean` version next to the original.

   - **Option B – Using the compiled `.exe` (recommended for non‑CLI users)**  
     *(Once you have downloaded the `cldocf.exe` file from the releases page)*  
     - Place `cldocf.exe` anywhere you like (no other files needed).  
     - **Double‑click** the `.exe` to run it interactively.  
     - **Drag and drop** your `.docx` or `.odt` files directly onto the `.exe` – it will process them with verbose output and logging enabled by default.

4. **Create a desktop shortcut (optional but recommended)**  
   - Right‑click on `cldocf.bat` (or `cldocf.exe`) and select **"Create shortcut"**.  
   - Drag the new shortcut to your Windows Desktop for easy access.

5. **Add to PATH (for terminal / advanced users)**  
   If you use the command line and want to run `cldocf` from any folder:

   1. Press `Win + R`, type `sysdm.cpl`, and press Enter.  
   2. Go to the **Advanced** tab → click **Environment Variables**.  
   3. Under **System variables**, find `Path` → click **Edit** → **New**.  
   4. Paste the full path to the extracted folder (e.g., `C:\cldocf`) and click **OK**.  
   5. Now you can open any Command Prompt or PowerShell and type: `cldocf`

**Troubleshooting (Windows)**

| Issue | Solution |
| :--- | :--- |
| *"File cannot be loaded because scripts are disabled"* | The `.bat` file already uses `-ExecutionPolicy Bypass`, so this shouldn't happen. If it does, right‑click the `.bat` and select **"Run as administrator"** once. |
| *Double‑clicking the `.ps1` opens Notepad* | That's normal – **always use `cldocf.bat`** (or the compiled `.exe`), never double‑click the `.ps1` directly. |
| *"Compress-Archive" not recognized* | This only happens on very old Windows versions. Upgrade to PowerShell 5.1+ (Windows 10/11 have it). |
| *The `.exe` doesn't run / antivirus blocks it* | Some antivirus tools may flag compiled PowerShell scripts. Add an exception for `cldocf.exe` or use the `.bat` version instead. |
| *The `.exe` prints too much stuff* | *The exe is* **by defaut** *set to verbose and logging on. If you want otherwise, you can wither recompile the exe by disableing such flags or run `cldocf.exe --verbose:$false --logging:$false file.extension` or `cldocf.exe -v:$false -l:$false file.extension`*. |
---

## Usage (CLI)

```bash
cldocf [options] file.extension
-v, --verbose   #Enable verbose output
-l, --logging   #Enable logging file procedures
-d, --data      #Show the replaced metadata files and new content
-h, --help      #Show this help
```
