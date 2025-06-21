require "ISUI/ISBackButtonWheel"

function ISBackButtonWheel:onCommand(command)
	local focus = nil
	-- local isPaused = UIManager.getSpeedControls() and UIManager.getSpeedControls():getCurrentGameSpeed() == 0
	local isPaused = false;

	local playerObj = getSpecificPlayer(self.playerNum)

	if command == "PlayerInfo" and not isPaused then
		getPlayerInfoPanel(self.playerNum):setVisible(true)
		getPlayerInfoPanel(self.playerNum):addToUIManager()
		focus = getPlayerInfoPanel(self.playerNum).panel:getActiveView()
	elseif command == "Building" and not isPaused then
		local entityUI = ISEntityUI.players[self.playerNum]
		if entityUI and entityUI.instance and entityUI.instance.xuiStyleName == "BuildWindow" then
			ISEntityUI.players[self.playerNum].instance:close()
		else
			ISEntityUI.OpenBuildWindow(playerObj, nil, "*")
		end
		return
	elseif command == "Crafting" and not isPaused then
		local entityUI = ISEntityUI.players[self.playerNum]
		if entityUI and entityUI.instance and entityUI.instance.xuiStyleName == "HandcraftWindow" then
			entityUI.instance:close()
		else
			ISEntityUI.OpenHandcraftWindow(playerObj, nil, "*")
		end
		return
	elseif command == "MoveFurniture" and not isPaused then
		local mo = ISMoveableCursor:new(getSpecificPlayer(self.playerNum));
		getCell():setDrag(mo, mo.player);
	elseif command == "ZoomPlus" and not getCore():getAutoZoom(self.playerNum) then
		getCore():doZoomScroll(self.playerNum, 1)
	elseif command == "ZoomMinus" and not getCore():getAutoZoom(self.playerNum) then
		getCore():doZoomScroll(self.playerNum, -1)
	elseif command == "Pause" then
		if UIManager.getSpeedControls() and not isClient() then
			if UIManager.getSpeedControls():getCurrentGameSpeed() == 0 or getGameTime():getTrueMultiplier() > 1 then
				UIManager.getSpeedControls():ButtonClicked("Play")
			elseif UIManager.getSpeedControls() then
				UIManager.getSpeedControls():ButtonClicked("Pause")
			end
		end
	elseif command == "FastForward"  then
		if UIManager.getSpeedControls() then
			local multiplier = getGameTime():getTrueMultiplier()
			if multiplier == 1 or multiplier == 40 then
				UIManager.getSpeedControls():ButtonClicked("Fast Forward x 1")
			elseif multiplier == 5 then
				UIManager.getSpeedControls():ButtonClicked("Fast Forward x 2")
			elseif multiplier == 20 then
				UIManager.getSpeedControls():ButtonClicked("Wait")
			end
		end
	elseif command == "LastStand" then
		if Core.isLastStand() then
			JoypadState.players[self.playerNum+1].focus = nil
			doLastStandBackButtonWheel(self.playerNum, 's')
			return
		end
	elseif command == "ForageMode" then
		local manager =	ISSearchManager.getManager(playerObj);
		if manager then
			manager:toggleSearchMode();
			focus = getJoypadFocus(self.playerNum);
		end;
	elseif command == "ForageItem" then
		for _, icon in pairs(ISSearchManager.getManager(playerObj).closeIcons) do
			icon:doForage();
			break; --only pick up the first icon found
		end;
	elseif command == "DiscardForageItem" then
		for _, icon in pairs(ISSearchManager.getManager(playerObj).closeIcons) do
			icon:onClickDiscard();
			break; --only discard the first icon found
		end;
	end

	if focus ~= nil then
		setJoypadFocus(self.playerNum, focus)
	end
end