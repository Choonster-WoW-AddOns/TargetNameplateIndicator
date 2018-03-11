## 1.23
- Add support for separate self target indicator options (for the class resource bars, which are implemented as a nameplate)
- Add per-target type option to show/hide target indicator

## 1.22
- Add support for separate friendly and hostile target indicator configurations

## 1.21
- Bump TOC Interface version to 7.3

## 1.20
- Another new release to try and fix CurseForge packager error. MrFlamegoat says it should be fixed now.

## 1.19
- New release to try and fix CurseForge packager error.

## 1.18
- Use consistent spelling of reticule in config.lua
- Fix comment of RedChevronArrow texture not mentioning OligoFriends' Curse profile
- Add Red Hunter's Mark Arrow texture provided by thisguyyouknow of Curse

## 1.17
- Bump TOC Interface version to 7.2
- Add textures from ContinuousQ of Curse
- Fix Notes tag in TOC to mention options in config.lua instead of core.lua

## 1.16
- Add explanation of when changes will take effect to config.lua

## 1.15
- Change the default texture back to Reticule
- Fix typo in file name of neon green arrow texture

## 1.14
- Move configuration variables into config.lua
- Move textures to Textures directory
- Add screenshots to the repository
	- They won't be packaged with the AddOn
- Add neon green arrow texture provided by Nokiya420 of Curse

## 1.13
- Fix LibStub and CallbackHandler not being included in the packaged AddOn

## 1.12
- Bump TOC Interface version to 7.1
- Update LibNameplateRegistry to 0.18T
- Change the `LNR_ERROR_FATAL_INCOMPATIBILITY` callback to use the correct `incompatibilityType` values and remove ones that are no longer used by LNR
- Remove handlers for callbacks that are no longer fired by LNR
- Remove Ace3 from the OptionalDeps and X-Embeds TOC tags
	- TNI doesn't actually use Ace3 at all
- Rename .pkgmeta to pkgmeta.yaml for CurseForge's new packager

## 1.11
- Bump TOC Interface version to 7.0
- Add to p3lim's AddOn Packager Proxy

## 1.10
- Add textures from Imithat of WoWI

## 1.09
- Bump TOC Interface version to 6.0

## 1.08
- Trim trailing spaces
- Add DEBUG flag to enable/disable debugging output
- Replace all debugging print() calls with debugprint() calls
- Wrap debugprint() calls in --@debug@/--@end-debug@ so CurseForge packager comments them out
- Add FindGlobals tools-used reference in .pkgmeta
- Add OptionalDeps and X-Embeds tags to TOC as recommended by LibNameplateRegistry
- Rewrite around LibNameplateRegistry-1.0
- Update for 5.4
- Add three new textures

## 1.07
- Added red/green 3D arrow and skull and crossbones textures provided by OligoFriends of Curse/WoWI
- Not updating LibNameplate for now, the latest alpha versions don't seem to work very well.

## 1.06
- Added red inverted chevron textures provided by OligoFriends of Curse/WoWI

## 1.05
- Updated LibNameplate-1.0 to r145 for the nameplate changes in 5.1. This version of the library is still in alpha, so please report any errors or strange behaviour.

## 1.04
- Added neon textures provided by mezmorizedck of Curse
- Renamed the reticule texture to Reticule.tga and changed the TEXTURE_PATH variable's default value to match

## 1.03
- Updated LibNameplate to version 1.0.36, which should fix the GetNumRaidMembers error
- Updated TOC to 5.0

## 1.02
- Added a red arrow texture provided by DohNotAgain of WoWI
- Added more detail to the comments at the top of core.lua, including stuff about custom textures, GIMP and texture contribution.

## 1.01
- Changed default texture to read targeting reticule contributed by Dridzt of WoW Interface.
- Doubled the default width/height

## 1.00
- AddOn created. Hooray!