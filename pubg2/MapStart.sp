public void OnMapStart()
{
	char mapName[128];
	GetCurrentMap(mapName, sizeof(mapName));
	
	g_iBeamSprite = PrecacheModel("materials/sprites/laserbeam.vmt");
	g_iHaloSprite = PrecacheModel("materials/sprites/glow06.vmt");
	g_iPathLaserModelIndex = PrecacheModel(MODEL_BEAM);
	
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
	
	AddFileToDownloadsTable("materials/models/enhancedrockets2/w_rocket_original.vmt");
	AddFileToDownloadsTable("materials/models/enhancedrockets2/w_rocket_original.vtf");
	AddFileToDownloadsTable("models/enhancedrockets2/w_rocket_original.dx80.vtx");
	AddFileToDownloadsTable("models/enhancedrockets2/w_rocket_original.dx90.vtx");
	AddFileToDownloadsTable("models/enhancedrockets2/w_rocket_original.mdl");
	AddFileToDownloadsTable("models/enhancedrockets2/w_rocket_original.phy");
	AddFileToDownloadsTable("models/enhancedrockets2/w_rocket_original.sw.vtx");
	AddFileToDownloadsTable("models/enhancedrockets2/w_rocket_original.vvd");
	PrecacheModel("models/enhancedrockets2/w_rocket_original.mdl", false);
	PrecacheModel("models/props_vehicles/helicopter_rescue.mdl", false);
	
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