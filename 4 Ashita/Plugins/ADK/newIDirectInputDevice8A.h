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

#ifndef __NEWIDIRECTINPUTDEVICE8A_H_INCLUDED__
#define __NEWIDIRECTINPUTDEVICE8A_H_INCLUDED__

#if defined (_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

#include <windows.h>
#include <dinput.h>

class newIDirectInputDevice8A : public IDirectInputDevice8A
{
public:
    virtual __declspec(nothrow) HRESULT __stdcall QueryInterface(REFIID riid, LPVOID * ppvObj);
    virtual __declspec(nothrow) ULONG   __stdcall AddRef(void);
    virtual __declspec(nothrow) ULONG   __stdcall Release(void);
    virtual __declspec(nothrow) HRESULT __stdcall GetCapabilities(LPDIDEVCAPS lpDIDevCaps);
    virtual __declspec(nothrow) HRESULT __stdcall EnumObjects(LPDIENUMDEVICEOBJECTSCALLBACKA lpCallback, LPVOID pvRef, DWORD dwFlags);
    virtual __declspec(nothrow) HRESULT __stdcall GetProperty(REFGUID rguidProp, LPDIPROPHEADER pdiph);
    virtual __declspec(nothrow) HRESULT __stdcall SetProperty(REFGUID rguidProp, LPCDIPROPHEADER pdiph);
    virtual __declspec(nothrow) HRESULT __stdcall Acquire(void);
    virtual __declspec(nothrow) HRESULT __stdcall Unacquire(void);
    virtual __declspec(nothrow) HRESULT __stdcall GetDeviceState(DWORD cbData, LPVOID lpvData);
    virtual __declspec(nothrow) HRESULT __stdcall GetDeviceData(DWORD cbObjectData, LPDIDEVICEOBJECTDATA rgdod, LPDWORD pdwInOut, DWORD dwFlags);
    virtual __declspec(nothrow) HRESULT __stdcall SetDataFormat(LPCDIDATAFORMAT lpdf);
    virtual __declspec(nothrow) HRESULT __stdcall SetEventNotification(HANDLE hEvent);
    virtual __declspec(nothrow) HRESULT __stdcall SetCooperativeLevel(HWND hwnd, DWORD dwFlags);
    virtual __declspec(nothrow) HRESULT __stdcall GetObjectInfo(LPDIDEVICEOBJECTINSTANCEA pdidoi, DWORD dwObj, DWORD dwHow);
    virtual __declspec(nothrow) HRESULT __stdcall GetDeviceInfo(LPDIDEVICEINSTANCEA pdidi);
    virtual __declspec(nothrow) HRESULT __stdcall RunControlPanel(HWND hwndOwner, DWORD dwFlags);
    virtual __declspec(nothrow) HRESULT __stdcall Initialize(HINSTANCE hinst, DWORD dwVersion, REFGUID rguid);
    virtual __declspec(nothrow) HRESULT __stdcall CreateEffect(REFGUID rguid, LPCDIEFFECT lpeff, LPDIRECTINPUTEFFECT *ppdeff, LPUNKNOWN punkOuter);
    virtual __declspec(nothrow) HRESULT __stdcall EnumEffects(LPDIENUMEFFECTSCALLBACKA lpCallback, LPVOID pvRef, DWORD dwEffType);
    virtual __declspec(nothrow) HRESULT __stdcall GetEffectInfo(LPDIEFFECTINFOA pdei, REFGUID rguid);
    virtual __declspec(nothrow) HRESULT __stdcall GetForceFeedbackState(LPDWORD pdwOut);
    virtual __declspec(nothrow) HRESULT __stdcall SendForceFeedbackCommand(DWORD dwFlags);
    virtual __declspec(nothrow) HRESULT __stdcall EnumCreatedEffectObjects(LPDIENUMCREATEDEFFECTOBJECTSCALLBACK lpCallback, LPVOID pvRef, DWORD fl);
    virtual __declspec(nothrow) HRESULT __stdcall Escape(LPDIEFFESCAPE pesc);
    virtual __declspec(nothrow) HRESULT __stdcall Poll(void);
    virtual __declspec(nothrow) HRESULT __stdcall SendDeviceData(DWORD cbObjectData, LPCDIDEVICEOBJECTDATA rgdod, LPDWORD pdwInOut, DWORD fl);
    virtual __declspec(nothrow) HRESULT __stdcall EnumEffectsInFile(LPCSTR lpszFileName, LPDIENUMEFFECTSINFILECALLBACK pec, LPVOID pvRef, DWORD dwFlags);
    virtual __declspec(nothrow) HRESULT __stdcall WriteEffectToFile(LPCSTR lpszFileName, DWORD dwEntries, LPDIFILEEFFECT rgDiFileEft, DWORD dwFlags);
    virtual __declspec(nothrow) HRESULT __stdcall BuildActionMap(LPDIACTIONFORMATA lpdiaf, LPCSTR lpszUserName, DWORD dwFlags);
    virtual __declspec(nothrow) HRESULT __stdcall SetActionMap(LPDIACTIONFORMATA lpdiActionFormat, LPCSTR lptszUserName, DWORD dwFlags);
    virtual __declspec(nothrow) HRESULT __stdcall GetImageInfo(LPDIDEVICEIMAGEINFOHEADERA lpdiDevImageInfoHeader);

public:
    newIDirectInputDevice8A();
    newIDirectInputDevice8A(IDirectInputDevice8A** ppOrigInterface);
    virtual ~newIDirectInputDevice8A(void);
    
public:
    /**
     * @brief Property Helpers
     */
    HWND GetParentWindow(void) const;
    bool GetBlocked(void) const;
    void SetBlocked(bool bBlocked);

protected:
    IDirectInputDevice8A*   m_DirectInputDevice8;
    UINT                    m_ReferenceCount;
    bool                    m_BlockInput;
    HWND                    m_ParentWindow;
};

#endif // __NEWIDIRECTINPUTDEVICE8A_H_INCLUDED__