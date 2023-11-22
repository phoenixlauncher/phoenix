![Phoenix's Banner](/Images/phoenix-banner-small.jpg)

<div align="center">

  [![Discord](https://img.shields.io/discord/1059670439917527140?style=for-the-badge&logo=discord)](https://discord.gg/ZJdbcafA9Q)
  ![macOS Version](https://img.shields.io/badge/macos-13%2B-brightgreen?style=for-the-badge)
</div>

# Phoenix

Phoenix is a lightweight game launcher built in SwiftUI for macOS. 

![Screenshot of Phoenix in light mode](/Images/phoenix-light-compressed.webp#gh-light-mode-only)
![Screenshot of Phoenix in dark mode](/Images/phoenix-dark-compressed.webp#gh-dark-mode-only)

## Setup

To setup the app refer to [the setup page](https://github.com/phoenixlauncher/phoenix/wiki/1.-Setup).

## Building

If you want to build this app for yourself, just clone this repository

```bash
git clone git@github.com:PhoenixLauncher/Phoenix.git
```

then open `Phoenix.xcodeproj` in Xcode. You will first have to update the `Team` field in the `Signing and Capabilities` section of `Targets > Phoenix` in the main Project file. You can then create a `.app` file by going to `Product > Archive` in the menu bar, clicking `Distribute App`, selecting `Copy App` and then saving the folder somewhere easy to find like your desktop. The app will be inside the folder and you can copy it into your applications folder and begin using it!


