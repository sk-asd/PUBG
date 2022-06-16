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
		
		char ModelPath[PLATFORM_MAX_PATH];
		GetEntPropString(entity, Prop_Data, "m_ModelName", ModelPath, sizeof(ModelPath));
		if (StrContains(ModelPath, "models/enhancedrockets2/w_rocket_original.mdl") != -1 || StrContains(ModelPath, "enhancedrockets2/w_rocket_original.mdl") != -1)
		{
			GetEntPropVector(entity, Prop_Send, "m_vecOrigin", ah);
			AcceptEntityInput(entity, "Kill");
			CreateTimer(0.0, Remove_Entity, entity);
			CreateTimer(0.1, HelKontrol, _, TIMER_FLAG_NO_MAPCHANGE);
			CS_CreateExplosion(100, 700, ah);
			ikincisira[0] = ah[0];
			ikincisira[1] = ah[1];
			ikincisira[2] = ah[2];
			//-200bomba 20 roket
		} //models/props_survival/cases/case_random_drop.mdl
		if (StrContains(ModelPath, "models/props_survival/cases/case_random_drop.mdl") != -1 || StrContains(ModelPath, "props_survival/cases/case_random_drop.mdl") != -1)
		{
			SetEntityMoveType(entity, MOVETYPE_NONE);
		}
	}
	return Plugin_Handled;
}

public Action OnStartTouchPost(int entity, int client)
{
	if (g_bAktif)
	{
		char ModelPath[PLATFORM_MAX_PATH];
		GetEntPropString(entity, Prop_Data, "m_ModelName", ModelPath, sizeof(ModelPath));
		if (StrContains(ModelPath, "models/enhancedrockets2/w_rocket_original.mdl") != -1 || StrContains(ModelPath, "enhancedrockets2/w_rocket_original.mdl") != -1)
		{
			GetEntPropVector(entity, Prop_Send, "m_vecOrigin", aha);
			AcceptEntityInput(entity, "Kill");
			CreateTimer(0.0, Remove_Entity, entity);
			CS_CreateExplosion(100, 700, aha);
			ikincisirax[0] = aha[0];
			ikincisirax[1] = aha[1];
			ikincisirax[2] = aha[2];
			//-200bomba 20 roket
		}
	}
	return Plugin_Handled;
}


public Action Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	if (g_bAktif == true)
	{
		int client = GetClientOfUserId(event.GetInt("userid"));
		int attacker = GetClientOfUserId(event.GetInt("attacker"));
		int takimarkadasi = 0;
		kacles[attacker]++;
		
		if (g_iTeammates[attacker] != 0)
			takimarkadasi = g_iTeammates[attacker];
		
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
			char format[512], attname[32];
			GetClientName(attacker, attname, sizeof(attname));
			if (attacker != client)
			{
				Format(format, sizeof(format), "Oyun bitti. %i leş ile %s kazandı, tebrikler!", kacles[attacker], attname);
				ShowStatusMessage(-1, format, 5);
				foreachPlayer(i)
				{
					ShowOverlay(i, "sourcepawn_com/br_winner", 5.0);
					EmitSoundToClient(i, "sourcepawn_com/winnersound.mp3");
				}
			}
			ServerCommand("sm_pubgphiso0");
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
						if (attacker != client)
						{
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
							ServerCommand("sm_pubgphiso0");
						}
					}
				}
			}
		}
	}
	return Plugin_Handled;
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{
	if (g_bAktif)
	{
		if (g_iTeammates[attacker] == victim)
		{
			damage = damage / 2.0; //32 / 2 == 15
			return Plugin_Changed;
		}
		
		if (IsValidClient(attacker) && IsPlayerAlive(attacker) && IsValidEntity(victim))
		{
			char ModelPath[PLATFORM_MAX_PATH];
			GetEntPropString(victim, Prop_Data, "m_ModelName", ModelPath, sizeof(ModelPath));
			if (StrContains(ModelPath, "models/props_survival/cases/case_random_drop.mdl") != -1 || StrContains(ModelPath, "props_survival/cases/case_random_drop.mdl") != -1)
			{
				can += damage;
				if (can > 331.0)
				{
					PrintToChatAll("[SM] \x10%N \x04Drop'u kırdı!", attacker);
					silahlar[2] -= 500.0;
					int ent = CreateEntityByName(g_OzelSilah[GetRandomInt(0, sizeof(g_OzelSilah) - 1)]);
					DispatchSpawn(ent);
					TeleportEntity(ent, silahlar, NULL_VECTOR, NULL_VECTOR);
					ent = CreateEntityByName(g_OzelBombalar[GetRandomInt(0, sizeof(g_OzelBombalar) - 1)]);
					DispatchSpawn(ent);
					TeleportEntity(ent, silahlar, NULL_VECTOR, NULL_VECTOR);
					ent = CreateEntityByName("weapon_healthshot");
					DispatchSpawn(ent);
					TeleportEntity(ent, silahlar, NULL_VECTOR, NULL_VECTOR);
					
					GetClientAbsOrigin(attacker, TargetOrigin);
					float Distance = GetVectorDistance(TargetOrigin, silahlar);
					if (Distance < 500.0)
					{
						SetEntProp(attacker, Prop_Data, "m_ArmorValue", 100, 4);
						SetEntProp(attacker, Prop_Send, "m_bHasHelmet", 1);
					}
					can = 0.0;
					SDKUnhook(victim, SDKHook_OnTakeDamage, OnTakeDamage);
					dropvar = false;
				}
			}
		}
	}
	return Plugin_Continue;
}

public Action elbasladibitti(Event event, const char[] name, bool db)
{
	if(g_bAktif){
		g_bAktif = false;
		dropvar = false;
		hazirlanma = -1;
		SetCvar("mp_teammates_are_enemies", 0);
		SetCvar("mp_friendlyfire", 0);
		SilahTemizle();
		foreachPlayer(client) {
			SetEntityMoveType(client, MOVETYPE_WALK);
			kacles[client] = 0;
			SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
			g_iTeammates[client] = 0;
			foreachPlayer(target){
				SetListenOverride(client, target, Listen_Yes);
			}
			if(BaseComm_IsClientMuted(client)){
				BaseComm_SetClientMute(client, true);
			}
		}
		return Plugin_Continue;
	}
	return Plugin_Continue;
}

public void hazirdegisti(ConVar convar, const char[] oldValue, const char[] newValue) { hazirlanma = StringToInt(newValue); }
