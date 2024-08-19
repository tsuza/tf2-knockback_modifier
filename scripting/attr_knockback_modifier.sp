#include <sourcemod>

#include <tf2>
#include <tf2_stocks>

#include <tf2attributes>
#include <tf_custom_attributes>

#include <sdkhooks>
#include <sdktools>
#include <dhooks>

#include <stocksoup/memory>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_NAME         "[TF2-CA] Knockback Modifier"
#define PLUGIN_AUTHOR       "tsuza"
#define PLUGIN_DESCRIPTION  "Utilizes Nosoop's Framework. It lets you change the knockback of weapons."
#define PLUGIN_VERSION      "0.1.0"
#define PLUGIN_URL          "https://github.com/tsuza/TF2CA-weaponmodel_override"

public Plugin myinfo =
{
    name        =   PLUGIN_NAME,
    author      =   PLUGIN_AUTHOR,
    description =   PLUGIN_DESCRIPTION,
    version     =   PLUGIN_VERSION,
    url         =   PLUGIN_URL
}

// ||──────────────────────────────────────────────────────────────────────────||
// ||                              GLOBAL VARIABLES                            ||
// ||──────────────────────────────────────────────────────────────────────────||

enum eTakeDamageInfo: (+= 0x04) {
    // Vectors.
    m_DamageForce,
    m_DamagePosition = 12,
    m_ReportedPosition = 24,

    m_Inflictor = 36,
    m_Attacker,
    m_Weapon,
    m_Damage,
    m_MaxDamage,
    m_BaseDamage,
    m_BitsDamageType,
    m_DamageCustom,
    m_DamageStats,
    m_AmmoType,
    m_DamagedOtherPlayers,
    m_PlayerPenetrationCount,
    m_DamageBonus,
    m_DamageBonusProvider,
    m_ForceFriendlyFire,
    m_DamageForForce,
    m_CritType
};

// ||──────────────────────────────────────────────────────────────────────────||
// ||                               SOURCEMOD API                              ||
// ||──────────────────────────────────────────────────────────────────────────||

public void OnPluginStart()
{
    GameData hGameConf = new GameData("tf2.knockback_modifier");

    if(!hGameConf)
        SetFailState("Failed to get gamedata: tf2.knockback_modifier");

    DynamicDetour dtApplyPushFromDamage = DynamicDetour.FromConf(hGameConf, "CTFPlayer::ApplyPushFromDamage()");

    if(!dtApplyPushFromDamage)
        SetFailState("Failed to setup detour for CTFPlayer::ApplyPushFromDamage()");

    dtApplyPushFromDamage.Enable(Hook_Pre, OnApplyPushFromDamagePre);
    dtApplyPushFromDamage.Enable(Hook_Post, OnApplyPushFromDamagePost);

    delete hGameConf;

    return;
}

// ||──────────────────────────────────────────────────────────────────────────||
// ||                                EVENTS                                    ||
// ||──────────────────────────────────────────────────────────────────────────||

// void CTFPlayer::ApplyPushFromDamage( const CTakeDamageInfo &info, Vector vecDir )
public MRESReturn OnApplyPushFromDamagePre(int iClient, DHookParam hParams)
{
    // Getting the address of const CTakeDamageInfo &info.
    Address aTakeDamageInfo = hParams.Get(1);

    // Retrieving the weapon entity by offsetting the address above.
    int iWeapon = LoadEntityHandleFromAddress(AddressOffset(aTakeDamageInfo, m_Weapon));

    if(iWeapon <= 0 || !IsValidEntity(iWeapon))
        return MRES_Ignored;

    if(!IsValidClient(iClient))
        return MRES_Ignored;

    float fModifyKnockback = TF2CustAttr_GetFloat(iWeapon, "knockback modifier", -1.0);

    // It means that the weapon doesn't have that custom attribute.
    if(fModifyKnockback == -1.0)
        return MRES_Ignored;

    // Computers don't like dividing by zero.
    if(fModifyKnockback == 0.0)
        fModifyKnockback = 0.00001;

    float fCurrentKnockback = TF2Attrib_GetFloatValueFromName(iClient, "damage force increase hidden");

    float fNewKnockback = fCurrentKnockback * fModifyKnockback;

    TF2Attrib_AddCustomPlayerAttribute(iClient, "damage force increase hidden", fNewKnockback);

    return MRES_Ignored;
}

// void CTFPlayer::ApplyPushFromDamage( const CTakeDamageInfo &info, Vector vecDir )
public MRESReturn OnApplyPushFromDamagePost(int iClient, DHookParam hParams)
{
    // Getting the address of const CTakeDamageInfo &info.
    Address aTakeDamageInfo = hParams.Get(1);

    // Retrieving the weapon entity by offsetting the address above.
    int iWeapon = LoadEntityHandleFromAddress(AddressOffset(aTakeDamageInfo, m_Weapon));

    if(iWeapon <= 0 || !IsValidEntity(iWeapon))
        return MRES_Ignored;

    if(!IsValidClient(iClient))
        return MRES_Ignored;

    float fModifyKnockback = TF2CustAttr_GetFloat(iWeapon, "knockback modifier", -1.0);

    // It means that the weapon doesn't have that custom attribute.
    if(fModifyKnockback == -1.0)
        return MRES_Ignored;

    // Computers don't like dividing by zero.
    if(fModifyKnockback == 0.0)
        fModifyKnockback = 0.00001;

    // Retrieving the original knockback ( the one before we changed theirs ) by doing math.
    float fOldKnockback = TF2Attrib_GetFloatValueFromName(iClient, "damage force increase hidden") / fModifyKnockback;

    TF2Attrib_RemoveCustomPlayerAttribute(iClient, "damage force increase hidden");

    TF2Attrib_AddCustomPlayerAttribute(iClient, "damage force increase hidden", fOldKnockback);

    return MRES_Ignored;
}

// ||──────────────────────────────────────────────────────────────────────────||
// ||                           Internal Functions                             ||
// ||──────────────────────────────────────────────────────────────────────────||

stock bool IsValidClient(int client)
{
    if(client <= 0 || client > MaxClients)
        return false;

    if(!IsClientInGame(client))
        return false;

    if(GetEntProp(client, Prop_Send, "m_bIsCoaching"))
        return false;

    return true;
}

Address AddressOffset(Address pAddr, int iOffset)
{
    return pAddr + view_as<Address>(iOffset);
}

float TF2Attrib_GetFloatValueFromName(int iClient, char[] sAttributeName)
{
    Address pAttribute = TF2Attrib_GetByName(iClient, sAttributeName);

    // If the client doesn't have the attribute they'll return Address_Null, an invalid address.
    // If we don't check for it, it'll spam errors since it's checking reserved memory ( 0x8 ).
    if(!pAttribute)
        return 1.0;

    float fValue = TF2Attrib_GetValue(pAttribute);

    return fValue;
}
