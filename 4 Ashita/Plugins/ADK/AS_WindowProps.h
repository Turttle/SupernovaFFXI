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

#ifndef __ASHITA_ADK_AS_WINDOWPROPS_INCLUDED__
#define __ASHITA_ADK_AS_WINDOWPROPS_INCLUDED__

#if defined (_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

#include <Windows.h>
#include "AS_RECT.h"

namespace Ashita
{
    typedef struct _AS_WINDOWPROPS
    {
        HWND Hwnd;
        DWORD Style;
        DWORD StyleEx;
        AS_RECT WindowRect;

        /**
         * @brief Constructors
         */
        Ashita::_AS_WINDOWPROPS(void) : Hwnd(NULL), Style(0), StyleEx(0)
        {
        }
        Ashita::_AS_WINDOWPROPS(HWND hWnd, DWORD dwStyle, DWORD dwStyleEx, int X, int Y, int nWidth, int nHeight)
        {
            this->Hwnd = hWnd;
            this->Style = dwStyle;
            this->StyleEx = dwStyleEx;
            this->WindowRect.x = X;
            this->WindowRect.y = Y;
            this->WindowRect.w = nWidth;
            this->WindowRect.h = nHeight;
        }

        /**
        * @brief Resets the window property values to their defaults.
        */
        void Reset(void)
        {
            this->Hwnd = NULL;
            this->Style = 0;
            this->StyleEx = 0;
            this->WindowRect.x = 0;
            this->WindowRect.y = 0;
            this->WindowRect.w = 0;
            this->WindowRect.h = 0;
        }
    } AS_WindowProps;

}; // namespace Ashita

#endif // __ASHITA_ADK_AS_WINDOWPROPS_INCLUDED__
