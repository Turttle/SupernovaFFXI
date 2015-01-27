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

#ifndef __ASHITA_ADK_TARGET_H_INCLUDED__
#define __ASHITA_ADK_TARGET_H_INCLUDED__

#if defined (_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

namespace Ashita
{
    namespace FFXI
    {
        /**
         * @brief Sub Target Structure
         */
        struct SubTarget
        {
            unsigned int    SubTargetIndex;
            unsigned int    SubTargetID;
            unsigned int    SubTargetEntity;
            unsigned int    SubTargetWarPtr;
            unsigned char   SubTargetVisibility;        // Flag that determines if the target window shows..
            unsigned char   Unknown0000;                // Unknown boolean..
            unsigned short  SubTargetMask;
            unsigned int    CurrentTargetIndex;
            unsigned int    CurrentTargetID;
            unsigned int    CurrentTargetEntity;
            unsigned int    CurrentTargetWarp;
            unsigned char   CurrentTargetVisibility;    // Flag that determines if the current target arrow is visible..
            unsigned char   Unknown0001;                // Unknown boolean..
            unsigned short  CurrentTargetMask;
            unsigned char   Unknown0002;
            unsigned char   LockedOn;                   // Boolean if we are locked on target..
            unsigned char   Unknown0003;                // Unknown boolean..
            unsigned char   SubTargetActive;            // Boolean if the sub-target is open..
            unsigned char   SubTargetDeactivate;        // When set to 01, will force-close the sub-target window..
            unsigned short  Unknown0004;                // Unknown boolean..
            unsigned char   Unknown0005;
            unsigned char   Unknown0006;
            unsigned char   Unknown0007;
            unsigned char   Unknown0008;
            unsigned char   Unknown0009;
            unsigned int    Unknown0010;                // Possibly sub-target spell flags.. (Changes based on spell type..)
            unsigned short  Unknown0011;
            unsigned short  Unknown0012;
            unsigned char   MenuOpened;                 // Set to 1 while a menu is open, 0 otherwise..
            unsigned char   Unknown0013;
            unsigned char   Unknown0014;                // Unknown, gets set to 0 or 1 randomly..
            unsigned char   Unknown0015;                // Unknown, gets set to 0..
        };

        /**
         * @brief Target Structure
         */
        struct Target
        {
            unsigned int    TargetVTablePtr;
            unsigned int    Unknown0000;        // Always 0..
            unsigned int    TargetWindowPtr;
            unsigned int    Unknown0001;
            unsigned char   Unknown0002;        // Always set to 1 when targeting..
            unsigned char   Unknown0003[3];     // Alignment data.. 
            unsigned char   Name[48];
            unsigned int    Unknown0004;        // Always set to 0 when targeting..
            unsigned int    Entity;             // Pointer to the target entity..
            unsigned short  FrameOffsetX;       // Target frame screen offset..
            unsigned short  FrameOffsetY;       // Target frame screen offset..
            unsigned int    IconPosition;       // Target icon position..
            unsigned int    Unknown0005;
            unsigned int    Unknown0006;
            unsigned int    Unknown0007;
            unsigned int    TargetID;
            unsigned char   HealthPercent;
            unsigned char   DeathFlag;          // Dims the health bar when target is dead..
            unsigned char   ReraiseFlag;        // Dims the health bar when target is reraising.. (Death flag must be set!)
            unsigned char   Unknown0008;
            unsigned int    Unknown0009;
            unsigned char   Unknown0010;        // Toggles 0 -> 1 when first targeting..
        };
    };
};

#endif // __ASHITA_ADK_TARGET_H_INCLUDED__
