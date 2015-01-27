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

#ifndef __ASHITA_ADK_AS_MEMORY_INCLUDED__
#define __ASHITA_ADK_AS_MEMORY_INCLUDED__

#if defined (_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

#include <Windows.h>

#pragma comment( lib, "psapi.lib" )
#include <Psapi.h>

namespace Ashita
{
    class Memory
    {
        /**
         * @brief Compares the given memory data against the given pattern using the desired mask.
         *
         * @param lpData            Pointer to the actual memory to be compared again.
         * @param lpPattern         Pointer to the pattern to scan the memory for.
         * @param pszMask           String containing the mask for the pattern being compared against.
         *
         * @return True when the pattern is found, false otherwise.
         */
        static bool __stdcall MaskCompare(const unsigned char* lpData, const unsigned char* lpPattern, const char* pszMask)
        {
            for (; *pszMask; ++pszMask, ++lpData, ++lpPattern)
                if (*pszMask == 'x' && *lpData != *lpPattern)
                    return false;
            return (*pszMask) == NULL;
        }

    public:
        /**
         * @brief Locates the given pattern inside the given modules memory space.
         *
         * @param pszModuleName     The module to scan within for the given pattern.
         * @param lpPattern         The pattern to compare the memory against.
         * @param pszMask           String containing the mask for the pattern being compared against.
         *
         * @return Location of where the pattern was found, 0 otherwise.
         */
        static DWORD __stdcall FindPattern(const char* pszModuleName, const unsigned char* lpPattern, const char* pszMask)
        {
            MODULEINFO mod = { 0 };
            if (!::GetModuleInformation(::GetCurrentProcess(), ::GetModuleHandleA(pszModuleName), &mod, sizeof(MODULEINFO)))
                return 0;

            auto dataPtr = (unsigned char*)mod.lpBaseOfDll;

            for (DWORD x = 0; x < mod.SizeOfImage; x++)
            {
                if (Ashita::Memory::MaskCompare(dataPtr + x, lpPattern, pszMask))
                    return (DWORD)(dataPtr + x);
            }

            return 0;
        }

        /**
         * @brief Determines the calling module based on the given return address.
         *
         * @param dwReturnAddress   The address being returned to from the call.
         *
         * @return Module base address on success, otherwise dwReturnAddress;
         */
        static HMODULE __stdcall GetCallingModule(DWORD dwReturnAddress)
        {
            if (dwReturnAddress != 0)
            {
                MEMORY_BASIC_INFORMATION mbi = { 0 };
                if (::VirtualQuery((LPCVOID)dwReturnAddress, &mbi, sizeof(MEMORY_BASIC_INFORMATION)) == sizeof(MEMORY_BASIC_INFORMATION))
                    return (HMODULE)mbi.AllocationBase;
            }
            return (HMODULE)dwReturnAddress;
        }
    };
}; // namespace Ashita

#endif // __ASHITA_ADK_AS_MEMORY_INCLUDED__
