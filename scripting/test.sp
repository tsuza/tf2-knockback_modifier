#include <sourcemod>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_NAME		   "[TF2-CA] Knockback Modifier"
#define PLUGIN_AUTHOR	   "tsuza"
#define PLUGIN_DESCRIPTION "Utilizes Nosoop's Framework. It lets you change the knockback of weapons."
#define PLUGIN_VERSION	   "0.1.0"
#define PLUGIN_URL		   "https://github.com/tsuza/TF2CA-weaponmodel_override"
public Plugin myinfo =
{
	name		= PLUGIN_NAME,
	author		= PLUGIN_AUTHOR,
	description = PLUGIN_DESCRIPTION,
	version		= PLUGIN_VERSION,
	url			= PLUGIN_URL


}
// ||──────────────────────────────────────────────────────────────────────────||
// ||                               SOURCEMOD API                              ||
// ||──────────────────────────────────────────────────────────────────────────||
public void
	OnPluginStart()
{
	for (int i = 0; i < 10000; i++)
	{
		PrintToServer("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua");
	}

	return;
}