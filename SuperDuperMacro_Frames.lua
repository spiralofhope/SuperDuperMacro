local f, fs, t

-----------------------------------------
--[[ Creation of the main SDM window ]]--
-----------------------------------------

f = CreateFrame("Frame", "sdm_mainFrame", nil, UIParent)
f:Hide()
f:SetMovable(true)
f:SetSize(768,447)
f:ClearAllPoints()
f:SetPoint("TOPLEFT", 0, -104)
sdm_MakeDraggable(f)
f:SetScript("OnShow", function(self)
	--PlaySound( 839 )  -- igCharacterInfoOpen / IG_CHARACTER_INFO_OPEN
	sdm_UpdateList()
end)
f:SetScript("OnHide", function(self)
  --PlaySound( 840 )  -- igCharacterInfoClose / IG_CHARACTER_INFO_CLOSE
	sdm_currentlyPlacing=nil
	sdm_StopMove()
	self:ClearAllPoints()
	self:SetPoint("TOPLEFT", 0, -104)
end)

-- The following few lines are a bit weird, but they ensure that:
-- (1) when the user presses escape, the SDM frame will hide,
-- (2) when that happens, SDM will get a chance to show a dialog box, and
-- (3) the game menu doesn't show unless there were no windows open when escape was pressed.
tinsert(UISpecialFrames, "sdm_mainFrame")
hooksecurefunc("CloseSpecialWindows", function()
	sdm_mainFrame:Show()
	sdm_Quit()
end)

-- Artwork and text:

t = f:CreateTexture("sdm_mainFramePortrait", "BACKGROUND")
t:SetTexture("Interface\\AddOns\\SuperDuperMacro\\SDM-Icon.tga")
t:SetWidth(60)
t:SetHeight(60)
t:SetPoint("TOPLEFT", 7,-6)

t = f:CreateTexture("sdm_mainFrameLeft", "ARTWORK")
t:SetTexture("Interface\\AddOns\\SuperDuperMacro\\SDM-MainFrame-Left.tga")
t:SetWidth(256)
t:SetHeight(512)
t:SetPoint("TOPLEFT")

t = f:CreateTexture("sdm_mainFrameMiddle", "ARTWORK")
t:SetTexture("Interface\\AddOns\\SuperDuperMacro\\SDM-MainFrame-Middle.tga")
t:SetWidth(256) -- The original Auction House frame uses 320 for this value.
t:SetHeight(512)
t:SetPoint("TOPLEFT", sdm_mainFrameLeft, "TOPRIGHT")

t = f:CreateTexture("sdm_mainFrameRight", "ARTWORK")
t:SetTexture("Interface\\AddOns\\SuperDuperMacro\\SDM-MainFrame-Right.tga")
t:SetWidth(256)
t:SetHeight(512)
t:SetPoint("TOPLEFT", sdm_mainFrameMiddle, "TOPRIGHT")

fs = f:CreateFontString("sdm_mainFrameTitle", "OVERLAY", "GameFontNormal")
fs:SetText("Super Duper Macro") -- this text will be reset when the version number is loaded
fs:SetPoint("TOP", 0,-18)

-- Red buttons:

f = CreateFrame("Button", "sdm_quitButton", sdm_mainFrame, "UIPanelCloseButton")
f:SetPoint("TOPRIGHT", 3, -8)
f:SetScript("OnClick", function() sdm_Quit() end)

local linkButtonXOffs = 296
local linkButtonYOffs = -29
local linkButtonSize = 50

f = CreateFrame("Button", "sdm_linkToMacroFrame", sdm_mainFrame, "UIPanelCloseButton")
f:SetWidth(linkButtonSize)
f:SetHeight(linkButtonSize)
f:SetPoint("TOPLEFT", linkButtonXOffs, linkButtonYOffs)
f:SetScript("OnClick", function() sdm_Quit(" ShowMacroFrame()") end)
t = f:CreateTexture()
t:SetDrawLayer("OVERLAY", 7)
t:SetPoint("CENTER", -1,0)
t:SetWidth(20)
t:SetHeight(20)
t:SetTexture("Interface\\MacroFrame\\MacroFrame-Icon")
sdm_SetTooltip(f, "Show the default macro interface")

f = CreateFrame("Button", "sdm_newButton", sdm_mainFrame, "UIPanelButtonTemplate")
f:SetText("New")
f:SetWidth(50)
f:SetHeight(22)
-- position will be set later
f:SetScript("OnClick", sdm_NewButtonClicked)
sdm_AddToExclusiveGroup(f, "centerwindows", true)
sdm_SetTooltip(f, "Create a new macro, script, or folder")

f = CreateFrame("Button", "sdm_sendReceiveButton", sdm_mainFrame, "UIPanelButtonTemplate")
f:SetText("Share >>")
f:SetWidth(75)
f:SetHeight(22)
f:SetPoint("BOTTOMRIGHT", -6, 27)
f:SetScript("OnClick", function()
	if sdm_sendReceiveFrame:IsShown() then
		sdm_sendReceiveFrame:Hide()
	else
		sdm_sendReceiveFrame:Show()
	end
end)
sdm_SetTooltip(f, "Share macros with your friends")

f = CreateFrame("Button", "sdm_saveButton", sdm_mainFrame, "UIPanelButtonTemplate")
f:SetText("Save")
f:SetWidth(60)
f:SetHeight(22)
f:SetPoint("BOTTOM", 0,38)
f:SetPoint("RIGHT", sdm_sendReceiveButton, "LEFT", -46,0)
f:SetScript("OnClick", function()
	sdm_Edit(sdm_macros[sdm_currentEdit], sdm_bodyBox:GetText())
	sdm_UpdateList()
end)

f = CreateFrame("Button", "sdm_usageButton", sdm_mainFrame, "UIPanelButtonTemplate")
f:SetText("Usage...")
f:SetWidth(75)
f:SetHeight(22)
f:SetPoint("RIGHT", sdm_saveButton, "LEFT")
f:SetScript("OnClick", function() sdm_ShowUsage(sdm_macros[sdm_currentEdit]) end)
sdm_SetTooltip(f, "Click for instructions on how to use the selected item.")

f = CreateFrame("Button", "sdm_changeIconButton", sdm_mainFrame, "UIPanelButtonTemplate")
f:SetText("Change Name/Icon")
f:SetWidth(140)
f:SetHeight(22)
f:SetPoint("RIGHT", sdm_usageButton, "LEFT")
f:SetScript("OnClick", function()
	if MacroPopupFrame ~= nil and MacroPopupFrame:IsShown() then
		print(sdm_printPrefix.."The change macro name/icon frame is already open.")
	else
		sdm_changeIconFrame:Show()
	end
end)
sdm_AddToExclusiveGroup(f, "centerwindows", true)

f = CreateFrame("Button", "sdm_saveAsButton", sdm_mainFrame, "UIPanelButtonTemplate")
f:SetSize(80,22)
f:SetPoint("TOP", sdm_saveButton, "BOTTOM")
f:SetPoint("RIGHT", sdm_sendReceiveButton, "LEFT", -30,0)
f:SetText("Save As...")
f:SetScript("OnClick", sdm_SaveAsButtonClicked)
sdm_SetTooltip(f, "Saves a copy of the current item. You may change the type, or make it global or character-specific.")

f = CreateFrame("Button", "sdm_deleteButton", sdm_mainFrame, "UIPanelButtonTemplate")
f:SetText("Delete")
f:SetWidth(70)
f:SetHeight(22)
f:SetPoint("RIGHT", sdm_saveAsButton, "LEFT")
f:SetScript("OnClick", sdm_DeleteButtonClicked)

f = CreateFrame("Button", "sdm_downgradeButton", sdm_mainFrame, "UIPanelButtonTemplate")
f:SetPoint("RIGHT", sdm_deleteButton, "LEFT")
f:SetSize(90,22)
f:SetHeight(sdm_deleteButton:GetHeight())
f:SetText("Downgrade")
f:SetScript("OnClick", sdm_DowngradeButtonClicked)
sdm_SetTooltip(f, "Turns this macro into a default macro. Anything over 255 characters will be lost.")

f = CreateFrame("Button", "sdm_claimButton", sdm_mainFrame, "UIPanelButtonTemplate")
f:SetPoint("RIGHT", sdm_downgradeButton, "LEFT")
f:SetSize(65,22)
f:SetHeight(sdm_usageButton:GetHeight())
f:SetText("Claim")
f:SetScript("OnClick", sdm_ClaimButtonClicked)
sdm_SetTooltip(f, "Did you know that character-specific items can belong to multiple characters? Click this button to claim this item for your current character.")

f = CreateFrame("Button", "sdm_disownButton", sdm_mainFrame, "UIPanelButtonTemplate")
f:SetAllPoints(sdm_claimButton)
f:SetText("Disown")
f:SetScript("OnClick", sdm_DisownButtonClicked)
sdm_SetTooltip(f, "Removes this item from your current character's list. Other characters will still be able to use it.")

-- Edit box for macro body:

f = CreateFrame("ScrollFrame", "sdm_bodyScroller", sdm_mainFrame, "UIPanelScrollFrameTemplate")
f:SetSize(417,304)
f:SetPoint("BOTTOMRIGHT", -32,64)

f = CreateFrame("EditBox", "sdm_bodyBox")
f:SetMultiLine(true)
f:SetAutoFocus(false)
f:SetWidth(sdm_bodyScroller:GetWidth())
f:SetHeight(20) -- automatically resizes if there based on the amount of text
f:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
f:SetScript("OnTabPressed", function(self) self:Insert("    ") end)
f:SetScript("OnTextSet", function()
	sdm_saveButton:Disable()
	sdm_textChanged=-2
end)
f:SetScript("OnTextChanged", function()
	if sdm_textChanged then
		sdm_textChanged=sdm_textChanged+1
		if sdm_textChanged>0 then
			sdm_saveButton:Enable()
		end
	end
end)
f:SetFontObject("GameFontHighlightSmall")
sdm_bodyScroller:SetScrollChild(f)

-- The editable text area
f = CreateFrame("Button", "sdm_bodyBackground", sdm_mainFrame)
f:SetPoint("BOTTOMLEFT", sdm_bodyScroller, -5,-5)
f:SetPoint("TOPRIGHT", sdm_bodyScroller, 27,5)
f:SetBackdrop({
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true,
	tileSize = 16,
	edgeSize = 16
})
f:SetScript("OnClick", function()
	local e = sdm_bodyBox
	local l = e:GetNumLetters()
	e:SetCursorPosition(l)
	e:SetFocus()
end)

fs = f:CreateFontString("sdm_currentTitle", "OVERLAY", "SystemFont_Huge1") -- make this a layer of sdm_bodyBackground so that they show and hide together
fs:SetText("")
fs:SetWordWrap(true)
fs:SetPoint("BOTTOM", sdm_bodyBackground, "TOP")
fs:SetSize(403,40)
fs:SetJustifyH("CENTER")
fs:SetJustifyV("CENTER")

fs = f:CreateFontString("sdm_containerInstructions", "OVERLAY", "GameFontNormal")
fs:SetText(sdm_containerInstructionsString)
fs:SetPoint("BOTTOMLEFT", 10,10)
fs:SetPoint("TOPRIGHT", -10,-10)

-- Macro list:
f = CreateFrame("ScrollFrame", "sdm_listScroller", sdm_mainFrame, "UIPanelScrollFrameTemplate")
-- TODO - make this configurable / resizable
f:SetWidth(268)
f:SetPoint("TOP", sdm_newButton, "BOTTOM", 0, -5)
f:SetPoint("BOTTOMLEFT", 20,50)

f = CreateFrame("Frame", "sdm_macroList")
f:SetWidth(sdm_listScroller:GetWidth())
f:SetHeight(50) -- automatically resizes based on the number of items in the list
sdm_listScroller:SetScrollChild(f)

f = CreateFrame("Frame", "sdm_listBackground", sdm_mainFrame)
f:SetPoint("BOTTOMLEFT", sdm_listScroller, -5,-5)
f:SetPoint("TOPRIGHT", sdm_listScroller, 27,5)
f:SetBackdrop({
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true,
	tileSize = 16,
	edgeSize = 16
})


fs = f:CreateFontString("sdm_macroLimitText", "OVERLAY", "GameFontNormal")
fs:SetPoint("TOP", f, "BOTTOM")
fs:SetHeight(30)
fs:SetText("")

f = CreateFrame("Frame", "sdm_macroLimitFrame", sdm_mainFrame)
f:SetAllPoints(sdm_macroLimitText)
sdm_SetTooltip(f, "This limit only applies to standard macros and Super Duper button macros.  If you're running out of room, try storing some infrequently used Button Macros as Floating Macros using the 'Save As...' button.  To do this with standard macros, you will have to upgrade them first.")

-- List filters:

fs = sdm_mainFrame:CreateFontString("sdm_filterText", "ARTWORK", "GameFontNormal")
fs:SetText("Filters:")
fs:SetPoint("TOPLEFT", 75, -44)

f = CreateFrame("Frame", "sdm_typeFilterDropdown", sdm_mainFrame, "UIDropDownMenuTemplate")
f:EnableMouse(true)
f:SetPoint("LEFT", sdm_filterText, "RIGHT", -15,-3)
f:SetScript("OnShow", sdm_TypeDropdownLoaded)
sdm_SetTooltip(f, "Filter the list below")

f = CreateFrame("Frame", "sdm_charFilterDropdown", sdm_mainFrame, "UIDropDownMenuTemplate")
f:EnableMouse(true)
f:SetPoint("LEFT", sdm_typeFilterDropdown, "RIGHT", -28,0)
f:SetScript("OnShow", sdm_CharDropdownLoaded)
sdm_SetTooltip(f, "Filter the list below")

-- Button to expand/collapse all folders:

f = CreateFrame("CheckButton", "sdm_collapseAllButton", sdm_mainFrame)
f:SetWidth(16)
f:SetHeight(16)
f:SetPoint("TOPLEFT", 23,-70)
f:SetPoint("TOP", sdm_typeFilterDropdown, "BOTTOM", 0,3)
f:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-UP")
f:SetCheckedTexture("Interface\\Buttons\\UI-PlusButton-UP")
f:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight", "ADD")
f:SetNormalFontObject("GameFontNormal")
f:SetHighlightFontObject("GameFontHighlight")
f:SetText("All")
f:SetHitRectInsets(0, -20, 0, 0) -- this line extends the clickable area so that it covers the "All" text
f:SetScript("OnClick", sdm_CollapseAllButtonClicked)
sdm_SetTooltip(f, "Expand/collapse all folders")
fs = select(4, f:GetRegions())
fs:SetPoint("LEFT", f, "RIGHT")

-- List size slider:

f = CreateFrame("Slider", "sdm_iconSizeSlider", sdm_mainFrame)
f:SetOrientation("HORIZONTAL")
f:EnableMouse(true)
f:SetMinMaxValues(11,64)
f:SetHeight(17)
f:SetWidth(141)
f:SetPoint("LEFT", sdm_collapseAllButton, "RIGHT", 35,0)
f:SetHitRectInsets(0,0,-10,-10)
f:SetBackdrop({
	bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
	edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
	tile = true,
	tileSize = 8,
	edgeSize = 8,
	insets = {
		left = 3,
		right = 3,
		top = 6,
		bottom = 6
	}
})
f:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
sdm_SetTooltip(f, "Change the display size of the macros in the list above.")

sdm_newButton:SetPoint("LEFT", sdm_iconSizeSlider, "RIGHT", 20,0)

--------------------------------------------------
--[[ Creation of the Change Name/Icon" window ]]--
--------------------------------------------------

f = CreateFrame("Frame", "sdm_changeIconFrame", sdm_mainFrame, UIParent)
f:Hide()
f:SetToplevel(true)
f:SetSize(293,60)
f:SetPoint("TOP", 70,-100)
f:SetBackdrop({
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
	tile = true,
	tileSize = 32,
	edgeSize = 32,
		insets = {
		left = 11,
		right = 12,
		top = 12,
		bottom = 11
	}
})
f:SetScript("OnShow", function(self)
	sdm_OnShow_changeIconFrame(self)
end)
f:SetScript("OnHide", function(self)
	sdm_OnHide_changeIconFrame(self)
end)
sdm_AddToExclusiveGroup(f, "centerwindows")
sdm_MakeDraggable(f)

f = CreateFrame("EditBox", "sdm_changeNameInput", sdm_changeIconFrame, "InputBoxTemplate")
f:SetAutoFocus(false)
f:SetSize(200,26)
f:SetPoint("TOPLEFT", 70,-21)
f:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
f:SetScript("OnEnterPressed", sdm_ChangeIconOkayed)

fs = f:CreateFontString("sdm_changeNameInput_Text", "ARTWORK", "GameFontNormal")
fs:SetText("Name: ")
fs:SetPoint("RIGHT", f, "LEFT", -5,0)

--------------------------------------------
--[[ Creation of the "New Macro" window ]]--
--------------------------------------------

f = CreateFrame("Frame", "sdm_newFrame", sdm_mainFrame, UIParent)
f:SetFrameStrata("HIGH")
f:Hide()
f:SetWidth(280)
f:SetHeight(145)
f:SetPoint("CENTER", 70,0)
f:SetBackdrop({
	-- path to the background texture
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
	-- path to the border texture
	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
	-- true to repeat the background texture to fill the frame, false to scale it
	tile = true,
	-- size (width or height) of the square repeating background tiles (in pixels)
	tileSize = 32,
	-- thickness of edge segments and square size of edge corners (in pixels)
	edgeSize = 32,
	-- distance from the edges of the frame to those of the background texture (in pixels)
	insets = {
		left = 11,
		right = 12,
		top = 12,
		bottom = 11
	}
})
sdm_MakeDraggable(f)
f:SetScript("OnHide", function() UIFrameFlashStop(sdm_createMacroButton_flash) end)
sdm_AddToExclusiveGroup(f, "centerwindows")

-- Radio buttons:

function sdm_FancifyNewRadioButton(button, text, colorCode)
	fs = button:CreateFontString(button:GetName().."Text", "ARTWORK", "GameFontNormal")
	fs:SetPoint("LEFT", button, "RIGHT")
	fs:SetText(text)
	if colorCode then
		local _,outline,_,fill,text = button:GetRegions()
		local r,g,b = sdm_GetColor(colorCode)
		outline:SetVertexColor(r,g,b)
		fill:SetVertexColor(r,g,b)
		text:SetTextColor(r,g,b)
	end
end

function sdm_CreateRadioButton(name, groupName, parent, below, text, colorCode)
	local button = CreateFrame("CheckButton", name, parent, "SendMailRadioButtonTemplate")
	sdm_AddToRadioGroup(button, groupName)
	sdm_FancifyNewRadioButton(button, text, colorCode)
	if below then
		button:SetPoint("TOPLEFT", below, "BOTTOMLEFT")
	end
	return button
end

f = sdm_CreateRadioButton("sdm_buttonRadio", "NewType", sdm_newFrame, nil, "Button Macro", "b")
f:SetPoint("TOPLEFT", 15,-15)
f:SetChecked(1)
sdm_SetTooltip(f, "Button macros can be placed on your action bars. However, you can only have a limited number of these. They can also be called with a slash command.")

f = sdm_CreateRadioButton("sdm_floatingRadio", "NewType", sdm_newFrame, sdm_buttonRadio, "Floating Macro", "f")
sdm_SetTooltip(f, "You can make as many floating macros as you like, but they cannot be placed on your action bars. They can called in other macros via a slash command.")

f = sdm_CreateRadioButton("sdm_scriptRadio", "NewType", sdm_newFrame, sdm_floatingRadio, "Script", "s")
sdm_SetTooltip(f, "Scripts are blocks of lua code. You can call these with a slash command or a function call.")

f = sdm_CreateRadioButton("sdm_folderRadio", "NewType", sdm_newFrame, sdm_scriptRadio, "Folder")
sdm_SetTooltip(f, "Folders can contain macros, scripts, or other folders. Alt-click on a folder for options and instructions.")

f = sdm_CreateRadioButton("sdm_globalRadio", "NewChar", sdm_newFrame, nil, "Global")
f:SetPoint("LEFT", sdm_buttonRadio, "RIGHT", 103,0)
f:SetChecked(1)
sdm_SetTooltip(f, "Selecting 'Global' will make this available to all characters.")

f = sdm_CreateRadioButton("sdm_charspecRadio", "NewChar", sdm_newFrame, sdm_globalRadio, "Character-specific")
sdm_SetTooltip(f, "Selecting 'Character-specific' will make this available only to select characters. Use the 'Claim' and 'Disown' buttons to enable or disable it for individual characters.")

-- Text input box:

f = CreateFrame("EditBox", "sdm_newMacroNameInput", sdm_newFrame, "InputBoxTemplate")
f:SetAutoFocus(false)
f:SetWidth(200)
f:SetHeight(26)
f:SetPoint("TOPLEFT", sdm_folderRadio, "BOTTOMLEFT", 50,0)
f:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
f:SetScript("OnEnterPressed", function() sdm_createMacroButton:Click() end)
fs = f:CreateFontString(sdm_newMacroNameText, "ARTWORK", "GameFontNormal")
fs:SetPoint("RIGHT", f, "LEFT", -5,0)
fs:SetText("Name: ")
sdm_SetTooltip(f, "Some characters (such as spaces) are not allowed in Super Duper macro names.  If you would like spaces (or nothing) to show on the button text, use the 'Change Name/Icon' button after you have created the macro and select the 'Different name on button' option.")

-- Red buttons:

f = CreateFrame("Button", "sdm_createMacroButton", sdm_newFrame, "UIPanelButtonTemplate")
f:SetText("Create")
f:SetWidth(80)
f:SetHeight(22)
f:SetPoint("TOPLEFT", sdm_newMacroNameInput, "BOTTOMLEFT")
f:SetScript("OnClick", sdm_CreateMacroButtonClicked)
local flash = f:CreateTexture("sdm_createMacroButton_flash", "OVERLAY")
flash:SetTexture("Interface\\Buttons\\UI-Panel-Button-Glow")
flash:SetBlendMode("ADD")
flash:SetTexCoord(0, .75, 0, .609375)
flash:SetPoint("BOTTOMLEFT", -7,-7)
flash:SetPoint("TOPRIGHT", 7,7)
flash:Hide()

f = CreateFrame("Button", "sdm_cancelNewMacroButton", sdm_newFrame, "UIPanelButtonTemplate")
f:SetText("Cancel")
f:SetWidth(80)
f:SetHeight(22)
f:SetPoint("LEFT", sdm_createMacroButton, "RIGHT")
f:SetScript("OnClick", sdm_CancelNewMacroButtonPressed)

-----------------------------------------------
--[[ Creation of the "Send/Receive" window ]]--
-----------------------------------------------

f = CreateFrame("Frame", "sdm_sendReceiveFrame", sdm_mainFrame)
f:Hide()
f:SetWidth(256)
f:SetHeight(394)
f:SetPoint("LEFT", sdm_mainFrame, "RIGHT", -10,0)
f:SetBackdrop({
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
	tile = true,
	tileSize = 32,
	edgeSize = 32,
	insets = {
		left = 11,
		right = 12,
		top = 12,
		bottom = 11
	}
})
f:SetScript("OnShow", function()
	sdm_sendReceiveButton:SetText("Share <<")
end)
f:SetScript("OnHide", function()
	sdm_sendReceiveButton:SetText("Share >>")
	if (not sdm_sending) then
		sdm_sendStatusBar:SetValue(0)
		sdm_sendStatusBar_text:SetText("")
	end
	if (not sdm_receiving) then
		sdm_receiveStatusBar:SetValue(0)
		sdm_receiveStatusBar_text:SetText("")
	end
end)
sdm_MakeDraggable(f)

-- Frame text:

fs = f:CreateFontString("sdm_sendInstructionText", "ARTWORK", "GameFontNormal")
fs:SetText("Send currently selected macro to:")
fs:SetPoint("LEFT", f, "TOPLEFT", 15,-20)

fs = f:CreateFontString("sdm_receiveInstructionText", "ARTWORK", "GameFontNormal")
fs:SetText("Await a macro from:")
fs:SetPoint("TOPLEFT", sdm_sendInstructionText, "BOTTOMLEFT", 0,-206)

-- Status bars:

f = CreateFrame("Frame", "sdm_sendBarParent", sdm_sendReceiveFrame)
f:SetWidth(200)
f:SetHeight(30)
f:SetPoint("TOP", 0,-181)
f:SetBackdrop({
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true,
	tileSize = 32,
	edgeSize = 8,
	insets = {
		left = 2,
		right = 2,
		top = 2,
		bottom = 2
	}
})
f:SetBackdropColor(0, 0, 0, 0.7)

f = CreateFrame("StatusBar", "sdm_sendStatusBar", sdm_sendBarParent)
f:SetMinMaxValues(0,100)
f:SetValue(0)
f:SetPoint("BOTTOMLEFT", 5,5)
f:SetPoint("TOPRIGHT", -5,-5)
f:SetStatusBarTexture("Interface\\PaperDollInfoFrame\\UI-Character-Skills-Bar", "BACKGROUND")
f:SetStatusBarColor(0, 0.5, 1)
fs = f:CreateFontString("sdm_sendStatusBar_text", "ARTWORK", "GameFontNormal")
fs:SetText("")
fs:SetTextColor(1, 0.5, 0)
fs:SetPoint("CENTER")

f = CreateFrame("Frame", "sdm_receiveBarParent", sdm_sendReceiveFrame)
f:SetWidth(200)
f:SetHeight(30)
f:SetPoint("TOP", 0,-351)
f:SetBackdrop({
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true,
	tileSize = 32,
	edgeSize = 8,
	insets = {
		left = 2,
		right = 2,
		top = 2,
		bottom = 2
	}
})
f:SetBackdropColor(0, 0, 0, 0.7)

f = CreateFrame("StatusBar", "sdm_receiveStatusBar", sdm_receiveBarParent)
f:SetMinMaxValues(0,100)
f:SetValue(0)
f:SetPoint("BOTTOMLEFT", 5,5)
f:SetPoint("TOPRIGHT", -5,-5)
f:SetStatusBarTexture("Interface\\PaperDollInfoFrame\\UI-Character-Skills-Bar", "BACKGROUND")
f:SetStatusBarColor(0, 0.5, 1)
fs = f:CreateFontString("sdm_receiveStatusBar_text", "ARTWORK", "GameFontNormal")
fs:SetText("")
fs:SetTextColor(1, 0.5, 0)
fs:SetPoint("CENTER")

-- Radio buttons:

f = sdm_CreateRadioButton("sdm_sendPartyRadio", "SendTo", sdm_sendReceiveFrame, nil, "Party")
f:SetPoint("TOPLEFT", sdm_sendInstructionText, "BOTTOMLEFT", 0,-4)
f:SetChecked(1)

f = sdm_CreateRadioButton("sdm_sendRaidRadio", "SendTo", sdm_sendReceiveFrame, sdm_sendPartyRadio, "Raid")

f = sdm_CreateRadioButton("sdm_sendBattlegroundRadio", "SendTo", sdm_sendReceiveFrame, sdm_sendRaidRadio, "Battleground")

f = sdm_CreateRadioButton("sdm_sendGuildRadio", "SendTo", sdm_sendReceiveFrame, sdm_sendBattlegroundRadio, "Guild")

f = sdm_CreateRadioButton("sdm_sendArbitraryRadio", "SendTo", sdm_sendReceiveFrame, sdm_sendGuildRadio, "A specific character:")

f = sdm_CreateRadioButton("sdm_sendTargetRadio", "SendTo", sdm_sendReceiveFrame, nil, "Your current target")
f:SetPoint("TOPLEFT", sdm_sendArbitraryRadio, "BOTTOMLEFT", 0,-25)

f = sdm_CreateRadioButton("sdm_receiveArbitraryRadio", "ReceiveFrom", sdm_sendReceiveFrame, nil, "A specific character:")
f:SetPoint("TOPLEFT", sdm_receiveInstructionText, "BOTTOMLEFT", 0,-4)
f:SetChecked(1)

f = sdm_CreateRadioButton("sdm_receiveTargetRadio", "ReceiveFrom", sdm_sendReceiveFrame, nil, "Your current target")
f:SetPoint("TOPLEFT", sdm_receiveArbitraryRadio, "BOTTOMLEFT", 0,-25)

f = sdm_CreateRadioButton("sdm_receiveAnyoneRadio", "ReceiveFrom", sdm_sendReceiveFrame, sdm_receiveTargetRadio, "Anyone")

-- Input boxes:

local boxWidth = 180
local boxHeight = 26
local boxOffset = 32

f = CreateFrame("EditBox", "sdm_sendInput", sdm_sendReceiveFrame, "InputBoxTemplate")
f:SetAutoFocus(false)
f:SetWidth(boxWidth)
f:SetHeight(boxHeight)
f:SetPoint("TOPLEFT", sdm_sendArbitraryRadio, "BOTTOMLEFT", boxOffset,0)
f:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
f:SetScript("OnEnterPressed", function() sdm_sendButton:Click() end)
f:SetScript("OnEditFocusGained", function()
	if not sdm_sendArbitraryRadio:GetChecked() then
		sdm_sendArbitraryRadio:Click()
	end
end)

f = CreateFrame("EditBox", "sdm_receiveInput", sdm_sendReceiveFrame, "InputBoxTemplate")
f:SetAutoFocus(false)
f:SetWidth(boxWidth)
f:SetHeight(boxHeight)
f:SetPoint("TOPLEFT", sdm_receiveArbitraryRadio, "BOTTOMLEFT", boxOffset,0)
f:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
f:SetScript("OnEnterPressed", function() sdm_sendButton:Click() end)
f:SetScript("OnEditFocusGained", function()
	if not sdm_receiveArbitraryRadio:GetChecked() then
		sdm_receiveArbitraryRadio:Click()
	end
end)

-- Red buttons:

f = CreateFrame("Button", "sdm_quitSendReceiveButton", sdm_sendReceiveFrame, "UIPanelCloseButton")
f:SetPoint("TOPRIGHT", -3,-3)
f:SetScript("OnClick", function() sdm_sendReceiveFrame:Hide() end)

local buttonOver = 38
local buttonUp = 30
local buttonWidth = 60
local buttonHeight = 24

f = CreateFrame("Button", "sdm_sendButton", sdm_sendReceiveFrame, "UIPanelButtonTemplate")
f:SetText("Send")
f:SetWidth(buttonWidth)
f:SetHeight(buttonHeight)
f:SetPoint("CENTER", sdm_sendBarParent, "CENTER", -buttonOver, buttonUp)
f:SetScript("OnClick", sdm_SendButtonClicked)
sdm_SetTooltip(f, "Make sure that your recipient clicks 'Receive' before you click 'Send'.")

f = CreateFrame("Button", "sdm_cancelSendButton", sdm_sendReceiveFrame, "UIPanelButtonTemplate")
f:SetText("Cancel")
f:SetWidth(buttonWidth)
f:SetHeight(buttonHeight)
f:SetPoint("CENTER", sdm_sendBarParent, "CENTER", buttonOver, buttonUp)
f:SetScript("OnClick", sdm_CancelSend)
f:Disable()

f = CreateFrame("Button", "sdm_receiveButton", sdm_sendReceiveFrame, "UIPanelButtonTemplate")
f:SetText("Receive")
f:SetWidth(buttonWidth)
f:SetHeight(buttonHeight)
f:SetPoint("CENTER", sdm_receiveBarParent, "CENTER", -buttonOver, buttonUp)
f:SetScript("OnClick", sdm_ReceiveButtonClicked)
sdm_SetTooltip(f, "Once you have received the macro, click the glowing 'Create' button to save it.")
sdm_AddToExclusiveGroup(f, "centerwindows", true)

f = CreateFrame("Button", "sdm_cancelReceiveButton", sdm_sendReceiveFrame, "UIPanelButtonTemplate")
f:SetText("Cancel")
f:SetWidth(buttonWidth)
f:SetHeight(buttonHeight)
f:SetPoint("CENTER", sdm_receiveBarParent, "CENTER", buttonOver, buttonUp)
f:SetScript("OnClick", sdm_CancelReceive)
f:Disable()

---------------------------------------------------------
--[[ Buttons that we add to the default macro window ]]--
---------------------------------------------------------

function sdm_CreateDefaultMacroFrameButtons()
	--Create the button that links from the default macro frame to the SDM frame
	f = CreateFrame("Button", "$parent_linkToSDM", MacroFrame, "UIPanelCloseButton")
	f:SetWidth(linkButtonSize)
	f:SetHeight(linkButtonSize)	f:SetPoint("TOPLEFT", linkButtonXOffs, linkButtonYOffs)
	f:SetScript("OnClick", function() 
		HideUIPanel(MacroFrame)
		sdm_mainFrame:Show()
	end)
	t = f:CreateTexture()
	t:SetDrawLayer("OVERLAY", 7)
	t:SetPoint("CENTER", -1,0)
	t:SetWidth(20)
	t:SetHeight(20)
	t:SetTexture("Interface\\AddOns\\SuperDuperMacro\\SDM-Icon.tga")
	sdm_SetTooltip(f, "Open Super Duper Macro, an advanced macro interface that lets you create longer macros")

	--Create the button that turns a regular macro into a Super Duper macro
	f = CreateFrame("Button", "$parent_convertToSuper", MacroFrame, "UIPanelButtonTemplate")
	f:SetPoint("TOPLEFT", MacroDeleteButton, "TOPRIGHT")
	f:SetPoint("BOTTOMRIGHT", MacroNewButton, "BOTTOMLEFT")
	f:SetText("Upgrade!  ")
	t = f:CreateTexture()
	t:SetDrawLayer("OVERLAY", 7)
	margin = 0.25 * f:GetHeight()
	t:SetPoint("TOPRIGHT", f, "TOPRIGHT", -margin, -margin)
	t:SetPoint("BOTTOM", f, "BOTTOM", 0, margin)
	t:SetWidth(t:GetHeight())
	t:SetTexture("Interface\\AddOns\\SuperDuperMacro\\SDM-Icon.tga")
	f:SetScript("OnClick", sdm_UpgradeButtonClicked)
	sdm_SetTooltip(f, "Turn the selected macro into a Super Duper Macro, allowing you to make it longer")

	-- The following three frames are only showed when SDM's "Change Name/Icon" button is clicked.  Clicking this button hijacks the default MacroPopupFrame and modifies it to our needs.

	-- Create the "Different name on button" checkbox
	f = CreateFrame("CheckButton", "$parent_buttonTextCheckBox", MacroPopupFrame, "UICheckButtonTemplate")
	f:SetWidth(20)
	f:SetHeight(20)
	f:SetPoint("TOPLEFT", 25, -18)
	f:SetScript("OnClick", function() 
		sdm_buttonTextCheckBoxClicked(MacroPopupFrame_buttonTextCheckBox:GetChecked()) 
	end)
	f:Hide()

	-- Create the "Cancel" button
	f = CreateFrame("Button", "$parent_sdmCancelButton", MacroPopupFrame, "UIPanelButtonTemplate")
	f:SetWidth(78)
	f:SetHeight(22)
	f:SetPoint("BOTTOMRIGHT", -11, 13)
	f:SetText(CANCEL)
	f:SetScript("OnClick", function() 
		sdm_changeIconFrame:Hide()
	end)

	-- Create the "Okay" button
	f = CreateFrame("Button", "$parent_sdmOkayButton", MacroPopupFrame, "UIPanelButtonTemplate")
	f:SetWidth(78)
	f:SetHeight(22)
	f:SetPoint("RIGHT", MacroPopupCancelButton, "LEFT", -2, 0)
	f:SetText(OKAY)
	f:SetScript("OnClick", sdm_ChangeIconOkayed)
end
