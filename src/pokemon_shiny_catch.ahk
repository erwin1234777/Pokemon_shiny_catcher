;;#SingleInstance force
#SingleInstance off

SendMode Input
SetWorkingDir %A_ScriptDir%

config := A_ScriptDir . "\config.ini"
if not (FileExist(config)) {
    FileAppend,
    (
        [Coordinates]
            xCord=0
            yCord=0
            clickXCord=0
            clickYCord=0
        [ColorSearch]
            targetColor=0x000000
            lastColor=0x000000
        [PokeOptions]
            sunStarter=0
        [CitraMappings]
        [mGBAMappings]
        [Other]
            IterationCount=0
            checkWinActive=1
            citra_pid=0
    ), % config, utf-16
}
; local variables not to be saved/reused in ini
startTime := A_TickCount
currentlyTrue := "="
stopped := 1

; ini variables
IniRead, xCord, % config, Coordinates, xCord, 0
IniRead, yCord, % config, Coordinates, yCord, 0
IniRead, clickXCord, % config, Coordinates, clickXCord, 0
IniRead, clickYCord, % config, Coordinates, clickYCord, 0
IniRead, targetColor, % config, ColorSearch, targetColor, 0x000000
IniRead, lastColor, % config, ColorSearch, lastColor, 0x000000
IniRead, sunStarter, % config, PokeOptions, sunStarter, 0
IniRead, citra_pid, % config, Other, citra_pid, 0
IniRead, IterationCount, % config, Other, IterationCount, 0
IniRead, checkWinActive, % config, Other, checkWinActive, 1

;; make an object called citra_mappings with the property a = string b

_citraMappings := {KeyA:"a", KeyB:"s", KeyX:"z", KeyY:"x", KeyL:"q", KeyR:"w", KeyZl:"1", KeyZr:"2", KeyStart:"m", KeySelect:"n", KeyHome:"b", KeyDebug:"o", DpadUp:"4", DpadLeft:"5", DpadRight:"6", DpadDown:"7"}

ResetGUI(running := false, runningGiven := false, citraRunning := false, citraShinyRunning := false) {
    global
    Gui, Destroy
    Gui, Show, w400 h400, Erwin's Shiny Catcher
    ; x10 x100 x190 grid
    ; y+30 grid y80 y120 y150 y180 y210 y240 y280

    ;help buttons
    Gui, Add, Button, gGeneralHelp x370 y370 w20 h20, ?
    Gui, Add, Button, gStaticPKMNHelp x90 y185 w20 h20, ?
    Gui, Add, Button, gGivenPKMNHelp x230 y185 w20 h20, ?
    Gui, Add, Button, gEggPKMNHelp x370 y185 w20 h20, ?

    ; first row
    Gui, Add, Button, gStartButton x10 y180 w80 h30, StaticPKMN 
    Gui, Add, Button, gGivenButton x150 y180 w80 h30, GivenPKMN
    Gui, Add, Button, gEggPKMN x290 y180 w80 h30, EggPKMN
    ; second row
    Gui, Add, Button, cGreen BackgroundTrans cRED gStopButton x10 y210 w80 h30, Stop
    Gui, Add, Button, gResetButton x150 y210 w80 h30, Reset Timer/Count
    Gui, Add, Button, gReloadButton x290 y210 w80 h30, Reload
    ; third row
    Gui, Add, Button, gGetColor x10 y240 w80 h30, Get Color
    Gui, Add, Button, gActiveWin x150 y240 w80 h30, ForceWindow
    Gui, Add, Button, gTestButton x290 y240 w80 h30, Test
    ; fourth row
    Gui, Add, Button, gCitraSunStarter x10 y270 w80 h30, StartSunStarter
    Gui, Add, Button, gSetMouseClickPos x150 y270 w80 h30, MouseClickPos
    Gui, Add, Button, gSetStarter x290 y270 w80 h30, SetSunPKMN

    ;icons
    Gui, Add, Progress, x200 y350 w15 h15 c%lastColor% vLastColorGUI, 100
    Gui, Add, Progress, x230 y350 w15 h15 c%targetColor% vCurrentColorGUI, 100

    ;text 1 p/ row +30y 
    ; row 1
    Gui, Add, Text, vIterationCount x10 y20 w50 h30, Resets: %IterationCount%
    local timeDiff := Round((A_TickCount - startTime) / 1000 / 60, 1)
    Gui, Add, Text, vTimeElapsed x150 y20 w100 h30, %timeDiff% minutes
    Gui, Add, Text, x290 y20 w80 h30, PiD: %citra_pid%
    ; row 2
    Gui, Add, Text, x10 y50 w80 h30, Color: %targetColor%
    Gui, Add, Progress, x100 y49 w15 h15 c%targetColor% vCurrentColorGUI2, 100
    if(sunStarter) {
         Gui, Add, Text, x150 y50 w80 h30, Sun Starter: %sunStarter%
    }
    ;row 3
    Gui, Add, Text, x10 y80 w80 h30, X: %xCord%
    Gui, Add, Text, x150 y80 w80 h30, ClickX: %clickXCord%
    ;row 4
    Gui, Add, Text, x10 y110 w80 h30, Y: %yCord%
    Gui, Add, Text, x150 y110 w80 h30, ClickY: %clickYCord%
    ;row 5
    Gui, Add, Text, x150 y140 w80 h30 Center vStatusLabel, Stopped ; Add a text control to display the status
    Gui, Add, Text, vCurrentlyTrue x220 y350 w15 h15, %currentlyTrue%
    ;row 6
    ;Gui, Add, Text, x10 y140 w280 h30 Center vCheckWin, ActiveWin: %checkWinActive% ;
   
    GuiControl, Font, StatusLabel, ; Set the font color of the 'StatusLabel' control
    ;GuiControl,, StatusLabel, "Expected " . targetColor . " found " . lastColor . " [ " . (targetColor = lastColor) . " ]"

    if  (running) {
        StartButtonFunc()
    }
    if  (runningGiven) {
        givenButtonFunc()
    }
    if  (citraRunning) {
        citraStarterSunClickMethod()
    }
    if (citraShinyRunning) {
        citraShinyCatchingInFrontOfPokemon()
    }
    return

    GetColor:
        GuiControl, Disable, gGetColor
        sleep 5000
        Gui, Submit, NoHide
        CoordMode, Mouse, Screen
        CoordMode Pixel, Screen
        MouseGetPos, currentX, currentY
        PixelGetColor, cColor, %currentX%, %currentY%, RGB
        targetColor := cColor
        xCord := currentX
        yCord := currentY
        return ResetGUI()
    SetMouseClickPos:
        GuiControl, Disable, gGetColor
        sleep 5000
        Gui, Submit, NoHide
        CoordMode, Mouse, Screen
        MouseGetPos, currentX, currentY
        clickXCord := currentX
        clickYCord := currentY
        Click, %clickXCord%, %clickYCord%
        WinGet, citra_pid, PID, A
        return ResetGUI()
    StartButton:
        StartButtonFunc()
    return
    TestButton:
    ;;tempVar := _citraMappings["KeyX"]
    ;;tempVar2 := _citraMappings.KeyX
    ;;MsgBox, %tempVar%, %tempVar2%
    ;;    SetKeyDelay, 0, 300
    ;;    ensureCitraWinActive()

    ;;    foo := citraMappings["KeyX"]
    ;;    bar := _citraMappings["KeyX"]

    ;;    ;; works
    ;;    GuiControl,, StatusLabel, Testing SendInput...
    ;;    SendInput {z down}
    ;;    sleep 500
    ;;    SendInput {z up}
    ;;    sleep 1000

    ;;    ;; works
    ;;    GuiControl,, StatusLabel, Testing ControlSend 2...
    ;;    ControlSend, Citra ,{%bar%}, Citra
    ;;    sleep 1000

        citraShinyCatchingInFrontOfPokemon()

        return
    SetStarter:
            InputBox, sunStarter, Starter Selector,Type 1 for Rowlet`, 2 for Litten`, 3 for Popplio`, , 640, 480
            if(sunStarter !== 1 && sunStarter !== 2 && sunStarter !== 3) {
                sunStarter := 1
            }
            ResetGUI()
        return
    CitraSunStarter:
        citraStarterSunClickMethod()
    return
    GivenButton:
        givenButtonFunc()
    return
    GuiClose:
        IniWrite, % xCord, % config, Coordinates, xCord
        IniWrite, % yCord, % config, Coordinates, yCord
        IniWrite, % clickXCord, % config, Coordinates, clickXCord
        IniWrite, % clickYCord, % config, Coordinates, clickYCord
        IniWrite, % targetColor, % config, ColorSearch, targetColor
        IniWrite, % lastColor, % config, ColorSearch, lastColor
        IniWrite, % sunStarter, % config, PokeOptions, sunStarter
        IniWrite, % citra_pid, % config, Other, citra_pid
        IniWrite, % IterationCount, % config, Other, IterationCount
        IniWrite, % checkWinActive, % config, Other, checkWinActive
        ExitApp
    StopButton:
        stopped := 1
    return
    ActiveWin:
        checkWinActive := 1
    return
    ReloadButton:
        Reload
    ResetButton:
        IterationCount := 0
        startTime := A_TickCount
        ResetGUI()
    return
    EggPKMN:
    return
    StaticPKMNHelp:
    MsgBox, Placeholder for help with Static Pokemon and how to set it up
    return
    GivenPKMNHelp:
    MsgBox, Placeholder for help with Gift/Given Pokemon and how to set it up
    return
    EggPKMNHelp:
    MsgBox, Placeholder for help with Egg Pokemon and how to set it up
    return
    GeneralHelp:
    MsgBox, Make sure the keybinds are set to `nf4 = a`nf5 = b`nf6 = up`nf7 = down`nf8 = start`nf9 = select.`nMake sure F1 and F2 load state, and that Shift + F1/Shift + F2 save state.`n`n`nThis is used in every script, check scripts help (?) before using them if you are new
    return
}

ResetGUI()

resetFrame() {
	SetKeyDelay, 0, 25
	ControlSend, mGBA ,{F8}, mGBA ; f8 = start
      sleep 100
	SetKeyDelay, 0, 25
	ControlSend, mGBA ,{F4}, mGBA ; f4 = a
      sleep 100
	SetKeyDelay, 0, 25
	ControlSend, mGBA ,{F5}, mGBA ; f5 = b
      sleep 100
	SetKeyDelay, 0, 25
	ControlSend, mGBA ,{F5}, mGBA ; f5 = b
      sleep 100
	SetKeyDelay, 0, 25
	ControlSend, mGBA ,{F5}, mGBA ; f5 = b
      sleep 100
	SetKeyDelay, 0, 25
	ControlSend, mGBA ,{F5}, mGBA ; f5 = b
      sleep 100
	return
}

save() {
        SetKeyDelay, 0, 100
        ControlSend, mGBA ,+{F2}, mGBA
        sleep 100
}

reload() {
        SetKeyDelay, 0, 100
        ControlSend, mGBA ,{F2}, mGBA
        sleep 50
}

startButtonFunc(mode = "emerald") {
    global
    GuiControl,, StatusLabel, Running...
    stopped := 0
    Loop {
        if (stopped) {
            break
        }
        SetTitleMatchMode, 2
        if(mode = "unbound") {
            ; mapping
            ; f4 = a
            ; f5 = b
            ; f6 = up
            ; f7 = down
            ; f8 = start
            ; f9 = select
            ensureWinActive()

            reload()

	        resetFrame()

	        save()

            ;SetKeyDelay, 0, 50
            ;SendEvent {F6} ; f6 = up
            ;sleep 50

	        Loop 3 { ; loop f4 = a
 	        	 SetKeyDelay, 0, 100
              	 ControlSend, mGBA ,{F4}, mGBA ; f4 = a
              	 sleep 70
	        }
            sleep 400
            Gui, Submit, NoHide
            CoordMode, Mouse, Screen
            CoordMode Pixel, Screen
            PixelGetColor, cColor, %xCord%, %yCord%, RGB
            sleep, 200
            if (cColor = targetColor) {
                currentlyTrue := "="
                if(lastColor = cColor) {
                    GuiControl,, vCurrentlyTrue, =
                    lastColor := cColor
                    SetKeyDelay, 0, 100
                    ControlSend, mGBA ,{F2}, mGBA
                    Sleep 200
                    IterationCount += 1
                    ; updating fields we set above in the GUI
                    GuiControl,, vIterationCount, Resets: %IterationCount%
                    GuiControl,, vColorOutput, %cColor%
                    GuiControl,, vXOutput, %xCord%
                    GuiControl,, vYOutput, %yCord%
                    GuiControl,, vLastColorGUI, %lastColor%
                    GuiControl,, vCurrentColorGUI, %cColor%
                    GuiControl,, vCurrentColorGUI2, %cColor%
                    GuiControl,, vCheckWin, ActiveWin: %checkWinActive% ;
                } else {
                    GuiControl,, vCurrentlyTrue, =
                    lastColor := cColor
                    SetKeyDelay, 0, 100
                    ControlSend, mGBA ,{F2}, mGBA
                    Sleep 200
                    IterationCount += 1
                    GuiControl,, vIterationCount, Resets: %IterationCount%
                    GuiControl,, vColorOutput, %cColor%
                    GuiControl,, vXOutput, %xCord%
                    GuiControl,, vYOutput, %yCord%
                    GuiControl,, vLastColorGUI, %lastColor%
                    GuiControl,, vCurrentColorGUI, %cColor%
                    GuiControl,, vCurrentColorGUI2, %cColor%
                    GuiControl,, vCheckWin, ForceWindow: %checkWinActive% ;
                    return ResetGUI(true)
                }
            } else {
                currentlyTrue := "!="
                GuiControl,, vCurrentlyTrue, !=
                GuiControl,, StatusLabel, "Expected " . targetColor . " found " . lastColor . " [ " . (targetColor = lastColor) . " ]"
                GuiControl,, vIterationCount, Resets: %IterationCount%
                GuiControl,, vColorOutput, %cColor%
                GuiControl,, vXOutput, %xCord%
                GuiControl,, vYOutput, %yCord%
                GuiControl,, vLastColorGUI, %lastColor%
                GuiControl,, vCurrentColorGUI, %cColor%
                GuiControl,, vCheckWin, ForceWindow: %checkWinActive% ;
                return ResetGUI()
                break
            }
        } else if(mode = "emerald") {
            ; mapping
            ; f4 = a
            ; f5 = b
            ; f6 = up
            ; f7 = down
            ; f8 = start
            ; f9 = select
            GuiControl,, StatusLabel, Running Emerald...
            ensureWinActive()
            GuiControl,, StatusLabel, reloading Emerald...
            reload()
            GuiControl,, StatusLabel, resetting frame...
            resetFrame()
            GuiControl,, StatusLabel, saving...
            save()

            ;SetKeyDelay, 0, 50
            ;SendEvent {F6} ; f6 = up
            ;sleep 50
            GuiControl,, StatusLabel, moving up...
            ;; move up
            Loop 3 { ; loop f6 = up
                SetKeyDelay, 0, 100
                ControlSend, mGBA ,{F6}, mGBA ; f6 = up
                sleep 70
            }
            sleep 800
            Loop 8 {
                SetKeyDelay, 0, 100
                ControlSend, mGBA ,{F4}, mGBA ; f4 = up
                sleep 70
            }
            sleep 400
            GuiControl,, StatusLabel, getting color...
            Gui, Submit, NoHide
            CoordMode, Mouse, Screen
            CoordMode Pixel, Screen
            PixelGetColor, cColor, %xCord%, %yCord%, RGB
            sleep, 200
            if (cColor = targetColor) {
                currentlyTrue := "="
                if(lastColor = cColor) {
                    GuiControl,, vCurrentlyTrue, =
                    lastColor := cColor
                    SetKeyDelay, 0, 100
                    ControlSend, mGBA ,{F2}, mGBA
                    Sleep 200
                    IterationCount += 1
                    ; updating fields we set above in the GUI
                    GuiControl,, vIterationCount, Resets: %IterationCount%
                    GuiControl,, vColorOutput, %cColor%
                    GuiControl,, vXOutput, %xCord%
                    GuiControl,, vYOutput, %yCord%
                    GuiControl,, vLastColorGUI, %lastColor%
                    GuiControl,, vCurrentColorGUI, %cColor%
                    GuiControl,, vCurrentColorGUI2, %cColor%
                    GuiControl,, vCheckWin, ActiveWin: %checkWinActive% ;
                } else {
                    GuiControl,, vCurrentlyTrue, =
                    lastColor := cColor
                    SetKeyDelay, 0, 100
                    ControlSend, mGBA ,{F2}, mGBA
                    Sleep 200
                    IterationCount += 1
                    GuiControl,, vIterationCount, Resets: %IterationCount%
                    GuiControl,, vColorOutput, %cColor%
                    GuiControl,, vXOutput, %xCord%
                    GuiControl,, vYOutput, %yCord%
                    GuiControl,, vLastColorGUI, %lastColor%
                    GuiControl,, vCurrentColorGUI, %cColor%
                    GuiControl,, vCurrentColorGUI2, %cColor%
                    GuiControl,, vCheckWin, ForceWindow: %checkWinActive% ;
                    return ResetGUI(true)
                }
            } else {
                currentlyTrue := "!="
                GuiControl,, vCurrentlyTrue, !=
                GuiControl,, StatusLabel, "Expected " . targetColor . " found " . lastColor . " [ " . (targetColor = lastColor) . " ]"
                GuiControl,, vIterationCount, Resets: %IterationCount%
                GuiControl,, vColorOutput, %cColor%
                GuiControl,, vXOutput, %xCord%
                GuiControl,, vYOutput, %yCord%
                GuiControl,, vLastColorGUI, %lastColor%
                GuiControl,, vCurrentColorGUI, %cColor%
                GuiControl,, vCheckWin, ForceWindow: %checkWinActive% ;
                return ResetGUI()
                break
            }
        }
        GuiControl,, StatusLabel, Stopped
    }
}

givenButtonFunc() {
    global
    GuiControl,, StatusLabel, Running...
    stopped := 0
    Loop {
        if (stopped) {
            break
        }
        SetTitleMatchMode, 2
        ; mapping
        ; f4 = a
        ; f5 = b
        ; f6 = up
        ; f7 = down
        ; f8 = start
        ; f9 = select
        ensureWinActive()

        reload()

	    resetFrame()

	    save()
        Loop 2 { ; loop f4 = a
            SetKeyDelay, 0, 100
            ControlSend, mGBA ,{F4}, mGBA ; f4 = a
            sleep 70
        }
        Gui, Submit, NoHide
        CoordMode, Mouse, Screen
        CoordMode Pixel, Screen
        PixelGetColor, cColor, %xCord%, %yCord%, RGB
        sleep, 200
        if (cColor = targetColor) {
            currentlyTrue := "="
            if(lastColor = cColor) {
             GuiControl,, vCurrentlyTrue, =
             lastColor := cColor
             SetKeyDelay, 0, 100
             ControlSend, mGBA ,{F2}, mGBA
             Sleep 200
             IterationCount += 1
             ; updating fields we set above in the GUI
             GuiControl,, vIterationCount, Resets: %IterationCount%
             GuiControl,, vColorOutput, %cColor%
             GuiControl,, vXOutput, %xCord%
             GuiControl,, vYOutput, %yCord%
             GuiControl,, vLastColorGUI, %lastColor%
             GuiControl,, vCurrentColorGUI, %cColor%
             GuiControl,, vCurrentColorGUI2, %cColor%
             GuiControl,, vCheckWin, ActiveWin: %checkWinActive% ;
            } else {
             GuiControl,, vCurrentlyTrue, =
             lastColor := cColor
             SetKeyDelay, 0, 100
             ControlSend, mGBA ,{F2}, mGBA
             Sleep 200
             IterationCount += 1
             GuiControl,, vIterationCount, Resets: %IterationCount%
             GuiControl,, vColorOutput, %cColor%
             GuiControl,, vXOutput, %xCord%
             GuiControl,, vYOutput, %yCord%
             GuiControl,, vLastColorGUI, %lastColor%
             GuiControl,, vCurrentColorGUI, %cColor%
             GuiControl,, vCurrentColorGUI2, %cColor%
             GuiControl,, vCheckWin, ForceWindow: %checkWinActive% ;
             return ResetGUI(false, false, true)
            }
        } else {
            currentlyTrue := "!="
            GuiControl,, vCurrentlyTrue, !=
            GuiControl,, StatusLabel, "Expected " . targetColor . " found " . lastColor . " [ " . (targetColor = lastColor) . " ]"
            GuiControl,, vIterationCount, Resets: %IterationCount%
            GuiControl,, vColorOutput, %cColor%
            GuiControl,, vXOutput, %xCord%
            GuiControl,, vYOutput, %yCord%
            GuiControl,, vLastColorGUI, %lastColor%
            GuiControl,, vCurrentColorGUI, %cColor%
            GuiControl,, vCheckWin, ForceWindow: %checkWinActive% ;
            return ResetGUI()
            break
        }
    }
    GuiControl,, StatusLabel, Stopped
}

UpdateStatusLabel() {
    if (stopped)
        GuiControl,, StatusLabel, Stopped
    else
        GuiControl,, StatusLabel, Running
}

ensureCitraWinActive() {
        try {
        IfWinNotActive, Citra
        {
            WinActivate, Citra
            WinWaitActive, Citra
        }
        } catch e {
        }
        return
}

ensureWinActive() {
        try {
        IfWinNotActive, mGBA
        {
            WinActivate, mGBA
            WinWaitActive, mGBA
        }
        } catch e {
        }
        return
}

sendCitraKey(key) {
    ensureCitraWinActive()
    SetKeyDelay, 0, 25
    ControlSend, Citra ,{%key%}, Citra
    sleep 100
}

citraStarterSunClickMethod() {

    ;;maping for citra keys
    ;;a = a
    ;;b = s
    ;;x = z
    ;;y = x
    ;;l = q
    ;;r = w
    ;;zl = 1;
    ;;zr = 2;
    ;;start = m
    ;;select = n
    ;;home = b;
    ;;debug = o
    global

    if(sunStarter = 0){
        MsgBox,0, Error, Please set a starter first. Expected [1,2,3], got [%sunStarter%]
        return
    }
    if(clickXCord = 0 || clickYCord = 0) {
        MsgBox,0,Error, Please set a click position first. Expected [Hex], got [X: %clickXCord% Y: %clickYCord%]
        return
    }
    if(cColor = 0) {
        MsgBox, 0, Error, Please set a color first. Expected [Hex], got [Hex: %cColor%]
        return
    }
    GuiControl,, StatusLabel, Running...
    CoordMode, Mouse, Screen
    stopped := 0
    Loop {
        if (stopped) {
            break
        }
        SetTitleMatchMode, 2
        ensureCitraWinActive()
        resetCitraGame()


        SetControlDelay -1
        GuiControl,, StatusLabel, Walking to Grass...
        ControlSend,, {Left down}, Citra
        sleep 900
        ControlSend,, {Left up}, Citra
        sleep 300
        GuiControl,, StatusLabel, Skipping Cutscene...
        if (stopped) {
            break
        }
        ;;keep left clicking for 5 seconds
        MouseMove, clickXCord, clickYCord
        Loop 27 {
            if (stopped) {
                break
            }
            ;;left click
            Click, down
            sleep 50
            Click, up
            ;; ControlSend,, {Left down}, Citra
            sleep 300

        }
        GuiControl,, StatusLabel, Talking to Professor...
        ;;press A
        SendInput {A down}
        sleep 100
        SendInput {A up}
        sleep 700
        ;;keep left clicking for 5 seconds
        MouseMove, clickXCord, clickYCord
        GuiControl,, StatusLabel, More talking...
        Loop 28 {
            if (stopped) {
                break
            }
            ;;left click
            Click, down
            sleep 50
            Click, up
            ;; ControlSend,, {Left down}, Citra
            sleep 300
        }
        GuiControl,, StatusLabel, Picking Pokemon...
        if(sunStarter = 1) {
        ;; do nothing, its already selected
        } else if(sunStarter = 2) {
            ;;press down to select second entry
            SendInput {Down down}
            sleep 10
            SendInput {Down up}
        } else if(sunStarter = 3) {
            ;;press down twice to select third entry
            SendInput {Down down}
            sleep 10
            SendInput {Down up}
            sleep 100
            SendInput {Down down}
            sleep 10
            SendInput {Down up}
        }
        sleep 200
        ;; press A;
        SendInput {A down}
        sleep 100
        SendInput {A up}
        sleep 300
        GuiControl,, StatusLabel, Selected Pokemon %sunStarter%...
        MouseMove, clickXCord, clickYCord
        Loop 4 {
            if (stopped) {
                break
            }
            ;;left click
            Click, down
            sleep 100
            Click, up
            ;; ControlSend,, {Left down}, Citra
            sleep 300
        }
        GuiControl,, StatusLabel, Confirming Choice...
        SendInput {A down}
        sleep 100
        SendInput {A up}
        sleep 3000
        GuiControl,, StatusLabel, Skipping Dialogue...
        Loop 3 {
            if (stopped) {
                break
            }
            ;;left click
            Click, down
            sleep 100
            Click, up
            ;; ControlSend,, {Left down}, Citra
            sleep 500
        }
        GuiControl,, StatusLabel, Checking pixel color...
        ;; last check for pokemon
        Gui, Submit, NoHide
        CoordMode, Mouse, Screen
        CoordMode Pixel, Screen
        PixelGetColor, cColor, %xCord%, %yCord%, RGB
        ;;check cColor = targetColor 5 times
        ;;add localvariable multipleCheck = false;
        ;;if cColor = targetColor, multipleCheck = true;

        multipleCheck := false
        Loop 12 {
            if (stopped) {
                break
            }
            PixelGetColor, cColor, %xCord%, %yCord%, RGB
            sleep, 100
            if (cColor = targetColor) {
                multipleCheck := true
                break
            } else {
                multipleCheck := false
            }
        }
        sleep, 200

        if (multipleCheck) {
            currentlyTrue := "="
            if(multipleCheck) {
             GuiControl,, vCurrentlyTrue, =
             lastColor := cColor
             SetKeyDelay, 0, 100
             Sleep 200
             IterationCount += 1
             ; updating fields we set above in the GUI
             GuiControl,, vIterationCount, Resets: %IterationCount%
             GuiControl,, vColorOutput, %cColor%
             GuiControl,, vXOutput, %xCord%
             GuiControl,, vYOutput, %yCord%
             GuiControl,, vLastColorGUI, %lastColor%
             GuiControl,, vCurrentColorGUI, %cColor%
             GuiControl,, vCurrentColorGUI2, %cColor%
             GuiControl,, vCheckWin, ActiveWin: %checkWinActive% ;
            } else {
             GuiControl,, vCurrentlyTrue, =
             lastColor := cColor
             SetKeyDelay, 0, 100
             Sleep 200
             IterationCount += 1
             GuiControl,, vIterationCount, Resets: %IterationCount%
             GuiControl,, vColorOutput, %cColor%
             GuiControl,, vXOutput, %xCord%
             GuiControl,, vYOutput, %yCord%
             GuiControl,, vLastColorGUI, %lastColor%
             GuiControl,, vCurrentColorGUI, %cColor%
             GuiControl,, vCurrentColorGUI2, %cColor%
             GuiControl,, vCheckWin, ForceWindow: %checkWinActive% ;
             return ResetGUI(false, false, true)
            }
        } else {
            currentlyTrue := "!="
            GuiControl,, vCurrentlyTrue, !=
            GuiControl,, StatusLabel, "Expected " . targetColor . " found " . lastColor . " [ " . (targetColor = lastColor) . " ]"
            GuiControl,, vIterationCount, Resets: %IterationCount%
            GuiControl,, vColorOutput, %cColor%
            GuiControl,, vXOutput, %xCord%
            GuiControl,, vYOutput, %yCord%
            GuiControl,, vLastColorGUI, %lastColor%
            GuiControl,, vCurrentColorGUI, %cColor%
            GuiControl,, vCheckWin, ForceWindow: %checkWinActive% ;
            return ResetGUI()
            break
        }
    }
    GuiControl,, StatusLabel, Stopped

}

citraShinyCatchingInFrontOfPokemon() {
    ;;maping for citra keys
    ;;a = a
    ;;b = s
    ;;x = z
    ;;y = x
    ;;l = q
    ;;r = w
    ;;zl = 1;
    ;;zr = 2;
    ;;start = m
    ;;select = n
    ;;home = b;
    ;;debug = o

    global
    GuiControl,, StatusLabel, Running...
    stopped := 0
    Loop {
        if (stopped) {
            break
        }
        SetTitleMatchMode, 2
        ensureCitraWinActive()
        resetCitraGame()
        ;;hold left for 4 seconds to go to grass
        GuiControl,, StatusLabel, Walking to Pokemon...
        DpadUp := _citraMappings["DpadUp"]
        DpadLeft := _citraMappings["DpadLeft"]
        DpadRight := _citraMappings["DpadRight"]
        DpadDown := _citraMappings["DpadDown"]
        KeyA := _citraMappings["KeyA"]
       
        SetKeyDelay, 0, 1000
        ControlSend, Citra ,{%DpadUp%}, Citra
        SetKeyDelay, 0, 65
        SendInput {DpadUp down}
        sleep 1000
        SendInput {DpadUp up}
        sleep 1000
        GuiControl,, StatusLabel, Intro animation
        sleep 3000
        ;;this sh*t is so scuffed, i have to PURPOSEFULLY DIE in order to get a static camera view to get a pixel count *massive facepalm*
        ;; you WILL need a shedinja with toxic orb to forcefully die in 2 turns AND at least 2 pokeballs (turn 1 poison, turn 2 die)
        GuiControl,, StatusLabel, Switching pokemon...
        ControlSend, Citra, {%DpadLeft%}, Citra
        sleep 200
        ;; press A
        ControlSend, Citra, {%KeyA%}, Citra
        sleep 200
        ;; press right
        ControlSend, Citra, {%DpadRight%}, Citra
        sleep 500
        ;; press A
        ControlSend, Citra, {%KeyA%}, Citra
        sleep 300
        ;; press A
        ControlSend, Citra, {%KeyA%}, Citra
        sleep 400
    
        GuiControl,, StatusLabel, Checking pixel color...
        ;; last check for pokemon
        Gui, Submit, NoHide
        CoordMode, Mouse, Screen
        CoordMode Pixel, Screen
        PixelGetColor, cColor, %xCord%, %yCord%, RGB
        ;;check cColor = targetColor 5 times
        ;;add localvariable multipleCheck = false;
        ;;if cColor = targetColor, multipleCheck = true;
    
        multipleCheck := false
        Loop 50 {
            if (stopped) {
                break
            }
            PixelGetColor, cColor, %xCord%, %yCord%, RGB
            sleep, 100
            if (cColor = targetColor) {
                multipleCheck := true
                break
            } else {
                multipleCheck := false
            }
        }
        sleep, 200
    
        if (multipleCheck) {
            currentlyTrue := "="
            if(multipleCheck) {
             GuiControl,, vCurrentlyTrue, =
             lastColor := cColor
             SetKeyDelay, 0, 100
             Sleep 200
             IterationCount += 1
             ; updating fields we set above in the GUI
             GuiControl,, vIterationCount, Resets: %IterationCount%
             GuiControl,, vColorOutput, %cColor%
             GuiControl,, vXOutput, %xCord%
             GuiControl,, vYOutput, %yCord%
             GuiControl,, vLastColorGUI, %lastColor%
             GuiControl,, vCurrentColorGUI, %cColor%
             GuiControl,, vCurrentColorGUI2, %cColor%
             GuiControl,, vCheckWin, ActiveWin: %checkWinActive% ;
            } else {
             GuiControl,, vCurrentlyTrue, =
             lastColor := cColor
             SetKeyDelay, 0, 100
             Sleep 200
             IterationCount += 1
             GuiControl,, vIterationCount, Resets: %IterationCount%
             GuiControl,, vColorOutput, %cColor%
             GuiControl,, vXOutput, %xCord%
             GuiControl,, vYOutput, %yCord%
             GuiControl,, vLastColorGUI, %lastColor%
             GuiControl,, vCurrentColorGUI, %cColor%
             GuiControl,, vCurrentColorGUI2, %cColor%
             GuiControl,, vCheckWin, ForceWindow: %checkWinActive% ;
             return ResetGUI(false, false, false, true)
            }
        } else {
            currentlyTrue := "!="
            GuiControl,, vCurrentlyTrue, !=
            GuiControl,, StatusLabel, "Expected " . targetColor . " found " . lastColor . " [ " . (targetColor = lastColor) . " ]"
            GuiControl,, vIterationCount, Resets: %IterationCount%
            GuiControl,, vColorOutput, %cColor%
            GuiControl,, vXOutput, %xCord%
            GuiControl,, vYOutput, %yCord%
            GuiControl,, vLastColorGUI, %lastColor%
            GuiControl,, vCurrentColorGUI, %cColor%
            GuiControl,, vCheckWin, ForceWindow: %checkWinActive% ;
            return ResetGUI()
        }
    }

    GuiControl,, StatusLabel, Stopped
}

citraStarterSun() {
    ;;maping for citra keys
    ;;a = a
    ;;b = s
    ;;x = z
    ;;y = x
    ;;l = q
    ;;r = w
    ;;zl = 1;
    ;;zr = 2;
    ;;start = m
    ;;select = n
    ;;home = b;
    ;;debug = o

    global
    GuiControl,, StatusLabel, Running...
    stopped := 0
    ensureCitraWinActive()
    resetCitraGame()
    ;;Loop {
    ;;    if (stopped) {
    ;;        break
    ;;    }
    ;;    SetTitleMatchMode, 2
    ;;        ; mapping
    ;;        ; f4 = a
    ;;        ; f5 = b
    ;;        ; f6 = up
    ;;        ; f7 = down
    ;;        ; f8 = start
    ;;        ; f9 = select
    ;;        ensureCitraWinActive()
    ;;}
    ;;config, window name Citra, left key
    ;;hold left for 4 seconds to go to grass
    GuiControl,, StatusLabel, Walking to Grass...
    SendInput {Left down}
    sleep 1000
    SendInput {Left up}
    sleep 1000
    GuiControl,, StatusLabel, Walked to Grass
    ;; press A
    SendInput {A down}
    sleep 100
    SendInput {A up}
    sleep 1500
    GuiControl,, StatusLabel, Skipping Cutscene...
    Loop 4 { ;; press A 4 times to skip all cutscene dialog
        ;; press A
        SendInput {A down}
        sleep 100
        SendInput {A up}
        sleep 700
    }
    sleep 2000
    GuiControl,, StatusLabel, Talkin to Professor...
    Loop 36 { ;; press A 2 times to through professor dialog
        ;; press A
        SendInput {A down}
        sleep 100
        SendInput {A up}
        sleep 700
    }
    GuiControl,, StatusLabel, Deciding which pokemon to take...
    sleep 1000
    if(false) {
        ;;press down to select second entry
        SendInput {Down down}
        sleep 100
        SendInput {Down up}
    } else if(true) {
        ;;press down twice to select third entry
        SendInput {Down down}
        sleep 100
        SendInput {Down up}
        sleep 100
        SendInput {Down down}
        sleep 100
        SendInput {Down up}
    }
    ;;press A to select
    SendInput {A down}
    sleep 100
    SendInput {A up}
    ;; confirm by pressing A 5 times
    GuiControl,, StatusLabel, Confirming Pokemon...
    Loop 5 {
        ;; press A
        SendInput {A down}
        sleep 100
        SendInput {A up}
        sleep 400
    }
    ;;waiting cutscene
    sleep 5000
    ;;press A once more to get into shiny screen
    SendInput {A down}
    sleep 100
    SendInput {A up}
    sleep 1000

    GuiControl,, StatusLabel, Shiny Check...
    return

    GuiControl,, StatusLabel, Stopped
}

resetCitraGame() {
    ensureCitraWinActive()
    GuiControl,, StatusLabel, Resetting Game...
    ;;Reset game, to do that press L + R + Select + Start at same time
    SendInput {q down}{w down}{n down}{m down};
    sleep 100
    ;;release
    SendInput {q up}{w up}{n up}{m up};
    sleep 1500
    GuiControl,, StatusLabel, Game Reset, going to menu...
    SendInput {A down}
    sleep 100
    SendInput {A up}
    GuiControl,, StatusLabel, Selecting Save
    sleep 1000
    SendInput {A down}
    sleep 100
    SendInput {A up}
    GuiControl,, StatusLabel, Starting...
    sleep 1500
}