# Changelog

`git log` is another good way to peer into the innards of this repository.



# 8.x - Battle for Azeroth (BfA)


## 8.2 series

## 8.2.5.1

- Significant style changes


## 8.2.5.0

- TOC bump

 
## 8.0 series

### 8.2.0.1

- Updated `README.markdown` to note the limitation for `#showtooltip`


### 8.1.0.2

- Partially-addressed #15 - Fix "Change Name/Icon"


### 8.1.0.1

- Fixed #16 - Long Macros Not working
- While fixing #16, significant code style changes were made in a few places.


### 8.0.1.1

- Tested for 8.0.1
- Removed a .toc reference to a file that does not exist.
  -  I don't know what `SuperDuperMacro_MacroInterpreter.lua` is.  It feels like this was just included in the rest of the addon.



## 7.3 series

### BETA

hypehuman has officially left World of Warcraft, but has added me as a contributor.

https://github.com/hypehuman/super-duper-macro/pull/1

I'll keep WoWInterface updated so people can use Minion and whatnot.


###  7.3.2.0

- Merged pull 6 - Fix an exception when change icon:
  https://github.com/spiralofhope/SuperDuperMacro/pull/6
    -  With thanks to a08381.


### 7.3.0.3

- Fixed issue #3 - Fix child window scaling


### 7.3.0.2

- Corrected the TOC


### 7.3.0.1

- Commented-out `PlaySound()`, because it will now only accept soundkit IDs.
  -  It will be updated later.


# Old notes


### 2016-04-21 - 6.2.4-21463

spiralofhope's fork - https://github.com/spiralofhope/SuperDuperMacro

- **Note that no Lua code has been changed!**
- Added tagging to the git repository, for all previous releases mentioned with `git log`.
  -  This allows a user to visit the git repository to easily view any of those tagged versions.
- Documentation update.
- Changing SuperDuperMacro's version numbering scheme to show what version of World of Warcraft it's been most recently tested-against.


### 2014-10-16 - 2.6.1

* Fixes "Different name on button" and "Expand/collapse all folders".


### 2014-10-16 - 2.6

* Fixes character-specific macros, which broke when World of Warcraft 6 (Warlords of Draenor) gave us more global macros.


### 2012-02-20 - 2.4.6

* Fixed a bug where the interface sometimes inappropriately prevented you from making new macros.


### 2012-01-17 - 2.4.5

* Fixed a bug that caused the `Change Name/Icon` window to sometimes be unresponsive.
* Now `Change Name/Icon` always deselects the icon when it opens so that you don't accidentally change the icon of one of your macros.


### 2011-12-17 - 2.4.4

* Fixed a bug where the button on the macro frame that opens SuperDuperMacro would sometimes appear in the wrong place.


### 2011-11-30 - 2.4.3

* Re-enabled the text that shows how many more button macros you can create.


### 2011-11-30 - 2.4.2

* Fixed a minor error that occurs when running SuperDuperMacro for the first time
* When attempting to pick up a macro during combat, you will get an error message created by SuperDuperMacro instead of Blizzard's `Interface action failed due to an addon`.


### 2011-11-30 - 2.4.1

* Updated for World of Warcraft 4.0 (Cataclysm)
  *  You will lose any custom icons for your macros.  Sorry!


### 2011-11-20 - 2.4

* Fixed the Send/Receive feature; now you can share macros with your friends again, as long as you are both using the latest version.
* Fixed a bug where buttons on the SuperDuperMacro frame would sometimes stretch away.
* Many UI Improvements.


### 2011-11-16 - 2.3

* The SuperDuperMacro frame now hides when you press `escape`.
* Added more tooltips.


### 2011-11-15 - 2.2.1

* Fixed a bug where the macro list sometimes became unclickable.


### 2011-11-04 - 2.2

* Upgraded macros will now appropriately change their icons based on the macro code (unless an icon other than the Question Mark icon was selected).
  *  If you upgraded a macro with version 2.1, you will need to manually change the icon to the Question Mark icon.
* Added a `Downgrade` button that converts a SuperDuperMacro macro into a standard macro.
* Added a `Claim`/`Disown` button that allows you to have a single character-specific macro or script that applies to multiple characters.
* Added a `Save As...` button that allows you to save an existing macro as a different type or character.
  *  For example, you can save a button macro as a floating macro if you want to free up a macro slot.
* Several UI improvements.


### 2011-10-19 - 2.1

* Added an `Upgrade` button to the standard macro frame, allowing you to convert a standard macro into a SuperDuperMacro macro.
* Removed an overbearing version-checking system.


### 2011-10-16 - 2.0

* Incorporated compatibility updates by survivorx and ambro.


### 2009-02-26 - 1.8.3

* Changing the name of a macro will now properly update the title text above the edit box.
* Improved the `/sdm test` function.  Please re-test it and submit your results!


### 2009-02-26 - 1.8.2

* Fixed a bug that caused the image on button macros to show as a question mark more often than necessary.
* Added a command `/sdm test` that does nothing but check some nyi code.  Please run this command and report the results at wowinterface.com.


### 2009-02-21 - 1.8.1

* SuperDuperMacro no longer conflicts with LayMacroTooltip or with other addons that modify the macro frame.


### 2009-02-20 - 1.8

* Added the option of creating folders to organize your macros.
* Numerous minor UI improvements.


### 2009-02-08 - 1.7

* Made the macro list better:
  *  Color-coded the different macro types.
  *  Created a slider below the menu to adjust the size of the icons.
  *  Added drop-down menus to filter the list by type and character.
* Changed the storage of macros in preparation for a future version that will include a sortable macro list with user-defined folders.
* Fixed the save confirmation dialog box now shows while dead.
* Fixed a typo in the `Usage...` text for scripts.


### 2009-01-27 - 1.6.1

* Fixed a serious bug that happened upon login after leaving "different name on button" blank.
  *  You may now safely leave it blank if you wish to show no text on the button.


### 2009-01-19 - 1.6

* Changed the slash command to run a floating macro.
  *  Click the `Usage...` button for details.
* Added a command to run button macros.
  *  Click the `Usage...` button for details.
* Added an interface for changing the name and icon of a macro within the SuperDuperMacro window.
* Button macro names now conflict with each other (unless they are specific to different characters).
* Disallowed some characters in macro/script names because they were causing problems.
  *  You may find that some of these problematic characters still work on button macros, for which you can select a different name in the `Change Name/Icon` frame.
* Changed the appearance of button macros when viewed in the default macro frame.
* Added a clickable, scrolling menu of macros.  This will be further improved later.
* Several efficiency improvements.  As a consequence, your SuperDuperMacro-created button macros will be removed from action bars and lose thieir icons.  Sorry!


### 2009-01-12 - 1.5.1

* Minor bug fixes.


### 2009-01-12 - 1.5

* Added the ability to share macros with other players (The new `Send/Receive` button).
* Fixed a bug where the Save button was sometimes inappropriately disabled.


### 2009-01-09 - 1.4.1

* Fixed a minor bug that sometimes occurred while loading.


### 2009-01-08 - 1.4

* Added an option to show/hide the text on macro buttons.
* Fixed `>` to be more accurate.
* SuperDuperMacro will no longer attempt to create, delete, or modify macros during combat.  You can still do these things, but the changes will not take effect until after combat.
* Deleting floating macros will now actually disable them.
* Greatly increased the efficiency of operations like saving and deleting.
* Increased the limit on the length of each line to 1023, and made the number of lines limitless (actually, the maximum length of any string is 2^24 characters, so the limit is somewhere below that, but that's the length of about 20 average novels and it will probably crash your client).
* Changed the structure of the macro frames to eliminate the chance of a recently-discovered "C stack overflow" error on very long macros.


### 2008-12-16 - 1.3.1

* Fixed an occasional bug with the `Get Link` and `Delete` buttons.
* Blocked the user from attempting to make more button macros than the standard macro interface can hold.


### 2008-12-15 - 1.3

* You can now use the addon to store long scripts and call them via a function or slash command.
* SuperDuperMacro now keeps track of the button macros it creates, and deletes orphaned ones upon login. If you are upgrading from a previous version, you can delete the old button macros that SuperDuperMacro created (the text of the new ones all start with `#sdm` ).
* Because of this, SuperDuperMacro will no longer ever replace your macros, and their names do not need to be unique at all.  Floating macros and Scripts still have some restrictions on naming, you will get a warning it you try to violate them.
* Added many UI improvements to make working with the addon more intuitive:
  *  Pressing `tab` will now add four spaces.
  *  Pressing `enter` will now be equivalent to the appropriate button click.
  *  Moved some buttons around to more appropriate places.
  *  Added buttons that link between the regular macro window and the SuperDuperMacro window.
  *  Buttons will now "gray out" when appropriate.
  *  The SuperDuperMacro window will now become unresponsive during confirmation dialogs.


### 2008-12-13 - 1.2

* Fixed a bug that caused major problems when there were no macros in the list.


### 2008-12-12 - 1.1

* More UI improvements.
  *  Some UI elements are still placeholders.


### 2008-11-13 - 1.0

* Making it ready for 3.0 (Wrath of the Lich King).
