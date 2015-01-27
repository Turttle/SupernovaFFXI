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

#ifndef __ASHITA_ADK_INVENTORY_H_INCLUDED__
#define __ASHITA_ADK_INVENTORY_H_INCLUDED__

#if defined (_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

#include "enums.h"

namespace Ashita
{
    namespace FFXI
    {
        /**
         * @brief Storage item entry structure.
         */
        struct ItemEntry
        {
            unsigned short  Id;         // Id of this item.
            unsigned short  Index;      // Index of this item in the storage type.
            unsigned int    Count;      // Number of items in the stack.
            unsigned int    Flag;       // 5 = Equipped, 25 = Bazaar
            unsigned int    Price;      // Price if being sold.
            unsigned char   Extra[28];  // Weaponskill Points, Charges, etc.
        };

        /**
         * @brief Inventory array structure.
         */
        struct ItemArray
        {
            ItemEntry       Item[81];   // Total items in the specific storage..
        };

        /**
         * @brief Treasure pool item entry structure.
         */
        struct TreasureEntry
        {
            unsigned int    Flag;               // Item flags.
            unsigned int    ItemID;             // Item Id.
            unsigned int    Count;              // Item stack count.
            unsigned int    Unknown[9];         // Unknown
            unsigned int    Status;             // Item status.
            unsigned short  MyLot;              // Personal lot on item.
            unsigned short  WinningLot;         // Current winning lot.
            unsigned int    WinningEntityID;    // Winning entity id.
            unsigned int    WinningEntityIndex; // Winning entity index.
            unsigned int    Unknown0[4];        // Unknown
            unsigned int    TimeToLive;         // Time left in the pool.
            unsigned int    DropTime;           // Time item entered pool.
        };

        /**
         * @brief Equipment entry structure.
         */
        struct EquipmentEntry
        {
            unsigned int    Slot;       // Slot of the equipped item.
            unsigned int    ItemIndex;  // Item index in inventory.
        };

        /**
         * @brief Full inventory structure.
         */
        struct InventoryStruct
        {
            char            Unknown0000[0x98C0];
            ItemArray       Storage[Ashita::Enums::StorageType::StorageMax];
            char            Unknown0001[0x21C];
            TreasureEntry   TreasurePool[10];
            unsigned int    Unknown0002;//something to do with being in town maybe treasure related? 1 in town, 2 outside.
            unsigned char   Unknown0003;
            unsigned char   StorageMaxCapacity[Ashita::Enums::StorageType::StorageMax];
            unsigned short  StorageMaxCapacity1[Ashita::Enums::StorageType::StorageMax];
            unsigned char   Unknown0005[0x188];
            EquipmentEntry  Equipment[Ashita::Enums::EquipmentSlot::EquipmentMax];
            unsigned char   Unknown0006[0x240];//36 bytes each entry 16 entries
            unsigned char   Unknown0007[0xBC];
            unsigned int    CraftWait; //2 = crafting, 4 = wait to craft. set to 0 to override
            unsigned int    Unknown0008;
            unsigned int    Unknown0009;//something to do with crafting.
            unsigned int    Unknown0010;//something to do with crafting.
        };
    };
};

#endif // __ASHITA_ADK_INVENTORY_H_INCLUDED__
