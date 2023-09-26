## v0.0.2-alpha - 2023-09-26

Added an interactive menu and a small description before installation.

### Key changes
- aria2 is no longer downloaded if there is an already installed copy on the system.
- Added option to install old version of WSL 2 (currently not working).
- An interactive menu has been added.
- The script has been revised.

### Known issues
- "The service has not been started" appeared during testing for no reason. The error may be due to changes applied by [Hardentools](https://github.com/securitywithoutborders/hardentools).
- **Very** limited functionality.

## v0.0.1-alpha - 2023-04-29

Initial release.

### Known issues
- aria2 downloads with a maximum of 5 threads, even if I set it to 16.
- "The service has not been started" appeared during testing for no reason. I was installing WSL and Ubuntu in about the same way the script does. I need to perform some testing...
- **Very** limited functionality.
