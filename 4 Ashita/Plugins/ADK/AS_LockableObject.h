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

#ifndef __ASHITA_ADK_AS_LOCKABLEOBJECT_INCLUDED__
#define __ASHITA_ADK_AS_LOCKABLEOBJECT_INCLUDED__

#if defined (_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

#include <Windows.h>

namespace Ashita
{
    namespace Threading
    {
        class AS_LockableObject
        {
            CRITICAL_SECTION m_CriticalSection;

            /**
             * @brief Disables the copy constructor.
             */
            AS_LockableObject(const AS_LockableObject& obj) = delete;

        public:
            /**
            * @brief Constructor
            */
            Ashita::Threading::AS_LockableObject(void)
            {
                ::InitializeCriticalSection(&this->m_CriticalSection);
            }

            /**
            * @brief Deconstructor
            */
            virtual Ashita::Threading::AS_LockableObject::~AS_LockableObject(void)
            {
                ::DeleteCriticalSection(&this->m_CriticalSection);
            }

        public:
            /**
            * @brief Locks the critical section of this object.
            */
            void Lock(void)
            {
                ::EnterCriticalSection(&this->m_CriticalSection);
            }

            /**
            * @brief Unlocks the critical section of this object.
            */
            void Unlock(void)
            {
                ::LeaveCriticalSection(&this->m_CriticalSection);
            }
        };

    }; // namespace Threading
}; // namespace Ashita

#endif // __ASHITA_ADK_AS_LOCKABLEOBJECT_INCLUDED__
