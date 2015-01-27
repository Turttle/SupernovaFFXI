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

#ifndef __ASHITA_ADK_ASHITA_H_INCLUDED__
#define __ASHITA_ADK_ASHITA_H_INCLUDED__

#if defined (_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

/**
 * @brief Interface Header Version
 */
#define ASHITA_INTERFACE_VERSION 1.04

/**
 * @brief Define DirectInput Version
 */
#ifndef DIRECTINPUT_VERSION
#define DIRECTINPUT_VERSION 0x0800
#endif

#include <Windows.h>
#include <functional>
#include <string>

/**
 * @brief Direct3D Includes
 */
#include "d3d8\includes\d3d8.h"
#include "d3d8\includes\d3dx8.h"

/**
 * @brief Ashita ADK Includes
 */
#include "newIDirectInputDevice8A.h"
#include "AS_CommandParse.h"
#include "AS_Event.h"
#include "AS_Exception.h"
#include "AS_LockableObject.h"
#include "AS_Memory.h"
#include "AS_Rect.h"
#include "AS_Registry.h"
#include "AS_String.h"
#include "AS_Thread.h"
#include "AS_WindowProps.h"
#include "ffxi\enums.h"
#include "ffxi\entity.h"
#include "ffxi\inventory.h"
#include "ffxi\party.h"
#include "ffxi\player.h"
#include "ffxi\target.h"

/**
 * @brief Lua state forward declaration.
 */
struct lua_State { };

/**
 * @brief Button click callback function typdef.
 */
typedef std::function<void(int, void*, float, float)> BUTTONCLICK;

///////////////////////////////////////////////////////////////////////////////////////////////////
//
// Ashita Gui Definitions
//
// Various definitions needed and used with the Ashita UI implementation.
//
///////////////////////////////////////////////////////////////////////////////////////////////////

typedef struct TAUiBar AUiBar;

typedef enum TAUiType
{
    AUI_TYPE_UNDEF = 0,
    AUI_TYPE_BOOLCPP = 1,
    AUI_TYPE_BOOL8 = 2,
    AUI_TYPE_BOOL16,
    AUI_TYPE_BOOL32,
    AUI_TYPE_CHAR,
    AUI_TYPE_INT8,
    AUI_TYPE_UINT8,
    AUI_TYPE_INT16,
    AUI_TYPE_UINT16,
    AUI_TYPE_INT32,
    AUI_TYPE_UINT32,
    AUI_TYPE_FLOAT,
    AUI_TYPE_DOUBLE,
    AUI_TYPE_COLOR32,   // 32 bits color. Order is RGBA if API is OpenGL or Direct3D10, and inversed if API is Direct3D9 (can be modified by defining 'colorOrder=...', see doc)
    AUI_TYPE_COLOR3F,   // 3 floats color. Order is RGB.
    AUI_TYPE_COLOR4F,   // 4 floats color. Order is RGBA.
    AUI_TYPE_CDSTRING,  // Null-terminated C Dynamic String (pointer to an array of char dynamically allocated with malloc/realloc/strdup)
    AUI_TYPE_STDSTRING = (0x2fff0000 + sizeof(std::string)),    // C++ STL string (std::string)
    AUI_TYPE_QUAT4F = AUI_TYPE_CDSTRING + 2,                    // 4 floats encoding a quaternion {qx,qy,qz,qs}
    AUI_TYPE_QUAT4D,    // 4 doubles encoding a quaternion {qx,qy,qz,qs}
    AUI_TYPE_DIR3F,     // direction vector represented by 3 floats
    AUI_TYPE_DIR3D      // direction vector represented by 3 doubles
} AUiType;
#define AUI_TYPE_CSSTRING(n) ((AUiType)(0x30000000+((n)&0xfffffff))) // Null-terminated C Static String of size n (defined as char[n], with n<2^28)

typedef struct TAUiEnumVal
{
    int             Value;
    const char*     Label;
} AUiEnumVal;

typedef struct TAUiStructMember
{
    const char*     Name;
    AUiType         Type;
    size_t          Offset;
    const char*     DefString;
} AUiStructMember;

typedef enum TAUiParamValueType
{
    AUI_PARAM_INT32,
    AUI_PARAM_FLOAT,
    AUI_PARAM_DOUBLE,
    AUI_PARAM_CSTRING
} AUiParamValueType;

typedef void(__stdcall * AUiSummaryCallback)(char* summaryString, size_t summaryMaxLength, const void* value, void* clientData);
typedef void(__stdcall * AUiGetVarCallback)(void* value, void* clientData);
typedef void(__stdcall * AUiSetVarCallback)(const void* value, void* clientData);
typedef void(__stdcall * AUiButtonCallback)(const char* name, void* clientData);
typedef void(__stdcall * AUiCopyCDStringToClient)(char** destinationClientStringPtr, const char* sourceString);
typedef void(__stdcall * AUiCopyStdStringToClient)(std::string& destinationClientString, const std::string& sourceString);

///////////////////////////////////////////////////////////////////////////////////////////////////
//
// Ashita::Enums
//
// Useful enumerations used for Ashita specific command and interfaces.
//
///////////////////////////////////////////////////////////////////////////////////////////////////
namespace Ashita
{
    namespace Enums
    {
        /**
         * @brief Command Input Type
         */
        enum CommandInputType : int
        {
            ForceHandle = -3,   // Informs Ashita to force parse this command.
            Script = -2,        // Informs Ashita to handle this command as a script.
            Parse = -1,         // Informs Ashita to parse this command.
            Menu = 0,           // Command input as if it were invoked from the game menu.
            Typed = 1,          // Command input as if it were typed by the player.
            Macro = 2           // Command input as if it were invoked from a macro.
        };

        /**
         * @brief Frame Anchor Points
         */
        enum FrameAnchor : unsigned int
        {
            TopLeft = 0,
            TopRight = 1,
            BottomLeft = 2,
            BottomRight = 3,

            Right = 1,
            Bottom = 2
        };

        /**
         * @brief Mouse Input Type
         */
        enum MouseInput : unsigned int
        {
            // Click events..
            LeftClick = 0,
            RightClick = 1,
            MiddleClick = 2,
            X1Click = 3,
            X2Click = 4,

            // Mouse wheel events..
            MouseWheelUp = 5,
            MouseWheelDown = 6,

            // Mouse move events..
            MouseMove = 7
        };
    }; // namespace Enums
}; // namespace Ashita

///////////////////////////////////////////////////////////////////////////////////////////////////
//
// IAbility
//
// Resource object used for ability entries.
//
///////////////////////////////////////////////////////////////////////////////////////////////////
struct IAbility
{
    unsigned short ID;                  // The real ability id not the recast id.
    unsigned char  Type;                // Ability type.
    unsigned char  ListIconID;          // e.g. 40-47 for the elemental-colored dots
    unsigned short Unknown;             // Unknown
    unsigned short MP;                  // Mp Cost if any
    unsigned short TimerID;             // Recast ID
    unsigned short ValidTargets;        // Valid targets
    signed   char  TP;                  // Tp if any, -1 if not
    signed   char  Cat;                 // For non abilitys like /ranged etc -1 for none
    const char*    Name[5];             // Ability name for the selected language.
    const char*    Description[5];      // Description of the ability.
};

///////////////////////////////////////////////////////////////////////////////////////////////////
//
// ISpell
//
// Resource object used for spell entries.
//
///////////////////////////////////////////////////////////////////////////////////////////////////
struct ISpell
{
    unsigned short ID;                  // Spell ID, also used in recast 
    unsigned short MagicType;           // Magic type
    unsigned short Element;             // Spell element
    unsigned short ValidTargets;        // Valid cast targets
    unsigned short Skill;               // Magic skill type    
    unsigned short MP;                  // Mp cost
    unsigned char  Cast;                // Cast time (1/4 second)
    unsigned char  Recast;              // Recast time (1/4 second)
    unsigned char  RequiredLevel[24];   // RequiredLevel[JobID] 0xFF == can not be learned.
    unsigned short ResourceID;          // Resource ID
    unsigned short IconIndex;           // Index of the icon.
    const char*    Name[5];             // Spell name for the selected language.
    const char*    Description[5];      // Description of the spell.
};

///////////////////////////////////////////////////////////////////////////////////////////////////
//
// IItem
//
// Resource object used for item entries.
//
///////////////////////////////////////////////////////////////////////////////////////////////////
struct IItem
{
    unsigned int    ItemID;             // Item id.
    unsigned short  Flags;              // Item flags.
    unsigned short  StackSize;          // Stack size.
    unsigned short  ItemType;           // Item type.
    unsigned short  ResourceID;         // Item resource id.
    unsigned short  ValidTargets;       // Item valid targets.

    unsigned short  Level;              // Item level.
    unsigned short  Slot;               // Item slot.
    unsigned short  Races;              // Item races.
    unsigned int    Jobs;               // Item jobs.
    unsigned short  ShieldSize;         // Item shield size.

    unsigned short  Damage;             // Item damage.
    unsigned short  Delay;              // Item delay.
    unsigned short  DPS;                // Item dps.
    unsigned char   Skill;              // Item skill.
    unsigned char   JugSize;            // Item jug size.

    unsigned char   MaxCharges;         // Item max charges.
    unsigned char   CastTime;           // Item cast time.
    unsigned short  UseDelay;           // Item use delay.
    unsigned int    ReuseDelay;         // Item reuse delay.

    unsigned int    Elements;           // Item elements.
    unsigned int    ItemLevel;          // Item level. (Used by armor and weapons.)

    unsigned short  Var1;               // Furnishings: Element.
    unsigned int    Var2;               // Furnishings: StorageSlots.

    char*           Name;               // Item name.
    char*           Description;        // Item description.
    char*           LogNameSingular;    // Item log name. (Singular)
    char*           LogNamePlural;      // Item log name. (Plural)

    unsigned int    ImageSize;          // Item image size.
    unsigned char   ImageType;          // Item image type.
    char            ImageName[16];      // Item image name.
    char            Bitmap[0x978];      // Item image data.
};

///////////////////////////////////////////////////////////////////////////////////////////////////
//
// IChatManager
//
// Ashita chat manager that handles hooks and commands that deal with the games input and
// command systems. 
//
///////////////////////////////////////////////////////////////////////////////////////////////////
struct IChatManager
{
    virtual void ParseCommand(const char* command, int nCommandType) = 0;
    virtual void QueueCommand(const char* command, int nCommandType) = 0;
    virtual void AddChatMessage(int nMode, const char* message) = 0;
    virtual int ParseAutoTranslate(const char* message, char* pszBuffer, int nBufferLength, bool bAddBrackets) = 0;
    virtual const char* GetInputText(void) const = 0;
    virtual void SetInputText(const char* message) = 0;
    virtual void RunTextScript(bool bUseTaskQueue, const char* script) = 0;
    virtual void Write(const char* format, ...) = 0;
};

///////////////////////////////////////////////////////////////////////////////////////////////////
//
// IConfigurationManager
//
// Ashita configuration manager that holds loaded configuration information for the Ashita core
// as well as plugins and other loaded data.
//
///////////////////////////////////////////////////////////////////////////////////////////////////
struct IConfigurationManager
{
    virtual bool LoadConfiguration(const char* className) = 0;
    virtual bool LoadConfiguration(const char* className, const char* file) = 0;
    virtual void RemoveConfiguration(const char* className) = 0;
    virtual bool SaveConfiguration(const char* className) = 0;

    virtual Ashita::AS_String GetConfigString(const char* className, const char* name) = 0;
    virtual int GetConfigString(const char* className, const char* name, LPVOID lpOutput) = 0;
    virtual bool GetConfigBool(const char* className, const char* name, bool defaultValue) = 0;
    virtual int GetConfigInt(const char* className, const char* name, int defaultValue) = 0;
    virtual float GetConfigFloat(const char* className, const char* name, float defaultValue) = 0;
    virtual double GetConfigDouble(const char* className, const char* name, double defaultValue) = 0;

    virtual void SetConfigValue(const char* className, const char* name, const char* value) = 0;
};

///////////////////////////////////////////////////////////////////////////////////////////////////
//
// Keyboard Callback Typedefs
//
///////////////////////////////////////////////////////////////////////////////////////////////////
typedef HRESULT(__stdcall *GetDataCallback)(DWORD, LPDIDEVICEOBJECTDATA, DWORD, LPDWORD, DWORD);
typedef HRESULT(__stdcall *GetStateCallback)(DWORD, LPVOID);
typedef BOOL(__stdcall *KeyboardProcCallback)(WPARAM, LPARAM);

///////////////////////////////////////////////////////////////////////////////////////////////////
//
// IKeyboard
//
// Keyboard interface object to expose helpful functions related to the keyboard.
//
///////////////////////////////////////////////////////////////////////////////////////////////////
struct IKeyboard : newIDirectInputDevice8A
{
    // The following are exposed from newIDirectInputDevice8A:
    //      HWND GetParentWindow(void);
    //      bool GetBlocked(void);
    //      void SetBlocked(bool bBlocked);

    virtual void BindKey(unsigned int key, bool bDown, bool bAlt, bool bCtrl, bool bWinKey, bool bAppsKey, bool bShift, const char* pszCommand) = 0;
    virtual void UnbindKey(unsigned int key, bool bDown, bool bAlt, bool bCtrl, bool bWinKey, bool bAppsKey, bool bShift) = 0;
    virtual void UnbindAllKeys(void) = 0;
    virtual bool IsKeyBound(unsigned int key, bool bAlt, bool bCtrl, bool bWinKey, bool bAppsKey, bool bShift) = 0;
    virtual void ListBinds(void) = 0;

    virtual unsigned int V2D(unsigned int key) = 0;
    virtual unsigned int D2V(unsigned int key) = 0;
    virtual unsigned int S2D(const char* pszKey) = 0;
    virtual const char* D2S(unsigned int key) = 0;

    virtual void AddCallback(const char* alias, LPVOID lpGetDataCallback, LPVOID lpGetStateCallback, LPVOID lpKeyboardCallback) = 0;
    virtual void RemoveCallback(const char* alias) = 0;
};

///////////////////////////////////////////////////////////////////////////////////////////////////
//
// IKeyboard
//
// Keyboard interface object to expose helpful functions related to the keyboard.
//
///////////////////////////////////////////////////////////////////////////////////////////////////
struct IMouse : newIDirectInputDevice8A
{
    // The following are exposed from newIDirectInputDevice8A:
    //      HWND GetParentWindow(void);
    //      bool GetBlocked(void);
    //      void SetBlocked(bool bBlocked);
};

///////////////////////////////////////////////////////////////////////////////////////////////////
//
// IInputManager
//
// Ashita input manager that exposes the control interfaces.
//
///////////////////////////////////////////////////////////////////////////////////////////////////
struct IInputManager
{
    virtual IKeyboard* GetKeyboard(void) = 0;
    virtual IMouse* GetMouse(void) = 0;
};

///////////////////////////////////////////////////////////////////////////////////////////////////
//
// IPacketManager
//
// Ashita packet manager that handles hooks and commands that deal with the games packet system.
//
///////////////////////////////////////////////////////////////////////////////////////////////////
struct IPacketManager
{
    virtual void AddIncomingPacket(void* pRawPacket, unsigned short uiPacketId, unsigned int uiPacketLength) = 0;
    virtual void AddOutgoingPacket(void* pRawPacket, unsigned short uiPacketId, unsigned int uiPacketLength) = 0;
};

///////////////////////////////////////////////////////////////////////////////////////////////////
//
// IPluginManager
//
// Ashita plugin manager that maintains the current plugins.
//
///////////////////////////////////////////////////////////////////////////////////////////////////
struct IPluginManager
{
    virtual int GetPluginCount(void) = 0;

    virtual bool LoadPlugin(const char* name) = 0;
    virtual bool UnloadPlugin(const char* name) = 0;
    virtual void* GetPlugin(const char* name) = 0;
    virtual void* GetPlugin(int nIndex) = 0;
};

///////////////////////////////////////////////////////////////////////////////////////////////////
//
// IPointerManager
//
// Ashita pointer manager that maintains the current pointers to various game data.
//
///////////////////////////////////////////////////////////////////////////////////////////////////
struct IPointerManager
{
    virtual unsigned int GetPointer(const char* name) = 0;
};

///////////////////////////////////////////////////////////////////////////////////////////////////
//
// IResourceManager
//
// Ashita resource manager that maintains various useful data parsed from the game dat files.
//
///////////////////////////////////////////////////////////////////////////////////////////////////
struct IResourceManager
{
    virtual IAbility* GetAbilityByID(unsigned int abilityId) = 0;
    virtual IAbility* GetAbilityByName(const char* pszName, int nLanguageId) = 0;
    virtual IAbility* GetAbilityByTimerID(unsigned int timerId) = 0;

    virtual ISpell* GetSpellByID(unsigned int spellId) = 0;
    virtual ISpell* GetSpellByName(const char* pszName, int nLanguageId) = 0;

    virtual IItem* GetItemByID(unsigned int itemId) = 0;
    virtual IItem* GetItemByName(const char* pszName) = 0;

    virtual const char* GetString(const char* pszTable, unsigned int nIndex) = 0;
    virtual const char* GetString(const char* pszTable, unsigned int nIndex, int nLanguageId) = 0;
    virtual unsigned int GetString(const char* pszTable, const char* pszName) = 0;
    virtual unsigned int GetString(const char* pszTable, const char* pszName, int nLanguageId) = 0;
};

///////////////////////////////////////////////////////////////////////////////////////////////////
//
// IEntity
//
// Data object interface to obtain and set various information about entities.
//
///////////////////////////////////////////////////////////////////////////////////////////////////
struct IEntity
{
    /**
     * @brief Plugins SHOULD NOT use this function! Use the get/set functions instead!
     */
    virtual Ashita::FFXI::Entity* GetEntity(unsigned int nIndex) const = 0;

    virtual float GetLocalX(unsigned int nIndex) const = 0;
    virtual float GetLocalY(unsigned int nIndex) const = 0;
    virtual float GetLocalZ(unsigned int nIndex) const = 0;
    virtual float GetLocalRoll(unsigned int nIndex) const = 0;
    virtual float GetLocalYaw(unsigned int nIndex) const = 0;
    virtual float GetLocalPitch(unsigned int nIndex) const = 0;
    virtual float GetLastX(unsigned int nIndex) const = 0;
    virtual float GetLastY(unsigned int nIndex) const = 0;
    virtual float GetLastZ(unsigned int nIndex) const = 0;
    virtual float GetLastRoll(unsigned int nIndex) const = 0;
    virtual float GetLastYaw(unsigned int nIndex) const = 0;
    virtual float GetLastPitch(unsigned int nIndex) const = 0;
    virtual float GetMoveX(unsigned int nIndex) const = 0;
    virtual float GetMoveY(unsigned int nIndex) const = 0;
    virtual float GetMoveZ(unsigned int nIndex) const = 0;
    virtual unsigned int GetTargetID(unsigned int nIndex) const = 0;
    virtual unsigned int GetServerID(unsigned int nIndex) const = 0;
    virtual const char* GetName(unsigned int nIndex) const = 0;
    virtual float GetMovementSpeed(unsigned int nIndex) const = 0;
    virtual float GetAnimationSpeed(unsigned int nIndex) const = 0;
    virtual unsigned int GetWarpPointer(unsigned int nIndex) const = 0;
    virtual float GetDistance(unsigned int nIndex) const = 0;
    virtual float GetHeading(unsigned int nIndex) const = 0;
    virtual unsigned int GetPetOwnerID(unsigned int nIndex) const = 0;
    virtual unsigned int GetPetTP(unsigned int nIndex) const = 0;
    virtual unsigned char GetHealthPercent(unsigned int nIndex) const = 0;
    virtual unsigned char GetType(unsigned int nIndex) const = 0;
    virtual unsigned char GetRace(unsigned int nIndex) const = 0;
    virtual unsigned char GetModelFade(unsigned int nIndex) const = 0;
    virtual unsigned short GetModelFace(unsigned int nIndex) const = 0;
    virtual unsigned short GetModelHead(unsigned int nIndex) const = 0;
    virtual unsigned short GetModelBody(unsigned int nIndex) const = 0;
    virtual unsigned short GetModelHands(unsigned int nIndex) const = 0;
    virtual unsigned short GetModelLegs(unsigned int nIndex) const = 0;
    virtual unsigned short GetModelFeet(unsigned int nIndex) const = 0;
    virtual unsigned short GetModelMain(unsigned int nIndex) const = 0;
    virtual unsigned short GetModelSub(unsigned int nIndex) const = 0;
    virtual unsigned short GetModelRanged(unsigned int nIndex) const = 0;
    virtual unsigned short GetActionWaitTimer1(unsigned int nIndex) const = 0;
    virtual unsigned short GetActionWaitTimer2(unsigned int nIndex) const = 0;
    virtual unsigned int GetRenderFlag1(unsigned int nIndex) const = 0;
    virtual unsigned int GetRenderFlag2(unsigned int nIndex) const = 0;
    virtual unsigned int GetRenderFlag3(unsigned int nIndex) const = 0;
    virtual unsigned int GetRenderFlag4(unsigned int nIndex) const = 0;
    virtual unsigned int GetRenderFlag5(unsigned int nIndex) const = 0;
    virtual unsigned short GetNpcSpeechLoop(unsigned int nIndex) const = 0;
    virtual unsigned short GetNpcSpeechFrame(unsigned int nIndex) const = 0;
    virtual float GetMovementSpeed2(unsigned int nIndex) const = 0;
    virtual unsigned short GetCostumeID(unsigned int nIndex) const = 0;
    virtual unsigned int GetStatus(unsigned int nIndex) const = 0;
    virtual unsigned int GetStatusServer(unsigned int nIndex) const = 0;
    virtual unsigned int GetStatusNpcChat(unsigned int nIndex) const = 0;
    virtual unsigned int GetClaimID(unsigned int nIndex) const = 0;
    virtual unsigned short GetAnimationTick(unsigned int nIndex) const = 0;
    virtual unsigned short GetAnimationStep(unsigned int nIndex) const = 0;
    virtual unsigned char GetAnimationPlay(unsigned int nIndex) const = 0;
    virtual unsigned int GetEmoteID(unsigned int nIndex) const = 0;
    virtual unsigned int GetSpawnFlags(unsigned int nIndex) const = 0;
    virtual unsigned int GetLinkshellColor(unsigned int nIndex) const = 0;
    virtual unsigned short GetCampaignNameFlag(unsigned int nIndex) const = 0;
    virtual unsigned short GetFishingTimer(unsigned int nIndex) const = 0;
    virtual unsigned short GetFishingCastTimer(unsigned int nIndex) const = 0;
    virtual unsigned short GetTargetIndex(unsigned int nIndex) const = 0;
    virtual unsigned short GetPetIndex(unsigned int nIndex) const = 0;
    virtual float GetModelSize(unsigned int nIndex) const = 0;
    virtual unsigned short GetMonstrosityFlag(unsigned int nIndex) const = 0;
    virtual const char* GetMonstrosityName(unsigned int nIndex) const = 0;

    virtual void SetLocalX(unsigned int nIndex, float fLocalX) = 0;
    virtual void SetLocalY(unsigned int nIndex, float fLocalY) = 0;
    virtual void SetLocalZ(unsigned int nIndex, float fLocalZ) = 0;
    virtual void SetLocalRoll(unsigned int nIndex, float fLocalRoll) = 0;
    virtual void SetLocalYaw(unsigned int nIndex, float fLocalYaw) = 0;
    virtual void SetLocalPitch(unsigned int nIndex, float fLocalPitch) = 0;
    virtual void SetLastX(unsigned int nIndex, float fLastX) = 0;
    virtual void SetLastY(unsigned int nIndex, float fLastY) = 0;
    virtual void SetLastZ(unsigned int nIndex, float fLastZ) = 0;
    virtual void SetLastRoll(unsigned int nIndex, float fLastRoll) = 0;
    virtual void SetLastYaw(unsigned int nIndex, float fLastYaw) = 0;
    virtual void SetLastPitch(unsigned int nIndex, float fLastPitch) = 0;
    virtual void SetMoveX(unsigned int nIndex, float fMoveX) = 0;
    virtual void SetMoveY(unsigned int nIndex, float fMoveY) = 0;
    virtual void SetMoveZ(unsigned int nIndex, float fMoveZ) = 0;
    virtual void SetTargetID(unsigned int nIndex, unsigned int nTargetID) = 0;
    virtual void SetServerID(unsigned int nIndex, unsigned int nServerID) = 0;
    virtual void SetName(unsigned int nIndex, const char* pszName) = 0;
    virtual void SetMovementSpeed(unsigned int nIndex, float fMovementSpeed) = 0;
    virtual void SetAnimationSpeed(unsigned int nIndex, float fAnimationSpeed) = 0;
    virtual void SetWarpPointer(unsigned int nIndex, void* lpWarpPointer) = 0;
    virtual void SetDistance(unsigned int nIndex, float fDistance) = 0;
    virtual void SetHeading(unsigned int nIndex, float fHeading) = 0;
    virtual void SetPetOwnerID(unsigned int nIndex, unsigned int nPetOwnerID) = 0;
    virtual void SetPetTP(unsigned int nIndex, unsigned int nPetTP) = 0;
    virtual void SetHealthPercent(unsigned int nIndex, unsigned char cHealthPercent) = 0;
    virtual void SetType(unsigned int nIndex, unsigned char cType) = 0;
    virtual void SetRace(unsigned int nIndex, unsigned char cRace) = 0;
    virtual void SetModelFade(unsigned int nIndex, unsigned char cModelFade) = 0;
    virtual void SetModelFace(unsigned int nIndex, unsigned short sModelFace) = 0;
    virtual void SetModelHead(unsigned int nIndex, unsigned short sModelHead) = 0;
    virtual void SetModelBody(unsigned int nIndex, unsigned short sModelBody) = 0;
    virtual void SetModelHands(unsigned int nIndex, unsigned short sModelHands) = 0;
    virtual void SetModelLegs(unsigned int nIndex, unsigned short sModelLegs) = 0;
    virtual void SetModelFeet(unsigned int nIndex, unsigned short sModelFeet) = 0;
    virtual void SetModelMain(unsigned int nIndex, unsigned short sModelMain) = 0;
    virtual void SetModelSub(unsigned int nIndex, unsigned short sModelSub) = 0;
    virtual void SetModelRanged(unsigned int nIndex, unsigned short sModelRanged) = 0;
    virtual void SetActionWaitTimer1(unsigned int nIndex, unsigned short sActionWaitTimer1) = 0;
    virtual void SetActionWaitTimer2(unsigned int nIndex, unsigned short sActionWaitTimer2) = 0;
    virtual void SetRenderFlag1(unsigned int nIndex, unsigned int nRenderFlag1) = 0;
    virtual void SetRenderFlag2(unsigned int nIndex, unsigned int nRenderFlag2) = 0;
    virtual void SetRenderFlag3(unsigned int nIndex, unsigned int nRenderFlag3) = 0;
    virtual void SetRenderFlag4(unsigned int nIndex, unsigned int nRenderFlag4) = 0;
    virtual void SetRenderFlag5(unsigned int nIndex, unsigned int nRenderFlag5) = 0;
    virtual void SetNpcSpeechLoop(unsigned int nIndex, unsigned short sNpcSpeechLoop) = 0;
    virtual void SetNpcSpeechFrame(unsigned int nIndex, unsigned short sNpcSpeechFrame) = 0;
    virtual void SetMovementSpeed2(unsigned int nIndex, float fMovementSpeed2) = 0;
    virtual void SetCostumeID(unsigned int nIndex, unsigned short sCostumeID) = 0;
    virtual void SetStatus(unsigned int nIndex, unsigned int nStatus) = 0;
    virtual void SetStatusServer(unsigned int nIndex, unsigned int nStatusServer) = 0;
    virtual void SetStatusNpcChat(unsigned int nIndex, unsigned int nStatusNpcChat) = 0;
    virtual void SetClaimID(unsigned int nIndex, unsigned int nClaimID) = 0;
    virtual void SetAnimationTick(unsigned int nIndex, unsigned short sAnimationTick) = 0;
    virtual void SetAnimationStep(unsigned int nIndex, unsigned short sAnimationStep) = 0;
    virtual void SetAnimationPlay(unsigned int nIndex, unsigned char sAnimationPlay) = 0;
    virtual void SetEmoteID(unsigned int nIndex, unsigned int nEmoteID) = 0;
    virtual void SetSpawnFlags(unsigned int nIndex, unsigned int nSpawnFlags) = 0;
    virtual void SetLinkshellColor(unsigned int nIndex, unsigned int nLinkshellColor) = 0;
    virtual void SetCampaignNameFlag(unsigned int nIndex, unsigned short sCampaignNameFlag) = 0;
    virtual void SetFishingTimer(unsigned int nIndex, unsigned short sFishingTimer) = 0;
    virtual void SetFishingCastTimer(unsigned int nIndex, unsigned short sFishingCastTimer) = 0;
    virtual void SetTargetIndex(unsigned int nIndex, unsigned short sTargetIndex) = 0;
    virtual void SetPetIndex(unsigned int nIndex, unsigned short sPetIndex) = 0;
    virtual void SetModelSize(unsigned int nIndex, float fModelSize) = 0;
    virtual void SetMonstrosityFlag(unsigned int nIndex, unsigned short sMonstrosityFlag) = 0;
    virtual void SetMonstrosityName(unsigned int nIndex, const char* pszMonstrosityName) = 0;
};

///////////////////////////////////////////////////////////////////////////////////////////////////
//
// IPrimitiveObject
//
// Primitive object exposure to interact with primitive objects.
//
///////////////////////////////////////////////////////////////////////////////////////////////////
struct IPrimitiveObject
{
    virtual void SetTextureFromFile(const char* path) = 0;
    virtual void SetTextureFromResource(HMODULE hModule, const char* resource) = 0;

    virtual bool GetVisibility(void) const = 0;
    virtual float GetPositionX(void) const = 0;
    virtual float GetPositionY(void) const = 0;
    virtual float GetWidth(void) const = 0;
    virtual float GetHeight(void) const = 0;
    virtual D3DCOLOR GetColor(void) const = 0;

    virtual void SetVisibility(bool bVisible) = 0;
    virtual void SetPositionX(float fPosX) = 0;
    virtual void SetPositionY(float fPosY) = 0;
    virtual void SetWidth(float fWidth) = 0;
    virtual void SetHeight(float fHeight) = 0;
    virtual void SetColor(D3DCOLOR color) = 0;
};

///////////////////////////////////////////////////////////////////////////////////////////////////
//
// IFontObject
//
// Font object exposure to interact with font objects.
//
///////////////////////////////////////////////////////////////////////////////////////////////////
struct IFontObject
{
    virtual D3DCOLOR GetColor(void) const = 0;
    virtual Ashita::AS_String GetFontName(void) const = 0;
    virtual int GetFontHeight(void) const = 0;
    virtual float GetPositionX(void) const = 0;
    virtual float GetPositionY(void) const = 0;
    virtual bool GetLockPosition(void) const = 0;
    virtual Ashita::AS_String GetText(void) const = 0;
    virtual bool GetVisibility(void) const = 0;
    virtual bool GetBold(void) const = 0;
    virtual bool GetItalic(void) const = 0;
    virtual bool GetRightJustified(void) const = 0;
    virtual void GetTextSize(SIZE* lpSize) const = 0;
    virtual Ashita::Enums::FrameAnchor GetAnchor(void) const = 0;
    virtual Ashita::Enums::FrameAnchor GetAnchorParent(void) const = 0;
    virtual bool GetAutoResize(void) const = 0;
    virtual IFontObject* GetParent(void) const = 0;
    virtual BUTTONCLICK GetClickFunction(void) const = 0;

    virtual void SetColor(D3DCOLOR color) = 0;
    virtual void SetFont(const char* font, int nHeight) = 0;
    virtual void SetPosition(float fPosX, float fPosY) = 0;
    virtual void SetLockPosition(bool bLocked) = 0;
    virtual void SetText(const char* text) = 0;
    virtual void SetVisibility(bool bVisible) = 0;
    virtual void SetBold(bool bBold) = 0;
    virtual void SetItalic(bool bItalic) = 0;
    virtual void SetRightJustified(bool bRightJustified) = 0;
    virtual void SetAnchor(Ashita::Enums::FrameAnchor anchor) = 0;
    virtual void SetAnchorParent(Ashita::Enums::FrameAnchor anchor) = 0;
    virtual void SetAutoResize(bool bResize) = 0;
    virtual void SetParent(IFontObject* parent) = 0;
    virtual void SetClickFunction(BUTTONCLICK lpClickFunc) = 0;

    virtual bool HitTest(float fPosX, float fPosY) = 0;

    virtual IPrimitiveObject* GetBackground(void) const = 0;
};

///////////////////////////////////////////////////////////////////////////////////////////////////
//
// IFontManager
//
// Ashita font manager that exposes various font functions.
//
///////////////////////////////////////////////////////////////////////////////////////////////////
struct IFontManager
{
    virtual IFontObject* CreateFontObject(const char* alias) = 0;
    virtual IFontObject* GetFontObject(const char* alias) = 0;
    virtual void DeleteFontObject(const char* alias) = 0;

    virtual bool GetHideObjects(void) const = 0;
    virtual void SetHideObjects(bool bHide) = 0;
};

///////////////////////////////////////////////////////////////////////////////////////////////////
//
// IInventory
//
// Data object interface to obtain and set various information for the inventory.
//
///////////////////////////////////////////////////////////////////////////////////////////////////
struct IInventory
{
    virtual Ashita::FFXI::ItemEntry* GetInventoryItem(int nStorageId, int nSlotId) const = 0;
    virtual short GetInventoryMax(int nStorageId) const = 0;
    virtual Ashita::FFXI::TreasureEntry* GetTreasureItem(int nSlotId) const = 0;
    virtual Ashita::FFXI::EquipmentEntry* GetEquipmentItem(int nSlotId) const = 0;
    virtual unsigned int GetCraftWaitTimer(void) const = 0;
};

///////////////////////////////////////////////////////////////////////////////////////////////////
//
// IParty
//
// Data object interface to obtain and set various information for the party.
//
///////////////////////////////////////////////////////////////////////////////////////////////////
struct IParty
{
    // Party member functions..
    virtual unsigned char GetPartyMemberIndex(int nMemberIndex) const = 0;
    virtual unsigned char GetPartyMemberNumber(int nMemberIndex) const = 0;
    virtual const char* GetPartyMemberName(int nMemberIndex) const = 0;
    virtual unsigned int GetPartyMemberID(int nMemberIndex) const = 0;
    virtual unsigned int GetPartyMemberTargetIndex(int nMemberIndex) const = 0;
    virtual unsigned int GetPartyMemberHP(int nMemberIndex) const = 0;
    virtual unsigned int GetPartyMemberMP(int nMemberIndex) const = 0;
    virtual unsigned int GetPartyMemberTP(int nMemberIndex) const = 0;
    virtual unsigned char GetPartyMemberHPP(int nMemberIndex) const = 0;
    virtual unsigned char GetPartyMemberMPP(int nMemberIndex) const = 0;
    virtual unsigned short GetPartyMemberZone(int nMemberIndex) const = 0;
    virtual unsigned char GetPartyMemberActive(int nMemberIndex) const = 0;

    // Party member job information functions..
    virtual unsigned char GetPartyMemberMainJob(int nMemberIndex) const = 0;
    virtual unsigned char GetPartyMemberMainJobLevel(int nMemberIndex) const = 0;
    virtual unsigned char GetPartyMemberSubJob(int nMemberIndex) const = 0;
    virtual unsigned char GetPartyMemberSubJobLevel(int nMemberIndex) const = 0;

    // Alliance information functions..
    virtual unsigned int GetAllianceLeaderID(void) const = 0;
    virtual unsigned int GetAllianceParty0LeaderID(void) const = 0;
    virtual unsigned int GetAllianceParty1LeaderID(void) const = 0;
    virtual unsigned int GetAllianceParty2LeaderID(void) const = 0;
    virtual unsigned char GetAllianceParty0Visible(void) const = 0;
    virtual unsigned char GetAllianceParty1Visible(void) const = 0;
    virtual unsigned char GetAllianceParty2Visible(void) const = 0;
    virtual unsigned int GetAllianceParty0Count(void) const = 0;
    virtual unsigned int GetAllianceParty1Count(void) const = 0;
    virtual unsigned int GetAllianceParty2Count(void) const = 0;
    virtual unsigned int GetAllianceInvitedFlag(void) const = 0;
};

///////////////////////////////////////////////////////////////////////////////////////////////////
//
// IPlayer
//
// Data object interface to obtain and set various information for the player.
//
///////////////////////////////////////////////////////////////////////////////////////////////////
struct IPlayer
{
    virtual unsigned int GetHPMax(void) const = 0;
    virtual unsigned int GetMPMax(void) const = 0;
    virtual unsigned char GetMainJob(void) const = 0;
    virtual unsigned char GetMainJobLevel(void) const = 0;
    virtual unsigned char GetSubJob(void) const = 0;
    virtual unsigned char GetSubJobLevel(void) const = 0;
    virtual unsigned short GetExpCurrent(void) const = 0;
    virtual unsigned short GetExpNeeded(void) const = 0;
    virtual short GetStat(int nStat) const = 0;
    virtual short GetStatMod(int nStat) const = 0;
    virtual unsigned short GetAttack(void) const = 0;
    virtual unsigned short GetDefense(void) const = 0;
    virtual short GetElement(int nElement) const = 0;
    virtual unsigned short GetTitle(void) const = 0;
    virtual unsigned short GetRank(void) const = 0;
    virtual unsigned short GetRankPoints(void) const = 0;
    virtual unsigned char GetNation(void) const = 0;
    virtual unsigned char GetResidence(void) const = 0;
    virtual unsigned int GetHomepoint(void) const = 0;
    virtual Ashita::FFXI::CombatSkill GetCombatSkill(int nSkill) const = 0;
    virtual Ashita::FFXI::CraftSkill GetCraftSkill(int nSkill) const = 0;
    virtual unsigned short GetLimitPoints(void) = 0;
    virtual unsigned char GetMeritPoints(void) = 0;
    virtual unsigned char GetLimitMode(void) = 0;
    virtual short* GetBuffs(void) const = 0;

    virtual bool HasKeyItem(unsigned int id) = 0;
    virtual bool HasAbility(unsigned int id) = 0;
    virtual bool HasSpell(unsigned int id) = 0;
    virtual bool HasTrait(unsigned int id) = 0;
    virtual bool HasPetCommand(unsigned int id) = 0;
    virtual bool HasWeaponSkill(unsigned int id) = 0;
};

///////////////////////////////////////////////////////////////////////////////////////////////////
//
// ITarget
//
// Data object interface to obtain and set various information for the target.
//
///////////////////////////////////////////////////////////////////////////////////////////////////
struct ITarget
{
    virtual const char* GetTargetName(void) const = 0;
    virtual unsigned int GetTargetHealthPercent(void) const = 0;

    virtual unsigned int GetTargetIndex(void) const = 0;
    virtual unsigned int GetTargetID(void) const = 0;
    virtual Ashita::FFXI::Entity* GetTargetEntity(void) const = 0;
    virtual unsigned int GetTargetWarpPtr(void) const = 0;
    virtual unsigned short GetTargetMask(void) const = 0;

    virtual unsigned int GetMainTargetIndex(void) const = 0;
    virtual unsigned int GetMainTargetID(void) const = 0;
    virtual Ashita::FFXI::Entity* GetMainTargetEntity(void) const = 0;
    virtual unsigned int GetMainTargetWarpPtr(void) const = 0;
    virtual unsigned short GetMainTargetMask(void) const = 0;

    virtual bool GetTargetLockedOn(void) const = 0;
    virtual bool GetSubTargetActive(void) const = 0;
    virtual bool GetTargetMenuOpened(void) const = 0;
};

///////////////////////////////////////////////////////////////////////////////////////////////////
//
// IDataManager
//
// Ashita data manager that exposes various data object interfaces for game information.
//
///////////////////////////////////////////////////////////////////////////////////////////////////
struct IDataManager
{
    virtual IEntity* GetEntity(void) = 0;
    virtual IInventory* GetInventory(void) = 0;
    virtual IParty* GetParty(void) = 0;
    virtual IPlayer* GetPlayer(void) = 0;
    virtual ITarget* GetTarget(void) = 0;
};

///////////////////////////////////////////////////////////////////////////////////////////////////
//
// IGuiManager
//
// Gui Manager interface that exposes various gui functions.
//
///////////////////////////////////////////////////////////////////////////////////////////////////
struct IGuiManager
{
    virtual int GetBarCount(void) = 0;

    // Bar object management..
    virtual AUiBar* CreateBar(const char* barName) = 0;
    virtual AUiBar* GetBarByIndex(int barIndex) = 0;
    virtual AUiBar* GetBarByName(const char* barName) = 0;
    virtual int DeleteBar(AUiBar* bar) = 0;
    virtual int DeleteAllBars(void) = 0;

    // Bar position management..
    virtual int SetBottomBar(const AUiBar* bar) = 0;
    virtual AUiBar* GetBottomBar(void) = 0;
    virtual int SetTopBar(const AUiBar* bar) = 0;
    virtual AUiBar* GetTopBar(void) = 0;

    // Bar specific functions..
    virtual const char* GetBarName(const AUiBar* bar) = 0;
    virtual int RefreshBar(const AUiBar* bar) = 0;
    virtual int RemoveVar(const AUiBar* bar, const char* name) = 0;
    virtual int RemoveAllVars(const AUiBar* bar) = 0;
    virtual int GetParam(const AUiBar* bar, const char* varName, const char* paramName, AUiParamValueType paramValueType, unsigned int outValueMaxCount, void* outValues) = 0;
    virtual int SetParam(const AUiBar* bar, const char* varName, const char* paramName, AUiParamValueType paramValueType, unsigned int inValueCount, const void* inValues) = 0;

    // Bar control creations..
    virtual int AddVarRW(const AUiBar* bar, const char* name, AUiType type, void* var, const char* def) = 0;
    virtual int AddVarRO(const AUiBar* bar, const char* name, AUiType type, const void* var, const char* def) = 0;
    virtual int AddVarCB(const AUiBar* bar, const char* name, AUiType type, AUiSetVarCallback setCallback, AUiGetVarCallback getCallback, void *clientData, const char* def) = 0;
    virtual int AddButton(const AUiBar* bar, const char* name, AUiButtonCallback callback, void *clientData, const char* def) = 0;
    virtual int AddSeparator(const AUiBar* bar, const char* name, const char* def) = 0;

    // Global management functions..
    virtual int Define(const char* def) = 0;
    virtual AUiType DefineEnum(const char* name, const AUiEnumVal* enumValues, unsigned int nbValues) = 0;
    virtual AUiType DefineEnumFromString(const char* name, const char* enumString) = 0;
    virtual AUiType DefineStruct(const char* name, const AUiStructMember* structMembers, unsigned int nbMembers, size_t structSize, AUiSummaryCallback summaryCallback, void* summaryClientData) = 0;
    virtual int RemoveStruct(const char* name) = 0;
    virtual void CopyCDStringToClientFunc(AUiCopyCDStringToClient copyCDStringFunc) = 0;
    virtual void CopyCDStringToLibrary(char **destinationLibraryStringPtr, const char *sourceClientString) = 0;
};

///////////////////////////////////////////////////////////////////////////////////////////////////
//
// IAshitaCore
//
// Main Ashita core interface that exposes the various other interfaces usable by Ashita plugins.
//
///////////////////////////////////////////////////////////////////////////////////////////////////
struct IAshitaCore
{
    virtual const char* GetAshitaInstallPathA(void) const = 0;
    virtual const wchar_t* GetAshitaInstallPathW(void) const = 0;
    virtual HMODULE GetHandle(void) const = 0;
    virtual HWND GetFFXiHwnd(void) const = 0;

    virtual IConfigurationManager* GetConfigurationManager(void) = 0;
    virtual IPointerManager* GetPointerManager(void) = 0;
    virtual IResourceManager* GetResourceManager(void) = 0;

    virtual IFontManager* GetFontManager(void) = 0;
    virtual IChatManager* GetChatManager(void) = 0;
    virtual IDataManager* GetDataManager(void) = 0;
    virtual IInputManager* GetInputManager(void) = 0;
    virtual IPacketManager* GetPacketManager(void) = 0;
    virtual IPluginManager* GetPluginManager(void) = 0;
    virtual IGuiManager* GetGuiManager(void) = 0;
};

///////////////////////////////////////////////////////////////////////////////////////////////////
//
// PluginData
//
// Plugin data that Ashita plugins expose to Ashita when being loaded.
//
///////////////////////////////////////////////////////////////////////////////////////////////////
struct PluginData
{
    char    Name[256];          // The name of this plugin.
    char    Author[256];        // The author of this plugin.
    double  InterfaceVersion;   // The interface version this plugin is compiled with.
    double  PluginVersion;      // The plugins version.
    int     Priority;           // The priority of this plugin.

    /**
     * @brief Default Constructor
     */
    PluginData(void)
    {
        strcpy_s(this->Name, sizeof(this->Name), "Unknown");
        strcpy_s(this->Author, sizeof(this->Author), "Ashita Development Team");

        this->InterfaceVersion = ASHITA_INTERFACE_VERSION;
        this->PluginVersion = 1.00f;
        this->Priority = 0;
    }

    /**
     * @brief Overload Constructor
     */
    PluginData(const char* name, const char* author, double dblInterfaceVersion, double dblPluginVersion, int nPriority)
    {
        strcpy_s(this->Name, sizeof(this->Name), name);
        strcpy_s(this->Author, sizeof(this->Author), author);
        this->InterfaceVersion = dblInterfaceVersion;
        this->PluginVersion = dblPluginVersion;
        this->Priority = nPriority;
    }
};

///////////////////////////////////////////////////////////////////////////////////////////////////
//
// IPlugin
//
// Main plugin interface that Ashita plugins must follow.
//
///////////////////////////////////////////////////////////////////////////////////////////////////
struct IPlugin
{
    virtual PluginData GetPluginData(void) = 0;

    // Main Plugin Handlers
    virtual bool Initialize(IAshitaCore* ashitaCore, DWORD dwPluginId) = 0;
    virtual void Release(void) = 0;

    // ChatManager
    virtual bool HandleCommand(const char* pszCommand, int nCommandType) = 0;
    virtual bool HandleNewChatLine(short sMode, char* pszChatLine) = 0;

    // PacketManager
    virtual bool HandleIncomingPacket(unsigned int uiPacketId, unsigned int uiPacketSize, void* lpRawData) = 0;
    virtual bool HandleOutgoingPacket(unsigned int uiPacketId, unsigned int uiPacketSize, void* lpRawData) = 0;

    // Direct3D
    virtual bool Direct3DInitialize(IDirect3DDevice8* lpDevice) = 0;
    virtual void Direct3DRelease(void) = 0;
    virtual void Direct3DPreRender(void) = 0;
    virtual void Direct3DRender(void) = 0;
};

///////////////////////////////////////////////////////////////////////////////////////////////////
//
// PluginBase
//
// Main base class that Ashita plugins inherit to ensure they follow the proper Ashita standard.
//
///////////////////////////////////////////////////////////////////////////////////////////////////
class PluginBase : public IPlugin
{
protected:
    IAshitaCore*        m_AshitaCore;       // The main Ashita Core object.
    DWORD               m_PluginId;         // The ID assigned to this plugin when it was loaded.
    IDirect3DDevice8*   m_Direct3DDevice;   // The Direct3D device object.

public:
    /**
     * @brief Constructor
     */
    PluginBase(void)
    { }

    /**
     * @brief Deconstructor
     */
    virtual ~PluginBase(void)
    { }

public:
    /**
     * @brief Gets the plugin data of this plugin.
     *
     * @return PluginData structure containing information of this plugin.
     */
    PluginData GetPluginData(void)
    {
        return PluginData("PluginBase", "Ashita Development Team", ASHITA_INTERFACE_VERSION, 1.0f, 0);
    }

public:
    /**
     * @brief Initializes this plugin and prepares it for use.
     *
     * @param ashitaCore            The main AshitaCore object exposed to plugins.
     * @param dwPluginId            The id of this plugin. (The base address where it was loaded.)
     *
     * @return True on success, false otherwise. (If false, the plugin will be unloaded.)
     */
    bool Initialize(IAshitaCore* ashitaCore, DWORD dwPluginId)
    {
        this->m_AshitaCore = ashitaCore;
        this->m_PluginId = dwPluginId;
        return false;
    }

    /**
     * @brief Releases this plugin, called when the plugin is being unloaded.
     */
    void Release(void)
    { }

public:
    /**
     * @brief Allows a plugin to attempt to handle a game command.
     *
     * @param pszCommand            The command being processed.
     * @param nCommandType          The type of command being processed.
     *
     * @return True on handled, false otherwise.
     */
    bool HandleCommand(const char* pszCommand, int nCommandType)
    {
        return false;
    }

    /**
     * @brief Allows a plugin to attempt to handle a new chat line.
     *
     * @param sMode                 The chat type being added.
     * @param pszChatLine           The chat line being added.
     *
     * @return True on handled, false otherwise.
     */
    bool HandleNewChatLine(short sMode, char* pszChatLine)
    {
        return false;
    }

    /**
     * @brief Allows a plugin to attempt to handle an incoming packet.
     *
     * @param uiPacketId            The id of the packet.
     * @param uiPacketSize          The size of the packet.
     * @param lpRawData             The raw packet data.
     *
     * @return True on handled, false otherwise.
     *
     * @note    Returning true on this will block the packet from being handled! This can
     *          have undesired effects! Use with caution as this can get you banned!
     */
    bool HandleIncomingPacket(unsigned int uiPacketId, unsigned int uiPacketSize, void* lpRawData)
    {
        return false;
    }

    /**
     * @brief Allows a plugin to attempt to handle an outgoing packet.
     *
     * @param uiPacketId            The id of the packet.
     * @param uiPacketSize          The size of the packet.
     * @param lpRawData             The raw packet data.
     *
     * @return True on handled, false otherwise.
     *
     * @note    Returning true on this will block the packet from being handled! This can
     *          have undesired effects! Use with caution as this can get you banned!
     */
    bool HandleOutgoingPacket(unsigned int uiPacketId, unsigned int uiPacketSize, void* lpRawData)
    {
        return false;
    }

public:
    /**
     * @brief Direct3D initialize call to prepare this plugin for Direct3D calls.
     *
     * @param lpDevice              The Direct3D device currently wrapped by Ashita.
     *
     * @return True on success, false otherwise.
     *
     * @note    Plugins that do not return true on this call will not receive any other
     *          Direct3D calls listed below!
     */
    bool Direct3DInitialize(IDirect3DDevice8* lpDevice)
    {
        this->m_Direct3DDevice = lpDevice;
        return false;
    }

    /**
     * @brief Direct3D release call to allow this plugin to cleanup any Direct3D objects.
     */
    void Direct3DRelease(void)
    { }

    /**
     * @brief Direct3D prerender call to allow this plugin to prepare for rendering.
     */
    void Direct3DPreRender(void)
    { }

    /**
     * @brief Direct3D render call to allow this plugin to render any custom things.
     */
    void Direct3DRender(void)
    { }
};

///////////////////////////////////////////////////////////////////////////////////////////////////
//
// Plugin Exports
//
// The following are functions that each plugin MUST export in order for it to be able to be 
// loaded within Ashita.
//
// If a plugin does not properly export these functions, it will be rejected from loading.
//
// Plugins must export the following functions:
//      GetInterfaceVersion
//      CreatePluginData
//      CreatePlugin
//
///////////////////////////////////////////////////////////////////////////////////////////////////

typedef double(__stdcall *GetInterfaceVersionFunc)(void);
typedef void(__stdcall *CreatePluginDataFunc)(PluginData* lpBuffer);
typedef IPlugin* (__stdcall *CreatePluginFunc)(char* pszUnused);

#endif // __ASHITA_ADK_ASHITA_H_INCLUDED__
