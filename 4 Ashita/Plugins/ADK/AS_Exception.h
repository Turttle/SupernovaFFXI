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

#ifndef __ASHITA_ADK_AS_EXCEPTION_INCLUDED__
#define __ASHITA_ADK_AS_EXCEPTION_INCLUDED__

#if defined (_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

#include <Windows.h>
#include <eh.h>

#include "AS_String.h"

namespace Ashita
{
    namespace Exception
    {
        /**
         * @brief Define misssing STATUS code.
         */
#ifndef STATUS_POSSIBLE_DEADLOCK
#define STATUS_POSSIBLE_DEADLOCK 0xC0000194
#endif

        /**
         * @brief Macro for translating exception defines to strings.
         */
#define CASE(Exception) \
    case Exception: \
        this->m_Exception = #Exception; \
        break;

        /**
         * @brief Exception object that can obtain all exceptions.
         */
        class AS_Exception
        {
            unsigned int    m_ExceptionId;
            const char*     m_Exception;

        public:
            /**
             * @brief Constructor
             */
            AS_Exception(unsigned int id)
                : m_ExceptionId(id)
            {
                switch (this->m_ExceptionId)
                {
                    CASE(EXCEPTION_ACCESS_VIOLATION);
                    CASE(EXCEPTION_ARRAY_BOUNDS_EXCEEDED);
                    CASE(EXCEPTION_BREAKPOINT);
                    CASE(EXCEPTION_DATATYPE_MISALIGNMENT);
                    CASE(EXCEPTION_FLT_DENORMAL_OPERAND);
                    CASE(EXCEPTION_FLT_DIVIDE_BY_ZERO);
                    CASE(EXCEPTION_FLT_INEXACT_RESULT);
                    CASE(EXCEPTION_FLT_INVALID_OPERATION);
                    CASE(EXCEPTION_FLT_OVERFLOW);
                    CASE(EXCEPTION_FLT_STACK_CHECK);
                    CASE(EXCEPTION_FLT_UNDERFLOW);
                    CASE(EXCEPTION_GUARD_PAGE);
                    CASE(EXCEPTION_ILLEGAL_INSTRUCTION);
                    CASE(EXCEPTION_IN_PAGE_ERROR);
                    CASE(EXCEPTION_INT_DIVIDE_BY_ZERO);
                    CASE(EXCEPTION_INT_OVERFLOW);
                    CASE(EXCEPTION_INVALID_DISPOSITION);
                    CASE(EXCEPTION_INVALID_HANDLE);
                    CASE(EXCEPTION_NONCONTINUABLE_EXCEPTION);
                    CASE(EXCEPTION_POSSIBLE_DEADLOCK);
                    CASE(EXCEPTION_PRIV_INSTRUCTION);
                    CASE(EXCEPTION_SINGLE_STEP);
                    CASE(EXCEPTION_STACK_OVERFLOW);

                default:
                    this->m_Exception = "Unknown exception occurred.";
                    break;
                }
            }

            /**
             * @brief Deconstructor
             */
            ~AS_Exception(void)
            { }

        public:
            /**
             * @brief Returns the exception id of this exception object.
             */
            unsigned int GetExceptionId(void) const
            {
                return this->m_ExceptionId;
            }

            /**
             * @brief Returns the exception string of this exception object.
             */
            const char* GetException(void) const
            {
                return this->m_Exception;
            }
        };

        /**
         * @brief Scoped SEH translator class to automate custom exception filtering.
         */
        class ScopedTranslator
        {
            _se_translator_function m_Function;

        public:
            /**
             * @brief Constructor
             */
            ScopedTranslator(void)
            {
                this->m_Function = ::_set_se_translator(&ScopedTranslator::ScopedTranslatorFunc);
            }

            /**
             * @brief Deconstructor
             */
            ~ScopedTranslator(void)
            {
                if (this->m_Function != NULL)
                {
                    ::_set_se_translator(this->m_Function);
                    this->m_Function = NULL;
                }
            }

        private:
            /**
             * @brief Exception filter.
             */
            static void ScopedTranslatorFunc(unsigned int id, struct _EXCEPTION_POINTERS* lpPtrs)
            {
                // Rethrow this exception with our wrapper..
                UNREFERENCED_PARAMETER(lpPtrs);
                throw Ashita::Exception::AS_Exception(id);
            }
        };
    };
}; // namespace Ashita

#endif // __ASHITA_ADK_AS_EXCEPTION_INCLUDED__
