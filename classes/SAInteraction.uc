class SAInteraction extends Interaction;

const PHASE_DONE= -1;
const PHASE_SHOWING= 0;
const PHASE_DELAYING= 1;
const PHASE_HIDING= 2;

enum PopupPosition {
    PP_TOP_LEFT,
    PP_TOP_CENTER,
    PP_TOP_RIGHT,
    PP_BOTTOM_LEFT,
    PP_BOTTOM_CENTER,
    PP_BOTTOM_RIGHT
};

struct PopupMessage {
    var string header;
    var string body;
    var Texture2D image;
};

var Color DrawColor;
var PopupPosition ppPosition;
var texture NotificationBackground;
var float NotificationWidth, NotificationHeight, NotificationPhaseStartTime, NotificationIconSpacing,
        NotificationShowTime, NotificationHideTime, NotificationHideDelay, NotificationBorderSize;
var int NotificationPhase;
var array<PopupMessage> messageQueue;
var string newLineSeparator;

function bool keyEvent(int ControllerId, name Key, EInputEvent EventType, optional float AmountDepressed=1.f,
        optional bool bGamepad) {
    local PopupMessage msg;

    if (EventType == IE_Pressed && key == 'F4') {
        msg.header= "Achievement Completed";
        msg.body= "Test Pack|The quick brown fox jumped over the lazy dog";
        msg.image= Texture2D'EditorMaterials.Tick';
        addMessage(msg);
    }
    return false;
}

function addMessage(PopupMessage newMessage) {
    messageQueue.AddItem(newMessage);

    if (messageQueue.Length == 1) {
        NotificationPhaseStartTime= class'WorldInfo'.static.GetWorldInfo().TimeSeconds;
        NotificationPhase= PHASE_SHOWING;
    }
}

event PostRender(Canvas Canvas) {
    local int i;
    local float IconSize, TempX, TempY, DrawHeight, TimeElapsed, TempWidth, TempHeight;
    local array<string> parts, wrappedText;

    if (NotificationPhase == PHASE_DONE) {
        return;
    }

    TimeElapsed= class'WorldInfo'.static.GetWorldInfo().TimeSeconds - NotificationPhaseStartTime;
    switch(NotificationPhase) {
        case PHASE_SHOWING:
            if (TimeElapsed < NotificationShowTime) {
                DrawHeight= (TimeElapsed / NotificationShowTime) * NotificationHeight;
            } else {
                NotificationPhase= PHASE_DELAYING;
                NotificationPhaseStartTime= class'WorldInfo'.static.GetWorldInfo().TimeSeconds - (TimeElapsed - NotificationShowTime);
                DrawHeight= NotificationHeight;
            }
            break;
        case PHASE_DELAYING:
            if (TimeElapsed < NotificationHideDelay ) {
                DrawHeight= NotificationHeight;
            } else {
                NotificationPhase= PHASE_HIDING; // Hiding Phase
                TimeElapsed-= NotificationHideDelay;
                NotificationPhaseStartTime= class'WorldInfo'.static.GetWorldInfo().TimeSeconds - TimeElapsed;
                DrawHeight= (1.0 - (TimeElapsed / NotificationHideTime)) * NotificationHeight;
            }
            break;
        case PHASE_HIDING:
            if (TimeElapsed < NotificationHideTime) {
                DrawHeight= (1.0 - (TimeElapsed / NotificationHideTime)) * NotificationHeight;
            } else {
                // We're done
                messageQueue.remove(0, 1);
                if (messageQueue.Length != 0) {
                    NotificationPhaseStartTime= class'WorldInfo'.static.GetWorldInfo().TimeSeconds;
                    NotificationPhase= PHASE_SHOWING;
                } else {
                    NotificationPhase= PHASE_DONE;
                }
                return;
            }
            break;
    }

    switch(ppPosition) {
        case PP_TOP_LEFT:
        case PP_BOTTOM_LEFT:
            TempX= 0;
            break;
        case PP_TOP_CENTER:
        case PP_BOTTOM_CENTER:
            TempX = (canvas.ClipX / 2.0) - (NotificationWidth / 2.0);
            break;
        case PP_TOP_RIGHT:
        case PP_BOTTOM_RIGHT:
            TempX= canvas.ClipX - NotificationWidth;
            break;
        default:
            `Warn("Unrecognized position:" @ ppPosition);
            break;
    }

    switch(ppPosition) {
        case PP_BOTTOM_LEFT:
        case PP_BOTTOM_CENTER:
        case PP_BOTTOM_RIGHT:
            TempY= canvas.ClipY - DrawHeight;
            break;
        case PP_TOP_LEFT:
        case PP_TOP_CENTER:
        case PP_TOP_RIGHT:
            TempY= DrawHeight - NotificationHeight;
            break;
        default:
            `Warn("Unrecognized position:" @ ppPosition);
            break;
    }

    // Draw the Background
    canvas.SetPos(TempX, TempY);
    canvas.SetDrawColorStruct(DrawColor);
    canvas.DrawTileStretched(NotificationBackground, NotificationWidth, NotificationHeight, 0, 0, NotificationWidth,
            NotificationHeight);


    // Offset for Border and Calc Icon Size
    TempX += NotificationBorderSize;
    TempY += NotificationBorderSize;

    IconSize= NotificationHeight - (NotificationBorderSize * 2.0);
    canvas.SetPos(TempX, TempY);
    canvas.DrawTile(messageQueue[0].image, IconSize, IconSize, 0, 0, messageQueue[0].image.SizeX, messageQueue[0].image.SizeY);
    canvas.SetDrawColor(255, 255, 255, 255);
    // Offset for desired Spacing between Icon and Text
    TempX += IconSize + NotificationIconSpacing;

    canvas.SetPos(TempX, TempY);
    canvas.DrawText(messageQueue[0].header);

    canvas.SetClip(TempX + (NotificationWidth - IconSize - NotificationBorderSize * 2.0 - NotificationIconSpacing), TempY);

    // Set up next line
    ParseStringIntoArray(messageQueue[0].body, parts, default.newLineSeparator, true);
    for(i= 0; i < parts.Length; i++) {
        canvas.StrLen(parts[i], TempWidth, TempHeight);
        TempY += TempHeight;
        canvas.SetPos(TempX, TempY);
        canvas.DrawText(parts[i]);
    }
}

defaultproperties
{
    NotificationBackground=Texture'Wep_1P_Shared_TEX.WEP_Detail_1_D'
    //NotificationBackground=Texture'Bkgnd'
    //NotificationBackground=Texture'Engine_MI_Shaders.T_Specular'
    //NotificationBackground=Texture'EngineResources.Black'
    //NotificationBackground=Texture'ENV_Material_Types_TEX.Metal.Env_Basic_Metal_DIff'
    NotificationWidth=250.0f
    NotificationHeight=70.f
    NotificationShowTime= 0.3
    NotificationHideTime= 0.5
    NotificationHideDelay= 3.5
    NotificationBorderSize= 7.0
    NotificationIconSpacing= 10.0
    NotificationPhase=PHASE_DONE

    ppPosition=PP_BOTTOM_CENTER

    OnReceivedNativeInputKey=keyEvent

    DrawColor=(R=255,G=255,B=255,A=255)
    newLineSeparator="|"
}
