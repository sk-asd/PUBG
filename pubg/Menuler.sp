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
	return Plugin_Handled;
}

public int callback(Menu menu, MenuAction action, int client, int item) { if (action == MenuAction_Select) {  } else if (action == MenuAction_End) { delete menu; } }

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
		float origin[3] = { 0.0, 0.0, 0.0 };
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
			kv.GetVector("Koordinat", origin); //modelspawn yapılacak tm
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
			}
			takimm.Display(client, MENU_TIME_FOREVER);
		}
	}
	else
	{
		PrintToChat(client, "[SM] \x01Aktif bir PUBG oyunu yok!");
	}
	return Plugin_Handled;
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
			
			SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
			SDKUnhook(g_iTeammates[client], SDKHook_OnTakeDamage, OnTakeDamage);
			
			foreachPlayer(i)
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
	return client;
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
	return client;
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
	return Plugin_Handled;
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
				File file = OpenFile(dosyayolu, "w+");
				delete file;
			}
			
			KeyValues kv = new KeyValues("pubgsilah");
			kv.ImportFromFile(dosyayolu);
			Format(format, sizeof(format), "%i", GetRandomInt(0, 100000));
			kv.JumpToKey(format, true);
			float origin[3] = { 0.0, 0.0, 0.0 };
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
			GetClientAimText(client, newSpawn);
			SaveLocation(newSpawn);
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
		}
		else if (item == 5)
		{
			char map[64];
			GetCurrentMap(map, sizeof(map));
			StringToLowerCase(map);
			BuildPath(Path_SM, dosyayolu, sizeof(dosyayolu), "configs/pubgalan/%s_oyuncu.cfg", map);
			if (FileExists(dosyayolu)) {
				ARRAY_Spawns.Clear();
				DeleteFile(dosyayolu);
				PrintCenterText(client, "Pubg oyuncu spawn noktaları sıfırlandı.");
			}
			PubgAyar(client, 0);
		}
		else if (item == 6)
		{
			SaveConfiguration();
			PrintCenterText(client, "Pubg konumları başarılı bir şekilde kaydedildi.");
		}
	}
	else if (action == MenuAction_End)
		delete menu;
	
	return client;
}
