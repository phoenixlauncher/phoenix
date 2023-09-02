# Setup

To run this launcher, your Mac must be on at least macOS 13.0 (Ventura).

Download the [latest release](https://github.com/Shock9616/Phoenix/releases) from the releases page and install the app like you would with any other. The first time you open the app, you will get an alert saying that your Mac can't check the app for malicious software. This is because I'm a broke university student who can't afford an Apple Developer Program membership. Open up the app anyways :)

Wen you first open the app, it'll look something like this:
<img src="Readme Images/phoenixplaceholder.webp" alt="Screenshot of the app"/>

## Adding a game

You can add a game by clicking the '+' button in the toolbar. Fill in as much information as you can.

### Name:
This is just the name of the game that is displayed in the sidebar and the toolbar.
### Icon:
The app icon that shows in the sidebar. A good source for these is [macosicons.com](https://macOSicons.com).
### Platform: 
The platform / store of the game. Will help organize the games in the sidebar.
### Command:
This is the terminal command that will launch your app. I know that not everyone has used the terminal before, so here are some templates for some common places to find games:

#### App Store/Regular Mac games:

```
open -a "<App Name>"
```

or

```
open ~/Applications/<App Name Here>.app
```

#### Steam games:

Steam games are now automatically detected by Phoenix when they are in the Application Support directory! But, on the off chance that you want to change it or need to enter it yourself, here's the format to use:

```
open steam://run/<steam app ID here>
```

You can find your game's ID by going to [SteamDB](steamdb.info) and searching for your game. The app ID will be in the leftmost column.

#### Parallels

If you didn't know, Applications installed in Parallels have Mac apps that act as launchers in `~/Applications (Parallels)/<VM Name> Applications/`, so any Windows game you play via Parallels can be launched like this (Using my VM called 'Windows 11' as an example):

```
open ~/Applications\ (Parallels)/Windows\ 11\ Applications/<game name>.exe.app
```

#### Crossover

Crossover apps are installed to `~/Applications/CrossOver` so they can be launched like this:

```
open ~/Applications/CrossOver/<game name>.app
```

#### Emulated games:

There isn't a set formula for emulated games, since the games are all run by different apps. That said, most (not all) will work with one of these options:

```
open /path/to/rom/file

For example, this command opens Metroid Prime Hunters in DeSuME for me:

open ~/Documents/Gaming/ROMs/NDS/Metroid\ Prime\ Hunters.nds
```

or 

```
open /Applications/<emulator name here>.app/Contents/MacOS/<emulator name> /path/to/rom/file

For example, this command opens Metroid Dread in Ryujinx for m:

open /Applications/Ryujinx.app/Contents/MacOS/Ryujinx ~/Documents/Gaming/ROMs/Switch/Metroid\ Dread.nsp
```

or 

```
/Applications/<emulator name here>.app/Contents/MacOS/<emulator name> "/path/to/rom/file"

For example, this command opens Red Dead Revolver in AetherSX2 for me:

/Applications/AetherSX2.app/Contents/MacOS/AetherSX2 "/Volumes/Crucial X6/Games/PS2/Red Dead Revolver/Red Dead Revolver.iso"
```
### Description:
This is the description of the game. Pretty self-explanatory.
### Genres: 
This is where you put the genres of your game. You can have as many as you want. Format them with new lines like this:
```
Action
Adventure
Sci-fi
```
### Header: 
This is the header image. It'll make the app look a hell of a lot better. Unless you are insane, please use one.
### Rating:
A rating of the game out of 10.
### Developer: 
The developer of the game. I know you love us, but we are not the devs. Don't put us!
### Publisher: 
The publisher of the game. Hopefully not Activision.
### Release Date:
The date that the game was released.

 ## Final Result:

It should look something like this after that:
<img src="Readme Images/phoenixnms.webp" alt="Screenshot of the app"/>

To run the game, you need at the VERY least a name and a launcher command. All the other things are for making the launcher look nicer. Once you've added a game you can delete the placeholder game by right-clicking and selecting 'Delete Game'. You can edit a game you've already added by clicking the pencil button next to the play button. 

Once you have a game and it's launcher command is configured, you can hit the play button and it will open up!



