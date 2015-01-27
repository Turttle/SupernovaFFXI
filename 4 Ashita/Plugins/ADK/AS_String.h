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

#ifndef __ASHITA_ADK_AS_STRING_INCLUDED__
#define __ASHITA_ADK_AS_STRING_INCLUDED__

#if defined (_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

#include <Windows.h>
#include <string>
#include <sstream>
#include <vector>

namespace Ashita
{
    namespace Encoding
    {
        /**
         * @brief Converts the incoming wide string to ascii.
         *
         * @param input         The incoming unicode string.
         *
         * @return The converted string object.
         */
        static std::string ToAscii(const std::wstring& input)
        {
            std::string str(input.begin(), input.end());
            return str;
        }

        /**
         * @brief Converts the incoming wide string to ascii.
         *
         * @param input         The incoming unicode string.
         *
         * @return The converted string object.
         */
        static std::wstring ToUnicode(const std::string& input)
        {
            std::wstring str(input.begin(), input.end());
            return str;
        }

    }; // namespace Encoding

    class AS_String
    {
        std::wstring m_BaseString;

        /**
         * @brief Obtains the raw string internally.
         *
         * @return The raw base string.
         */
        const std::wstring raw(void) const
        {
            return this->m_BaseString;
        }

    public:
        /**
         * @brief Constructors
         */
        AS_String(void)
            : m_BaseString(L"")
        { }
        AS_String(const char* pszString)
            : m_BaseString(Ashita::Encoding::ToUnicode(pszString))
        { }
        AS_String(const wchar_t* pszString)
            : m_BaseString(pszString)
        { }
        AS_String(const std::string& str)
            : m_BaseString(Ashita::Encoding::ToUnicode(str))
        { }
        AS_String(const std::wstring& str)
            : m_BaseString(str)
        { }

    public:
        /**
         * @brief Returns the base string.
         *
         * @return The base unicode string of this object.
         */
        std::wstring unicode(void) const
        {
            return this->m_BaseString;
        }

        /**
         * @brief Returns the base string as ascii.
         *
         * @return The base string of this object converted to ascii.
         */
        std::string ascii(void) const
        {
            return Ashita::Encoding::ToAscii(this->m_BaseString);
        }

        /**
         * @brief Returns the base strings length.
         *
         * @return The length of the base string.
         */
        size_t length(void)
        {
            return this->m_BaseString.length();
        }

    public:
        /**
         * @brief Assignment operators.
         */
        void operator= (const std::string& str)
        {
            this->m_BaseString = Ashita::Encoding::ToUnicode(str);
        }
        void operator= (const std::wstring& str)
        {
            this->m_BaseString = str;
        }
        void operator= (const char* pszStr)
        {
            this->m_BaseString = Ashita::Encoding::ToUnicode(pszStr);
        }
        void operator= (const wchar_t* pszStr)
        {
            this->m_BaseString = pszStr;
        }

    public:
        /**
         * @brief Equality operators.
         */
        bool operator== (const Ashita::AS_String& str)
        {
            return (str.raw() == this->m_BaseString);
        }
        bool operator== (const std::string& str)
        {
            Ashita::AS_String temp(str);
            return (temp == this->m_BaseString);
        }
        bool operator== (const std::wstring& str)
        {
            return (wcscmp(str.c_str(), this->m_BaseString.c_str()) == 0);
        }
        bool operator!= (const Ashita::AS_String& str)
        {
            return (str.raw() != this->m_BaseString);
        }
        bool operator!= (const std::string& str)
        {
            Ashita::AS_String temp(str);
            return (temp != this->m_BaseString);
        }
        bool operator!= (const std::wstring& str)
        {
            Ashita::AS_String temp(str);
            return (temp != this->m_BaseString);
        }

    public:
        /**
         * @brief Addition (assigment) operators.
         */
        Ashita::AS_String operator+ (const Ashita::AS_String& str)
        {
            return Ashita::AS_String(this->m_BaseString + str.raw());
        }
        Ashita::AS_String operator+= (const Ashita::AS_String& str)
        {
            this->m_BaseString.append(str.raw());
            return *this;
        }

    public:
        /**
         * @brief Stream operators.
         */
        friend std::ostream& operator<< (std::ostream& out, Ashita::AS_String& str)
        {
            out << Ashita::Encoding::ToAscii(str.raw());
            return out;
        }
        friend std::wostream& operator<< (std::wostream& out, Ashita::AS_String& str)
        {
            out << str.raw();
            return out;
        }

    public:
        /**
         * @brief Splits a string based on the given delimiter.
         *
         * @param delim         The delimiter to split the string with.
         *
         * @return A vector of found parts split from the string.
         */
        std::vector<AS_String> split(wchar_t delim)
        {
            std::vector<AS_String> parts;
            std::wstringstream ss(this->m_BaseString);

            std::wstring item;
            while (std::getline(ss, item, delim))
                parts.push_back(item);

            return parts;
        }
    };

}; // namespace Ashita

#endif // __ASHITA_ADK_AS_STRING_INCLUDED__
