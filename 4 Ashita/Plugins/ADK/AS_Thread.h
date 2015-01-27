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

#ifndef __ASHITA_ADK_AS_THREAD_INCLUDED__
#define __ASHITA_ADK_AS_THREAD_INCLUDED__

#if defined (_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

#include <Windows.h>
#include "AS_Event.h"

namespace Ashita
{
    namespace Threading
    {
        /**
         * @brief Thread Priority Enumeration
         */
        enum ThreadPriorty
        {
            Lowest = -2,
            BelowNormal = -1,
            Normal = 0,
            AboveNormal = 1,
            Highest = 2
        };

        class AS_Thread
        {
            HANDLE      m_ThreadHandle; // The thread handle of this object.
            DWORD       m_ThreadId;     // The thread id of this object.
            AS_Event    m_StartEvent;   // The starting event of this thread.
            AS_Event    m_EndEvent;     // The ending event of this thread.

        public:
            /**
            * @brief Constructor
            */
            Ashita::Threading::AS_Thread(void)
                : m_ThreadHandle(NULL), m_ThreadId(0), m_StartEvent(true), m_EndEvent(true)
            { }

            /**
            * @brief Deconstructor
            */
            virtual Ashita::Threading::AS_Thread::~AS_Thread(void)
            {
                if (this->m_ThreadHandle != NULL)
                    this->Stop();
            }

        public:
            /**
             * @brief Virtual thread entry point to be overriden.
             */
            virtual DWORD AS_ThreadEntry(void) = 0;

            /**
             * @brief Internal thread entry point to be invoked.
             */
            DWORD InternalEntry(void)
            {
                // Ensure we are valid..
                if (this->IsTerminated())
                    return 0;

                // Adjust events accordingly..
                this->m_EndEvent.Reset();
                ::Sleep(10);
                this->m_StartEvent.Raise();

                // Call the real entry point..
                return this->AS_ThreadEntry();
            }

            /**
             * @brief Starts this thread object.
             */
            void Start(void)
            {
                // Start the thread..
                this->m_StartEvent.Reset();
                this->m_ThreadHandle = CreateThread(NULL, NULL, ThreadCallback, (LPVOID)this, NULL, &this->m_ThreadId);
            }

            /**
             * @brief Stops this thread object.
             */
            void Stop(void)
            {
                // Stop the thread..
                this->RaiseEnd();

                if (this->WaitForFinish(INFINITE))
                {
                    ::CloseHandle(this->m_ThreadHandle);
                    this->m_ThreadHandle = NULL;
                    this->m_ThreadId = 0;
                }
            }

            /**
             * @brief Waits for this thread object to finish executing.
             *
             * @param dwMilliseconds    The time in milliseconds to wait for the thread to finish.
             *
             * @return True on success, false otherwise.
             */
            bool WaitForFinish(DWORD dwMilliseconds = INFINITE)
            {
                if (this->m_ThreadHandle == NULL)
                    return false;
                return (::WaitForSingleObject(this->m_ThreadHandle, dwMilliseconds) != WAIT_TIMEOUT);
            }

            /**
             * @brief Sets the threads priority.
             *
             * @param priority          The priority to set the thread to.
             */
            void SetPriority(Ashita::Threading::ThreadPriorty priority)
            {
                ::SetThreadPriority(this->m_ThreadHandle, priority);
            }

            /**
             * @brief Gets the priority of the thread.
             *
             * @return The priority id of the thread.
             */
            int GetPriority(void)
            {
                return ::GetThreadPriority(this->m_ThreadHandle);
            }

            /**
             * @brief Raises the end event for the thread.
             */
            void RaiseEnd(void)
            {
                this->m_EndEvent.Raise();
            }

            /**
             * @brief Resets the end event for the thread.
             */
            void ResetEnd(void)
            {
                this->m_EndEvent.Reset();
            }

            /**
             * @brief Returns if the thread is terminated or not.
             *
             * @return True if terminated, false otherwise.
             */
            bool IsTerminated(void)
            {
                return this->m_EndEvent.IsSignaled();
            }

        public:
            /**
             * @brief Returns the thread handle.
             */
            HANDLE GetHandle(void) const
            {
                return this->m_ThreadHandle;
            }

            /**
             * @brief Returns the thread id.
             */
            DWORD GetId(void) const
            {
                return this->m_ThreadId;
            }

            /**
             * @brief Returns the thread exit code.
             */
            DWORD GetExitCode(void) const
            {
                if (this->m_ThreadHandle == NULL)
                    return 0;

                DWORD dwExitCode = 0;
                ::GetExitCodeThread(this->m_ThreadHandle, &dwExitCode);
                return dwExitCode;
            }

        private:
            /**
             * @brief The threading callback handler to invoke the internal entrypoint of the thread.
             *
             * @param lpParam               The param of this thread. (AS_Thread object.)
             *
             * @return The return of the internal thread entry points function.
             */
            static DWORD __stdcall ThreadCallback(LPVOID lpParam)
            {
                auto thread = (Ashita::Threading::AS_Thread*)lpParam;
                return thread->InternalEntry();
            }
        };

    }; // namespace Threading
}; // namespace Ashita

#endif // __ASHITA_ADK_AS_THREAD_INCLUDED__
