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

#ifndef __ASHITA_ADK_AS_REGISTRY_INCLUDED__
#define __ASHITA_ADK_AS_REGISTRY_INCLUDED__

#if defined (_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

#include <Windows.h>
#include <string>

namespace Ashita
{
    class Registry
    {
    public:
        /**
         * @brief Install Path Id Enumeration
         */
        enum InstallPathId
        {
            FinalFantasyXI = 0,
            TetraMaster = 1,
            FinalFantasyXITestClient = 2,
            PlayOnline = 3,

            MAX_INSTALL_ID = 3
        };

        /**
         * @brief Obtains the install path for the given SquareEnix object.
         *
         * @param langId            The language id to use for the registry key for PlayOnline.
         * @param dwBufferLength    The buffer length of the output buffer.
         * @param lpOutputBuffer    The output buffer to store the found path.
         * @param pathId            The game id to obtain the install path of.
         *
         * @return True on success, false otherwise.
         */
        static bool GetInstallPath(int langId, DWORD dwBufferLength, LPSTR lpOutputBuffer, Ashita::Registry::InstallPathId pathId)
        {
            // Validation checks..
            if (langId < 0 || langId > Ashita::Registry::InstallPathId::MAX_INSTALL_ID || lpOutputBuffer == NULL || dwBufferLength == 0)
                return false;

            const char szLanguageTags[5][255] = { { "US" }, { "" }, { "US" }, { "EU" }, { "EU" } };
            const char szInstallFolder[4][255] = { { "0001" }, { "0002" }, { "0015" }, { "1000" } };

            char szRegistryPath[MAX_PATH] = { 0 };
            sprintf_s(szRegistryPath, MAX_PATH, "SOFTWARE\\PlayOnline%s\\InstallFolder", szLanguageTags[langId]);

            HKEY hKey = NULL;
            if (!(::RegOpenKeyExA(HKEY_LOCAL_MACHINE, szRegistryPath, 0, KEY_QUERY_VALUE | KEY_WOW64_32KEY, &hKey) == ERROR_SUCCESS))
                return false;

            char szInstallPath[MAX_PATH] = { 0 };
            DWORD dwSize = MAX_PATH;
            DWORD dwType = REG_DWORD;
            if (!(::RegQueryValueExA(hKey, szInstallFolder[pathId], NULL, &dwType, (LPBYTE)szInstallPath, &dwSize) == ERROR_SUCCESS))
            {
                ::RegCloseKey(hKey);
                return false;
            }

            ::RegCloseKey(hKey);

            // Ensure our buffer is large enough..
            if (strlen(szInstallPath) > dwBufferLength)
                return false;

            memcpy_s(lpOutputBuffer, dwBufferLength, szInstallPath, dwSize);
            return true;
        }

        /**
         * @brief Sets a registery DWORD value within the PlayOnline key.
         *
         * @param langid            The language id to use for the registry key for PlayOnline.
         * @param parent            The inner parent where the key is located.
         * @param keyName           The key to set the value of.
         * @param value             The new value to set the registry key to.
         *
         * @return True on success, false otherwise.
         */
        static bool SetRegistryValue(int langId, const char* parent, const char* keyName, DWORD dwValue)
        {
            const char szLanguageTags[5][255] = { { "US" }, { "" }, { "US" }, { "EU" }, { "EU" } };

            char szRegistryPath[MAX_PATH] = { 0 };
            sprintf_s(szRegistryPath, MAX_PATH, "SOFTWARE\\PlayOnline%s\\", szLanguageTags[langId]);
            strcat_s(szRegistryPath, MAX_PATH, parent);

            HKEY hKey = NULL;
            if (!(::RegOpenKeyExA(HKEY_LOCAL_MACHINE, szRegistryPath, 0, KEY_WRITE | KEY_QUERY_VALUE | KEY_WOW64_32KEY, &hKey) == ERROR_SUCCESS))
                return false;

            auto ret = ::RegSetValueExA(hKey, keyName, NULL, REG_DWORD, (LPBYTE)&dwValue, sizeof(DWORD));
            RegCloseKey(hKey);

            return (ret == ERROR_SUCCESS);
        }
    };

}; // namespace Ashita

#endif // __ASHITA_ADK_AS_REGISTRY_INCLUDED__
