/*
	Semboller
	
	☆	
	✯
	✧
	✦
	♢
	♦
	☝
	☟
	☞
	☜
	➔
	»
	›
	«
	‹
	·
	•
	●
*/

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#pragma semicolon 1
#pragma newdecls required

#define T           2   /**< Terrorists. */
#define CT          3   /**< Counter-Terrorists. */

char dosyayolu[PLATFORM_MAX_PATH];

bool g_bAktif = false;

int g_iBeamSprite = -1, g_iHaloSprite = -1;
int g_kacinci, g_iTeammates[MAXPLAYERS + 1] =  { 0 };

#define LoopAllTerrorist(%1) for (int %1 = 1; %1 <= MaxClients; %1++) if (IsClientInGame(%1) && GetClientTeam(%1) == T)

public Plugin myinfo = 
{
	name = "", 
	author = "phiso", 
	description = "", 
	version = "1.0", 
	url = "phiso#8896"
};

public void OnMapStart()
{
	g_iBeamSprite = PrecacheModel("materials/sprites/laserbeam.vmt");
	g_iHaloSprite = PrecacheModel("materials/sprites/glow06.vmt");
	
	AddFileToDownloadsTable("models/Plugincim_com/PUBG/silah.dx90.vtx");
	AddFileToDownloadsTable("models/Plugincim_com/PUBG/silah.mdl");
	AddFileToDownloadsTable("models/Plugincim_com/PUBG/silah.phy");
	AddFileToDownloadsTable("models/Plugincim_com/PUBG/silah.vvd");
	AddFileToDownloadsTable("materials/models/Plugincim_com/PUBG/silah.vmt");
	AddFileToDownloadsTable("materials/models/Plugincim_com/PUBG/silah.vtf");
	PrecacheModel("models/Plugincim_com/PUBG/silah.mdl");
}

public void OnPluginStart()
{
	RegConsoleCmd("sm_pubgayarla", PubgAyar);
	RegConsoleCmd("sm_pubgphiso", PubgBaslat);
	RegConsoleCmd("sm_pubgtakimol", CMD_PubgTakim);
	
	BuildPath(Path_SM, dosyayolu, sizeof(dosyayolu), "configs/pubgalan");
	if (!DirExists(dosyayolu))
		CreateDirectory(dosyayolu, 0o777);
}

public Action PubgBaslat(int client, int args)
{
	if (g_bAktif == false)
	{
		if (IsValidClient(client))
			CreateTimer(40.0, PubgSureBitti, client, TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		PrintToChat(client, "[SM] \x01Zaten aktif bir oyun var");
	}
	return Plugin_Continue;
}

public Action PubgSureBitti(Handle timer, any client)
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
		PrintToChat(client, "Sunucunda oluşturulmuş herhangi bir alan bulunmamaktadır.");
		delete kv;
		return Plugin_Handled;
	}
	do
	{
		kv.GetVector("Koordinat", origin); //modelspawn yapılacak
		SilahOlustur(origin, "models/Plugincim_com/PUBG/silah.mdl");
	}
	while (kv.GotoNextKey());
	delete kv;
	
	g_bAktif = true;
	return Plugin_Continue;
}

public Action CMD_PubgTakim(int client, int args)
{
	if (g_bAktif == false)
	{
		if (g_iTeammates[client] == 0)
		{
			Menu takimm = new Menu(TakimMenuCallBack);
			takimm.SetTitle("[PUBG] Takım Menüsü");
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
		else
		{
			PrintToChat(client, "[SM] \x01Zaten bir takım arkadaşın var! \x10%N", g_iTeammates[client]);
		}
	}
	else
	{
		PrintToChat(client, "[SM] \x01Aktif bir PUBG oyunu yok!");
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

public int TakimMenuCallBack(Menu menu, MenuAction action, int client, int position)
{
	if (action == MenuAction_Select)
	{
		char item[32];
		menu.GetItem(position, item, 32);
		int target = GetClientOfUserId(StringToInt(item));
		PrintToChat(target, "[SM] \x10%N \x01Takım daveti gönderdi.", client);
		OnayMenu(target, client);
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
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

			SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
			SDKHook(g_iTeammates[client], SDKHook_OnTakeDamage, OnTakeDamage);
		}
		else if (strcmp(info, "red") == 0)
		{
			PrintToChat(g_iTeammates[client], "[SM] \x10%N \x01adlı oyuncu Takım isteğini \x02reddetti!", client);
			g_iTeammates[client] = -1;
			g_iTeammates[g_iTeammates[client]] = -1;
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
}

public Action OnStartTouch(int entity, int client)
{
	//if (OyunOynaniyor)
	{
		if (IsValidClient(client) && IsPlayerAlive(client))
		{
			
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
		menu.CurrentKey = 9;
		menu.DrawItem("➔ Kapat");
		menu.Send(client, AyarMenu, MENU_TIME_FOREVER);
		delete menu;
	}
}

public int AyarMenu(Menu menu, MenuAction action, int client, int item)
{
	if (action == MenuAction_Select)
	{
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
			Format(format, sizeof(format), "%i", g_kacinci);
			kv.JumpToKey(format, true);
			float origin[3] = 0.0;
			GetClientAimText(client, origin);
			kv.SetVector("Koordinat", origin);
			kv.Rewind();
			kv.ExportToFile(dosyayolu);
			delete kv;
			g_kacinci++;
			PrintCenterText(client, "Pubg silah ayarı başarı ile yapıldı.");
			PubgAyar(client, 0);
		}
		else if (item == 2)
		{
			char map[64];
			GetCurrentMap(map, sizeof(map));
			StringToLowerCase(map);
			BuildPath(Path_SM, dosyayolu, sizeof(dosyayolu), "configs/pubgalan/%s_oyuncu.txt", map);
			if (!FileExists(dosyayolu))
			{
				Handle file = OpenFile(dosyayolu, "w+");
				CloseHandle(file);
			}
			
			KeyValues kv = new KeyValues("pubgoyuncu");
			kv.ImportFromFile(dosyayolu);
			kv.JumpToKey("Oyuncu Spawn Noktasi", true);
			float origin[3] = 0.0;
			GetClientAimText(client, origin);
			kv.SetVector("Koordinat2", origin);
			kv.Rewind();
			kv.ExportToFile(dosyayolu);
			delete kv;
			PrintCenterText(client, "Pubg oyuncu spawn noktası ayarı başarı ile yapıldı.");
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
			g_kacinci = 0;
		}
		else if (item == 5)
		{
			char map[64];
			GetCurrentMap(map, sizeof(map));
			StringToLowerCase(map);
			BuildPath(Path_SM, dosyayolu, sizeof(dosyayolu), "configs/pubgalan/%s_oyuncu.txt", map);
			if (FileExists(dosyayolu))
			{
				DeleteFile(dosyayolu);
				PrintCenterText(client, "Pubg oyuncu spawn noktaları sıfırlandı.");
			}
			PubgAyar(client, 0);
		}
	}
	else if (action == MenuAction_End)
	{
		
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