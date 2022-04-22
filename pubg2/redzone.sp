public Action redzone(int client, int args)
{
	randomkisi = GetRandomPlayer();
	if (IsClientInGame(randomkisi) && !IsFakeClient(randomkisi) && IsPlayerAlive(randomkisi))
	{
		char kisiname[32], format[256];
		GetClientAbsOrigin(randomkisi, origin1a);
		GetClientName(randomkisi, kisiname, sizeof(kisiname));//00FF00
		Format(format, sizeof(format), "<font color='#00FF00'>%s</font> <font color='#FF0000'>adlı oyuncuya bomba yağıyor!</font>", kisiname);
		ShowStatusMessage(-1, format, 3);
		koordinata[0] = origin1a[0];
		koordinata[1] = origin1a[1];
		koordinata[2] = origin1a[2];
		HavaSaldirisi2();
	}
}

stock void HavaSaldirisi2()
{
	koordinata[2] += 500.0;
	CreateTimer(0.1, HeliDusur2, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

public Action HeliDusur2(Handle timer)
{
	AddNormalSoundHook(SesBuguFix);
	yeniacia[0] = koordinata[0];
	yeniacia[1] = koordinata[1];
	yeniacia[2] = koordinata[2];
	while (aann < 6)
	{
		if (aann < 4)
		{
			yeniacia[1] += 100.0;
			int Bomba = CreateEntityByName("hegrenade_projectile", -1);
			DispatchSpawn(Bomba);
			SDKHook(Bomba, SDKHook_TouchPost, OnStartTouchPost);
			SetEntityModel(Bomba, "models/enhancedrockets2/w_rocket_original.mdl");
			SetEntityGravity(Bomba, 1.0);
			TeleportEntity(Bomba, yeniacia, aci, NULL_VECTOR);
		}
		
		if (aann == 5)
		{
			CreateTimer(0.1, bombaikii, _, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
			return Plugin_Stop;
		}
		aann++;
	}
	return Plugin_Handled;
}

public Action bombaikii(Handle timer)
{
	kac22++;
	if (kac22 == 3)
	{
		return Plugin_Stop;
	}
	else if (kac22 <= 3)
	{
		yeniacia[0] += 100.0;
		int Bomba2 = CreateEntityByName("hegrenade_projectile", -1);
		DispatchSpawn(Bomba2);
		SDKHook(Bomba2, SDKHook_TouchPost, OnStartTouchPost);
		SetEntityModel(Bomba2, "models/enhancedrockets2/w_rocket_original.mdl");
		SetEntityGravity(Bomba2, 1.0);
		TeleportEntity(Bomba2, yeniacia, aci, NULL_VECTOR);
		if (kac22 == 2)
		{
			anan2a[0] = yeniacia[0];
			anan2a[1] = yeniacia[1];
			anan2a[2] = yeniacia[2];
			CreateTimer(0.1, bombaucc, _, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
		}
		return Plugin_Continue;
	}
	return Plugin_Handled;
}

public Action bombaucc(Handle timer)
{
	kac33++;
	if (kac33 == 3)
	{
		return Plugin_Stop;
	}
	else if (kac33 <= 2)
	{
		anan2a[1] -= 100.0;
		int Bomba2 = CreateEntityByName("hegrenade_projectile", -1);
		DispatchSpawn(Bomba2);
		SDKHook(Bomba2, SDKHook_TouchPost, OnStartTouchPost);
		SetEntityModel(Bomba2, "models/enhancedrockets2/w_rocket_original.mdl");
		SetEntityGravity(Bomba2, 1.0);
		TeleportEntity(Bomba2, anan2a, aci, NULL_VECTOR);
		
		if (kac33 == 2)
		{
			CreateTimer(0.1, bombadortt, _, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
		}
		return Plugin_Continue;
	}
	return Plugin_Handled;
}


public Action bombadortt(Handle timer)
{
	kac44++;
	if (kac44 == 3)
	{
		kac22 = 0;
		kac33 = 0;
		kac44 = 0;
		aann = 1;
		return Plugin_Stop;
	}
	else if (kac44 <= 2)
	{
		if (kac44 == 1)
		{
			anan2a[0] -= 100.0;
			int Bomba = CreateEntityByName("hegrenade_projectile", -1);
			DispatchSpawn(Bomba);
			SDKHook(Bomba, SDKHook_TouchPost, OnStartTouchPost);
			SetEntityModel(Bomba, "models/enhancedrockets2/w_rocket_original.mdl");
			SetEntityGravity(Bomba, 1.0);
			TeleportEntity(Bomba, anan2a, aci, NULL_VECTOR);
		}
		else if (kac44 == 2)
		{
			anan2a[1] += 100.0;
			int Bomba2 = CreateEntityByName("hegrenade_projectile", -1);
			DispatchSpawn(Bomba2);
			SDKHook(Bomba2, SDKHook_TouchPost, OnStartTouchPost);
			SetEntityModel(Bomba2, "models/enhancedrockets2/w_rocket_original.mdl");
			SetEntityGravity(Bomba2, 1.0);
			TeleportEntity(Bomba2, anan2a, aci, NULL_VECTOR);
		}
		return Plugin_Continue;
	}
	return Plugin_Handled;
}

/*public CreatePlayerModelProp(int client)
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
*/

public Action RedZone(Handle timer)
{
	if (!g_bAktif)
	{
		return Plugin_Stop;
	}
	
	red--;
	if (red == 0)
	{
		ServerCommand("sm_redzone");
		red = g_credzone.IntValue;
	}
	else
	{
		if (red < 5)
		{
			char sBuffer[512];
			Format(sBuffer, sizeof(sBuffer), "<font color='#00FF00'>%d</font> <font color='#FF0000'>saniye sonra bombardıman başlayacak!</font>", red);
			ShowStatusMessage(-1, sBuffer, 2);
			PrintHintTextToAll("<font size='20' color='#00FF00'>%d</font> <font size='20' color='#FF0000'>saniye sonra bombardıman başlayacak!</font>", red);
			return Plugin_Continue;
		}
	}
	return Plugin_Handled;
}