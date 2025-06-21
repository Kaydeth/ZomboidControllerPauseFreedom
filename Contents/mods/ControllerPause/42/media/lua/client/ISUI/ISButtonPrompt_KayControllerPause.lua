require "ISUI/ISButtonPrompt"

local getBestYButtonAction_orig = ISButtonPrompt.getBestYButtonAction
function ISButtonPrompt:getBestYButtonAction(dir)
    if UIManager.getSpeedControls() and UIManager.getSpeedControls():getCurrentGameSpeed() == 0 then
        -- self:setYPrompt(nil, nil, nil);
        self.isLoot = false;
        self:setYPrompt(getText("IGUI_Controller_Inventory"), ISButtonPrompt.cmdShowInventory, nil);
        return;
    end

    return getBestYButtonAction_orig(self, dir)
end