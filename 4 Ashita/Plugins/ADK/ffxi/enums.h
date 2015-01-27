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

#ifndef __ASHITA_ADK_ENUMS_H_INCLUDED__
#define __ASHITA_ADK_ENUMS_H_INCLUDED__

namespace Ashita
{
    namespace Enums
    {
        /**
         * @brief Equipment Slot Enumeration
         */
        enum EquipmentSlot : unsigned char
        {
            Main = 0,
            Sub,
            Range,
            Ammo,
            Head,
            Body,
            Hands,
            Legs,
            Feet,
            Neck,
            Waist,
            Ear1,
            Ear2,
            Ring1,
            Ring2,
            Back,

            EquipmentMax = 16
        };

        /**
         * @brief Item Type Enumeration
         */
        enum ItemType : unsigned short
        {
            Nothing = 0x0000,
            Item = 0x0001,
            QuestItem = 0x0002,
            Fish = 0x0003,
            Weapon = 0x0004,
            Armor = 0x0005,
            Linkshell = 0x0006,
            UsableItem = 0x0007,
            Crystal = 0x0008,
            Currency = 0x0009,
            Furnishing = 0x000A,
            Plant = 0x000B,
            Flowerpot = 0x000C,
            PuppetItem = 0x000D,
            Mannequin = 0x000E,
            Book = 0x000F,
            RacingForm = 0x0010,
            BettingSlip = 0x0011,
            SoulPlate = 0x0012,
            Reflector = 0x0013,
            Logs = 0x0014,
            LotteryTicket = 0x0015,
            TabulaM = 0x0016,
            TabulaR = 0x0017,
            Voucher = 0x0018,
            Rune = 0x0019,
            Evolith = 0x001A,
            StorageSlip = 0x001B,
            Type1 = 0x001C
        };

        /**
         * @brief Job Type Enumeration
         */
        enum JobType : unsigned char
        {
            None = 0,
            Warrior = 1,
            Monk = 2,
            WhiteMage = 3,
            BlackMage = 4,
            RedMage = 5,
            Thief = 6,
            Paladin = 7,
            DarkKnight = 8,
            BeastMaster = 9,
            Bard = 10,
            Ranger = 11,
            Samurai = 12,
            Ninja = 13,
            Dragoon = 14,
            Summon = 15,
            BlueMage = 16,
            Corsair = 17,
            PuppetMaster = 18,
            Dancer = 19,
            Scholar = 20,
            Geomancer = 21,
            RuneFencer = 22
        };

        /**
         * @brief Name Flag Type Enumeration
         */
        enum NameFlagType
        {
            FLAG_INEVENT = 0x00000002,
            FLAG_CHOCOBO = 0x00000040,
            FLAG_WALLHACK = 0x00000200,
            FLAG_INVITE = 0x00000800,
            FLAG_ANON = 0x00001000,
            FLAG_UNKNOWN = 0x00002000,
            FLAG_AWAY = 0x00004000,
            FLAG_PLAYONLINE = 0x00010000,
            FLAG_LINKSHELL = 0x00020000,
            FLAG_DC = 0x00040000,
            FLAG_GM = 0x04000000,
            FLAG_GM_SUPPORT = 0x04000000,
            FLAG_GM_SENIOR = 0x05000000,
            FLAG_GM_LEAD = 0x06000000,
            FLAG_GM_PRODUCER = 0x07000000,
            FLAG_BAZAAR = 0x80000000,
        };

        /**
         * @brief Skill Type Enumeration
         */
        enum SkillType
        {
            // Weapon Skills
            HandToHand = 1,
            Dagger = 2,
            Sword = 3,
            GreatSword = 4,
            Axe = 5,
            GreatAxe = 6,
            Scythe = 7,
            Polarm = 8,
            Katana = 9,
            GreatKatana = 10,
            Club = 11,
            Staff = 12,

            // Combat Skills
            Archery = 25,
            Marksmanship = 26,
            Throwing = 27,
            Guard = 28,
            Evasion = 29,
            Shield = 30,
            Parry = 31,
            Divine = 32,
            Healing = 33,
            Enhancing = 34,
            Enfeebling = 35,
            Elemental = 36,
            Dark = 37,
            Summoning = 38,
            Ninjitsu = 39,
            Singing = 40,
            String = 41,
            Wind = 42,
            BlueMagic = 43,

            // Crafting Skills
            Fishing = 48,
            Woodworking = 49,
            Smithing = 50,
            Goldsmithing = 51,
            Clothcraft = 52,
            Leathercraft = 53,
            Bonecraft = 54,
            Alchemy = 55,
            Cooking = 56,
            Synergy = 57,

            ChocoboDigging = 58,
        };

        /**
         * @brief Storage Type Enumeration
         */
        enum StorageType : unsigned char
        {
            Inventory = 0,
            Safe = 1,
            Storage = 2,
            Temporary = 3,
            Locker = 4,
            Satchel = 5,
            Sack = 6,
            Case = 7,
            Wardrobe = 8,

            StorageMax = 9
        };
    };
};

#endif // __ASHITA_ADK_ENUMS_H_INCLUDED__
