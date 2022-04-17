#define T           2   /**< Terrorists. */
#define CT          3   /**< Counter-Terrorists. */
#define LoopAllTerrorist(%1) for (int %1 = 1; %1 <= MaxClients; %1++) if (IsClientInGame(%1) && GetClientTeam(%1) == T)
#define foreachPlayer(%1) for (int %1 = 1; %1 <= MaxClients; %1++) if (IsClientInGame(%1) && !IsFakeClient(%1))
#define PLUGIN_TAG                "[Sourcepawn.com]"
#define POSITION_X                "POSITION_X"
#define POSITION_Y                "POSITION_Y"
#define POSITION_Z                "POSITION_Z"

char dosyayolu[PLATFORM_MAX_PATH];

char g_szWeapons[][] = {
    "weapon_ak47", "weapon_m4a1_silencer", "weapon_m4a1", "weapon_famas", "weapon_mag7", "weapon_p90", 
    "weapon_deagle", "weapon_fiveseven", "weapon_ssg08", "weapon_taser", "weapon_breachcharge",
};

char g_OzelSilah[][] = {
    "weapon_ak47", "weapon_awp", "weapon_m4a1", "weapon_m4a1_silencer", "weapon_awp", "weapon_aug", 
};

char g_OzelBombalar[][] = {
    "weapon_hegrenade", "weapon_smokegrenade", "weapon_molotov", "weapon_tagrenade", "weapon_bumpmine", "weapon_breachcharge",
};

Handle ARRAY_Spawns;

int g_iBeamSprite = -1, g_iHaloSprite = -1;
int g_iTeammates[MAXPLAYERS + 1] = { 0 };
int hazirlanma;
int g_okacinci;
int kacles[MAXPLAYERS];
int dropmodel;

bool g_bAktif = false;
bool dropvar = false;

ConVar g_hazirlanma = null;

float can = 0.0;

float dropyeri[3], silahlar[3];
float TargetOrigin[3], Distance;