#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <basecomm>
#include <overlays>

#pragma semicolon 1
#pragma newdecls required
#pragma tabsize 0

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
	"weapon_ak47", "weapon_m4a1_silencer", "weapon_m4a1", "weapon_famas", "weapon_mag7", "weapon_mp7", "weapon_ump45", "weapon_bizon", "weapon_mp5sd", "weapon_mac10", "weapon_mp9", 
	"weapon_deagle", "weapon_fiveseven", "weapon_tec9", "weapon_revolver", "weapon_smokegrenade", 
	"weapon_bumpmine", "weapon_hegrenade", "weapon_molotov", "weapon_taser", 
};

Handle ARRAY_Spawns;

int g_iBeamSprite = -1, g_iHaloSprite = -1;
int g_iTeammates[MAXPLAYERS + 1] = { 0 };
int hazirlanma;
int g_okacinci;
int kacles[MAXPLAYERS];

bool g_bAktif = false;

ConVar g_hazirlanma = null;

public Plugin myinfo = 
{
	name = "PUBG Oyunu", 
	author = "phiso, hibna", 
	description = "Jailbreak modu için pubg oyunu", 
	version = "1.0", 
	url = "sourcepawn.com"
};

public void OnMapStart()
{
	char mapName[45];
	GetCurrentMap(mapName, sizeof(mapName));
	
	g_iBeamSprite = PrecacheModel("materials/sprites/laserbeam.vmt");
	g_iHaloSprite = PrecacheModel("materials/sprites/glow06.vmt");
	
	AddFileToDownloadsTable("models/sourcepawn_com/silah.dx90.vtx");
	AddFileToDownloadsTable("models/sourcepawn_com/silah.mdl");
	AddFileToDownloadsTable("models/sourcepawn_com/silah.phy");
	AddFileToDownloadsTable("models/sourcepawn_com/silah.vvd");
	AddFileToDownloadsTable("materials/models/sourcepawn_com/pubg_silah.vmt");
	AddFileToDownloadsTable("materials/models/sourcepawn_com/pubg_silah.vtf");
	PrecacheModel("models/sourcepawn_com/PUBG/silah.mdl");
	AddFileToDownloadsTable("materials/sourcepawn_com/br_winner.vtf");
	AddFileToDownloadsTable("materials/sourcepawn_com/br_winner.vmt");
	
	AddFileToDownloadsTable("sound/sourcepawn_com/silah.mp3");
	PrecacheSound("sourcepawn_com/silah.mp3");
	AddFileToDownloadsTable("sound/sourcepawn_com/winnersound.mp3");
	PrecacheSound("sourcepawn_com/winnersound.mp3");
	PrecacheSound("buttons/button14.wav");
	
	LoadConfiguration(mapName);
}


public void OnPluginStart()
{
	RegConsoleCmd("sm_pubgayarla", PubgAyar);
	RegConsoleCmd("sm_pubgphiso", PubgBaslat);
	RegConsoleCmd("sm_pubgphiso0", Pubg0);
	RegConsoleCmd("sm_pubgtakimol", CMD_PubgTakim);
	
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("round_start", elbasladibitti);
	HookEvent("round_end", elbasladibitti);
	
	BuildPath(Path_SM, dosyayolu, sizeof(dosyayolu), "configs/pubgalan");
	if (!DirExists(dosyayolu))
		CreateDirectory(dosyayolu, 0o777);
	
	ARRAY_Spawns = CreateArray();
	
	g_hazirlanma = CreateConVar("sm_pubgg_hazirlanma", "20", "Pubgye hazırlanmaları için kaç saniyeleri olsun?");
	HookConVarChange(g_hazirlanma, hazirdegisti);
	
	AutoExecConfig(true, "PUBG", "Sourcepawn.Com");
}

public void OnMapEnd()
{
	SaveConfiguration();
}

public Action elbasladibitti(Event event, const char[] name, bool db) { g_bAktif = false; hazirlanma = -1; SetCvar("mp_teammates_are_enemies", 0); SetCvar("mp_friendlyfire", 0); SilahTemizle(); foreachPlayer(player) { SetEntityMoveType(player, MOVETYPE_WALK); SDKUnhook(player, SDKHook_OnTakeDamage, OnTakeDamage); g_iTeammates[player] = 0; SetListenOverride(player, player, Listen_Yes); bool muteliymis[MAXPLAYERS + 1] = { false, ... }; if (BaseComm_IsClientMuted(player)) { muteliymis[player] = true; } SetListenOverride(player, muteliymis[player], Listen_No); } }

public void hazirdegisti(ConVar convar, const char[] oldValue, const char[] newValue) { hazirlanma = StringToInt(newValue); }

public Action Pubg0(int client, int args)
{
	if (g_bAktif == true)
	{
		g_bAktif = false;
		hazirlanma = -1;
		SetCvar("mp_teammates_are_enemies", 0);
		SetCvar("mp_friendlyfire", 0);
		SilahTemizle();
		YeriTemizle();
		LoopAllTerrorist(i)
		{
			SetEntityMoveType(i, MOVETYPE_WALK);
			ClearWeaponEx(i);
			GivePlayerItem(i, "weapon_knife");
		}
		foreachPlayer(player)
		{
			SDKUnhook(player, SDKHook_OnTakeDamage, OnTakeDamage);
			g_iTeammates[player] = 0;
			PrintToChat(player, "[SM] \x02%N \x04isimli yetkili pubg oyununu durdurdu!");
			SetListenOverride(player, player, Listen_Yes);
			bool muteliymis[MAXPLAYERS + 1] = { false, ... };
			if (BaseComm_IsClientMuted(player))
				muteliymis[player] = true;
			SetListenOverride(player, muteliymis[player], Listen_No);
		}
	}
	else
	{
		PrintToChat(client, "[SM] \x04Şu anda zaten bir \x02pubg \x04oyunu oynanmıyor!");
	}
}

public Action PubgBaslat(int client, int args)
{
	if (g_bAktif == false)
	{
		Panel wpanel = new Panel();
		char Mesaj[256];
		char sure[32];
		g_hazirlanma.GetString(sure, sizeof(sure));
		int suremenu = StringToInt(sure);
		Format(Mesaj, sizeof(Mesaj), "!- PUBG Oyunu Başlatıldı -!\n%d saniye sonra başlatılacak\n ", suremenu);
		wpanel.SetTitle(Mesaj, false);
		wpanel.DrawText("▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬");
		wpanel.DrawText("!pubgtakimol yazarak bir takım oluşturun.");
		wpanel.DrawText("Takım olanlar kendi aralarında sesli olarak konuşabilir.");
		wpanel.DrawText("Seslerini sadece takım arkadaşları duyar.");
		wpanel.DrawText("Oyun başladığında loot'lanarak düşmanları öldürün.\n ");
		wpanel.CurrentKey = 4;
		wpanel.DrawItem("Kapat.");
		hazirlanma = suremenu;
		g_bAktif = true;
		CreateTimer(1.0, countdown, _, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
		PrintToChatAll("[SM] \x02%N \x04Pubg oyununu başlattı!", client);
		YeriTemizle();
		LoopAllTerrorist(i)
		{
			ClearWeaponEx(i);
			SetEntityMoveType(i, MOVETYPE_NONE);
			RastgeleIsinla(i);
			wpanel.Send(i, callback, suremenu);
		}
		delete wpanel;
	}
	else
	{
		PrintToChat(client, "[SM] \x04Şu an bir \x02pubg \x04oyunu oynanıyor!");
	}
}

public int callback(Menu menu, MenuAction action, int client, int item) { if (action == MenuAction_Select) {  } else if (action == MenuAction_End) {  } }

stock void RastgeleIsinla(int oyuncu)
{
	int spawnID = GetRandomInt(0, g_okacinci - 1);
	Handle positions = GetArrayCell(ARRAY_Spawns, spawnID);
	
	float newSpawn[3];
	GetTrieValue(positions, POSITION_X, newSpawn[0]);
	GetTrieValue(positions, POSITION_Y, newSpawn[1]);
	GetTrieValue(positions, POSITION_Z, newSpawn[2]);
	
	TeleportEntity(oyuncu, newSpawn, NULL_VECTOR, NULL_VECTOR);
}

public Action countdown(Handle timer)
{
	if (hazirlanma == -1 || !g_bAktif)
	{
		return Plugin_Stop;
	}
	
	if (hazirlanma == 0)
	{
		KeyValues kv = CreateKeyValues("pubgsilah");
		char map[64];
		float origin[3] = 0.0;
		GetCurrentMap(map, sizeof(map));
		StringToLowerCase(map);
		BuildPath(Path_SM, dosyayolu, sizeof(dosyayolu), "configs/pubgalan/%s_silah.txt", map);
		FileToKeyValues(kv, dosyayolu);
		if (!kv.GotoFirstSubKey())
		{
			delete kv;
			return Plugin_Handled;
		}
		do
		{
			kv.GetVector("Koordinat", origin); //modelspawn yapılacak
			SilahOlustur(origin, "models/sourcepawn_com/silah.mdl");
		}
		while (kv.GotoNextKey());
		delete kv;
		hazirlanma = -1;
		char sBuffer[512];
		Format(sBuffer, sizeof(sBuffer), "<font color='#FF0000'>!-</font> <font color='#00FF00'>PUBG OYUNU BAŞLADI</font> <font color='#FF0000'>-!</font>");
		ShowStatusMessage(-1, sBuffer, 2);
		SetCvar("mp_teammates_are_enemies", 1);
		SetCvar("mp_friendlyfire", 1);
		LoopAllTerrorist(i)
		{
			ClearWeaponEx(i);
			SetEntityMoveType(i, MOVETYPE_WALK);
			int taser = CreateEntityByName("weapon_fists");
			if (taser != -1)
			{
				DispatchSpawn(taser);
				EquipPlayerWeapon(i, taser);
			}
		}
		return Plugin_Handled;
	}
	else
	{
		if (hazirlanma >= 1)
		{
			hazirlanma--;
			char sBuffer[512];
			Format(sBuffer, sizeof(sBuffer), "<font color='#00FF00'>%d</font> <font color='#FF0000'>saniye sonra oyun başlayacak!</font> <font color='#F0E68C'>!pubgtakimol</font>", hazirlanma);
			ShowStatusMessage(-1, sBuffer, 2);
			PrintHintTextToAll("<font size='20' color='#00FF00'>%d</font> <font size='20' color='#FF0000'>saniye sonra oyun başlayacak</font> <font size='20' color='#F0E68C'>!pubgtakimol</font>", hazirlanma);
			return Plugin_Continue;
		}
	}
	return Plugin_Handled;
}

public Action CMD_PubgTakim(int client, int args)
{
	if (hazirlanma != -1)
	{
		if (GetClientTeam(client) == T)
		{
			Menu takimm = new Menu(TakimMenuCallBack);
			takimm.SetTitle("[PUBG] Takım Menüsü");
			if (g_iTeammates[client] != 0)
				takimm.AddItem("ayrıl", "Takımdan Ayrıl");
			else
			{
				LoopAllTerrorist(i)
				{
					if (IsPlayerAlive(i) && i != client)
					{
						char name[32], id[32];
						GetClientName(i, name, 32);
						FormatEx(id, 32, "%d", GetClientUserId(i));
						takimm.AddItem(id, name);
					}
				}
				takimm.Display(client, MENU_TIME_FOREVER);
			}
		}
	}
	else
	{
		PrintToChat(client, "[SM] \x01Aktif bir PUBG oyunu yok!");
	}
}


public int TakimMenuCallBack(Menu menu, MenuAction action, int client, int position)
{
	if (action == MenuAction_Select)
	{
		char item[32];
		menu.GetItem(position, item, 32);
		if (strcmp(item, "ayrıl") == 0)
		{
			PrintToChat(client, "[SM] \x10%N \x01Takımdan ayrıldı!", g_iTeammates[client]);
			PrintToChat(g_iTeammates[client], "[SM] \x10%N \x01Takımdan ayrıldı!", client);
			g_iTeammates[client] = 0;
			g_iTeammates[g_iTeammates[client]] = 0;
			
			LoopAllTerrorist(i)
			{
				SetListenOverride(i, client, Listen_Yes);
				SetListenOverride(i, g_iTeammates[client], Listen_Yes);
			}
		}
		else
		{
			int target = GetClientOfUserId(StringToInt(item));
			if (g_iTeammates[client] == 0 && g_iTeammates[target] == 0)
			{
				PrintToChat(target, "[SM] \x10%N \x01Takım daveti gönderdi.", client);
				OnayMenu(target, client);
			}
			else
			{
				PrintToChat(client, "[SM] \x01Senin veya seçtiğin kişinin zaten takımı var!");
			}
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
}

public void OnayMenu(int client, int gonderen)
{
	Menu onaym = new Menu(OnayMenuCallBack);
	onaym.SetTitle("%N Takım Daveti Yolladı", gonderen);
	onaym.AddItem("kabul", "Kabul Et!");
	onaym.AddItem("red", "Reddet!");
	
	g_iTeammates[client] = gonderen;
	g_iTeammates[gonderen] = client;
	
	onaym.ExitButton = false;
	onaym.Display(client, 10);
}

public int OnayMenuCallBack(Menu menu, MenuAction action, int client, int itemNum)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		menu.GetItem(itemNum, info, sizeof(info));
		if (strcmp(info, "kabul") == 0)
		{
			float vecPosition[3];
			GetClientAbsOrigin(g_iTeammates[client], vecPosition);
			PrintToChatAll("[SM] \x10%N \x01adlı oyuncu ile \x10%N \x01Takım oldu!", client, g_iTeammates[client]);
			TeleportEntity(client, vecPosition, NULL_VECTOR, NULL_VECTOR);
			
			LoopAllTerrorist(i)
			{
				SetListenOverride(i, client, Listen_No);
				SetListenOverride(i, g_iTeammates[client], Listen_No);
			}
			
			SetListenOverride(g_iTeammates[client], client, Listen_Yes);
			SetListenOverride(client, g_iTeammates[client], Listen_Yes);
			
			SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
			SDKHook(g_iTeammates[client], SDKHook_OnTakeDamage, OnTakeDamage);
		}
		else if (strcmp(info, "red") == 0)
		{
			PrintToChat(g_iTeammates[client], "[SM] \x10%N \x01adlı oyuncu Takım isteğini \x02reddetti!", client);
			g_iTeammates[client] = 0;
			g_iTeammates[g_iTeammates[client]] = 0;
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{
	if (g_bAktif == true)
	{
		if (g_iTeammates[attacker] == victim)
		{
			damage = 0.0;
			return Plugin_Changed;
		}
	}
	return Plugin_Continue;
}

public Action OnStartTouch(int entity, int client)
{
	if (g_bAktif == true)
	{
		if (IsValidClient(client) && IsPlayerAlive(client))
		{
			GivePlayerItem(client, g_szWeapons[GetRandomInt(0, sizeof(g_szWeapons) - 1)]);
			Give_Effect(client, { 255, 0, 0, 130 } );
			int m_iRotator = GetEntPropEnt(entity, Prop_Send, "m_hEffectEntity");
			if (m_iRotator && IsValidEdict(m_iRotator))
				AcceptEntityInput(m_iRotator, "Kill");
			CreateTimer(0.0, Remove_Entity, entity);
			SDKUnhook(entity, SDKHook_StartTouch, OnStartTouch);
			
			EmitSoundToClient(client, "sourcepawn_com/silah.mp3");
		}
	}
}

public Action PubgAyar(int client, int args)
{
	if (IsValidClient(client))
	{
		Panel menu = new Panel();
		menu.SetTitle("✯ Pubg Ayar Menüsü ✯");
		menu.DrawText("▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬");
		menu.CurrentKey = 1;
		menu.DrawItem("✦ Silah Konumu Ekle");
		menu.CurrentKey = 2;
		menu.DrawItem("✦ Oyuncu Konumu Ekle");
		menu.DrawText("▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬");
		menu.CurrentKey = 4;
		menu.DrawItem("✦ Silah Konumu Sil");
		menu.CurrentKey = 5;
		menu.DrawItem("✦ Oyuncu Konumu Sil");
		menu.DrawText("▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬");
		menu.CurrentKey = 6;
		menu.DrawItem("✦ Konumları Kaydet");
		menu.DrawText("▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬");
		menu.DrawText("➔ Oyuncu konumu oluşturduktan sonra kaydetip çıkın!");
		menu.CurrentKey = 9;
		menu.DrawItem("Çık.");
		menu.Send(client, AyarMenu, MENU_TIME_FOREVER);
		delete menu;
	}
}

public int AyarMenu(Menu menu, MenuAction action, int client, int item)
{
	if (action == MenuAction_Select)
	{
		EmitSoundToClient(client, "buttons/button14.wav");
		if (item == 1)
		{
			char map[64];
			char format[512];
			GetCurrentMap(map, sizeof(map));
			StringToLowerCase(map);
			BuildPath(Path_SM, dosyayolu, sizeof(dosyayolu), "configs/pubgalan/%s_silah.txt", map);
			if (!FileExists(dosyayolu))
			{
				Handle file = OpenFile(dosyayolu, "w+");
				CloseHandle(file);
			}
			
			KeyValues kv = new KeyValues("pubgsilah");
			kv.ImportFromFile(dosyayolu);
			Format(format, sizeof(format), "%i", GetRandomInt(0, 100000));
			kv.JumpToKey(format, true);
			float origin[3] = 0.0;
			GetClientAimText(client, origin);
			kv.SetVector("Koordinat", origin);
			kv.Rewind();
			kv.ExportToFile(dosyayolu);
			delete kv;
			PrintCenterText(client, "Pubg silah ayarı başarı ile yapıldı.");
			PubgAyar(client, 0);
		}
		else if (item == 2)
		{
			float newSpawn[3];
			GetClientAbsOrigin(client, newSpawn);
			g_okacinci++;
			
			Handle trie = CreateTrie();
			SetTrieValue(trie, POSITION_X, newSpawn[0]);
			SetTrieValue(trie, POSITION_Y, newSpawn[1]);
			SetTrieValue(trie, POSITION_Z, newSpawn[2]);
			PushArrayCell(ARRAY_Spawns, trie);
			
			PrintCenterText(client, "Pubg oyuncu spawn noktası ayarı başarı ile yapıldı.");
			
			SaveConfiguration();
			PubgAyar(client, 0);
		}
		else if (item == 4)
		{
			char map[64];
			GetCurrentMap(map, sizeof(map));
			StringToLowerCase(map);
			BuildPath(Path_SM, dosyayolu, sizeof(dosyayolu), "configs/pubgalan/%s_silah.txt", map);
			if (FileExists(dosyayolu))
			{
				DeleteFile(dosyayolu);
				PrintCenterText(client, "Pubg silah spawn noktaları sıfırlandı.");
			}
			PubgAyar(client, 0);
		}
		else if (item == 5)
		{
			char map[64];
			GetCurrentMap(map, sizeof(map));
			StringToLowerCase(map);
			BuildPath(Path_SM, dosyayolu, sizeof(dosyayolu), "configs/pubgalan/%s_oyuncu.cfg", map);
			if (FileExists(dosyayolu))
			{
				ClearArray(ARRAY_Spawns);
				DeleteFile(dosyayolu);
				PrintCenterText(client, "Pubg oyuncu spawn noktaları sıfırlandı.");
			}
			PubgAyar(client, 0);
			g_okacinci = 0;
		}
		else if (item == 6)
		{
			char filename[64];
			GetPluginFilename(INVALID_HANDLE, filename, sizeof(filename));
			ServerCommand("sm plugins reload %s", filename);
			PrintCenterText(client, "Pubg konumları başarılı bir şekilde kaydedildi.");
		}
	}
	else if (action == MenuAction_End)
	{
		
	}
}

public Action Event_PlayerDeath(Handle event, const char[] name, bool dontBroadcast)
{
	if (g_bAktif == true)
	{
		int client = GetClientOfUserId(GetEventInt(event, "userid"));
		int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
		int takimarkadasi = g_iTeammates[attacker];
		kacles[attacker]++;
		
		if (IsValidClient(client))
			g_iTeammates[client] = 0;
		
		int yasayant = 0;
		LoopAllTerrorist(i)
		{
			if (IsPlayerAlive(i))
				yasayant++;
		}
		if (yasayant == 1)
		{
			PrintToChatAll("[SM] \x01PUBG Oyunu bitti! \x10%N \x01oyunu kazandı!", attacker);
			ServerCommand("sm_pubgphiso0");
			char format[512], attname[32];
			GetClientName(attacker, attname, sizeof(attname));
			Format(format, sizeof(format), "Oyun bitti. %i leş ile %s kazandı, tebrikler!", kacles[attacker], attname);
			ShowStatusMessage(-1, format, 5);
			foreachPlayer(i)
			{
				ShowOverlay(i, "sourcepawn_com/br_winner", 5.0);
				EmitSoundToClient(i, "sourcepawn_com/winnersound.mp3");
			}
			//overlay + bitiş sesi
		}
		else if (yasayant == 2)
		{
			if (IsValidClient(takimarkadasi))
			{
				if (IsPlayerAlive(takimarkadasi))
				{
					if (g_iTeammates[attacker] == takimarkadasi)
					{
						PrintToChatAll("[SM] \x01PUBG Oyunu bitti! \x10%N \x01ile \x10%N \x01oyunu kazandı!", attacker, takimarkadasi);
						ServerCommand("sm_pubgphiso0");
						char format[512], attname[32], tname[32];
						GetClientName(attacker, attname, sizeof(attname));
						GetClientName(takimarkadasi, tname, sizeof(tname));
						int kaclesaldilar = kacles[attacker] + kacles[takimarkadasi];
						Format(format, sizeof(format), "Oyun bitti. toplam %i leş ile %s ve %s kazandı, tebrikler!", kaclesaldilar, attname, tname);
						ShowStatusMessage(-1, format, 5);
						foreachPlayer(i)
						{
							ShowOverlay(i, "sourcepawn_com/br_winner", 5.0);
							EmitSoundToClient(i, "sourcepawn_com/winnersound.mp3");
						}
					}
				}
			}
		}
	}
}


/*

	Stocks
	
*/

stock bool IsValidClient(int client)
{
	if (!(1 <= client <= MaxClients) || !IsClientInGame(client) || IsFakeClient(client) || IsClientSourceTV(client) || IsClientReplay(client))
	{
		return false;
	}
	return true;
}

stock void StringToLowerCase(char[] szInput)
{
	int iIterator = 0;
	
	while (szInput[iIterator] != EOS)
	{
		if (!IsCharLower(szInput[iIterator]))szInput[iIterator] = CharToLower(szInput[iIterator]);
		else szInput[iIterator] = szInput[iIterator];
		
		iIterator++;
	}
	
	szInput[iIterator + 1] = EOS;
}
public void GetClientAimText(int client, float fPos[3])
{
	float pos[3] = 0.0;
	float ang[3] = 0.0;
	GetClientEyePosition(client, pos);
	GetClientEyeAngles(client, ang);
	Handle tr = TR_TraceRayFilterEx(pos, ang, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer, client);
	float fVec[3] = 0.0;
	TR_GetEndPosition(fPos, tr);
	TR_GetPlaneNormal(tr, fVec);
	TE_SetupBeamRingPoint(fPos, 1.0, 75.0, g_iBeamSprite, g_iHaloSprite, 0, 10, 0.5, 10.0, 0.0, { 255, 147, 0, 255 }, 5, 0);
	TE_SendToAll();
	tr.Close();
}

public bool TraceEntityFilterPlayer(int entity, int contentsMask)
{
	return entity > MaxClients;
}

stock int GetRandomPlayer(int team = -1, bool OnlyAlive = false)
{
	int[] clients = new int[MaxClients];
	int clientCount;
	for (int i = 1; i <= MaxClients; i++)
	{
		if ((team == -1 || GetClientTeam(i) == team) && (!OnlyAlive || !IsPlayerAlive(i)))
		{
			clients[clientCount++] = i;
		}
	}
	return (clientCount == 0) ? -1 : clients[GetRandomInt(0, clientCount - 1)];
}

stock void SilahOlustur(float position[3], const char[] model)
{
	
	int tas = CreateEntityByName("prop_physics_override");
	DispatchKeyValueVector(tas, "origin", position);
	DispatchKeyValue(tas, "model", model);
	DispatchKeyValue(tas, "physicsmode", "2");
	DispatchKeyValue(tas, "massScale", "1.0");
	DispatchSpawn(tas);
	
	char targetname[100];
	Format(targetname, sizeof(targetname), "tas_%i", tas);
	
	SetEntProp(tas, Prop_Send, "m_usSolidFlags", 8);
	SetEntProp(tas, Prop_Send, "m_CollisionGroup", 1);
	SetEntPropFloat(tas, Prop_Send, "m_flModelScale", 0.65);
	
	position[2] += 40.0;
	TeleportEntity(tas, position, NULL_VECTOR, NULL_VECTOR);
	
	int m_iRotator = CreateEntityByName("func_rotating");
	DispatchKeyValueVector(m_iRotator, "origin", position);
	DispatchKeyValue(m_iRotator, "targetname", targetname);
	DispatchKeyValue(m_iRotator, "maxspeed", "200");
	DispatchKeyValue(m_iRotator, "friction", "0");
	DispatchKeyValue(m_iRotator, "dmg", "0");
	DispatchKeyValue(m_iRotator, "solid", "0");
	DispatchKeyValue(m_iRotator, "spawnflags", "64");
	DispatchSpawn(m_iRotator);
	
	SetVariantString("!activator");
	AcceptEntityInput(tas, "SetParent", m_iRotator, m_iRotator);
	AcceptEntityInput(m_iRotator, "Start");
	
	SetEntPropEnt(tas, Prop_Send, "m_hEffectEntity", m_iRotator);
	
	SDKHook(tas, SDKHook_StartTouch, OnStartTouch);
}

stock void Give_Effect(int client, int Color[4])
{
	int clients[1];
	clients[0] = client;
	Handle message = StartMessageEx(GetUserMessageId("Fade"), clients, 1, 0);
	Protobuf pb = UserMessageToProtobuf(message);
	pb.SetInt("duration", 200);
	pb.SetInt("hold_time", 40);
	pb.SetInt("flags", 17);
	pb.SetColor("clr", Color);
	EndMessage();
} // efekt verilecek

stock void SetCvar(char[] cvarName, int value)
{
	ConVar IntCvar = FindConVar(cvarName);
	if (IntCvar == null)return;
	int flags = IntCvar.Flags;
	flags &= ~FCVAR_NOTIFY;
	IntCvar.Flags = flags;
	IntCvar.IntValue = value;
	flags |= FCVAR_NOTIFY;
	IntCvar.Flags = flags;
}

public Action Remove_Entity(Handle timer, int entity)
{
	if (IsValidEntity(entity))
		RemoveEntity(entity);
	return Plugin_Stop;
}

stock void ShowStatusMessage(int client = -1, const char[] message = NULL_STRING, int hold = 1)
{
	Event show_survival_respawn_status = CreateEvent("show_survival_respawn_status");
	if (show_survival_respawn_status != null)
	{
		show_survival_respawn_status.SetString("loc_token", message);
		show_survival_respawn_status.SetInt("duration", hold);
		show_survival_respawn_status.SetInt("userid", -1);
		if (client == -1)
		{
			foreachPlayer(player)
			{
				show_survival_respawn_status.FireToClient(player);
			}
		}
		else
		{
			if (!IsFakeClient(client))
				show_survival_respawn_status.FireToClient(client);
		}
		show_survival_respawn_status.Cancel();
	}
}

stock void SilahTemizle()
{
	char ModelPath[PLATFORM_MAX_PATH];
	for (int i = MaxClients; i < GetMaxEntities(); i++)
	{
		if (IsValidEdict(i) && IsValidEntity(i))
		{
			GetEntPropString(i, Prop_Data, "m_ModelName", ModelPath, sizeof(ModelPath));
			if (StrContains(ModelPath, "sourcepawn_com/silah") != -1)
			{
				RemoveEntity(i);
			}
		}
	}
}

stock void ClearWeaponEx(int client)
{
	int wepIdx;
	for (int i; i < 12; i++)
	{
		while ((wepIdx = GetPlayerWeaponSlot(client, i)) != -1)
		{
			RemovePlayerItem(client, wepIdx);
			RemoveEntity(wepIdx);
		}
	}
}

stock void YeriTemizle()
{
	int iEnt = MaxClients + 1;
	
	while ((iEnt = FindEntityByClassname(iEnt, "weapon_*")) != -1 && iEnt == FL_ONGROUND)
		AcceptEntityInput(iEnt, "Kill");
}

stock void SaveConfiguration()
{
	char path[75], mapName[45];
	GetCurrentMap(mapName, sizeof(mapName));
	
	BuildPath(Path_SM, path, sizeof(path), "configs/pubgalan/%s_oyuncu.cfg", mapName);
	if (!FileExists(path))
	{
		Handle file = OpenFile(path, "w");
		CloseHandle(file);
	}
	
	
	Handle file = OpenFile(path, "w");
	for (int i = 0; i < GetArraySize(ARRAY_Spawns); i++)
	{
		Handle trie = GetArrayCell(ARRAY_Spawns, i);
		float Px = 0.0;
		float Py = 0.0;
		float Pz = 0.0;
		GetTrieValue(trie, POSITION_X, Px);
		GetTrieValue(trie, POSITION_Y, Py);
		GetTrieValue(trie, POSITION_Z, Pz);
		WriteFileLine(file, "%f;%f;%f", Px, Py, Pz);
	}
}

stock void LoadConfiguration(const char[] mapName)
{
	char path[75];
	BuildPath(Path_SM, path, sizeof(path), "configs/pubgalan/%s_oyuncu.cfg", mapName);
	
	if (!DirExists("addons/sourcemod/configs/pubgalan"))
		CreateDirectory("/addons/sourcemod/configs/pubgalan", 0o777);
	
	Handle file = INVALID_HANDLE;
	if (!FileExists(path))
		file = OpenFile(path, "w");
	else
		file = OpenFile(path, "r");
	
	char line[200];
	ClearArray(ARRAY_Spawns);
	
	while (!IsEndOfFile(file) && ReadFileLine(file, line, sizeof(line)))
	{
		
		char positions[3][15];
		ExplodeString(line, ";", positions, sizeof positions, sizeof positions[]);
		
		Handle trie = CreateTrie();
		SetTrieValue(trie, POSITION_X, StringToFloat(positions[0]));
		SetTrieValue(trie, POSITION_Y, StringToFloat(positions[1]));
		SetTrieValue(trie, POSITION_Z, StringToFloat(positions[2]));
		
		PushArrayCell(ARRAY_Spawns, trie);
		
	}
	CloseHandle(file);
	
	g_okacinci = GetArraySize(ARRAY_Spawns);
	
	if (g_okacinci < 1)
		PrintToServer("%s Oyuncu Spawn Konumu Bulunamadı !", PLUGIN_TAG);
	else
		PrintToServer("%s %i Tane Oyuncu Spawn Yüklendi !", PLUGIN_TAG, g_okacinci);
	
} 
