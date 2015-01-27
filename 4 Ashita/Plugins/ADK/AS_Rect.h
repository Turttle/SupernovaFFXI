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

#ifndef __ASHITA_ADK_AS_RECT_H_INCLUDED__
#define __ASHITA_ADK_AS_RECT_H_INCLUDED__

#if defined (_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

#include <Windows.h>

namespace Ashita
{
    typedef struct _AS_RECT
    {
        int x, y, w, h;

        Ashita::_AS_RECT(void) : x(0), y(0), w(0), h(0)
        {
        }
        Ashita::_AS_RECT(int nX, int nY, int nW, int nH) : x(nX), y(nY), w(nW), h(nH)
        {
        }
        Ashita::_AS_RECT(const RECT& r) : x(r.left), y(r.top), w(r.right - r.left), h(r.bottom - r.top)
        {
        }

        RECT ToRECT(void) const
        {
            RECT r{ this->x, this->y, this->w - this->x, this->h - this->y };
            return r;
        }

        Ashita::_AS_RECT operator= (const Ashita::_AS_RECT& r)
        {
            this->x = r.x;
            this->y = r.y;
            this->w = r.w;
            this->h = r.h;
            return *this;
        }
        Ashita::_AS_RECT operator+ (const Ashita::_AS_RECT& r)
        {
            this->x += r.x;
            this->y += r.y;
            this->w += r.w;
            this->h += r.h;
            return *this;
        }
        Ashita::_AS_RECT operator- (const Ashita::_AS_RECT& r)
        {
            this->x -= r.x;
            this->y -= r.y;
            this->w -= r.w;
            this->h -= r.h;
            return *this;
        }
        bool operator== (const Ashita::_AS_RECT& r)
        {
            return (this->x == r.x &&
                this->y == r.y &&
                this->w == r.w &&
                this->h == r.h);
        }
        bool operator!= (const Ashita::_AS_RECT& r)
        {
            return !(*this == r);
        }
    } AS_RECT;

}; // namespace Ashita

#endif // __ASHITA_ADK_AS_RECT_H_INCLUDED__
