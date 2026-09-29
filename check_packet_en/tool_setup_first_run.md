# Tool Setup and First Run

Session 1 covers tool installation procedures and running your first simulation. Use the Ubuntu terminal in WSL on Windows, or the Terminal app on macOS. Verifying versions of all four tools and passing the CH01 test confirm readiness.

## 1. Required Tools

| Tool | Purpose | Installation Method |
|---|---|---|
| iverilog | Compiles Verilog modules and testbenches | Install Icarus Verilog |
| vvp | Executes compiled simulation runtime binaries | Included with Icarus Verilog |
| make | Executes per-chapter automated tests via Makefiles | Ubuntu package or macOS developer tools |
| git | Clones tutorial source code repository | OS-specific package manager |
| Code Editor | Edits `.v` and `.sv` files | Configure existing editor to save files as UTF-8 |
| GTKWave | Inspects waveforms visually | Optional; initial exercises use plain-text console logs |

## 2. Windows and Ubuntu

On Windows 11 or Windows 10 (version 2004 or higher), install WSL using the following procedure. For prerequisites and detailed troubleshooting, consult the [Microsoft WSL Installation Guide](https://learn.microsoft.com/en-us/windows/wsl/install).

1. Open PowerShell as Administrator.
2. Run the following command and restart your computer:

```powershell
wsl --install
```

3. Open Ubuntu from the Start menu and set up your Linux username and password.
4. Execute all subsequent commands within the Ubuntu terminal. Native Ubuntu Linux users also begin here:

```bash
sudo apt update
sudo apt install iverilog make git
```

When confirmation prompts appear, inspect the package list and confirm. The sudo password corresponds to your Ubuntu account password. Students with an existing WSL setup proceed directly to the version verification step.

## 3. macOS

1. Open Terminal and verify Homebrew status via `brew --version`.
2. If Homebrew is missing, follow instructions at the [Homebrew Official Website](https://brew.sh/). Install Xcode Command Line Tools, complete the environment post-install steps ("Next steps"), and restart Terminal.
3. Install Icarus Verilog and git:

```bash
brew install icarus-verilog git
```

If running `make --version` fails to invoke the tool, verify your Command Line Tools installation. If needed, trigger Apple developer tools installation manually:

```bash
xcode-select --install
```

For package details, consult the [Homebrew Icarus Verilog Formula](https://formulae.brew.sh/formula/icarus-verilog) and [Homebrew Installation Docs](https://docs.brew.sh/Installation).

## 4. Version Verification Procedure

Execute the following commands sequentially in your terminal. Output displaying valid version strings confirms tools are properly resolved in `PATH`:

```bash
iverilog -V
vvp -V
make --version
git --version
```

The course baseline testing environment uses Icarus Verilog 13.0. Because distribution package versions vary across operating systems, record your environment versions and exact console outputs.

## 5. Cloning Tutorial and Initial Verification

Execute the following commands in a designated working directory. If you already cloned the repository, navigate to `computer-architecture-verilog-tutorial` and execute the test command directly:

```bash
git clone https://github.com/yunju-baek/computer-architecture-verilog-tutorial.git
cd computer-architecture-verilog-tutorial
pwd
ls tutorial/ch01
make -C tutorial/ch01 test
```

`pwd` prints the working directory, and `ls tutorial/ch01` lists Chapter 1 files. `make` executes compilation and simulation in designated sequence. Verify `PASS ch01` in the final output, then verify the shell exit code immediately:

```bash
echo $?
```

Confirm and record both exit code `0` and the `PASS ch01` banner. Next, proceed with [Check 1 Assignment](check1/README.md). For command options and manual compilation examples, consult [Tutorial CH01](https://yunju-baek.github.io/computer-architecture-verilog-tutorial/ch01/).

## 6. Documenting Setup and Execution Issues

| Observed Condition | Items to Check |
|---|---|
| `command not found` | Current shell session, package completion status, `PATH` environment variable |
| `tutorial/ch01` path error | Output of `pwd` and location of `tutorial/` relative to repository root |
| `sudo` password prompt | Linux account password set during Ubuntu initialization |
| WSL installation/reboot in progress | Record current step and system messages; launch Ubuntu upon reboot |
| Compilation error or test `FAIL` | First error message, affected file and line number, exact command line |

Installation durations depend on network bandwidth and system restart timing. If installation remains ongoing during class hours, refer to instructor-provided execution logs to complete observation tasks first, and document your current setup progress and next verification steps in your report.
