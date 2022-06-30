public void OnPluginStart()
{
	RegConsoleCmd("sm_pubgayarla", PubgAyar);
	RegConsoleCmd("sm_pubg", PubgBaslat);
	RegConsoleCmd("sm_pubg0", Pubg0);
	RegConsoleCmd("sm_pubgtakim", CMD_PubgTakim);
	RegConsoleCmd("sm_dropgonder", DropOlustur);
	
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("round_start", elbasladibitti);
	HookEvent("round_end", elbasladibitti);
	HookEvent("hegrenade_detonate", BombaAtildi);
	
	BuildPath(Path_SM, dosyayolu, sizeof(dosyayolu), "configs/pubgalan");
	if (!DirExists(dosyayolu))
		CreateDirectory(dosyayolu, 0o777);
	
	ARRAY_Spawns = new ArrayList();
	
	g_hazirlanma = CreateConVar("sm_pubgg_hazirlanma", "20", "Pubgye hazırlanmaları için kaç saniyeleri olsun?", FCVAR_NOTIFY, true, 15.0, true, 50.0);
	g_cOnlyWarden = CreateConVar("sm_pubgg_bombakom", "0", "Bombardımanı sadace komutcu mu yapabilsin? (0 = Kapali | 1 = Acik)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hazirlanma.AddChangeHook(hazirdegisti);
	
	AutoExecConfig(true, "PUBG", "Sourcepawn.Com");
}
