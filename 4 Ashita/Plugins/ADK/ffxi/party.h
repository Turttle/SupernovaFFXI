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

#ifndef __ASHITA_ADK_PARTY_H_INCLUDED__
#define __ASHITA_ADK_PARTY_H_INCLUDED__

#if defined (_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

namespace Ashita
{
    namespace FFXI
    {
        /**
         * @brief Alliance Info Structure
         */
        struct AllianceInfo
        {
            int     AllianceLeaderID;   // Alliance leader id.
            int     Party0LeaderID;     // Main party leader.
            int     Party1LeaderID;     // Second party leader.
            int     Party2LeaderID;     // Third party leader.
            char    Party0Visible;      // Main party visible.
            char    Party1Visible;      // Second party visible.
            char    Party2Visible;      // Third party visible.
            char    Party0Count;        // Main party member count.
            char    Party1Count;        // Second party member count.
            char    Party2Count;        // Third party member count.
            char    Invited;            // Invited flag.
            char    Unknown;            // Unknown
        };

        /**
         * @brief Party Member Structure
         */
        struct PartyMember
        {
            AllianceInfo*   Alliance;       // Full alliance information.
            unsigned char   Index;          // Party member index.
            unsigned char   MemberNumber;   // Party member number.
            unsigned char   Name[18];       // Party member name.
            unsigned int    ID;             // Party member id.
            unsigned int    TargetIndex;    // Party member target index.
            unsigned int    Unknown0;       // Unknown
            unsigned int    CurrentHP;      // Party member hp.
            unsigned int    CurrentMP;      // Party member mp.
            unsigned int    CurrentTP;      // Party member tp.
            unsigned char   CurrentHPP;     // Party member hp percent.
            unsigned char   CurrentMPP;     // Party member mp percent.
            unsigned short  Zone;           // Party member zone id.
            unsigned int    Unknown1;       // Unknown
            unsigned int    FlagMask;       // Party member flags.
            unsigned char   Unknown2[49];   // Unknown
            unsigned char   MainJob;        // Party member main job id.
            unsigned char   MainJobLvl;     // Party member main job level.
            unsigned char   SubJob;         // Party member main job id.
            unsigned char   SubJobLvl;      // Party member main job level.
            unsigned char   Unknown3[3];    // Unknown
            unsigned int    IDDupe;         // Member id dupe.
            unsigned char   CurrentHPPDupe; // Member hp percent dupe.
            unsigned char   CurrentMPPDupe; // Member mp percent dupe.
            unsigned char   Active;         // Party member active flag.
            unsigned char   Unknown4;       // Unknown
        };
    };
};

#endif // __ASHITA_ADK_PARTY_H_INCLUDED__
