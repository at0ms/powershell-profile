# Andy's Powershell Profile
A lightweight PowerShell profile emphasizing readability, streamlined workflow, and distraction‑free use. 

## Previews
<details>
  <summary>Profile</summary>
  <br>
  <p align="center">
  <img src="https://raw.githubusercontent.com/at0ms/powershell-profile/refs/heads/main/assets/profile_preview1.png" width="700" height="700">
  <p>
</details>
<details>
  <summary>Setup Script</summary>
  <br>
  <p align="center">
  <img src="https://raw.githubusercontent.com/at0ms/powershell-profile/refs/heads/main/assets/setup_script_preview1.png" width="700" height="700">
  <p>
</details>

## Installation

### Interactive Setup (Elevated PowerShell Required)
```
irm "https://github.com/at0ms/powershell-profile/raw/main/scripts/setup.ps1" | iex
```

### Manual Installation
1. Download or clone this repository.
2. Create a folder named WindowsPowerShell in your user Documents directory (if it doesn’t already exist).
3. Copy `Microsoft.PowerShell_profile.ps1` from the `profile` folder into that directory.
4. Open a new PowerShell session to load the profile.
5. Verify that the profile loaded by running `psi` and pressing Enter.
6. Profit.

## Highlighted Features
* Removes the nag message prompting you to install the latest PowerShell version.
* Prevents sensitive information from being written to command history.
* Customizes PSReadLine colors to match a blue aesthetic.
* Loads an Oh My Posh theme from the profile directory. If none is found, it attempts to download one; if that fails, it falls back to a remote theme.
> More features are on the way. Feel free to jump in and contribute.

## Commands
<details>
  <summary>General</summary>
  <br>
  <ul>
    <li>psh - Shows help message.</li>
    <li>psi - Shows infomation about the script.</li>
  </ul>
</details>

## Release Notes
See [Release Notes](release-notes.md).

## Credits
* Chris Titus Tech
* DreamTimeZ

## Contributing
Pull requests are welcome. For major changes, please open an issue first
to discuss what you would like to change.

Please make sure to test your code before submitting a pull request. 

## License
[GNU GPL v3](https://choosealicense.com/licenses/gpl-3.0/)