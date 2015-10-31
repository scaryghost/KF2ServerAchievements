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
    var Texture image;
};

var color DrawColor;       // Color for drawing.
var PopupPosition ppPosition;
var texture NotificationBackground;
var float NotificationWidth, NotificationHeight, NotificationPhaseStartTime, NotificationIconSpacing,
        NotificationShowTime, NotificationHideTime, NotificationHideDelay, NotificationBorderSize;
var int NotificationPhase;
var array<PopupMessage> messageQueue;

function bool keyEvent(int ControllerId, name Key, EInputEvent EventType, optional float AmountDepressed=1.f,
        optional bool bGamepad) {
    //`Log("SAInteraction: key= " $ key);
    if (key == 'F4') {
        NotificationPhaseStartTime= class'WorldInfo'.static.GetWorldInfo().TimeSeconds;
        NotificationPhase= PHASE_SHOWING;
    }
    return false;
}

event PostRender(Canvas Canvas) {
    local float TempX, TempY, DrawHeight, TimeElapsed;

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
                NotificationPhase= PHASE_DONE;
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
}
