# Super Duper Macro

A 
[World of Warcraft](http://blog.spiralofhope.com/?p=2987) 
[addon](http://blog.spiralofhope.com/?p=17845).

Enables the creation of incredibly long macros.

A fork of 
[hypehuman](http://www.wowinterface.com/forums/member.php?action=getinfo&userid=52682)
's 
[Super Duper Macro](http://www.wowinterface.com/downloads/info10496)
.

[source code](https://github.com/spiralofhope/SuperDuperMacro)
 · [home page](http://blog.spiralofhope.com/?p=18050)
 · [releases](https://github.com/spiralofhope/SuperDuperMacro/releases)
 · [latest beta](https://github.com/spiralofhope/SuperDuperMacro/archive/master.zip)



# Notes

- This addon is largely unchanged from hypehuman's efforts!
- I am a documentation guy, not a programmer.  It is unlikely I can make any real changes.
  -  If you are a developer, I am happy to:
     -  Accept GitHub pull requests.
     -  Add you as a contributor on GitHub.
     -  Hand this project over!



# Installation

Since it's a regular addon, it's manually installed the same as every other addon would be.

1) [Download Super Duper Macro](https://github.com/spiralofhope/SuperDuperMacro/releases) 

2) Extract it to your `Interface\AddOns` folder.

Perhaps your game is installed to one of:

  `C:\Program Files\World of Warcraft` <br />
  `C:\Program Files\World of Warcraft (x86)` 

.. and so you would extract the contents of your downloaded archive to something like:

  `C:\Program Files\World of Warcraft\Interface\AddOns` 

.. and so you would end up with the folder 

  `C:\Program Files\World of Warcraft\Interface\AddOns\SuperDuperMacro`

.. and inside it would have `SuperDuperMacro.toc` and all the other files.


- [Curse blog entry on manually installing AddOns](https://support.curse.com/hc/en-us/articles/204270005)
- [Curse FAQ on manually installing AddOns](https://mods.curse.com/faqs/wow-addons#manual)


# Configuration / Usage

Open the interface by typing `/sdm`

- Create macros beyond the 255-character limit, and even beyond the 1023-character macrotext limit.
  -  However, no individual line in a macro may be more than 1023 characters long (you will get a warning).
  -  The number of lines is unlimited.
- Share macros in-game.
- Button macros
  -  36 global and 18 character-specific for each character.
* Floating macros accessed by `/click`
  -  You can make as many of these as you want.
* Lua scripts of unlimited length
  -  `/sdm run <name>`
  -  `sdm_RunScript("name")`


# Issues and suggestions

([issues list](https://github.com/spiralofhope/SuperDuperMacro/issues))

- If you seen an error, disable all addons but this one and re-test before creating an issue.
  -  If you have multiple addons installed, errors you think are for one addon may actually be for another.  No really, disable everything else.
- Search for your issue before creating an issue.
- Always report errors.
  -  There are several helpful addons to catch errors.  Try something like [TekErr](http://www.wowinterface.com/downloads/info6681).


# Special thanks

- The **SuperMacro** AddOn, which inspired the idea for this addon.
- All the regulars on the UI & Macro forums, who have been guiding me through this process.
