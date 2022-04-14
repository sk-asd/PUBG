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

#pragma semicolon 1
#pragma newdecls required

#define T           2   /**< Terrorists. */
#define CT          3   /**< Counter-Terrorists. */

char dosyayolu[PLATFORM_MAX_PATH];

int g_iBeamSprite = -1, g_iHaloSprite = -1;
int g_kacinci;

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
}

public void OnPluginStart()
{
	RegConsoleCmd("sm_pubgayarla", PubgAyar);
	RegConsoleCmd("sm_pubg", PubgBaslat);
	
	BuildPath(Path_SM, dosyayolu, sizeof(dosyayolu), "configs/pubgalan");
	if (!DirExists(dosyayolu))
		CreateDirectory(dosyayolu, 0o777);
}

public Action PubgBaslat(int client, int args)
{
	if (IsValidClient(client))
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
			kv.GetVector("Koordinat2", origin);//modelspawn yapılacak
			TeleportEntity(kisi, origin, NULL_VECTOR, NULL_VECTOR);
		}
		while (kv.GotoNextKey());
		delete kv;
		return Plugin_Handled;
	}
	return Plugin_Continue;
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
			char format[512];
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
	Stock
*/

/*public Action test(int client, int args)
{
	Menu menu = new Menu(Alan_Handler);
	menu.SetTitle("✦ Alanlar ✦\n ");
	char map[64];
	GetCurrentMap(map, sizeof(map));
	StringToLowerCase(map);
	BuildPath(Path_SM, dosyayolu, sizeof(dosyayolu), "configs/pubgalan/%s_silah.txt", map);
	KeyValues kv = CreateKeyValues("pubgsilah");
	FileToKeyValues(kv, dosyayolu);
	if (!kv.GotoFirstSubKey())
	{
		PrintToChat(client, "[SM] \x02Sunucunda oluşturulmuş herhangi bir alan bulunmamaktadır.");
		delete kv;
		return Plugin_Handled;
	}
	char pinid[32];
	do
	{
		kv.GetSectionName(pinid, sizeof(pinid));
		menu.AddItem(pinid, pinid);
	}
	while (kv.GotoNextKey());
	delete kv;
	menu.Display(client, 20);
	return Plugin_Handled;
}

public int Alan_Handler(Menu menu, MenuAction action, int client, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char item[32];
			menu.GetItem(param2, item, sizeof(item));
			char map[64];
			GetCurrentMap(map, sizeof(map));
			StringToLowerCase(map);
			BuildPath(Path_SM, dosyayolu, sizeof(dosyayolu), "configs/pubgalan/%s_silah.txt", map);
			float vector[3] = 0.0;
			KeyValues kv = CreateKeyValues("pubgsilah");
			FileToKeyValues(kv, dosyayolu);
			if (kv.JumpToKey(item, false))
			{
				kv.GetVector("Koordinat", vector);
				delete kv;
			}
			TeleportEntity(client, vector, NULL_VECTOR, NULL_VECTOR); //sectigi yere isinla
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}
*/

stock bool IsValidClient(int client)
{
	if (!(1 <= client <= MaxClients) || !IsClientInGame(client) || IsFakeClient(client) || IsClientSourceTV(client) || IsClientReplay(client))
	{
		return false;
	}
	return true;
}

public void GetAimCoords(int client, float vector[3])
{
	float vAngles[3];
	float vOrigin[3];
	GetClientEyePosition(client, vOrigin);
	GetClientEyeAngles(client, vAngles);
	
	Handle trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);
	if (TR_DidHit(trace))
		TR_GetEndPosition(vector, trace);
	trace.Close();
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