# Andy's Powershell Profile
A lightweight PowerShell profile emphasizing readability, streamlined workflow, and distraction‑free use. 

## Table of contents
- [Features](#Features)
- [Installation](#Installation)
    - [Interactive Setup (Recommended)](#Interactive-Setup-(Recommended))
    - [Manual Installation](#Manual-Installation)
- [Changes](#Changes)
- [Credits](#Credits)
- [Contributing](#Contributing)
- [License](#License)

## Features
- Removes the nag message prompting you to install the latest PowerShell version.
- Loads a local Oh My Posh theme, downloading or falling back to a remote one when unavailable.
- Customize behavior using a configuration file.

> More features are on the way. Feel free to jump in and contribute.

## Installation

### Interactive Setup (Recommended)
```powershell
irm "https://github.com/at0ms/powershell-profile/raw/main/Scripts/setup.ps1" | iex
```
> It's recommended to run this in an elevated shell.

### Manual Installation
1. Download or clone this repository.
2. Create a folder named WindowsPowerShell in your user Documents directory (if it doesn’t already exist).
3. Copy `Microsoft.PowerShell_profile.ps1` from the `profile` folder into that directory.
4. Open a new PowerShell session to load the profile.
5. Profit.

## Changes
See [Release Notes](RELEASE_NOTES.md).

## Credits
- Chris Titus Tech - Used Code from his PowerShell profile.
- DreamTimeZ - Used Code from his PowerShell profile.

## Contributing
Pull requests are welcome. For major changes, please open an issue first
to discuss what you would like to change.

Please make sure to test your code before submitting a pull request. 

## License
[GNU GPL v3](https://choosealicense.com/licenses/gpl-3.0/)