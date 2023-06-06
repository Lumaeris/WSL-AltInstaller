# [WIP] WSL-AltInstaller

This script installs WSL 2 and Ubuntu to the system after system ["amelioration"](https://ameliorated.io) (or if `wsl --install` does not work for some reason).

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
irm lum.lol/wsl | iex
```

## Known issues
- "The service has not been started" appeared during testing for no reason. The error may be due to changes applied by [Hardentools](https://github.com/securitywithoutborders/hardentools) or caused by [previous versions](https://github.com/jbara2002/windows-defender-remover/issues/38) of [Windows Defender Remover](https://github.com/jbara2002/windows-defender-remover).
- **Very** limited functionality.
