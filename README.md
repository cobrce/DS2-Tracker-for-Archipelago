This is a tracker for Dark Souls II Scholar of The First Sin obtimized for Archipelago runs, written in Livesplit-asl.

It tracks Key items and statues nececssary for exploring / finishing the randomized Archipelago game

![](https://raw.githubusercontent.com/cobrce/DS2-Tracker-for-Archipelago/refs/heads/master/ScreenShot.jpg)


# Shrine of winter:
### This tracks the 2 sufficient conditions that open the "Shrine of winter"
- Great souls : tracks the number of defeated Great souls boss (Rotten, Freyja, Sinner, Iron king), turns green when 4 defeated
- Soul memory : display the actual value and turn green when it reaches 1 million

# Key items:
- Silver cat ring / Flying feline boots / Laddersmith Gilligan moved to Majula : satisfying one of these checks is necessary to reach "Grave of saints" and "The black gulch"
- Rotunda lockstone : it gives access to "Hunter's copse"
- Giant's Kinship : necessary to finish the game, it unlocks "Nashandra" boss fight
- Soldier's Key / Antiquated key : give access to different regions in  "Lost bastille"
- King's passage : allows access to "Looking glass knight" and "Shrine of Amana"
- Lenigrast key : allows upgrading weapons

# Satues:
- Statue in Things Betwixt
- Rosabeth of Melfia
- Statue in Heide's Tower of Flame
- Statue in Lost Bastille
- Straid of Olaphis
- Statue in Black Gulch
- Statue near Manscorpion Tark
- Statue near Black Knight Halberd
- Statue Blocking the Chest in Shaded
- Lion Mage Set Statue in Shaded Ruins
- Fang Key Statue in Shaded Ruins
- Warlock Mask Statue in Shaded Ruins
- Milfanito Entrance Statue
- Cyclops Statue in Aldia's Keep
- Left Cage Statue in Aldia's Keep
- Right Cage Statue in Aldia's Keep
- Statue in Dragon Aerie

### Due to the way archipelago.dll works, statues depetrification are not updated in game until the player enters the area containing that statue, to speed up detection an experimental* way of detecting events directly from that dll is used.
*too lazy to implement that function for every version of the dll, I'm using a static RVA based on the v0.6.0-alpha.2 version

# How to use:
- Right click on live split -> Open layout -> from file -> select "layout.ls"
- Right click on live split -> Edit layout -> double click on "Scriptable Auto Splitter" -> press "Browse" button and give the correct path for "DS2_tracker.asl"

## if you already have layout (back it up before doing the following) you can simply add a "Scriptable Auto splitter" pointing to "DS2_tracker.asl" and it will automatically add its controls to the layout

# Credit:
- Thanks to Boblord14 for [cheat engine table](https://github.com/boblord14/Dark-Souls-2-SotFS-CT-Bob-Edition)
- Thanks to WildBunnie for [DS2 implementation of Archipelago](https://github.com/WildBunnie/DarkSoulsII-Archipelago)
- Thanks to [drtchops](https://github.com/drtchops/asl) for the the ASL repository