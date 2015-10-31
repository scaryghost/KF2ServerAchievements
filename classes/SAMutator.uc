class SAMutator extends Engine.Mutator;

simulated function Tick(float DeltaTime) {
    local PlayerController localController;
    local Interaction newInteraction;

    localController= GetALocalPlayerController();
    if (localController != none) {
        newInteraction= new class'SAInteraction';
        //https://forums.epicgames.com/threads/594381-How-to-set-up-keypress-interactions
        LocalPlayer(localController.Player).ViewportClient.InsertInteraction(newInteraction, 0);
        localController.Interactions.AddItem(newInteraction);
    }
    Disable('Tick');
}

function PostBeginPlay() {
    `Log("Hello World");
}

defaultproperties
{
    RemoteRole=ROLE_SimulatedProxy
    bAlwaysRelevant=true
}
