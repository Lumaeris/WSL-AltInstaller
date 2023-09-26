# [WIP] WSL-AltInstaller

This script installs WSL 2 and Ubuntu to the system after system "amelioration" ([AME10](https://docs.ameliorated.io/playbooks/ame10.html)/[AME11](https://docs.ameliorated.io/playbooks/ame11.html)) (or if `wsl --install` does not work for some reason).

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
irm lumaeris.com/wsl | iex
```

## Known issues
- "The service has not been started" appeared during testing for no reason. The error may be due to changes applied by [Hardentools](https://github.com/securitywithoutborders/hardentools).
- **Very** limited functionality.
