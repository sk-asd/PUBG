#define T           2   /**< Terrorists. */
#define CT          3   /**< Counter-Terrorists. */
#define LoopAllTerrorist(%1) for (int %1 = 1; %1 <= MaxClients; %1++) if (IsClientInGame(%1) && GetClientTeam(%1) == T)
#define foreachPlayer(%1) for (int %1 = 1; %1 <= MaxClients; %1++) if (IsClientInGame(%1) && !IsFakeClient(%1))
#define PLUGIN_TAG                "[Sourcepawn.com]"
#define POSITION_X                "POSITION_X"
#define POSITION_Y                "POSITION_Y"
#define POSITION_Z                "POSITION_Z"
#define MODEL_BEAM "materials/sprites/laserbeam.vmt"

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

ArrayList ARRAY_Spawns = null;

int g_iBeamSprite = -1, 
g_iHaloSprite = -1, 
g_iTeammates[MAXPLAYERS + 1] = { 0, ... }, 
hazirlanma = -1, 
kacles[MAXPLAYERS] = { 0, ... }, 
dropmodel = -1;

bool g_bAktif = false, 
dropvar = false;

ConVar g_hazirlanma = null;
ConVar g_cOnlyWarden = null;

float can = 0.0, dropyeri[3] = { 0.0, ... }, silahlar[3] = { 0.0, ... }, TargetOrigin[3] = { 0.0, ... }; 

float g_fexpcoordinate[3];
float koordinat[3] = 0.0;
float yeniaci[3];
float aci[3] = 90.0;
float ikincisira[3] = 0.0;
float anan2[3] = 0.0;
float ah[3] = 0.0;

int g_iPathLaserModelIndex;
int kac = 0;
int kac2 = 0;
int kac3 = 0;
int kac4 = 0;
int aan = 1;
