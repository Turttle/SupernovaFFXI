Ashitacast is an extension designed to provide the same functionality
as Spellcast on Windower.  It serves several functions

Typing simplification:
Numbers are automatically translated to roman numerals and punctuation/spacing
within spell/ability names are unnecessary.  Furthermore, you can use // to avoid specifying a type.

//fire4, //fireiv, /ma fire4 would all send out /ma "Fire IV" <t>
//fire4 <st> would pop up the st window and work correctly when you choose target.
//katonni would send out /ma "Katon: Ni" <t>

You can type a target's name or any portion of it into any spell.  Unlike spellcast, this includes mobs.
//fire4 kum would cast fire 4 on kumhau(or whatever mob has the closest match within casting range)

Only valid targets will be checked.  For example, if you typed /ma dia2 Toj and your party
had a player named Tojmahal and you were in range of a monster named Tojil, it would know to
select the monster.  If you typed /ma raise player and were in range of a living
player named Playerone and a dead player named Playertwo, it would know to
select playertwo.  In the case of 2 equal length matches, the one closer to
the start of the name takes precedence.  If the names are identical, the
closest valid target will be used.  This is also accurate for BRD songs.  If you
were to macro /ma "Victory March"(or just //victorymarch), it'll automatically
use <me> if pianissimo isn't active or <t> if it is.

This also implements an additional targeting option, <at>.  This will take the closest
monster claimed by your alliance, similar to the game's <bt>.

Known Bugs:
-The following targeting options do not work and will be read as names: <ft> <lastst>.
A fix will be made at some point, but it's not very high on my to-do list.  When it is fixed, I plan on
adding a few other options for your trust NPCs, like <trust1> <trust2> etc.


Equipment Management:
This is done through an XML file, which should be placed in Ashita/Config/Ashitacast/
and named CharacterName_JobName.xml.  XMLs will be automatically loaded or unloaded whenever you change jobs,
or can be triggered through commands.  There are some included sample files and a list of valid variables.
Equipment is layered precast<action<midcast in one chunk, which ensures that your precast will always lower
your casttime(or ranged time for rng) and your midcast will always be on in time(even on instant casts or rapid shot).

Setup: Copy the Ashitacast.dll file into your Ashita/Extensions folder.
Copy the Ashitacast folder into your Ashita/Config folder.
Adjust/make XMLs as needed, the examples should provide some help.

Commands - can use /ashitacast or /ac
/ac load - Reload aliases, storage XMLs, and swap XML for your current job.
/ac load swap - Load swap XML for your current job.
/ac load alias - Reload aliases.
/ac load storage - Reload storage XMLs.
/ac load Filename.xml - Load a swap XML.
/ac unload - Unload active swap XML, typing/targetting adjsutments remain without a swap XML.
/ac reload - Reload the loaded XML.

/ac print augs "Item Name" - Prints a code used to reference the augments on an item.
/ac print info - Print information about the currently loaded XML.
/ac print uvars - Print current values of all user-defined variables.
/ac print vars - Print current values of all built-in variables.
/ac print gear - Print a list of all gear that can be detected in your loaded XML.
/ac print validate - Print a list of all gear in your loaded XML that isn't in your inventory.
/ac print set [setname] - Print a set.

/ac naked - Remove all equipment.
/ac set [Name] [Optional: Seconds] - Equip the named set, and lock it on for X seconds(5 if unspecified).
/ac disable [Optional: Slot] - Stop a slot from being swapped out(or all gear swaps if slot not specified).
/ac enable [Optional: Slot] - Allow slot to be swapped out(or all gear swaps if slot not specified).

/ac var clear - Clear all user-defined variables.
/ac var set [Name] [Value] - Set a variable to a specific value.
/ac var inc [Name] [Optional: Amount] - Increase a variable(default: 1).
/ac var dec [Name] [Optional: Amount] - Decrease a variable(default: 1).

/ac gear [Event] - Collect your equipment from safe/locker/etc. automatically.
/ac stopgear - Interrupt the gearing function.

/ac export inv - Create a profile with all of your current items.

/ac help - Print information ingame.
/ac help export - Print information ingame.
/ac help load - Print information ingame.
/ac help print - Print information ingame.
/ac help var - Print information ingame.

Known bugs:
-Due to a potential problem with blocking packets, commands suffer a 0-300ms delay waiting for the next
status update.  I'm attempting to find a solution to this, but it's not noticable unless you
specifically look for it.


Minor Function: Aliases
You can define any amount of aliases in the spells/abilities/weaponskills files in the ashitacast folder.
These can be anything you'd like, and are input as follows:

Find the spell you're looking for, it'll look something like:
<alias id="3" name="cureiii">
</alias>

In between the tags, add any amount of entries, as so:
<alias id="3" name="cureiii">
<entry>//c3</entry>
<entry>/c3</entry>
<entry>cure3</entry> (i don't recommend doing this one, but you can)
</alias>

Save the file, unload and reload ashitacast if you have it loaded.  Now, you can type //c3 to get /ma "Cure III" <t>.
You can also use parameters as if you normally typed it, of course: //c3 playername, //c3 <st>, etc.

Any text is permitted in aliases, and the longest match will be used if there are multiple matching aliases.
(if you have //cure for cure1 and //cure4 for cure4, it won't think it's /ma "Cure" 4, it'll know it's using cure4)
While the plugin's limitations are extremely loose here, you should take care not to assign aliases that will
step on other plugins' toes or block ingame commands.

Minor Function: Autogear/Validate
Automatically retrieves all gear that can be located in both your XML and on your character.
This also places any items you're carrying that aren't in your XML in case > sack > satchel.
If you're not in your mog house, safe/locker/storage will not be used(even if you are at a nomad moogle).
Definitions should be done in Config\Ashitacast\Gear.xml for multiple characters, or Config\Ashitacast\Playername_Gear.xml
for a single player.  These files use the gear XML structure.  If you call "/ac gear Voidwatch" it will also gather the gear
in the specified events definitions.