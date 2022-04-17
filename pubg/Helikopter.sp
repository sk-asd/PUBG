public void BombaAtildi(Handle event, const char[] eventname, bool dontBroadcast)
{
	if (g_bAktif)
	{
		int client = GetClientOfUserId(GetEventInt(event, "userid"));
		if (g_cOnlyWarden.BoolValue)
		{
			if (warden_iswarden(client))
			{
				g_fexpcoordinate[0] = GetEventFloat(event, "x");
				g_fexpcoordinate[1] = GetEventFloat(event, "y");
				g_fexpcoordinate[2] = GetEventFloat(event, "z");
				
				koordinat[0] = g_fexpcoordinate[0];
				koordinat[1] = g_fexpcoordinate[1];
				koordinat[2] = g_fexpcoordinate[2];
				
				HavaSaldirisi();
			}
		}
		else
		{
			g_fexpcoordinate[0] = GetEventFloat(event, "x");
			g_fexpcoordinate[1] = GetEventFloat(event, "y");
			g_fexpcoordinate[2] = GetEventFloat(event, "z");
			
			koordinat[0] = g_fexpcoordinate[0];
			koordinat[1] = g_fexpcoordinate[1];
			koordinat[2] = g_fexpcoordinate[2];
			
			HavaSaldirisi();
		}
	}
}

stock void HavaSaldirisi()
{
	koordinat[2] += 500.0;
	EmitSoundToAll("Plugincim_com/PUBG/Helikopter.wav", 0, 0, 75, 0, 1.0, 100, -1, koordinat, NULL_VECTOR, true, 0.0);
	int Helikopter = CreateEntityByName("prop_dynamic_override", -1);
	DispatchKeyValue(Helikopter, "model", "models/props_vehicles/helicopter_rescue.mdl");
	SetEntPropFloat(Helikopter, Prop_Send, "m_flModelScale", 0.7, 0);
	DispatchSpawn(Helikopter);
	SetVariantString("3ready");
	AcceptEntityInput(Helikopter, "SetAnimation", -1, -1, 0);
	TeleportEntity(Helikopter, koordinat, NULL_VECTOR, NULL_VECTOR);
	CreateTimer(1.0, HeliDusur, Helikopter, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

public Action HeliDusur(Handle timer, int Helikopter)
{
	kac++;
	if (kac == 3)
	{
		kac = 0;
		AddNormalSoundHook(SesBuguFix);
		yeniaci[0] = koordinat[0];
		yeniaci[1] = koordinat[1];
		yeniaci[2] = koordinat[2];
		while (aan < 6)
		{
			if (aan < 4)
			{
				yeniaci[1] += 100.0;
				int Bomba = CreateEntityByName("hegrenade_projectile", -1);
				DispatchSpawn(Bomba);
				SDKHook(Bomba, SDKHook_Touch, OnStartTouch);
				SetEntityModel(Bomba, "models/enhancedrockets2/w_rocket_original.mdl");
				SetEntityGravity(Bomba, 1.0);
				TeleportEntity(Bomba, yeniaci, aci, NULL_VECTOR);
			}
			
			if (aan == 5)
			{
				CreateTimer(0.0, bombaiki, _, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
				PrintToChatAll("31 2");
				PrintToChatAll("%i aan", aan);
			}
			
			aan++;
		}
		return Plugin_Stop;
	}
	else if (kac <= 3)
	{
		koordinat[2] -= 75.0;
		TeleportEntity(Helikopter, koordinat, NULL_VECTOR, NULL_VECTOR);
		return Plugin_Continue;
	}
	return Plugin_Handled;
}

public Action bombaiki(Handle timer)
{
	kac2++;
	if (kac2 == 3)
	{
		return Plugin_Stop;
	}
	else if (kac2 <= 3)
	{
		PrintToChatAll(" \x0B31");
		yeniaci[0] += 100.0;
		int Bomba2 = CreateEntityByName("hegrenade_projectile", -1);
		DispatchSpawn(Bomba2);
		SDKHook(Bomba2, SDKHook_Touch, OnStartTouch);
		SetEntityModel(Bomba2, "models/enhancedrockets2/w_rocket_original.mdl");
		SetEntityGravity(Bomba2, 1.0);
		TeleportEntity(Bomba2, yeniaci, aci, NULL_VECTOR);
		if (kac2 == 2)
		{
			anan2[0] = yeniaci[0];
			anan2[1] = yeniaci[1];
			anan2[2] = yeniaci[2];
			CreateTimer(0.0, bombauc, _, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
		}
		return Plugin_Continue;
	}
	return Plugin_Handled;
}

public Action bombauc(Handle timer)
{
	kac3++;
	if (kac3 == 3)
	{
		return Plugin_Stop;
	}
	else if (kac3 <= 2)
	{
		PrintToChatAll(" \x0231");
		anan2[1] -= 100.0;
		int Bomba2 = CreateEntityByName("hegrenade_projectile", -1);
		DispatchSpawn(Bomba2);
		SDKHook(Bomba2, SDKHook_Touch, OnStartTouch);
		SetEntityModel(Bomba2, "models/enhancedrockets2/w_rocket_original.mdl");
		SetEntityGravity(Bomba2, 1.0);
		TeleportEntity(Bomba2, anan2, aci, NULL_VECTOR);
		PrintToChatAll("%i", kac3);
		
		if (kac3 == 2)
		{
			
			CreateTimer(0.0, bombadort, _, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
			PrintToChatAll("kac3 oldu");
		}
		return Plugin_Continue;
	}
	return Plugin_Handled;
}


public Action bombadort(Handle timer)
{
	kac4++;
	if (kac4 == 3)
	{
		kac = 0;
		kac2 = 0;
		kac3 = 0;
		kac4 = 0;
		aan = 1;
		return Plugin_Stop;
	}
	else if (kac4 <= 2)
	{
		if (kac4 == 1)
		{
			anan2[0] -= 100.0;
			int Bomba = CreateEntityByName("hegrenade_projectile", -1);
			DispatchSpawn(Bomba);
			SDKHook(Bomba, SDKHook_Touch, OnStartTouch);
			SetEntityModel(Bomba, "models/enhancedrockets2/w_rocket_original.mdl");
			SetEntityGravity(Bomba, 1.0);
			TeleportEntity(Bomba, anan2, aci, NULL_VECTOR);
			PrintToChatAll("%i", kac4);
		}
		else if (kac4 == 2)
		{
			anan2[1] += 100.0;
			int Bomba2 = CreateEntityByName("hegrenade_projectile", -1);
			DispatchSpawn(Bomba2);
			SDKHook(Bomba2, SDKHook_Touch, OnStartTouch);
			SetEntityModel(Bomba2, "models/enhancedrockets2/w_rocket_original.mdl");
			SetEntityGravity(Bomba2, 1.0);
			TeleportEntity(Bomba2, anan2, aci, NULL_VECTOR);
			PrintToChatAll("%i", kac4);
		}
		return Plugin_Continue;
	}
	return Plugin_Handled;
}

public CreatePlayerModelProp(int client)
{
	int skin = CreateEntityByName("prop_dynamic_override", -1);
	DispatchKeyValue(skin, "model", "models/enhancedrockets2/w_rocket_original.mdl");
	DispatchKeyValue(skin, "disablereceiveshadows", "1");
	DispatchKeyValue(skin, "disableshadows", "0");
	DispatchKeyValue(skin, "solid", "0");
	DispatchKeyValue(skin, "spawnflags", "256");
	SetEntProp(skin, Prop_Send, "m_CollisionGroup", 0, 4, 0);
	DispatchSpawn(skin);
	SetEntityRenderMode(skin, RENDER_WORLDGLOW);
	SetEntityRenderColor(skin, 255, 0, 0, 255);
	SetEntProp(skin, Prop_Send, "m_fEffects", 1, 4, 0);
	SetVariantString("!activator");
	AcceptEntityInput(skin, "SetParent", client, skin, 0);
	SetVariantString("primary");
	SetVariantColor( { 0, 255, 0, 255 } );
	AcceptEntityInput(skin, "SetGlowColor", -1, -1, 0);
	return skin;
}

public Action SesBuguFix(int clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags)
{
	if (g_bAktif)
	{
		if (StrContains(sample[0], "weapons/hegrenade/he_bounce-1.wav", true) != -1)
		{
			return Plugin_Stop;
		}
	}
	return Plugin_Continue;
}

public Action HelKontrol(Handle timer)
{
	char ModelPath[PLATFORM_MAX_PATH];
	for (int i = MaxClients; i < GetMaxEntities(); i++)
	{
		if (IsValidEdict(i) && IsValidEntity(i))
		{
			GetEntPropString(i, Prop_Data, "m_ModelName", ModelPath, sizeof(ModelPath));
			if (StrContains(ModelPath, "models/props_vehicles/helicopter_rescue.mdl") != -1 || StrContains(ModelPath, "props_vehicles/helicopter_rescue.mdl") != -1)
			{
				RemoveEntity(i);
			}
		}
	}
}

void CS_CreateExplosion(int damage, int radius, float pos[3])
{
	int entity;
	if ((entity = CreateEntityByName("env_explosion")) != -1)
	{
		DispatchKeyValue(entity, "spawnflags", "552");
		DispatchKeyValue(entity, "rendermode", "5");
		
		SetEntProp(entity, Prop_Data, "m_iMagnitude", damage);
		SetEntProp(entity, Prop_Data, "m_iRadiusOverride", radius);
		
		DispatchSpawn(entity);
		TeleportEntity(entity, pos, NULL_VECTOR, NULL_VECTOR);
		
		RequestFrame(TriggerExplosion, entity);
	}
}

public void TriggerExplosion(int entity)
{
	if (entity == INVALID_ENT_REFERENCE)
		return;
	
	AcceptEntityInput(entity, "explode");
	float entityPos[3];
	GetEntPropVector(entity, Prop_Data, "m_vecOrigin", entityPos);
	TE_SetupSmoke(entityPos, g_iPathLaserModelIndex, 10.0, 60);
	TE_SendToAll();
	AcceptEntityInput(entity, "Kill");
} 