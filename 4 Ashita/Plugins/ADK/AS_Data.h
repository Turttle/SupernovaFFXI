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

#ifndef __ASHITA_ADK_AS_DATA_INCLUDED__
#define __ASHITA_ADK_AS_DATA_INCLUDED__

#if defined (_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

#include <Windows.h>

namespace Ashita
{
    class Data
    {
    public:
        /**
         * @brief Packs bits into the given target. (Big Endian)
         */
        static unsigned int packBitsBE(unsigned char* target, unsigned __int64 value, int bitOffset, unsigned char lengthInBit)
        {
            return packBitsBE(target, value, 0, bitOffset, lengthInBit);
        }

        /**
         * @brief Packs bits into the given target. (Big Endian)
         */
        static unsigned int packBitsBE(unsigned char* target, unsigned __int64 value, int byteOffset, int bitOffset, unsigned char lengthInBit)
        {
            byteOffset += (bitOffset >> 3);
            bitOffset %= 8;

            unsigned __int64 bitmask = 0xFFFFFFFFFFFFFFFFLL;
            bitmask >>= (64 - lengthInBit);
            bitmask <<= bitOffset;
            value <<= bitOffset;
            value &= bitmask;
            bitmask ^= 0xFFFFFFFFFFFFFFFFLL;

            if ((lengthInBit + bitOffset) <= 8)
            {
                unsigned char* dataPointer = (unsigned char*)&target[byteOffset];
                unsigned char bitmaskUC = (unsigned char)bitmask;
                unsigned char valueUC = (unsigned char)value;

                *dataPointer &= bitmaskUC;
                *dataPointer |= valueUC;
            }
            else if ((lengthInBit + bitOffset) <= 16)
            {
                unsigned short* dataPointer = (unsigned short*)&target[byteOffset];
                unsigned short bitmaskUC = (unsigned short)bitmask;
                unsigned short valueUC = (unsigned short)value;

                *dataPointer &= bitmaskUC;
                *dataPointer |= valueUC;
            }
            else if ((lengthInBit + bitOffset) <= 32)
            {
                unsigned int* dataPointer = (unsigned int*)&target[byteOffset];
                unsigned int bitmaskUC = (unsigned int)bitmask;
                unsigned int valueUC = (unsigned int)value;

                *dataPointer &= bitmaskUC;
                *dataPointer |= valueUC;
            }
            else if ((lengthInBit + bitOffset) <= 64)
            {
                unsigned __int64* dataPointer = (unsigned __int64*)&target[byteOffset];

                *dataPointer &= bitmask;
                *dataPointer |= value;
            }
            else
            {
                // We should not get here.. an error occurred..
                // Target size > 64bits
            }
            return ((byteOffset << 3) + bitOffset + lengthInBit);
        }

        /**
         * @brief Unpacks bits from the given target. (Big Endian)
         */
        static unsigned __int64 unpackBitsBE(unsigned char* target, int bitOffset, unsigned char lengthInBit)
        {
            return unpackBitsBE(target, 0, bitOffset, lengthInBit);
        }

        /**
         * @brief Unpacks bits from the given target. (Big Endian)
         */
        static unsigned __int64 unpackBitsBE(unsigned char* target, int byteOffset, int bitOffset, unsigned char lengthInBit)
        {
            byteOffset += (bitOffset >> 3);
            bitOffset %= 8;

            unsigned __int64 bitmask = 0xFFFFFFFFFFFFFFFFLL;
            bitmask >>= (64 - lengthInBit);
            bitmask <<= bitOffset;

            unsigned __int64 retVal = 0;

            if ((lengthInBit + bitOffset) <= 8)
            {
                unsigned char* dataPointer = (unsigned char*)&target[byteOffset];

                retVal = ((*dataPointer)&(unsigned char)bitmask) >> bitOffset;
            }
            else if ((lengthInBit + bitOffset) <= 16)
            {
                unsigned short* dataPointer = (unsigned short*)&target[byteOffset];

                retVal = ((*dataPointer)&(unsigned short)bitmask) >> bitOffset;
            }
            else if ((lengthInBit + bitOffset) <= 32)
            {
                unsigned int* dataPointer = (unsigned int*)&target[byteOffset];

                retVal = ((*dataPointer)&(unsigned int)bitmask) >> bitOffset;
            }
            else if ((lengthInBit + bitOffset) <= 64)
            {
                unsigned __int64* dataPointer = (unsigned __int64*)&target[byteOffset];

                retVal = ((*dataPointer)&(unsigned __int64)bitmask) >> bitOffset;
            }
            else
            {
                // We should not get here.. an error occurred..
                // Target size > 64bits
                return 0;
            }
            return retVal;
        }

        /**
         * @brief Packs bits into the given target. (Little Endian)
         */
        static unsigned int packBitsLE(unsigned char* target, unsigned __int64 value, int bitOffset, unsigned char lengthInBit)
        {
            return packBitsLE(target, value, 0, bitOffset, lengthInBit);
        }

        /**
         * @brief Packs bits into the given target. (Little Endian)
         */
        static unsigned int packBitsLE(unsigned char* target, unsigned __int64 value, int byteOffset, int bitOffset, unsigned char lengthInBit)
        {
            byteOffset += (bitOffset >> 3);
            bitOffset %= 8;

            unsigned char bytesNeeded;
            if ((bitOffset + lengthInBit) <= 8)
                bytesNeeded = 1;
            else if ((bitOffset + lengthInBit) <= 16)
                bytesNeeded = 2;
            else if ((bitOffset + lengthInBit) <= 32)
                bytesNeeded = 4;
            else if ((bitOffset + lengthInBit) <= 64)
                bytesNeeded = 8;
            else
            {
                // We should not get here.. an error occurred..
                // Target size > 64bits
                return 0;
            }

            unsigned char* modifiedTarget = new unsigned char[bytesNeeded];
            for (unsigned char curByte = 0; curByte < bytesNeeded; ++curByte)
            {
                modifiedTarget[curByte] = target[byteOffset + (bytesNeeded - 1) - curByte];
            }

            int newBitOffset = (bytesNeeded << 3) - (bitOffset + lengthInBit);
            packBitsBE(&modifiedTarget[0], value, 0, newBitOffset, lengthInBit);

            for (unsigned char curByte = 0; curByte < bytesNeeded; ++curByte)
            {
                target[byteOffset + (bytesNeeded - 1) - curByte] = modifiedTarget[curByte];
            }

            if (modifiedTarget) delete[] modifiedTarget;
            return ((byteOffset << 3) + bitOffset + lengthInBit);
        }

        /**
         * @brief Unpacks bits into the given target. (Little Endian)
         */
        static unsigned __int64 unpackBitsLE(unsigned char* target, int bitOffset, unsigned char lengthInBit)
        {
            return unpackBitsLE(target, 0, bitOffset, lengthInBit);
        }

        /**
         * @brief Unpacks bits into the given target. (Little Endian)
         */
        static unsigned __int64 unpackBitsLE(unsigned char* target, int byteOffset, int bitOffset, unsigned char lengthInBit)
        {
            byteOffset += (bitOffset >> 3);
            bitOffset %= 8;

            unsigned char bytesNeeded;
            if ((bitOffset + lengthInBit) <= 8)
                bytesNeeded = 1;
            else if ((bitOffset + lengthInBit) <= 16)
                bytesNeeded = 2;
            else if ((bitOffset + lengthInBit) <= 32)
                bytesNeeded = 4;
            else if ((bitOffset + lengthInBit) <= 64)
                bytesNeeded = 8;
            else
            {
                // We should not get here.. an error occurred..
                // Target size > 64bits
                return 0;
            }

            unsigned __int64 retVal = 0;
            unsigned char* modifiedTarget = new unsigned char[bytesNeeded];

            for (unsigned char curByte = 0; curByte < bytesNeeded; ++curByte)
            {
                modifiedTarget[curByte] = target[byteOffset + (bytesNeeded - 1) - curByte];
            }

            if (bytesNeeded == 1)
            {
                unsigned char bitmask = 0xFF >> bitOffset;
                retVal = (modifiedTarget[0] & bitmask) >> (8 - (lengthInBit + bitOffset));
            }
            else
            {
                int newBitOffset = (bytesNeeded * 8) - (bitOffset + lengthInBit);
                retVal = unpackBitsBE(&modifiedTarget[0], 0, newBitOffset, lengthInBit);
            }

            if (modifiedTarget) delete[]modifiedTarget;
            return retVal;
        }
    };
}; // namespace Ashita

#endif // __ASHITA_ADK_AS_DATA_INCLUDED__
