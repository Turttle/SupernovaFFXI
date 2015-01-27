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

#ifndef __ASHITA_ADK_AS_EVENT_INCLUDED__
#define __ASHITA_ADK_AS_EVENT_INCLUDED__

#if defined (_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

#include <Windows.h>

namespace Ashita
{
    namespace Threading
    {
        class AS_Event
        {
            HANDLE m_EventHandle;

        public:
            /**
             * @brief Constructor
             */
            Ashita::Threading::AS_Event(bool bManualReset = true)
            {
                this->m_EventHandle = ::CreateEvent(NULL, bManualReset, FALSE, NULL);
            }

            /**
             * @brief Deconstructor
             */
            virtual Ashita::Threading::AS_Event::~AS_Event(void)
            {
                if (this->m_EventHandle != NULL)
                    ::CloseHandle(this->m_EventHandle);
                this->m_EventHandle = NULL;
            }

        public:
            /**
             * @brief Resets this event.
             *
             * @return True on success, false otherwise.
             */
            bool Reset(void)
            {
                return (::ResetEvent(this->m_EventHandle) ? true : false);
            }

            /**
             * @brief Raises the event.
             *
             * @return True on success, false otherwise.
             */
            bool Raise(void)
            {
                return (::SetEvent(this->m_EventHandle) ? true : false);
            }

            /**
             * @brief Determines if this event is signaled.
             *
             * @return True if signaled, false otherwise.
             */
            bool IsSignaled(void)
            {
                return (::WaitForSingleObject(this->m_EventHandle, 0) == WAIT_OBJECT_0);
            }

            /**
             * @brief Waits for the event object with the given timeout.
             *
             * @param dwMilliseconds        The timeout to wait for the event.
             *
             * @return True on success, false on timeout.
             */
            bool WaitForEvent(DWORD dwMilliseconds)
            {
                return (::WaitForSingleObject(this->m_EventHandle, dwMilliseconds) == WAIT_OBJECT_0);
            }
        };

    }; // namespace Threading
}; // namespace Ashita

#endif // __ASHITA_ADK_AS_EVENT_INCLUDED__
