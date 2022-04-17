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
	char path[128], mapName[512];
	GetCurrentMap(mapName, sizeof(mapName));
	
	BuildPath(Path_SM, path, sizeof(path), "configs/pubgalan/%s_oyuncu.cfg", mapName);
	if (!FileExists(path))
	{
		Handle file = OpenFile(path, "w");
		CloseHandle(file);
	}
	
	
	Handle file = OpenFile(path, "r+");
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
	char path[128];
	BuildPath(Path_SM, path, sizeof(path), "configs/pubgalan/%s_oyuncu.cfg", mapName);
	
	if (!DirExists("addons/sourcemod/configs/pubgalan"))
		CreateDirectory("/addons/sourcemod/configs/pubgalan", 0o777);
	
	Handle file;
	if (!FileExists(path))
		file = OpenFile(path, "w+");
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
	int spawnID = GetRandomInt(0, g_okacinci - 1);
	Handle positions = GetArrayCell(ARRAY_Spawns, spawnID);
	
	float newSpawn[3];
	GetTrieValue(positions, POSITION_X, newSpawn[0]);
	GetTrieValue(positions, POSITION_Y, newSpawn[1]);
	GetTrieValue(positions, POSITION_Z, newSpawn[2]);
	
	TeleportEntity(oyuncu, newSpawn, NULL_VECTOR, NULL_VECTOR);
}