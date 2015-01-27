/**
* Copyright (c) 2011-2014 - Ashita Development Team
*
* Ashita is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* Ashita is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with Ashita.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef __ASHITA_ADK_PLAYER_H_INCLUDED__
#define __ASHITA_ADK_PLAYER_H_INCLUDED__

#if defined (_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

namespace Ashita
{
    namespace FFXI
    {
        /**
         * @brief Player Stats Structure
         */
        struct PlayerStats
        {
            short Strength;
            short Dexterity;
            short Vitality;
            short Agility;
            short Intelligence;
            short Mind;
            short Charisma;
        };

        /**
         * @brief Player Elements Structure
         */
        struct PlayerElements
        {
            short Fire;
            short Ice;
            short Wind;
            short Earth;
            short Lightning;
            short Water;
            short Light;
            short Dark;
        };

        /**
         * @brief Combat Skill Structure
         */
        struct CombatSkill
        {
            unsigned short RawSkill;

            unsigned short GetSkill(void) const { return (unsigned short)(this->RawSkill & 0x7FFF); }
            bool GetCapped(void) const          { return (this->RawSkill & 0x8000) == 0 ? false : true; }
        };

        /**
         * @brief Player Combat Skills Structure
         */
        struct PlayerCombatSkills
        {
            CombatSkill Unknown;
            CombatSkill HandToHand;
            CombatSkill Dagger;
            CombatSkill Sword;
            CombatSkill GreatSword;
            CombatSkill Axe;
            CombatSkill GreatAxe;
            CombatSkill Scythe;
            CombatSkill Polearm;
            CombatSkill Katana;
            CombatSkill GreatKatana;
            CombatSkill Club;
            CombatSkill Staff;
            CombatSkill Unused0000;
            CombatSkill Unused0001;
            CombatSkill Unused0002;
            CombatSkill Unused0003;
            CombatSkill Unused0004;
            CombatSkill Unused0005;
            CombatSkill Unused0006;
            CombatSkill Unused0007;
            CombatSkill Unused0008;
            CombatSkill Unused0009;
            CombatSkill Unused0010;
            CombatSkill Unused0011;
            CombatSkill Archery;
            CombatSkill Marksmanship;
            CombatSkill Throwing;
            CombatSkill Guarding;
            CombatSkill Evasion;
            CombatSkill Shield;
            CombatSkill Parrying;
            CombatSkill Divine;
            CombatSkill Healing;
            CombatSkill Enhancing;
            CombatSkill Enfeebling;
            CombatSkill Elemental;
            CombatSkill Dark;
            CombatSkill Summon;
            CombatSkill Ninjitsu;
            CombatSkill Singing;
            CombatSkill String;
            CombatSkill Wind;
            CombatSkill BlueMagic;
            CombatSkill Unused0012;
            CombatSkill Unused0013;
            CombatSkill Unused0014;
            CombatSkill Unused0015;
        };

        /**
         * @brief Craft Skill Structure
         */
        struct CraftSkill
        {
            unsigned short RawSkill;

            unsigned short GetSkill(void) const { return (unsigned short)((this->RawSkill & 0x1FE0) >> 5); }
            unsigned short GetRank(void) const  { return (unsigned short)(this->RawSkill & 0x1F); }
            bool GetCapped(void) const          { return ((this->RawSkill & 0x8000) >> 15) == 0 ? false : true; }
        };

        /**
         * @brief Player Craft Skills Structure
         */
        struct PlayerCraftSkills
        {
            CraftSkill Fishing;
            CraftSkill Woodworking;
            CraftSkill Smithing;
            CraftSkill Goldsmithing;
            CraftSkill Clothcraft;
            CraftSkill Leathercraft;
            CraftSkill Bonecraft;
            CraftSkill Alchemy;
            CraftSkill Cooking;
            CraftSkill Synergy;
            CraftSkill Riding;
            CraftSkill Unused0000;
            CraftSkill Unused0001;
            CraftSkill Unused0002;
            CraftSkill Unused0003;
        };

        /**
         * @brief Player Info Structure
         */
        struct PlayerInfo
        {
            unsigned int        HPMax;
            unsigned int        MPMax;
            unsigned char       MainJob;
            unsigned char       MainJobLevel;
            unsigned char       SubJob;
            unsigned char       SubJobLevel;
            unsigned short      ExpCurrent;
            unsigned short      ExpNeeded;
            PlayerStats         Stats;
            PlayerStats         StatsModifiers;
            short               Attack;
            short               Defense;
            PlayerElements      Elements;
            unsigned short      Title;
            unsigned short      Rank;
            unsigned short      RankPoints;
            unsigned char       Nation;
            unsigned char       Residence;
            unsigned int        Homepoint; // (Homepoint & 0x0000FFFF)
            PlayerCombatSkills  CombatSkills;
            PlayerCraftSkills   CraftSkills;
            unsigned char       Unknown0000[144];
            unsigned short      LimitPoints;
            unsigned char       MeritPoints;
            unsigned char       LimitMode;
            unsigned char       Unknown0001[290];
            short               Buffs[32];
        };
    };
};

#endif // __ASHITA_ADK_PLAYER_H_INCLUDED__
