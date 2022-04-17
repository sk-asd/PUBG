public void OnMapStart()
{
	char mapName[128];
	GetCurrentMap(mapName, sizeof(mapName));
	
	g_iBeamSprite = PrecacheModel("materials/sprites/laserbeam.vmt");
	g_iHaloSprite = PrecacheModel("materials/sprites/glow06.vmt");
	
	PrecacheModel("models/props_survival/cases/case_random_drop.mdl");
	
	AddFileToDownloadsTable("models/sourcepawn_com/silah.dx90.vtx");
	AddFileToDownloadsTable("models/sourcepawn_com/silah.mdl");
	AddFileToDownloadsTable("models/sourcepawn_com/silah.phy");
	AddFileToDownloadsTable("models/sourcepawn_com/silah.vvd");
	AddFileToDownloadsTable("materials/models/sourcepawn_com/pubg_weapon.vmt");
	AddFileToDownloadsTable("materials/models/sourcepawn_com/pubg_weapon.vtf");
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


public void OnMapEnd()
{
	SaveConfiguration();
} 