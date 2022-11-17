
local addon = CreateFrame("Frame", "MTAddon")
addon:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
addon:RegisterEvent("ADDON_LOADED")
addon:RegisterEvent("PLAYER_LOGIN")
addon:RegisterEvent("TRADE_SKILL_ITEM_CRAFTED_RESULT")

addon.defaultDB = {
	PROC_DATA = {}
}

function addon:TRADE_SKILL_ITEM_CRAFTED_RESULT(result)
	--print("quantity: " .. result.quantity)
	--print("multicraft: " .. result.multicraft)

	if result.multicraft ~= 0 then
		local normalQuantity = result.quantity - result.multicraft
		local multicraftFactor = math.abs(result.multicraft / normalQuantity) -- Whyever tf the factor sometimes is negative??


		if MulticraftTrackerDB.PROC_DATA[multicraftFactor] == nil then
			MulticraftTrackerDB.PROC_DATA[multicraftFactor] = 1
		else
			MulticraftTrackerDB.PROC_DATA[multicraftFactor] = MulticraftTrackerDB.PROC_DATA[multicraftFactor] + 1
		end

		print("Multicraft Data Collected\nFactor: " .. multicraftFactor .. "\nTimes occured: " .. MulticraftTrackerDB.PROC_DATA[multicraftFactor])

	end
	--for k, v in pairs(result) do
	--	print(k .. ": " .. tostring(v))
	--end
end

function addon:ADDON_LOADED(addon_name)
	if addon_name ~= 'MulticraftTracker' then
		return
	end
	addon:loadDefaultDB()
	--addon:initOptions()
	addon:initMTFrame()
end

function addon:loadDefaultDB() 
	MulticraftTrackerDB = MulticraftTrackerDB or CopyTable(self.defaultDB)
end

function addon:getExportString()
	if MulticraftTrackerDB.PROC_DATA == nil then
		return "No Export Data Found"
	end
	table.sort(MulticraftTrackerDB.PROC_DATA)
	local exportString = ""
	for k, v in pairs(MulticraftTrackerDB.PROC_DATA) do
		exportString = exportString .. tostring(k) .. "," .. tostring(v) .. "\n"
	end
	return exportString
end

function addon:PLAYER_LOGIN()
	SLASH_MULTICRAFTTRACKER1 = "/mt"
	SLASH_MULTICRAFTTRACKER2 = "/multicrafttracker"
	SLASH_MULTICRAFTTRACKER3 = "/multi"
	SlashCmdList["MULTICRAFTTRACKER"] = function(input)

		input = SecureCmdOptionParse(input)
		if not input then return end

		local command, rest = input:match("^(%S*)%s*(.-)$")
		command = command and command:lower()
		rest = (rest and rest ~= "") and rest:trim() or nil

		if command == "config" then
			InterfaceOptionsFrame_OpenToCategory(addon.optionsPanel)
		end

		if command == "" or command == "export" then
			print("MT: Export Data")
			--MTFrame:Show()
			addon:KethoEditBox_Show(addon:getExportString())
			KethoEditBoxEditBox:HighlightText()
		end

		if command == "reset" then
			MulticraftTrackerDB.PROC_DATA = {}
			print("MT: Data Reset")
		end
	end
end


function addon:initMTFrame()

	MTFrame.title = MTFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	MTFrame.title:SetPoint("CENTER", MTFrameTitleBG, "CENTER", 5, 0)
	MTFrame.title:SetText("Multicraft Tracker")


    -- ScrollFrame
	local sf = CreateFrame("ScrollFrame", "MTScrollFrame", MTFrame, "UIPanelScrollFrameTemplate")
	sf:SetPoint("LEFT", 16, 0)
	sf:SetPoint("RIGHT", -32, 0)
	sf:SetPoint("TOP", 0, -16)
	
	-- EditBox
	local eb = CreateFrame("EditBox", "MTEditBox", MTScrollFrame)
	eb:SetSize(sf:GetSize())
	eb:SetMultiLine(true)
	eb:SetAutoFocus(false) -- dont automatically focus
	eb:SetFontObject("ChatFontNormal")
	eb:SetScript("OnEscapePressed", function() f:Hide() end)
	sf:SetScrollChild(eb)


	makeFrameMoveable()

	-- reset button?
	--local bLoad = CreateFrame("Button", "LoadSetButton", LoadoutReminderFrame, "SecureActionButtonTemplate,UIPanelButtonTemplate")
	--bLoad:RegisterForClicks("AnyUp", "AnyDown")
	--bLoad:SetSize(200 ,30)
	--bLoad:SetPoint("CENTER",LoadoutReminderFrame, "CENTER", 0, 5)	
	--bLoad:SetAttribute("type1", "macro")
	--bLoad:SetAttribute("macrotext", "")
	--bLoad:SetText("Load Addonset")
end

function addon:initOptions()
	self.optionsPanel = CreateFrame("Frame")
	self.optionsPanel.name = "MulticraftTracker"
	local title = self.optionsPanel:CreateFontString('optionsTitle', 'OVERLAY', 'GameFontNormal')
    title:SetPoint("TOP", 0, 0)
	title:SetText("Multicraft Tracker Options")

	InterfaceOptions_AddCategory(self.optionsPanel)
end

function makeFrameMoveable()
	MTFrame:SetMovable(true)
	MTFrame:SetScript("OnMouseDown", function(self, button)
		self:StartMoving()
		end)
		MTFrame:SetScript("OnMouseUp", function(self, button)
		self:StopMovingOrSizing()
		end)
end


-- thx ketho forum guy
function addon:KethoEditBox_Show(text)
    if not KethoEditBox then
        local f = CreateFrame("Frame", "KethoEditBox", UIParent, "DialogBoxFrame")
        f:SetPoint("CENTER")
        f:SetSize(600, 500)
        
        f:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight", -- this one is neat
            edgeSize = 16,
            insets = { left = 8, right = 6, top = 8, bottom = 8 },
        })
        f:SetBackdropBorderColor(0, .44, .87, 0.5) -- darkblue
        
        -- Movable
        f:SetMovable(true)
        f:SetClampedToScreen(true)
        f:SetScript("OnMouseDown", function(self, button)
            if button == "LeftButton" then
                self:StartMoving()
            end
        end)
        f:SetScript("OnMouseUp", f.StopMovingOrSizing)
        
        -- ScrollFrame
        local sf = CreateFrame("ScrollFrame", "KethoEditBoxScrollFrame", KethoEditBox, "UIPanelScrollFrameTemplate")
        sf:SetPoint("LEFT", 16, 0)
        sf:SetPoint("RIGHT", -32, 0)
        sf:SetPoint("TOP", 0, -16)
        sf:SetPoint("BOTTOM", KethoEditBoxButton, "TOP", 0, 0)
        
        -- EditBox
        local eb = CreateFrame("EditBox", "KethoEditBoxEditBox", KethoEditBoxScrollFrame)
        eb:SetSize(sf:GetSize())
        eb:SetMultiLine(true)
        eb:SetAutoFocus(true) -- dont automatically focus
        eb:SetFontObject("ChatFontNormal")
        eb:SetScript("OnEscapePressed", function() f:Hide() end)
        sf:SetScrollChild(eb)
        
        -- Resizable
        f:SetResizable(true)
        
        local rb = CreateFrame("Button", "KethoEditBoxResizeButton", KethoEditBox)
        rb:SetPoint("BOTTOMRIGHT", -6, 7)
        rb:SetSize(16, 16)
        
        rb:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
        rb:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
        rb:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
        
        rb:SetScript("OnMouseDown", function(self, button)
            if button == "LeftButton" then
                f:StartSizing("BOTTOMRIGHT")
                self:GetHighlightTexture():Hide() -- more noticeable
            end
        end)
        rb:SetScript("OnMouseUp", function(self, button)
            f:StopMovingOrSizing()
            self:GetHighlightTexture():Show()
            eb:SetWidth(sf:GetWidth())
        end)
        f:Show()
    end
    
    if text then
        KethoEditBoxEditBox:SetText(text)
    end
    KethoEditBox:Show()
end