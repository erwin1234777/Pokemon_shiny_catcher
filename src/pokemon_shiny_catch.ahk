#SingleInstance force

SendMode Input
SetWorkingDir %A_ScriptDir%
StartTime := A_TickCount
targetColor := "0x000000"
lastColor := "0x000000"
currentlyTrue := "="
IterationCount := 0
xCord := 0
yCord := 0
checkWinActive := 1
stopped := 1

ResetGUI(running := false, runningGiven := false) {
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


    ;icons
    Gui, Add, Progress, x200 y350 w15 h15 c%lastColor% vLastColorGUI, 100
    Gui, Add, Progress, x230 y350 w15 h15 c%targetColor% vCurrentColorGUI, 100

    ;text 1 p/ row +30y 
    ; row 1
    Gui, Add, Text, vIterationCount x10 y20 w50 h30, Resets: %IterationCount%
    local timeDiff := Round((A_TickCount - StartTime) / 1000 / 60, 1)
    Gui, Add, Text, vTimeElapsed x200 y20 w100 h30, %timeDiff% minutes have passed
    ; row 2
    Gui, Add, Text, x10 y50 w80 h30, Color: %targetColor%
    Gui, Add, Progress, x100 y49 w15 h15 c%targetColor% vCurrentColorGUI2, 100
    ;row 3
    Gui, Add, Text, x10 y80 w80 h30, X: %xCord%
    ;row 4
    Gui, Add, Text, x10 y110 w80 h30, Y: %yCord%
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
    return
    StartButton:
        StartButtonFunc()
    return
    TestButton:
        ResetGUI()
    return
    GivenButton:
        givenButtonFunc()
    return
    GuiClose:
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
        StartTime := A_TickCount
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
startButtonFunc() {
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
    }
    GuiControl,, StatusLabel, Stopped
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
             return ResetGUI(false, true)
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

ensureWinActive() {
        try {
        IfWinNotActive, POKEMON FIRE
        {
            WinActivate, POKEMON FIRE
            WinWaitActive, POKEMON FIRE
        }
        } catch e {
        }
        return
}
