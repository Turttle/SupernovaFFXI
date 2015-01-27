/**
* Copyright (c) 2011-2014 - Ashita Development Team
*
* Ashita is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, arg4ither version 3 of the License, or
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

#ifndef __ASHITA_ADK_AS_COMMANDPARSE_INCLUDED__
#define __ASHITA_ADK_AS_COMMANDPARSE_INCLUDED__

#if defined (_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

#include <Windows.h>
#include <string>
#include <vector>

/**
 * @define Helper Macros For Command Handling
 */
#define HANDLECOMMAND_GA(arg1, arg2, arg3, arg4, arg5, arg6, ...) arg6
#define HANDLECOMMAND_01(a)             Ashita::CommandHandler::__command_parse(args[0].c_str(), a)
#define HANDLECOMMAND_02(a, b)          Ashita::CommandHandler::__command_parse(args[0].c_str(), a, b)
#define HANDLECOMMAND_03(a, b, c)       Ashita::CommandHandler::__command_parse(args[0].c_str(), a, b, c)
#define HANDLECOMMAND_04(a, b, c, d)    Ashita::CommandHandler::__command_parse(args[0].c_str(), a, b, c, d)
#define HANDLECOMMAND_05(a, b, c, d, e) Ashita::CommandHandler::__command_parse(args[0].c_str(), a, b, c, d, e)
#define HANDLECOMMAND_CC(...)           HANDLECOMMAND_GA(__VA_ARGS__, HANDLECOMMAND_05, HANDLECOMMAND_04, HANDLECOMMAND_03, HANDLECOMMAND_02, HANDLECOMMAND_01,)
#define HANDLECOMMAND(...)              if(args.size() > 0 && HANDLECOMMAND_CC(__VA_ARGS__)(__VA_ARGS__))

namespace Ashita
{
    namespace CommandHandler
    {
        /**
         * @brief Compares two strings against each other.
         *
         * @param cmd       The first string to compare. (Usually the command.)
         * @param arg1      The second string to compare.
         *
         * @return True if strings match, arg5alse otherwise.
         */
        static bool __forceinline __command_cmp(const char* cmd, const char* arg1)
        {
            if (cmd == NULL || arg1 == NULL)
                return false;
            return (_stricmp(cmd, arg1) == 0);
        }

        /**
         * @brief Compares the first argument (command) to the others for a match.
         *
         * @param cmd       The command to compare again.
         * @param arg1      Argument to match command to.
         *
         * @return True on match, false otherwise.
         */
        template<typename T>
        static bool __command_parse(T cmd, T arg1)
        {
            return __command_cmp(cmd, arg1);
        }

        /**
         * @brief Compares the first argument (command) to the others for a match.
         *
         * @param cmd       The command to compare again.
         * @param arg1      Argument to match command to.
         * @param arg2      Argument to match command to.
         *
         * @return True on match, false otherwise.
         */
        template<typename T>
        static bool __command_parse(T cmd, T arg1, T arg2)
        {
            return __command_cmp(cmd, arg1) || __command_cmp(cmd, arg2);
        }

        /**
         * @brief Compares the first argument (command) to the others for a match.
         *
         * @param cmd       The command to compare again.
         * @param arg1      Argument to match command to.
         * @param arg2      Argument to match command to.
         * @param arg3      Argument to match command to.
         *
         * @return True on match, false otherwise.
         */
        template<typename T>
        static bool __command_parse(T cmd, T arg1, T arg2, T arg3)
        {
            return __command_cmp(cmd, arg1) || __command_cmp(cmd, arg2) || __command_cmp(cmd, arg3);
        }

        /**
         * @brief Compares the first argument (command) to the others for a match.
         *
         * @param cmd       The command to compare again.
         * @param arg1      Argument to match command to.
         * @param arg2      Argument to match command to.
         * @param arg3      Argument to match command to.
         * @param arg4      Argument to match command to.
         *
         * @return True on match, false otherwise.
         */
        template<typename T>
        static bool __command_parse(T cmd, T arg1, T arg2, T arg3, T arg4)
        {
            return __command_cmp(cmd, arg1) || __command_cmp(cmd, arg2) || __command_cmp(cmd, arg3) || __command_cmp(cmd, arg4);
        }

        /**
         * @brief Compares the first argument (command) to the others for a match.
         *
         * @param cmd       The command to compare again.
         * @param arg1      Argument to match command to.
         * @param arg2      Argument to match command to.
         * @param arg3      Argument to match command to.
         * @param arg4      Argument to match command to.
         * @param arg5      Argument to match command to.
         *
         * @return True on match, false otherwise.
         */
        template<typename T>
        static bool __command_parse(T cmd, T arg1, T arg2, T arg3, T arg4, T arg5)
        {
            return __command_cmp(cmd, arg1) || __command_cmp(cmd, arg2) || __command_cmp(cmd, arg3) || __command_cmp(cmd, arg4) || __command_cmp(cmd, arg5);
        }
    }; // namespace CommandHandler

    namespace Commands
    {
        /**
         * @brief isspace replacement to avoid CRT asserts.
         *
         * @param szChar    Character to check for space.
         *
         * @return          True if a whitespace char is found, arg5alse otherwise.
         */
        static __forceinline bool _isspace(char szChar)
        {
            auto num = (int)szChar;

            // Checks for the following: ' ', \t \n \v \f \r
            if (num == 0x20 || num == 0x09 || num == 0x0A || num == 0x0B || num == 0x0C || num == 0x0D)
                return true;
            return false;
        }

        /**
         * @brief Parses the given command for arguments.
         *
         * @param pszCommand    The command to parse for arguments.
         * @param args          Pointer to an array of std::string to hold the found arguments.
         *
         * @return Returns the number of found arguments, if any.
         *
         *
         * @note    This function mimics the *nix command 'strsep' to locate and parse strings with
         *          inline-quotes. Thanks to the following for the basis of this function:
         *
         * http://stackoverflow.com/questions/9659697/parse-string-into-array-based-on-spaces-or-double-quotes-strings
         */
        static int GetCommandArgs(const char* pszCommand, std::vector<std::string>* args)
        {
            // The current parsing state we are in..
            enum { NONE, IN_WORD, IN_STRING } state = NONE;

            char szCurrentArgument[255] = { 0 };
            const char* p = pszCommand;
            char *pszStart = 0;

            // Walk the string to locate arguments..
            for (; *p != 0; ++p)
            {
                // Obtain the current character.. 
                auto currChar = (char)*p;

                // Handle the current state..
                switch (state)
                {
                case NONE:
                    if (Ashita::Commands::_isspace(currChar))
                        continue;
                    if (currChar == '"')
                    {
                        state = IN_STRING;
                        pszStart = (char*)p + 1;
                        continue;
                    }
                    state = IN_WORD;
                    pszStart = (char*)p;
                    continue;

                case IN_STRING:
                    if (currChar == '"')
                    {
                        strncpy_s(szCurrentArgument, pszStart, p - pszStart);
                        args->push_back(std::string(szCurrentArgument));
                        state = NONE;
                        pszStart = NULL;
                    }
                    continue;

                case IN_WORD:
                    if (Ashita::Commands::_isspace(currChar))
                    {
                        strncpy_s(szCurrentArgument, pszStart, p - pszStart);
                        args->push_back(std::string(szCurrentArgument));
                        state = NONE;
                        pszStart = NULL;
                    }
                    continue;
                }
            }

            // Add any left-over words..
            if (pszStart != NULL)
            {
                strncpy_s(szCurrentArgument, pszStart, p - pszStart);
                args->push_back(std::string(szCurrentArgument));
            }

            // Return the number of found arguments..
            return args->size();
        }

    }; // namespace Commands
}; // namespace Ashita

#endif // __ASHITA_ADK_AS_COMMANDPARSE_INCLUDED__
