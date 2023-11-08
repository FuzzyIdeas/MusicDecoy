<p align="center">
    <a href="https://files.lowtechguys.com/MusicDecoy.zip"><img width="128" height="128" src="Music/Assets.xcassets/AppIcon.appiconset/icon_256x256.png" style="filter: drop-shadow(0px 2px 4px rgba(80, 50, 6, 0.2));"></a>
    <h1 align="center"><code style="text-shadow: 0px 3px 10px rgba(8, 0, 6, 0.35); font-size: 3rem; font-family: ui-monospace, Menlo, monospace; font-weight: 800; background: transparent; color: #4d3e56; padding: 0.2rem 0.2rem; border-radius: 6px">Music Decoy</code></h1>
    <h4 align="center" style="padding: 0; margin: 0; font-family: ui-monospace, monospace;">Stop launching the Music app<br>whenever you press <b>▶ Play</b></h4>
</p>

<p align="center">
    <a href="https://files.lowtechguys.com/MusicDecoy.zip">
        <img width=300 src="https://files.alinpanaitiu.com/download-button-dark.svg">
    </a>
</p>

## Installation

- Download, unzip, move to `/Applications`
- or.. `brew install music-decoy`


## What does this do?

Nothing. The app does absolutely nothing while running. 0% CPU all day long.

But by simply having it running, the macOS system won't launch the Music app whenever you accidentally press Play.

It won't launch Music even if you try to launch it manually! *that might not actually be a good thing, but.. oh well*

## How does it achieve that?

By having the same bundle identifier as the system Music app: `com.apple.Music`

In more technical terms, this is what I found out about how the **▷ Play** mechanism works:

1. The `Play` event is caught by the `rcd` daemon (living at `/System/Library/CoreServices/rcd.app/Contents/MacOS/rcd`)
2. The daemon checks if there is any app playing something and forwards the event to that app
3. If there is no such app, `rcd` checks if any running app has `com.apple.Music` as its bundle identifier
    - Without a running `com.apple.Music` app, `rcd` launches the system Music app
    - *But if there is such an app, the event is forwarded to it instead*

## Uh.. how do I quit this app?

The app has no Dock icon and no menubar icon so to quit it you'd need to do *one of the following*:

- Launch **Activity Monitor**, find **Music Decoy** and press the ❌ button at the top
- Run the following command in the Terminal: `killall 'Music Decoy'`

## Alternatives

Based on [this StackExchange answer](https://apple.stackexchange.com/questions/372948/how-can-i-prevent-music-app-from-starting-automatically-randomly), there are a few different ways to achieve the same effect:

- `launchctl unload -w /System/Library/LaunchAgents/com.apple.rcd.plist`
    - Problem: *disables the Play button completely*
- [noTunes](https://github.com/tombonez/noTunes) which listens for launched apps and kills Music as soon as it is launched
    - Problem: *it does use a tiny bit of CPU in the background* although checking for launched apps is very little work
    - Advantage: *it can launch a custom app on Play* which this app can't do

## *Frequently* asked questions?

I think they were only asked once, and they might not even be questions but I might as well record the info for posterity.

### VLC crashes

Looks like VLC tries to use [ScriptingBridge](https://developer.apple.com/documentation/scriptingbridge) to send commands to the Music app.

```sh
warning: failed to get scripting definition from /Applications/Music Decoy.app; it may not be scriptable.
-[SBApplication playerState]: unrecognized selector sent to instance 0x600003399050
```

You can fix this by configuring the following setting:

![vlc setting for music decoy](https://files.lowtechguys.com/vlc-music-decoy-setting.png)
