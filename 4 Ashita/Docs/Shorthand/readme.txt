Shorthand provides the input adjustment portion of Ashitacast1.  To be specific:

-You may omit any symbols when typing spell names.
-You may omit or add additional spaces without requiring " "s.
-You can type normal numerals in the place of roman numerals.
-You can type partial player or mob names as your target(valid target with the typed string closest to the start becomes target, in the case of identical names it goes to the one closest to you).
ie: if 2 mobs were named Tojil and Ojil, Oji would go to the second one.  If a mob was named Tojil and a player in range was named Tojmahal, and you typed Toj, the spell would target the one that is appropriate for that spell.
-You can omit target entirely and it'll be directed to <t>(or <me> in the case of self-target only spells).
-You can type //blizzard4 instead of an abbreviation.  In this case, it would check to see if you have an avatar out and send the blood pact instead of the spell if so.

Additionally, shorthand provides the ability to WS while disengaged.  As some users may feel uncomfortable having this active, you can enable or disable it using the configuration file or while loaded. 

Commands
/shh export - Print a config XML with all abilities/spells/ws from the resources to Config/Shorthand-Empty.xml
/shh reload - Reload reference lists from your config XML.
/shh packetall [on/off] - When enabled, forces shorthand to send packets for all abilities/spells/ranged/ws. (Will -NOT- make commands your job doesn't have usable besides BLU.)
/shh packetblu [on/off] - When enabled, forces shorthand to send packets for all blue magic. (Will allow you to use blue magic you have set even if not on BLU)
/shh packetws [on/off] - When enabled, forces shorthand to send packets for all weaponskills. (Will allow you to WS while disengaged)
/raw [Command] - Sends a command that will be ignored by shorthand.
Example: /raw /ma "Blizzard III" <t>

Commands that will be parsed when using Shorthand:
/ra
/range
/shoot
/throw
/a
/attack
/ma
/magic
/ja
/jobability
/pet
/ws
/weaponskill
/i (not a normal in-game command, short for /item)
/item (will only try to use usable items in inventory, example usage would be: /i echodrops)
// (can be used for any spell, ability, ws, item)
