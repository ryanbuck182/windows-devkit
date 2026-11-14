# Hello!

This is my Windows dev kit.
It contains various scripts, command aliases, configs, etc. for when I'm developing on Windows.
Feel free to take a look.

## Installing

The devkit installs to `~/.devkit` for the current user, so it doesn't need admin.
It adds the git settings and aliases, the PowerShell commands and prompt, and puts the commands on PATH so they work in cmd too.

**From a clone:** run `setup.bat`. It builds the installer and runs it.

**Without cloning:** open [`dist/devkit-install.ps1`](dist/devkit-install.ps1) on GitHub, click "Copy raw file", and paste it into PowerShell.
If Windows Terminal warns about pasting multiple lines, paste anyway.

If git doesn't have your name and email yet, the installer asks for them.
In a clone, you can put them in `config.psd1` instead (see `config.psd1.template`).

To update, run `setup.bat` again (or `devkit-rebuild`), or paste the latest installer.

## Making changes

Edit the files in `src/`. `build.ps1` bundles them into `dist/devkit-install.ps1`, which is committed so it can be copied from GitHub.
`setup.bat` rebuilds it, and a GitHub Action fails if the committed version is out of date.
