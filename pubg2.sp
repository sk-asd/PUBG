#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <basecomm>
#include <overlays>
#include <warden>
#include "pubg/Global.sp"
#include "pubg/MapStart.sp"
#include "pubg/Stocks.sp"
#include "pubg/Hooks.sp"
#include "pubg/Helikopter.sp"
#include "pubg/Menuler.sp"
#include "pubg/Start.sp"
#pragma semicolon 1
#pragma newdecls required 
#pragma tabsize 0
public Plugin myinfo = { name = "PUBG Oyunu", author = "phiso, hibna", description = "Jailbreak modu için pubg oyunu", version = "1.0", url = "sourcepawn.com" };

/*


                                                                                            
  __________  __ _________   ____  ____ ___________ __  _  ______       ____  ____   _____  
 /  ___/  _ \|  |  \_  __ \_/ ___\/ __ \\____ \__  \\ \/ \/ /    \    _/ ___\/  _ \ /     \ 
 \___ (  <_> )  |  /|  | \/\  \__\  ___/|  |_> > __ \\     /   |  \   \  \__(  <_> )  Y Y  \
/____  >____/|____/ |__|    \___  >___  >   __(____  /\/\_/|___|  / /\ \___  >____/|__|_|  /
     \/                         \/    \/|__|       \/           \/  \/     \/            \/ 

*/
