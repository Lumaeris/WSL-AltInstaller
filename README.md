# [WIP] WSL-AltInstaller

This script installs WSL 2 and Ubuntu to the system after system ["amelioration"](https://ameliorated.io) (or if "wsl --install" does not work for some reason).

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
irm github.com/Lumaeris/WSL-AltInstaller/raw/main/install.ps1 | iex
```

## Known issues
- aria2 downloads with a maximum of 5 threads, even if I set it to 16.
- "The service has not been started" appeared during testing for no reason. I was installing WSL and Ubuntu in about the same way the script does. I need to perform some testing...
- **Very** limited functionality.
