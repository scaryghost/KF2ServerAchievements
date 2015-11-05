class SAMutator extends Engine.Mutator;

simulated function Tick(float DeltaTime) {
    local PlayerController localController;
    local SAInteraction newInteraction;

    localController= GetALocalPlayerController();
    if (localController != none) {
        newInteraction= new class'SAInteraction';
        newInteraction.owner= localController;
        //https://forums.epicgames.com/threads/594381-How-to-set-up-keypress-interactions
        LocalPlayer(localController.Player).ViewportClient.InsertInteraction(newInteraction, 0);
        localController.Interactions.AddItem(newInteraction);
    }
    Disable('Tick');
}

function PostBeginPlay() {
    `Log("Hello World");
}

function bool CheckReplacement(Actor Other) {
    local PlayerReplicationInfo pri;
    local SAReplicationInfo saRepInfo;

    if (PlayerReplicationInfo(Other) != none && Other.Owner != none) {
        pri= PlayerReplicationInfo(Other);
        saRepInfo= Spawn(class'SAReplicationInfo', pri.Owner);
        saRepInfo.ownerPri= pri;
    }
    return super.CheckReplacement(Other);
}

defaultproperties
{
    RemoteRole=ROLE_SimulatedProxy
    bAlwaysRelevant=true
}
