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
	float pos[3] = { 0.0, 0.0, 0.0 }
	float ang[3] = { 0.0, 0.0, 0.0 }
	GetClientEyePosition(client, pos);
	GetClientEyeAngles(client, ang);
	Handle tr = TR_TraceRayFilterEx(pos, ang, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer, client);
	float fVec[3] = { 0.0, 0.0, 0.0 }
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
		if (IsClientInGame(i) && !IsFakeClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == 2)
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
			if (StrContains(ModelPath, "sourcepawn_com/silah") != -1 || StrContains(ModelPath, "models/props_vehicles/helicopter_rescue.mdl") != -1 || StrContains(ModelPath, "props_vehicles/helicopter_rescue.mdl") != -1 || StrContains(ModelPath, "models/enhancedrockets2/w_rocket_original.mdl") != -1 || StrContains(ModelPath, "enhancedrockets2/w_rocket_original.mdl") != -1 )
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
	char path[128], mapName[512];
	GetCurrentMap(mapName, sizeof(mapName));
	
	BuildPath(Path_SM, path, sizeof(path), "configs/pubgalan/%s_oyuncu.cfg", mapName);
	if (!FileExists(path))
	{
		File file = OpenFile(path, "w");
		delete file;
	}
	
	File file = OpenFile(path, "r+");
	StringMap trie = null;
	float P[3] = { 0.0, ... };
	for (int i = 0; i < ARRAY_Spawns.Length; i++)
	{
		trie = ARRAY_Spawns.Get(i);
		trie.GetValue(POSITION_X, P[0]);
		trie.GetValue(POSITION_Y, P[1]);
		trie.GetValue(POSITION_Z, P[2]);
		file.WriteLine("%f;%f;%f", P[0], P[1], P[2]);
	}
	delete file;
}

void SaveLocation(float Position[3]) {
	StringMap trie = CreateTrie();
	trie.SetValue(POSITION_X, Position[0]);
	trie.SetValue(POSITION_Y, Position[1]);
	trie.SetValue(POSITION_Z, Position[2]);
	ARRAY_Spawns.Push(trie);
}

stock void LoadConfiguration(const char[] mapName)
{
	char path[128];
	BuildPath(Path_SM, path, sizeof(path), "configs/pubgalan/%s_oyuncu.cfg", mapName);
	
	if (!DirExists("addons/sourcemod/configs/pubgalan"))
		CreateDirectory("/addons/sourcemod/configs/pubgalan", 0o777);
	
	File file;
	if (!FileExists(path))
		file = OpenFile(path, "w+");
	else
		file = OpenFile(path, "r");
	
	char line[200];
	ARRAY_Spawns.Clear();
	
	char positions[3][15];
	StringMap trie = CreateTrie();
	while (!file.EndOfFile() && file.ReadLine(line, sizeof(line)))
	{
		ExplodeString(line, ";", positions, sizeof positions, sizeof positions[]);
		trie.SetValue(POSITION_X, StringToFloat(positions[0]));
		trie.SetValue(POSITION_Y, StringToFloat(positions[1]));
		trie.SetValue(POSITION_Z, StringToFloat(positions[2]));
		ARRAY_Spawns.Push(trie);
		
	}
	delete file;
	
	if (ARRAY_Spawns.Length < 1)
		PrintToServer("%s Oyuncu Spawn Konumu Bulunamadı !", PLUGIN_TAG);
	else
		PrintToServer("%s %i Tane Oyuncu Spawn Yüklendi !", PLUGIN_TAG, ARRAY_Spawns.Length);
}

void SpawnDrop(float pos[3])
{
	dropmodel = CreateEntityByName("prop_physics_override");
	SetEntityModel(dropmodel, "models/props_survival/cases/case_random_drop.mdl");
	DispatchKeyValue(dropmodel, "targetname", "pubgdropcase");
	SetEntProp(dropmodel, Prop_Data, "m_iHealth", 331);
	SetEntProp(dropmodel, Prop_Data, "m_takedamage", 2);
	ActivateEntity(dropmodel);
	DispatchSpawn(dropmodel);
	TeleportEntity(dropmodel, pos, NULL_VECTOR, NULL_VECTOR);
	SDKHook(dropmodel, SDKHook_OnTakeDamage, OnTakeDamage);
}

stock void RastgeleIsinla(int oyuncu)
{
	int spawnID = GetRandomInt(0, ARRAY_Spawns.Length - 1);
	StringMap positions = ARRAY_Spawns.Get(spawnID);
	
	float newSpawn[3];
	positions.GetValue(POSITION_X, newSpawn[0]);
	positions.GetValue(POSITION_Y, newSpawn[1]);
	positions.GetValue(POSITION_Z, newSpawn[2]);
	
	TeleportEntity(oyuncu, newSpawn, NULL_VECTOR, NULL_VECTOR);
}

public Action Pubg0(int client, int args)
{
	if (!g_bAktif)
	{
		PrintToChat(client, "[SM] \x04Şu anda zaten bir \x02pubg \x04oyunu oynanmıyor!");
		return Plugin_Handled;
	}
	g_bAktif = false;
	dropvar = false;
	hazirlanma = -1;
	SetCvar("mp_teammates_are_enemies", 0);
	SetCvar("mp_friendlyfire", 0);
	SilahTemizle();
	YeriTemizle();
	WinPanelDelete();
	LoopAllTerrorist(i)
	{
		kacles[i] = 0;
		SetEntityMoveType(i, MOVETYPE_WALK);
		ClearWeaponEx(i);
		GivePlayerItem(i, "weapon_knife");
	}
	foreachPlayer(client) {
		SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
		g_iTeammates[client] = 0;
		PrintToChat(client, "[SM] \x02%N \x04isimli yetkili pubg oyununu durdurdu!");
		SetClientListeningFlags(client, VOICE_LISTENALL);
		foreachPlayer(target){
			if(BaseComm_IsClientMuted(target)){
				BaseComm_SetClientMute(target, true);
			}
		}
	}
	return Plugin_Handled;
}

public Action DropOlustur(int client, int args)
{
	if (!warden_iswarden(client))
	{
		PrintToChat(client, "[SM] \x04Bu komutu kullanmak için \x0Bkomutçu \x04olmalısın!");
		return Plugin_Handled;
	}
	if (!g_bAktif)
	{
		PrintToChat(client, "[SM] \x04Şuan \x02pubg \x04oynanmıyor!");
		return Plugin_Handled;
	}
	if (dropvar)
	{
		PrintToChat(client, "[SM] \x04Şuan bir \x02drop \x04var!");
		return Plugin_Handled;
	}
	
	GetClientAimText(client, dropyeri);
	dropyeri[2] += 500.0;
	int cikti = 0;
	while (TR_PointOutsideWorld(dropyeri)) {
		cikti++;
		dropyeri[2] -= 50.0;
	}
	silahlar[0] = dropyeri[0];
	silahlar[1] = dropyeri[1];
	silahlar[2] = cikti * 50 + dropyeri[2];
	SpawnDrop(dropyeri);
	dropvar = true;
	return Plugin_Handled;
}

stock void WinPanelDelete()
{
	Event newevent_round = CreateEvent("round_start");
	
	for (int z = 1; z <= MaxClients; z++)
	if (IsClientInGame(z) && !IsFakeClient(z))
		newevent_round.FireToClient(z);
	
	newevent_round.Cancel();
}

stock void WinPanelMessage(int client = -1, const char[] message = NULL_STRING, float hold = 1.0)
{
	Event newevent_message = CreateEvent("cs_win_panel_round");
	newevent_message.SetString("funfact_token", message);
	if (client == -1)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && !IsFakeClient(i))
			{
				newevent_message.FireToClient(i);
			}
		}
	}
	else
	{
		if (!IsFakeClient(client))
			newevent_message.FireToClient(client);
	}
	CreateTimer(hold, deletewinpanel, _, TIMER_FLAG_NO_MAPCHANGE);
	newevent_message.Cancel();
}

public Action deletewinpanel(Handle timer)
{
	WinPanelDelete();
} 

stock void WinPanelMessageEx(int client = -1, const char[] message = NULL_STRING)
{
	Event newevent_message = CreateEvent("cs_win_panel_round");
	newevent_message.SetString("funfact_token", message);
	if (client == -1)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && !IsFakeClient(i))
			{
				newevent_message.FireToClient(i);
			}
		}
	}
	else
	{
		if (!IsFakeClient(client))
			newevent_message.FireToClient(client);
	}
	newevent_message.Cancel();
}
