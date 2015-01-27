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

#ifndef __ASHITA_ADK_ENTITY_H_INCLUDED__
#define __ASHITA_ADK_ENTITY_H_INCLUDED__

#if defined (_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

namespace Ashita
{
    namespace FFXI
    {
        /**
         * @brief Entity Position Structure
         */
        struct EntityPosition
        {
            float X;
            float Y;
            float Z;
            float Unknown0001;
            float Roll;
            float Yaw; // Heading
            float Pitch;

            bool operator==(const EntityPosition &pos)
            {
                return ((this->X == pos.X) && (this->Y == pos.Y) && (this->Z == pos.Z));
            }

            bool operator!=(const EntityPosition &pos)
            {
                return !(this == &pos);
            }
        };

        /**
         * @brief Entity Move Structure
         */
        struct EntityMove
        {
            float X;
            float Y;
            float Z;
            float Unknown0001;

            bool operator==(const EntityMove &pos)
            {
                return ((this->X == pos.X) && (this->Y == pos.Y) && (this->Z == pos.Z));
            }

            bool operator!=(const EntityMove &pos)
            {
                return !(this == &pos);
            }
        };

        /**
         * @brief Entity Movement Structure
         */
        struct EntityMovement
        {
            EntityPosition LocalPosition;
            float Unknown0001;
            EntityPosition LastPosition;
            unsigned int Unknown0002;
            EntityMove Move;
        };

        /**
         * @brief Entity Look Structure
         */
        struct EntityLook
        {
            unsigned short Face;
            unsigned short Head;
            unsigned short Body;
            unsigned short Hands;
            unsigned short Legs;
            unsigned short Feet;
            unsigned short Main;
            unsigned short Sub;
            unsigned short Ranged;
        };

        /**
         * @brief Entity Render Structure
         */
        struct EntityRender
        {
            unsigned int RenderFlag0000; // Main Entity Rendering Flag..
            unsigned int RenderFlag0001; // Name Flags.. (Party, Away, Anon, etc.)
            unsigned int RenderFlag0002; // Name flags.. (Bazaar, GM icon, etc.)
            unsigned int RenderFlag0003; // Entity shadow..
            unsigned int RenderFlag0004; // Name visibility..
        };

        /**
         * @brief Entity Animation Structure
         */
        struct EntityAnimation
        {
            unsigned char Animation1[4];
            unsigned char Animation2[4];
            unsigned char Animation3[4];
            unsigned char Animation4[4];
            unsigned char Animation5[4];
            unsigned char Animation6[4];
            unsigned char Animation7[4];
            unsigned char Animation8[4];
            unsigned char Animation9[4];
            unsigned char Animation10[4];
        };

        /**
         * @brief Entity Look Structure
         */
#pragma pack(push, 1)
        struct Entity
        {
            unsigned int    EntityVTablePtr; // CYyObject
            EntityMovement  Movement;
            unsigned char   Unknown0000[28];
            unsigned int    UnknownVTablePtr;
            unsigned int    TargetID;
            unsigned int    ServerID;
            unsigned char   Name[28];
            float           MovementSpeed;
            float           AnimationSpeed;
            unsigned int    WarpPtr;
            unsigned int    Unknown0001;
            unsigned int    Unknown0002;
            unsigned int    Unknown0003[9];
            float           Distance;
            unsigned int    Unknown0004;        // 0x64
            unsigned int    Unknown0005;        // 0x64
            float           Heading;            // Yaw
            unsigned int    PetOwnerID;
            unsigned int    PetTP;
            unsigned char   HealthPercent;
            unsigned char   Unknown0006;
            unsigned char   Unknown0007;
            unsigned char   Type;
            unsigned char   Race;
            unsigned char   Unknown0008;
            unsigned short  Unknown0009;        // Some type of timer..
            unsigned short  Unknown0010;        // Deals with model update..
            unsigned char   ModelFade;          // Updates the entity model. (Blinking)
            unsigned char   Unknown0013[9];
            EntityLook      Look;
            unsigned char   Unknown0014[14];
            unsigned short  ActionWaitTimer1;
            unsigned short  ActionWaitTimer2;
            EntityRender    Render;
            float           Unknown0015;        // Deals with fishing..
            unsigned int    Unknown0016;        // Fade-in effect (Valid values: 3, 6)
            unsigned short  Unknown0017;        // Fade-in misc (-1 gets reset to 0)
            unsigned int    Unknown0018;
            unsigned short  NpcSpeechLoop;
            unsigned short  NpcSpeechFrame;
            unsigned char   Unknown0019[14];
            float           MovementSpeed2;
            unsigned short  NpcWalkPos1;
            unsigned short  NpcWalkPos2;
            unsigned short  NpcWalkMode;
            unsigned short  CostumeID;
            unsigned char   mou4[4];            // Always 'mou4'..
            unsigned int    Status;
            unsigned int    StatusServer;
            unsigned int    StatusNpcChat;      // Only used while talking with npc..
            unsigned int    Unknown0020;
            unsigned int    Unknown0021;
            unsigned int    Unknown0022;
            unsigned int    Unknown0023;
            unsigned int    ClaimID;            // Entity ID that has current claim (or last claim)..
            unsigned int    Unknown0025;        // Has something to do with inventory..
            EntityAnimation Animations;         // Animation strings.. idl, sil, wlk, etc..
            unsigned short  AnimationTick;      // Current ticks of the animation..
            unsigned short  AnimationStep;      // Current step of the animation..
            unsigned char   AnimationPlay;      // 6 stand/sit, 12 play current emote..
            unsigned char   Unknown0026;        // Something with animations..
            unsigned short  Unknown0027;        // Something with animations..
            unsigned short  Unknown0028;        // Something with animations..
            unsigned short  Unknown0029;        // Does nothing..
            unsigned int    EmoteID;            // Emote string..
            unsigned int    SpawnFlags;         // 0x0001 PC, 0x0002 NPC, 0x0010 Mob, 0x000D Self
            unsigned int    LinkshellColor;
            unsigned short  NameColor;          // Sets the players name color..
            unsigned short  CampaignNameFlag;   // Usually 0x4000, otherwise any value in the low-byte sets campaign flag..
            unsigned short  FishingTimer;       // Counts down from when you click 'fish' to either catch or real in..
            unsigned short  FishingCastTimer;   // Counts down fromw when you click 'fish' til your bait hits the water..
            unsigned int    FishingUnknown0001; // Gets set to 1800 when you hook a fish.. then unknown afterward..
            unsigned int    FishingUnknown0002; // Gets read when you first cast your rod..
            unsigned short  FishingUnknown0003; // Gets set when you first cast your rod..
            unsigned char   Unknown0030[14];
            unsigned short  TargetIndex;        // The players target's index.
            unsigned short  PetIndex;
            unsigned short  Unknown0031;        // Countdown after talking with an npc.
            unsigned char   Unknown0032;        // Flag after talkign with an npc.
            unsigned char   BallistaScoreFlag;  // Deals with Ballista / PvP, shows game information..
            unsigned char   PankrationEnabled;  // Displays the Pankration score flags.
            unsigned char   PankrationFlagFlip; // Determines which side each flag is on.
            unsigned short  Unknown0036;        // Deals with current action..
            float           ModelSize;          // Entity model size..
            unsigned int    Unknown0037;
            unsigned short  MonstrosityFlag;    // 01 Sets the entity name to a status icon of a black cat..    
            unsigned short  Unknown0038;
            unsigned char   MonstrosityName[36];
        };
#pragma pack(pop)
    };
};

#endif // __ASHITA_ADK_ENTITY_H_INCLUDED__