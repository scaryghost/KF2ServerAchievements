class SAMutator extends KFGame.KFMutator
    dependson(SAReplicationInfo)
    config(ServerAchievements);

var() config array<string> achievementPackClassnames;
var() config string dataLinkClassname;

var private array<class<AchievementPack> > loadedAchievementPacks;
var private DataLink dataLnk;
var private GlobalEventDispatcher globalDispatcher;

function PostBeginPlay() {
    local class<AchievementPack> loadedPack;    
    local array<string> uniqueClassnames;
    local string it;    
    local class<DataLink> dataLinkClass;

    `Log("Attempting to load" @ achievementPackClassnames.Length @ "achievement packs", true, 'ServerAchievements');    
    if (achievementPackClassnames.Length == 0) {
        achievementPackClassnames.AddItem(PathName(class'TestStandardAchievementPack'));
    }
    foreach achievementPackClassnames(it) {
        class'Arrays'.static.uniqueInsert(uniqueClassnames, it);
    }
    foreach uniqueClassnames(it) {
        loadedPack= class<AchievementPack>(DynamicLoadObject(it, class'Class'));
        if (loadedPack == none) {
            `Warn("Failed to load achievement pack" @ it, true, 'ServerAchievements');
        } else {
            `Log("Successfully loaded" @ it, true, 'ServerAchievements');
            loadedAchievementPacks.AddItem(loadedPack);
        }
    }

    if (Len(dataLinkClassname) == 0) {
        `Warn("No data link specified, defaulting to ServerAchievements.FileDataLink", true, 'ServerAchievements');
        dataLnk= new class'FileDataLink';
        dataLinkClassname= PathName(dataLnk.class);
    } else {
        dataLinkClass= class<DataLink>(DynamicLoadObject(dataLinkClassname, class'Class'));
        if (dataLinkClass == None) {
            `Warn("Cannot load DataLink class:" @ dataLinkClassname, true, 'ServerAchievements');
            `Warn("Defaulting to ServerAchievements.FileDataLink", true, 'ServerAchievements');
            dataLnk= new class'FileDataLink'; 
        } else {
            dataLnk= new dataLinkClass;
        }
    }

    SaveConfig();

    globalDispatcher = new class'GlobalEventDispatcher';
}

simulated event Tick(float DeltaTime) {
    local MatchInfo info;

    if (WorldInfo.Game.GameReplicationInfo.bMatchIsOver) {
        info.mapName= WorldInfo.GetMapName(true);
        info.difficulty= KFGameReplicationInfo(WorldInfo.Game.GameReplicationInfo).GameDifficulty;
        info.length= KFGameReplicationInfo(WorldInfo.Game.GameReplicationInfo).GameLength;
        if (WorldInfo.Game.IsA('KFGameInfo')) {
            info.result= KFGameInfo(WorldInfo.Game).GetLivingPlayerCount() <= 0 ? SA_MR_LOST : SA_MR_WON;
        } else {
            info.result= SA_MR_UNKNOWN;
        }

        globalDispatcher.notifyMatchEnded(info);

        Disable('Tick');
    }
}

function bool CheckReplacement(Actor Other) {
    local PlayerReplicationInfo pri;
    local SAReplicationInfo saRepInfo;

    if (KFPlayerController(Other) != None) {
        KFPlayerController(Other).MatchStatsClass = class'ServerAchievements.EphemeralMatchStats';
    } else if (PlayerReplicationInfo(Other) != none && Other.Owner != None && Other.Owner.IsA('PlayerController') && 
            PlayerController(Other.Owner).bIsPlayer) {
        pri= PlayerReplicationInfo(Other);

        saRepInfo= Spawn(class'SAReplicationInfo', pri.Owner);
        saRepInfo.globalDispatcher = globalDispatcher;
        saRepInfo.playerDispatcher = new class'PlayerEventDispatcher';
        saRepInfo.dataLnk= dataLnk;
        saRepInfo.achievementPackClasses= loadedAchievementPacks;
    }
    return super.CheckReplacement(Other);
}

function bool OverridePickupQuery(Pawn Other, class<Inventory> ItemClass, Actor Pickup, out byte bAllowPickup) {
    local SAReplicationInfo saRepInfo;
    local bool result;

    result= super.OverridePickupQuery(Other, ItemClass, Pickup, bAllowPickup);
    if (!result || (result && bAllowPickup != 0)) {
        saRepInfo= class'SAReplicationInfo'.static.findSAri(Other.Controller);
        if (saRepInfo != none) {
            saRepInfo.playerDispatcher.notifyItemPickup(Pickup);
        }
    }
    return result;
}

function bool PreventDeath(Pawn Killed, Controller Killer, class<DamageType> damageType, vector HitLocation) {
    local SAReplicationInfo saRepInfo;
    local PlayerEventDispatcher dispatcher;

	if (!super.PreventDeath(Killed, Killer, damageType, HitLocation)) {
        if (Killed.IsA('KFPawn_Human')) {
            saRepInfo= class'SAReplicationInfo'.static.findSAri(Killed.Controller);
            if (saRepInfo != none) {
                dispatcher = saRepInfo.playerDispatcher;
                dispatcher.notifyDeathEvent(dispatcher.DeathEventType.PLAYER_DIED, Killed, Killer, damageType);
            }
        } else if (Killer.IsA('KFPlayerController')) {
            saRepInfo= class'SAReplicationInfo'.static.findSAri(Killer);
            
            if (saRepInfo != none && Killed.IsA('KFPawn_Monster')) {
                dispatcher = saRepInfo.playerDispatcher;
                dispatcher.notifyDeathEvent(dispatcher.DeathEventType.MONSTER_DIED, Killed, Killer, damageType);
            }
        }
        return false;
    }
    return true;
}

function ModifyNextTraderIndex(out byte NextTraderIndex) {
    local KFGameReplicationInfo gri;

    super.ModifyNextTraderIndex(NextTraderIndex);

    gri= KFGameReplicationInfo(WorldInfo.Game.GameReplicationInfo);
    if (gri != none) {
        globalDispatcher.notifyWaveStarted(gri.WaveNum, gri.WaveMax);
    }
}

function NotifyLogout(Controller Exiting) {
    local SAReplicationInfo saRepInfo;
    local array<AchievementPack> packs;

    super.NotifyLogout(Exiting);

    saRepInfo= class'SAReplicationInfo'.static.findSAri(Exiting);
    saRepInfo.getAchievementPacks(packs);
    dataLnk.saveAchievementState(PlayerController(saRepInfo.Owner).PlayerReplicationInfo.UniqueId, packs);
}
