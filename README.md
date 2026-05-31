# Analyze.bat

This batch script will allow you to either pass the relative path if you are in the same file path of your sample, or pass the full file path into a command line argument. You can also drag and drop a file on top of the batch script if you have it on your desktop, and it will kick off the instance of running the tools against the file. 

The script will run 4 tools against the file in question:
* Floss
* Detect-It-Easy
* Capa
* pestats.py

Each tool will output a separate json file in the path you are running this batch script. 

## Setup & Requirements

### Prerequisites

This script requires the following tools to be installed and configured before use:

**1. FLOSS**
- Download from [mandiant/flare-floss](https://github.com/mandiant/flare-floss/releases)
- Ensure `floss` is available on your system `PATH` (so it can be called from any directory)

**2. CAPA + CAPA Rules**
- Download `capa.exe` from [mandiant/capa](https://github.com/mandiant/capa/releases)
- Clone the rules repo: `git clone https://github.com/mandiant/capa-rules.git C:\Tools\capa-rules`
- Ensure `capa.exe` is on your `PATH`

**3. Detect It Easy (DIE)**
- Download from [horsicq/Detect-It-Easy](https://github.com/horsicq/Detect-It-Easy/releases)
- Place `diec.exe` at `C:\Tools\die\diec.exe` (or update the path in the script)

**4. PEStats**
- Download `pestats.py` and place it at `C:\Tools\pestats.py` (or update the path in the script)
- Requires Python 3 and `pefile`: `pip install pefile`
- Copy of the python script can be found in this repo: https://github.com/as0ni/pestats
  - Credit to https://github.com/as0ni for this script. 

---

### Configuration

Open the script and update the paths at the top to match your environment:

```bat
set "CAPA_RULES=C:\Tools\capa-rules"
set "DIE_PATH=C:\Tools\die\diec.exe"
set "PESTATS_PATH=C:\Tools\pestats.py"
set "FLOSS_CMD=floss"
```

---

### Usage

**Drag and drop** a file onto the `.bat` script, or run it from the command line:

```
analyze.bat C:\Samples\suspicious.exe
```

If no argument is provided, the script will prompt you to enter a file path.

---

### Output

Four JSON files are written to the **same directory as the analyzed file**:

| File | Tool |
|---|---|
| `<filename>_floss.json` | String extraction |
| `<filename>_capa.json` | Capability detection |
| `<filename>_die.json` | File type / packer detection |
| `<filename>_pestats.json` | PE header statistics |
