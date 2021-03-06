/**
 * Handles the UI aspects of the mutator
 * @author Eric Tsai (scaryghost)
 */
class SAInteraction extends Interaction
    config(Input);

const PHASE_DONE= -1;
const PHASE_SHOWING= 0;
const PHASE_DELAYING= 1;
const PHASE_HIDING= 2;

/**
 * Enumeration of available positions for popup notifications
 */
enum PopupPosition {
    PP_BOTTOM_CENTER,       ///< Default position, bottom and center
    PP_BOTTOM_LEFT,         ///< Bottom and left
    PP_BOTTOM_RIGHT,        ///< Bottom and right
    PP_TOP_CENTER,          ///< Pop down top and center
    PP_TOP_LEFT,            ///< Pop down top and left
    PP_TOP_RIGHT            ///< Pop down top and right
};

/**
 * Tuple containing the attributes of popup message
 */
struct PopupMessage {
    var string header;          ///< Header to display at the top
    var string body;            ///< Content of the message
    var Texture2D image;        ///< Image to display with the message
};

/** Where to display popup messagse on the screen, defaults to bottom and center */
var globalconfig PopupPosition msgPosition;
var PlayerController owner;

var private array<AchievementPack> ownerAchvPacks;
var private IntPoint MousePosition;
var private bool menuOpen, leftButtonPressed, rightButtonPressed, showHud, centerCursor;
var private MobileMenuScene scene;
var private Color DrawColor, CursorColor;
var private Texture2D NotificationBackground, CursorTexture;
var private float NotificationWidth, NotificationHeight, NotificationPhaseStartTime, NotificationIconSpacing,
        NotificationShowTime, NotificationHideTime, NotificationHideDelay, NotificationBorderSize;
var private int NotificationPhase;
var private array<PopupMessage> messageQueue;
/** Character indicating a newline should be inserted */
var privatewrite string newLineSeparator;

/**
 * Opens and closes the achievement progress menu
 */
exec function toggleAchievementMenu() {
    local SAReplicationInfo saRepInfo;
    local MobilePlayerInput mbPlayerInput;

    mbPlayerInput= MobilePlayerInput(owner.PlayerInput);
    menuOpen= !menuOpen;
    if (menuOpen) {
        if (centerCursor) {
            MousePosition.X= owner.myHUD.SizeX / 2;
            MousePosition.Y= owner.myHUD.SizeY / 2;
            centerCursor= false;
        }

        showHud= owner.myHUD.bShowHUD;
        owner.myHUD.bShowHUD= false;
        owner.IgnoreMoveInput(true);
        owner.IgnoreLookInput(true);
        scene= mbPlayerInput.OpenMenuScene(class'AchievementMenuScene');

        if (ownerAchvPacks.Length == 0) {
            saRepInfo= class'SAReplicationInfo'.static.findSAri(owner);
            saRepInfo.getAchievementPacks(ownerAchvPacks);
        }
        AchievementMenuScene(scene).achievementPacks= ownerAchvPacks;
        AchievementMenuScene(scene).refreshAchievementLabel();
    } else {
        owner.myHUD.bShowHUD= showHud;
        owner.IgnoreMoveInput(false);
        owner.IgnoreLookInput(false);
        MobilePlayerInput(owner.PlayerInput).CloseMenuScene(scene);
    }
}

// Function is a modification of the code provided from this thread:
// https://forums.epicgames.com/threads/817252-Creating-Menus-Buttons-Using-Canvas
function bool CheckBounds(MobileMenuObject menuObject) {
    local float FinalRangeX, FinalRangeY, actualTop, actualLeft;

    if(menuObject.bIsActive) {
        actualTop= scene.Top + menuObject.Top;
        actualLeft= scene.Left + menuObject.Left;

        //From the X position add to that the width to create a value starting from the X position to the legnth of the object.
        FinalRangeX = actualLeft + menuObject.Width;
        //From the Y position add to that the height to create a value starting from the Y position to the height of the object.
        FinalRangeY = actualTop + menuObject.Height;

        //CheckMousePositionWithinBounds
        return (MousePosition.X >= actualLeft && MousePosition.X <= FinalRangeX && 
                MousePosition.Y >= actualTop && MousePosition.Y <= FinalRangeY);
    }
    return false;
}

function bool axisEvent(int ControllerId, name Key, float Delta, float DeltaTime, optional bool bGamepad) {
    local MobileMenuObject it;

    if (menuOpen) {
        if (Key == 'MouseX') {
            MousePosition.X = Clamp(MousePosition.X + Delta, 0, owner.myHUD.SizeX);
        } else if (Key == 'MouseY') {
            MousePosition.Y = Clamp(MousePosition.Y - Delta, 0, owner.myHUD.SizeY);
        }

        if (leftButtonPressed) {
            foreach scene.MenuObjects(it) {
                if (CheckBounds(it)) {
                    it.OnTouch(Touch_Moved, MousePosition.X, MousePosition.Y, None, DeltaTime);
                }
            }
        }
    }

    return false;
}

function bool keyEvent(int ControllerId, name Key, EInputEvent EventType, optional float AmountDepressed=1.f,
        optional bool bGamepad) {
    local MobileMenuObject it;

    leftButtonPressed= (Key == 'LeftMouseButton' && EventType == IE_Pressed);
    rightButtonPressed= (Key == 'RightMouseButton' && EventType == IE_Pressed);

    if (leftButtonPressed && menuOpen) {
        foreach scene.MenuObjects(it) {
            if (CheckBounds(it)) {
                it.OnTouch(Touch_Began, MousePosition.X, MousePosition.Y, None, 0);
            }
        }
        return true;
    } else if (Key == 'LeftMouseButton' && EventType == IE_Released && menuOpen) {
        foreach scene.MenuObjects(it) {
            if (CheckBounds(it)) {
                it.OnTouch(Touch_Ended, MousePosition.X, MousePosition.Y, None, 0);
            }
        }
        return true;
    }

    return (menuOpen && rightButtonPressed);
}

/**
 * Adds a message to be displayed as a popup
 * @param newMessage        Message to be displayed
 */
function addMessage(const out PopupMessage newMessage) {
    messageQueue.AddItem(newMessage);

    if (messageQueue.Length == 1) {
        NotificationPhaseStartTime= class'WorldInfo'.static.GetWorldInfo().TimeSeconds;
        NotificationPhase= PHASE_SHOWING;
    }
}

event PostRender(Canvas Canvas) {
    local int i;
    local float IconSize, TempX, TempY, DrawHeight, TimeElapsed, TempWidth, TempHeight;
    local array<string> parts;

    if (menuOpen) {
        MobilePlayerInput(owner.PlayerInput).RenderMenus(Canvas, 0.1f);
        // Set the canvas position to the mouse position
        Canvas.SetPos(MousePosition.X, MousePosition.Y);
        // Set the cursor color
        Canvas.DrawColor = CursorColor;
        // Draw the texture on the screen
        canvas.DrawTileStretched(CursorTexture, CursorTexture.SizeX * 0.2, CursorTexture.SizeY * 0.2, 0, 0, CursorTexture.SizeX, 
                CursorTexture.SizeY);
    }

    if (NotificationPhase == PHASE_DONE) {
        return;
    }

    // Popup code taken from KFMod.HUDKillingFloor (KF1 code)
    // Modifications made to enable popup placement in 6 locations
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

    switch(msgPosition) {
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
            `Warn("Unrecognized position:" @ msgPosition);
            break;
    }

    switch(msgPosition) {
        case PP_BOTTOM_CENTER:
        case PP_BOTTOM_LEFT:
        case PP_BOTTOM_RIGHT:
            TempY= canvas.ClipY - DrawHeight;
            break;
        case PP_TOP_CENTER:
        case PP_TOP_LEFT:
        case PP_TOP_RIGHT:
            TempY= DrawHeight - NotificationHeight;
            break;
        default:
            `Warn("Unrecognized position:" @ msgPosition);
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

    canvas.Font= class'Engine'.static.GetSmallFont();
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
    NotificationBackground=Texture2D'Wep_1P_Shared_TEX.WEP_Detail_1_D'
    NotificationWidth=250.0f
    NotificationHeight=70.f
    NotificationShowTime= 0.3
    NotificationHideTime= 0.5
    NotificationHideDelay= 3.5
    NotificationBorderSize= 7.0
    NotificationIconSpacing= 10.0
    NotificationPhase=PHASE_DONE

    OnReceivedNativeInputAxis=axisEvent
    OnReceivedNativeInputKey=keyEvent

    CursorTexture=Texture2D'UI_Managers.LoaderManager_SWF_I13'
    CursorColor=(R=255,G=255,B=255,A=255)
    DrawColor=(R=255,G=255,B=255,A=255)
    newLineSeparator="|"

    menuOpen=false
    centerCursor= true
}
