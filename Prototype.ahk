; Prototype AutoHotkey script for Ultra-Rancher
; Demonstrates a simple 2D pseudo-3D engine with sprite interactions
; Uses GDI+ for drawing images with transparency

#SingleInstance Force
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

; ==== Initialize GDI+ ====
if !pToken := Gdip_Startup()
{
    MsgBox, GDI+ failed to start.
    ExitApp
}

; ==== Load sprites ====
; Replace with paths to your images
playerSprite := Gdip_CreateBitmapFromFile("player.png")
objectSprite := Gdip_CreateBitmapFromFile("object.png")

; Simple world data
playerX := 400
playerY := 300
objectX := 450
objectY := 350
scale := 1.0

Gui, New, +AlwaysOnTop +Resize +hwndGuiHwnd
Gui, Show, w800 h600, Ultra-Rancher Prototype

; Create a GDI+ graphics surface
hbm := CreateDIBSection(800, 600)
hdc := CreateCompatibleDC()
obm := SelectObject(hdc, hbm)
Graphics := Gdip_GraphicsFromHDC(hdc)
Gdip_SetSmoothingMode(Graphics, 4)

SetTimer, Render, 16
return

Render:
    Gdip_GraphicsClear(Graphics, 0xFF000000)
    ; Draw object with simple scaling for pseudo depth
    depth := objectY - playerY
    factor := 1 + depth/300.0
    width := Gdip_GetImageWidth(objectSprite) * factor
    height := Gdip_GetImageHeight(objectSprite) * factor
    objX := objectX - width/2
    objY := objectY - height
    Gdip_DrawImage(Graphics, objectSprite, objX, objY, width, height)
    ; Draw player sprite
    pW := Gdip_GetImageWidth(playerSprite)
    pH := Gdip_GetImageHeight(playerSprite)
    Gdip_DrawImage(Graphics, playerSprite, playerX - pW/2, playerY - pH, pW, pH)
    UpdateLayeredWindow(GuiHwnd, hdc, 0, 0, 800, 600)
return

; Movement controls move the world around the player
$q::MoveWorld(-10, -10)
$w::MoveWorld(0, -10)
$e::MoveWorld(10, -10)
$a::MoveWorld(-10, 0)
$s::MoveWorld(0, 10)
$d::MoveWorld(10, 0)

MoveWorld(dx, dy)
{
    global objectX, objectY
    objectX -= dx
    objectY -= dy
}

; Click detection
Gui, +E0x80000 ; WS_EX_LAYERED
Gui, Add, Picture, x0 y0 w800 h600 hwndPicHwnd,
Gui, Show
OnMessage(0x201, "WM_LBUTTONDOWN")
return

WM_LBUTTONDOWN()
{
    global objectX, objectY, playerX, playerY, objectSprite
    MouseGetPos, mx, my
    ; Determine object size based on pseudo depth
    depth := objectY - playerY
    factor := 1 + depth/300.0
    width := Gdip_GetImageWidth(objectSprite) * factor
    height := Gdip_GetImageHeight(objectSprite) * factor
    objX := objectX - width/2
    objY := objectY - height
    if (mx >= objX && mx <= objX + width && my >= objY && my <= objY + height)
    {
        MsgBox, You clicked the object!
    }
}

GuiClose:
ExitApp

; ==== Cleanup ====
OnExit, ExitSub
ExitSub:
    Gdip_DisposeImage(playerSprite)
    Gdip_DisposeImage(objectSprite)
    SelectObject(hdc, obm)
    DeleteObject(hbm)
    DeleteDC(hdc)
    Gdip_Shutdown(pToken)
return
