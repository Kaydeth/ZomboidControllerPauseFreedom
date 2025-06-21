require "Joypad/JoyPadSetup"

function JoypadControllerData:onPressButtonNoFocus(button)
    local joypadData = self.joypad

    local activeWhilePaused = joypadData.activeWhilePaused

    local displayListBox = button == Joypad.AButton and not joypadData.player and not IsoPlayer.allPlayersDead()
    if displayListBox then
        activeWhilePaused = true
    end

    -- if not activeWhilePaused and isGamePaused() and button ~= Joypad.Start and button ~= Joypad.Back then
    if not activeWhilePaused and joypadData.inMainMenu and button ~= Joypad.Start and button ~= Joypad.Back then
        return
    end

    if ISTermsOfServiceUI and ISTermsOfServiceUI.instance and ISTermsOfServiceUI.instance:isReallyVisible() then
        if button == Joypad.AButton then
            local focus = ISTermsOfServiceUI.instance
            joypadData.focus = focus
            updateJoypadFocus(joypadData)
        end
        return
    end

    -----
    -- Case 1: In the main menu.
    -----

    if MainScreen.instance and MainScreen.instance:isReallyVisible() then
        -- Activating a controller in the main menu does not display the JoypadListBox.
        -- Also, the controller is not assigned to any player.
        if button == Joypad.AButton then
            local focus = MainScreen.instance:getCurrentFocusForController()
            if focus == nil then return end
            joypadData.inMainMenu = true
            joypadData.focus = focus
            updateJoypadFocus(joypadData)
            return
        end
        return
    end

    -----
    -- Case 2: In game.
    -----

    if joypadData.player and getCell() and getCell():getDrag(joypadData.player) then
        if button == Joypad.Start and joypadData.player and getSpecificPlayer(joypadData.player) then
            getPlayerBackButtonWheel(joypadData.player):onCommand("Pause")
            return
        end

        getCell():getDrag(joypadData.player):onJoypadPressButton(joypadIndex, joypadData, button);
        return;
    end

    if displayListBox then
        local playerNum
        if joypadData == JoypadState.joypads[1] then
            playerNum = 0
        elseif joypadData == JoypadState.joypads[2] then
            playerNum = 1
        elseif joypadData == JoypadState.joypads[3] then
            playerNum = 2
        else
            playerNum = 3
        end
        joypadData.listBox = ISJoypadListBox.Create(playerNum, joypadData)
        joypadData.listBox:fill()
        joypadData.listBox:setVisible(true)
        joypadData.listBox:addToUIManager()
        joypadData.focus = joypadData.listBox
        joypadData.activeWhilePaused = true
        return
    end

    if button == Joypad.Back and joypadData.player and getSpecificPlayer(joypadData.player) then
        local wheel = getPlayerBackButtonWheel(joypadData.player)
        wheel:addCommands()
        wheel:addToUIManager(true)
        wheel:setVisible(true)
        setJoypadFocus(joypadData.player, wheel)
        getSpecificPlayer(joypadData.player):setJoypadIgnoreAimUntilCentered(true)
        return
    end

    if button == Joypad.Start and joypadData.player and getSpecificPlayer(joypadData.player) then
        self:onPauseButtonPressed()
        return
    end

    if joypadData.player and getPlayerData(joypadData.player) then
        local buts = getButtonPrompts(joypadData.player)
        if button == Joypad.AButton then
            buts:onAPress()
        end
        if button == Joypad.BButton then
            buts:onBPress()
        end
        if button == Joypad.XButton then
            buts:onXPress()
        end
        if button == Joypad.YButton then
            buts:onYPress()
        end
        if button == Joypad.LBumper then
            buts:onLBPress()
        end
        if button == Joypad.RBumper then
            buts:onRBPress()
        end
    end

    if button == Joypad.LStickButton or button == Joypad.RStickButton then
        ISJoystickButtonRadialMenu.onJoypadDown(button, joypadData)
    end
end

function JoypadControllerData:onPressButton(button)
    local joypadData = self.joypad

    if not joypadData then return end

    if not joypadData.focus then
        self:onPressButtonNoFocus(button)
        return
    end
    if MainScreen.instance and MainScreen.instance.inGame and MainScreen.instance:isReallyVisible() then
        if button == Joypad.Start and joypadData.focus == MainScreen.instance then
            self:onPauseButtonPressed()
        else
            joypadData.focus:onJoypadDown(button, joypadData)
        end
        return
    end

    if button == Joypad.Start and joypadData.player and getSpecificPlayer(joypadData.player) then
        getPlayerBackButtonWheel(joypadData.player):onCommand("Pause")
        -- setGameSpeed(0)
        -- self:onPauseButtonPressed()
        return
    end
    
    if joypadData.isDoingNavigation then
        return
    end

    -- if not joypadData.activeWhilePaused and isGamePaused() then
    if not joypadData.activeWhilePaused and joypadData.inMainMenu then
        return;
    end

    joypadData.focus:onJoypadDown(button, joypadData);
end