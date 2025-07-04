require "ISUI/ISBackButtonWheel"

function ISBackButtonWheel:addCommands()
	local playerObj = getSpecificPlayer(self.playerNum)
	
	self:center()

	self:clear()

	-- local isPaused = UIManager.getSpeedControls() and UIManager.getSpeedControls():getCurrentGameSpeed() == 0
	isPaused = false

	if isPaused then
		self:addSlice(nil, nil, nil)
		self:addSlice(nil, nil, nil)
	else
		if not ISBackButtonWheel.disablePlayerInfo then
			self:addSlice(getText("IGUI_BackButton_PlayerInfo"), getTexture("media/ui/Heart2_On.png"), self.onCommand, self, "PlayerInfo")
		else
			self:addSlice(nil, nil, nil)
		end
		if not ISBackButtonWheel.disableCrafting then
			self:addSlice(getText("IGUI_BackButton_Crafting"), getTexture("media/ui/Carpentry_On.png"), self.onCommand, self, "Crafting")
			self:addSlice(getText("IGUI_BackButton_Building"), getTexture("media/ui/Build_Tool.png"), self.onCommand, self, "Building")
		else
			self:addSlice(nil, nil, nil)
		end
	end

	if getCore():isZoomEnabled() and not getCore():getAutoZoom(self.playerNum) then
		if ISBackButtonWheel.disableZoomIn then
			self:addSlice(nil, nil, nil)
		else
			self:addSlice(getText("IGUI_BackButton_Zoom", getCore():getNextZoom(self.playerNum, -1) * 100), getTexture("media/ui/ZoomIn.png"), self.onCommand, self, "ZoomMinus")
		end
	end

	if UIManager.getSpeedControls() and not isClient() then
		if ISBackButtonWheel.disableTime then
			self:addSlice(nil, nil, nil)
			self:addSlice(nil, nil, nil)
		else
			if UIManager.getSpeedControls():getCurrentGameSpeed() == 0 or getGameTime():getTrueMultiplier() > 1 then
				self:addSlice(getText("IGUI_BackButton_Play"), getTexture("media/ui/speedControls/Play_Off.png"), self.onCommand, self, "Pause")
			else
				self:addSlice(getText("UI_optionscreen_binding_Pause"), getTexture("media/ui/speedControls/Pause_Off.png"), self.onCommand, self, "Pause")
			end
	
			local multiplier = getGameTime():getTrueMultiplier()
			if multiplier == 1 or multiplier == 40 then
				self:addSlice(getText("IGUI_BackButton_FF1"), getTexture("media/ui/speedControls/FFwd1_Off.png"), self.onCommand, self, "FastForward")
			elseif multiplier == 5 then
				self:addSlice(getText("IGUI_BackButton_FF2"), getTexture("media/ui/speedControls/FFwd2_Off.png"), self.onCommand, self, "FastForward")
			elseif multiplier == 20 then
				self:addSlice(getText("IGUI_BackButton_FF3"), getTexture("media/ui/speedControls/Wait_Off.png"), self.onCommand, self, "FastForward")
			end
		end
	end

	if Core.isLastStand() then
		self:addSlice(getText("IGUI_BackButton_LastStand"), Joypad.Texture.AButton, self.onCommand, self, "LastStand")
	end

	if getCore():isZoomEnabled() and not getCore():getAutoZoom(self.playerNum) then
		if ISBackButtonWheel.disableZoomOut then
			self:addSlice(nil, nil, nil)
		else
			self:addSlice(getText("IGUI_BackButton_Zoom", getCore():getNextZoom(self.playerNum, 1) * 100), getTexture("media/ui/ZoomOut.png"), self.onCommand, self, "ZoomPlus")
		end
	end

	if not isPaused and not playerObj:getVehicle() and not ISBackButtonWheel.disableMoveable then
		self:addSlice(getText("IGUI_BackButton_Movable"), getTexture("media/ui/Furniture_Off2.png"), self.onCommand, self, "MoveFurniture")
	else
		self:addSlice(nil, nil, nil)
	end

	local searchManager = ISSearchManager.getManager(playerObj);
	if not isPaused and searchManager and not ISBackButtonWheel.disableScavenge then
		if searchManager.isSearchMode then
			self:addSlice(getText("UI_disable_search_mode"), getTexture("media/ui/foraging/eyeconOff.png"), self.onCommand, self, "ForageMode");
			searchManager:checkCloseIcons();
			for _, icon in pairs(searchManager.closeIcons) do
				self:addSlice(getText("IGUI_Pickup") .. " " .. icon.itemObj:getDisplayName(), icon.itemTexture, self.onCommand, self, "ForageItem");
				self:addSlice(getText("UI_foraging_DiscardItem") .. " " .. icon.itemObj:getDisplayName(), icon.itemTexture, self.onCommand, self, "DiscardForageItem");
				break; --only add the first icon found
			end;
		else
			self:addSlice(getText("UI_enable_search_mode"), getTexture("media/ui/foraging/eyeconOn.png"), self.onCommand, self, "ForageMode");
		end;
	end;
end

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