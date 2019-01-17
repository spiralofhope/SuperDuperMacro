--[[ Interface-related Functions ]]--

function sdm_About()
	print(sdm_printPrefix.."by hypehuman. Version "..sdm_version..". Check for updates at www.wowinterface.com")
end

function sdm_TypeDropdownLoaded(self)
	self:SetScript("OnShow", nil)
	UIDropDownMenu_Initialize(self, sdm_InitializeTypeDropdown);
	UIDropDownMenu_SetText(self, "Type");
	UIDropDownMenu_SetWidth(self, 52);
end

function sdm_CharDropdownLoaded(self)
	self:SetScript("OnShow", nil)
	UIDropDownMenu_Initialize(self, sdm_InitializeCharDropdown);
	UIDropDownMenu_SetText(self, "Character");
	UIDropDownMenu_SetWidth(self, 75);
end

function sdm_InitializeTypeDropdown()
	local info = UIDropDownMenu_CreateInfo();
	local buttons = {
		{val="b", txt="Button Macros"},
		{val="f", txt="Floating Macros"},
		{val="s", txt="Scripts"}
	}
	for _,v in ipairs(buttons) do
		info.value = v.val;
		info.text = sdm_GetColor(v.val, v.txt);
		info.func = sdm_FilterButtonClicked;
		info.checked = sdm_listFilters[info.value];
		info.keepShownOnClick = 1;
		UIDropDownMenu_AddButton(info);
	end
end

function sdm_InitializeCharDropdown()
	local info = UIDropDownMenu_CreateInfo();
	local buttons = {
		{val="global", txt="Global"},
		{val="true", txt="This Character"},
		{val="false", txt="Other Characters"}
	}
	
	for _,v in ipairs(buttons) do
		info.value = v.val;
		info.text = sdm_GetColor(v.val, v.txt);
		info.func = sdm_FilterButtonClicked;
		info.checked = sdm_listFilters[info.value];
		info.keepShownOnClick = 1;
		UIDropDownMenu_AddButton(info);	
	end
end

function sdm_FilterButtonClicked(self, _, _, on)
	sdm_listFilters[self.value] = on
	sdm_UpdateList()
end

function sdm_NewButtonClicked()
	sdm_SaveConfirmationBox("sdm_newFrame:Show() sdm_newMacroNameInput:SetFocus()")
end

function sdm_SaveAsButtonClicked()
	local saved = sdm_macros[sdm_currentEdit]
	sdm_saveAsText = sdm_bodyBox:GetText() -- we'll save this text into the new one, but leave the old one unsaved.
	sdm_saveAsIcon = saved.icon
	sdm_newFrame:Show()
	sdm_newMacroNameInput:SetFocus()
	sdm_newMacroNameInput:SetText(saved.name)
	if saved.type=="b" then
		sdm_buttonRadio:Click()
	elseif saved.type=="f" then
		sdm_floatingRadio:Click()
	elseif saved.type=="s" then
		sdm_scriptRadio:Click()
	end
	if saved.characters then
		sdm_charspecRadio:Click()
	else
		sdm_globalRadio:Click()
	end
end

function sdm_DeleteButtonClicked()
	sdm_ChangeContainer(sdm_macros[sdm_currentEdit], false)
	sdm_SelectItem(nil)
end

function sdm_ClaimButtonClicked()
	sdm_AddCharacter(sdm_macros[sdm_currentEdit], sdm_thisChar)
	sdm_SetUpMacro(sdm_macros[sdm_currentEdit])
	sdm_UpdateCurrentTitle()
	sdm_UpdateList()
	sdm_UpdateClaimDisownButtons()
end

function sdm_DisownButtonClicked()
	sdm_UnSetUpMacro(sdm_macros[sdm_currentEdit])
	sdm_RemoveCharacter(sdm_macros[sdm_currentEdit], sdm_thisChar)
	sdm_UpdateCurrentTitle()
	sdm_UpdateList()
	sdm_UpdateClaimDisownButtons()
end

function sdm_UpgradeButtonClicked()
	local index = MacroFrame.selectedMacro
	if index==nil then
		print(sdm_printPrefix.."You must select a standard macro first.")
		return
	end
	MacroSaveButton:Click()
	local newMacro = sdm_UpgradeMacro(index)
	if newMacro==nil then
		return
	end
	MacroFrame_linkToSDM:Click() -- show the SDM frame
	sdm_SelectItem(newMacro.ID) -- select the newly upgraded macro
	MacroFrame.selectedMacro = nil -- deselect the macro in the standard macro frame
end

function sdm_DowngradeButtonClicked()
	sdm_saveButton:Click()
	local index = sdm_DowngradeMacro(sdm_macros[sdm_currentEdit])
	if index==nil then
		return
	end
	sdm_SelectItem(nil) -- deselect the macro in the SDM frame
	sdm_Quit(" ShowMacroFrame()") -- show the standard macro frame
	local buttonName = "MacroButton"
	if index<=MAX_ACCOUNT_MACROS then -- global macro
		MacroFrameTab1:Click()
		buttonName = buttonName..index
	else -- character-specific macro
		MacroFrameTab2:Click()
		buttonName = buttonName..(index-MAX_ACCOUNT_MACROS)
	end
	getglobal(buttonName):Click() -- select the newly downgraded macro
end

function sdm_OnEnterTippedButton(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetText(self.tooltipText, nil, nil, nil, nil, true)
	GameTooltip:Show()
end

function sdm_OnLeaveTippedButton()
	GameTooltip_Hide()
end

-- if text is provided, sets up the button to show a tooltip when moused over. Otherwise, removes the tooltip.
function sdm_SetTooltip(self, text)
	if text then
		self.tooltipText = text
		self:SetScript("OnEnter", sdm_OnEnterTippedButton)
		self:SetScript("OnLeave", sdm_OnLeaveTippedButton)
	else
		self:SetScript("OnEnter", nil)
		self:SetScript("OnLeave", nil)
	end
end

function sdm_ListItemClicked(self, button)
	local mTab = sdm_macros[self.index]
	if button=="RightButton" then
		sdm_currentlyPlacing = self.index
		sdm_UpdateList()
	elseif sdm_currentlyPlacing then
		local container
		if mTab.type=="c" then --If we clicked on a container, place the item in this container
			container = mTab.ID
		else --If we clicked on a non-container, place the item in the container that contains this macro
			container = mTab.container
		end
		sdm_ChangeContainer(sdm_macros[sdm_currentlyPlacing], container)
		sdm_currentlyPlacing=nil
		sdm_UpdateList()
	elseif mTab.type=="c" and not IsAltKeyDown() then
		mTab.open = not mTab.open
		sdm_UpdateList()
	else
		sdm_SaveConfirmationBox("sdm_SelectItem("..self.index..")")
	end
end

function sdm_SelectItem(newCurrentEdit)
	if sdm_listLocked then return end
	if sdm_macros[newCurrentEdit] then
		sdm_currentEdit = newCurrentEdit
	else
		sdm_currentEdit = nil
	end
	local mTab = sdm_macros[sdm_currentEdit]
	if (not mTab) then
		sdm_deleteButton:Disable()
		sdm_usageButton:Disable()
		sdm_changeIconButton:Disable()
		sdm_bodyScroller:Hide()
		sdm_saveButton:Disable()
		sdm_saveAsButton:Disable()
		sdm_downgradeButton:Disable()
		sdm_sendButton:Disable()
		sdm_containerInstructions:Hide()
	else
		sdm_bodyBox:ClearFocus()
		sdm_deleteButton:Enable()
		sdm_changeIconButton:Enable()
		if mTab.type=="c" then
			sdm_bodyScroller:Hide()
			sdm_containerInstructions:Show()
			sdm_usageButton:Disable()
			sdm_saveAsButton:Disable()
			sdm_sendButton:Disable()
		else
			if not sdm_sending then
				sdm_sendButton:Enable()
			end
			sdm_bodyScroller:Show()
			sdm_containerInstructions:Hide()
			sdm_usageButton:Enable()
			sdm_saveAsButton:Enable()
			if mTab.type=="b" and sdm_UsedByThisChar(mTab) then
				sdm_downgradeButton:Enable()
			else
				sdm_downgradeButton:Disable()
			end
		end
		sdm_bodyBox:SetText(mTab.text or "")
		sdm_saveButton:Disable()
	end
	sdm_UpdateClaimDisownButtons()
	sdm_UpdateCurrentTitle()
	sdm_UpdateList()
end

function sdm_UpdateClaimDisownButtons()
	local mTab = sdm_macros[sdm_currentEdit]
	if mTab and mTab.characters then
		sdm_claimButton:Enable()
		sdm_disownButton:Enable()
	else
		sdm_claimButton:Disable()
		sdm_disownButton:Disable()
	end
	if sdm_UsedByThisChar(mTab) then
		sdm_claimButton:Hide()
		sdm_disownButton:Show()
	else
		sdm_claimButton:Show()
		sdm_disownButton:Hide()
	end
end

function sdm_ResetContainers() --Deletes all folders and places all items into the main list
	sdm_mainContents={}
	for i,v in pairs(sdm_macros) do
		if v.type=="c" then
			sdm_macros[i]=nil
		else
			sdm_SortedInsert(sdm_mainContents, v)
			v.container=nil
		end
	end
end

function sdm_ChangeContainer(mTab, newContainer) --removes the mTab from its current container and places it in the container with ID newContainer.  If newContainer is nil, it's placed in the main folder.  If newContainer is false, the item is deleted.
	local parent = newContainer
	while parent do --check to see if we're trying to put a folder inside itself
		if parent==mTab.ID then return end
		parent = sdm_macros[parent].container
	end
	--remove the mTab from its current container.
	local prevContents--the .contents table of the container that currently holds this mTab
	if mTab.container==nil then
		prevContents = sdm_mainContents
	else
		prevContents = sdm_macros[mTab.container].contents
	end
	for i,ID in ipairs(prevContents) do
		if ID==mTab.ID then
			table.remove(prevContents, i)
			break
		end
	end
	--now we're done removing from old container
	if newContainer==false then --delete the mTab
		local type = mTab.type
		if type=="c" then --if we're deleting a container, move its contents into its parent.
			for _,ID in pairs(mTab.contents) do
				sdm_macros[ID].container=mTab.container
				sdm_SortedInsert(prevContents, sdm_macros[ID])
			end
		else
			sdm_UnSetUpMacro(mTab)
		end
		sdm_macros[mTab.ID]=nil
	else --move mTab into newContainer
		local contents --the new container's contents
		if newContainer then
			contents=sdm_macros[newContainer].contents
		else
			contents = sdm_mainContents
		end
		sdm_SortedInsert(contents, mTab)
		mTab.container = newContainer
	end
end

function sdm_SortedInsert(contents, mTab) --inserts mTab's ID into t (a table of IDs) at an appropriate location.  Returns the location.
	local lLim = 1
	local uLim = getn(contents)+1
	local test
	--perform a binary search to see where we should insert the mTab (to maintain alphabetical order)
	while lLim < uLim do
		test=math.floor((lLim+uLim)/2)
		if sdm_IsAtLeast(mTab, sdm_macros[contents[test]]) then
			lLim=test+1
		else
			uLim=test
		end
	end
	table.insert(contents, lLim, mTab.ID)
	return lLim
end

function sdm_IsAtLeast(one, two, i) --sees if the first mTab is greater than or equal to the second. This is used for sorting them in the list.
	i=i or 1
	local var
	if i==1 then -- first sort by case-insensitive name
		var=function(mTab)
			return mTab.name:upper()
		end
	elseif i==2 then -- if the case-insensitive names are the same, sort by case-sensitive name
		var=function(mTab)
			return mTab.name
		end
	elseif i==3 then -- if the case-sensitive names are the same, sort by type (folder, button, floating, script)
		var=function(mTab)
			return mTab.type
		end
	elseif i==4 then -- if the types are the same, sort by global/percharacter
		var=function(mTab)
			if mTab.characters then
				return "1"
			else
				return "0"
			end
		end
	else -- If they are both global or both percharacter, the macros are equivalent.
		return true
	end
	if var(one) > var(two) then
		return true
	elseif var(one) < var(two) then
		return false
	else
		return sdm_IsAtLeast(one, two, i+1)
	end
end

-- these names aren't really used by the program; they're just there because unnamed frames can sometimes behave strangely
function CreateListItemFrameName()
	sdm_numListItemsNamed = (sdm_numListItemsNamed or 0) + 1
	return "sdm_ListButton"..sdm_numListItemsNamed
end

function sdm_UpdateList()
	if not sdm_mainFrame:IsShown() then return end
	local f
	for i=getn(sdm_listItems),1,-1 do
		f=sdm_listItems[i]
		f:Hide()
		table.remove(sdm_listItems, i)
		table.insert(sdm_unusedListItems[f.isContainerFrame], f)
	end
	local sorted, offsets = {}, {}
	sdm_AddFolderContents(sorted, offsets, sdm_mainContents, 0)
	sdm_currentListItem = nil
	local listItem, isContainer
	for i,mTab in ipairs(sorted) do
		isContainer = mTab.type=="c"
		listItem = table.remove(sdm_unusedListItems[isContainer],1)
		if not listItem then
			--create the listItem
			listItem = CreateFrame("Button", CreateListItemFrameName(), sdm_macroList)
			listItem.icon = listItem:CreateTexture(nil, "OVERLAY")
			listItem.text = listItem:CreateFontString(nil,"ARTWORK","GameFontNormal")
			listItem.text:SetJustifyH("LEFT")
			listItem.text:SetPoint("TOP")
			listItem.text:SetPoint("BOTTOMRIGHT")
			listItem.text:SetNonSpaceWrap(true)
			listItem.isContainerFrame=isContainer
			listItem:SetPoint("RIGHT")
			listItem:SetPoint("LEFT")
			listItem.highlight = listItem:CreateTexture(nil, "BACKGROUND")
			listItem.highlight:SetAllPoints(listItem)
			listItem.highlight:SetTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight")
			listItem.highlight:SetBlendMode("ADD")
			listItem.highlight:Hide()
			listItem:SetScript("OnEnter", sdm_ListItemEntered)
			listItem:SetScript("OnLeave", sdm_ListItemLeft)
			listItem:SetScript("OnMouseUp", sdm_ListItemClicked)
			listItem.buttonHighlight = listItem:CreateTexture(nil, "HIGHLIGHT")
			listItem.buttonHighlight:SetBlendMode("ADD")
			listItem.buttonHighlight:SetAllPoints(listItem.icon)
			listItem:RegisterForDrag("LeftButton")
			if isContainer then
				listItem.icon:SetHeight(16)
				listItem.icon:SetWidth(16)
				listItem.buttonHighlight:SetTexture("Interface\\Buttons\\UI-PlusButton-Hilight")
			else
				listItem.slotIcon = listItem:CreateTexture(nil, "ARTWORK")
				listItem.slotIcon:SetTexture("Interface\\Buttons\\UI-EmptySlot-Disabled")
				listItem.slotIcon:SetPoint("CENTER", listItem.icon)
				listItem.buttonHighlight:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
				listItem.buttonHighlight:SetPoint("CENTER", listItem.icon, "CENTER")
			end
		end
		table.insert(sdm_listItems, listItem) --this should insert it at i
		--now, update the item's graphical elements
		if isContainer then
			if mTab.open then
				listItem.icon:SetTexture("Interface\\Buttons\\UI-MinusButton-UP")
			else
				listItem.icon:SetTexture("Interface\\Buttons\\UI-PlusButton-UP")
			end
			sdm_SetTooltip(listItem, "Alt-click for folder options and instructions")
		else
      if type(mTab.icon) == "number" then
        texture = mTab.icon
      else


        do  --  My old notes said to replace this
          --[[
          if mTab.icon:upper() == sdm_defaultIcon and mTab.type=="b" and (sdm_UsedByThisChar(mTab)) then
            _,texture = GetMacroInfo(sdm_GetMacroIndex(mTab.ID))
          else
            texture = "INTERFACE\\ICONS\\"..mTab.icon
          end
          --]]
          
          if mTab.icon ~= nil and type( mTab.icon ) ~= "number" then
            if mTab.icon:upper() == sdm_defaultIcon and mTab.type == "b" and ( sdm_UsedByThisChar( mTab ) ) then
            _,texture = GetMacroInfo( sdm_GetMacroIndex( mTab.ID ) )
            else
            texture = "INTERFACE\\ICONS\\" .. mTab.icon
            end
          end
          
        end

      end

			if texture then
				listItem.icon:SetTexture(texture)
				listItem.icon:SetWidth(sdm_iconSize)
				listItem.icon:SetHeight(sdm_iconSize)
			end
			listItem.slotIcon:SetWidth(sdm_iconSize*64/36)
			listItem.slotIcon:SetHeight(sdm_iconSize*64/36)
			if mTab.type=="b" and sdm_UsedByThisChar(mTab) then
				listItem:SetScript("OnDragStart", function(self, event, ...)
					if not InCombatLockdown() then
						PickupMacro(sdm_GetMacroIndex(sdm_macros[self.index].ID))
					else
						print(sdm_printPrefix.."You cannot pick up macros during combat.")
					end
				end)
			else
				listItem:SetScript("OnDragStart", nil)
			end
		end
		listItem.text:SetText(sdm_GetTitle(mTab))
		listItem:SetHeight(sdm_iconSize*(1+sdm_iconSpacing*2))
		listItem.icon:SetPoint("LEFT", sdm_iconSize*(sdm_iconSpacing + offsets[i]*(sdm_iconSpacing+1)) + (sdm_iconSize-listItem.icon:GetWidth())/2, 0)
		listItem.text:SetPoint("LEFT", sdm_iconSize*(sdm_iconSpacing + (offsets[i]+1)*(sdm_iconSpacing+1)), 0)
		listItem.index=mTab.ID
		if listItem.index==sdm_currentEdit then
			sdm_currentListItem = listItem
			listItem.highlight:SetVertexColor(sdm_GetColor(mTab.type))
			listItem.highlight:Show()
			listItem.text:SetTextColor(sdm_GetColor(nil))
		else
			listItem.highlight:Hide()
			listItem.text:SetTextColor(sdm_GetColor(mTab.type))
		end
		if listItem.index==sdm_currentlyPlacing then
			listItem:SetAlpha(0.3)
		else
			listItem:SetAlpha(1)
		end
		if i==1 then
			listItem:SetPoint("TOP")
		else
			listItem:SetPoint("TOP", sdm_listItems[i-1], "BOTTOM")
		end
		listItem:Show()
	end
end

function sdm_UpdateCurrentTitle()
	local mTab = sdm_macros[sdm_currentEdit]
	if mTab then
		sdm_currentTitle:Show()
		sdm_currentTitle:SetText(sdm_GetColoredTitle(mTab))
	else
		sdm_currentTitle:Hide()
	end
end

function sdm_GetTitle(mTab) -- the title that will be displayed in the list
	local result = mTab.name
	if mTab.characters then
		local lightTxt, darkTxt
		if sdm_UsedByThisChar(mTab) then
			lightTxt = " "..sdm_thisChar.name.." of "..sdm_thisChar.realm
			lightTxt = sdm_GetColor("true", lightTxt)
		else
			if mTab.characters[1] == nil then -- this item is character-specific, but it has not been claimed by any characters.
				darkTxt = " disowned"
			else
				darkTxt = " "..mTab.characters[1].name.." of "..mTab.characters[1].realm
			end
		end
		if mTab.characters[2] then
			darkTxt = (darkTxt or "").." and others"
		end
		if lightTxt then
			lightTxt = sdm_GetColor("true", lightTxt)
			result = result..lightTxt
		end
		if darkTxt then
			darkTxt = sdm_GetColor("false", darkTxt)
			result = result..darkTxt
		end
	end
	return result
end

function sdm_GetColoredTitle(mTab)
	local title = sdm_GetTitle(mTab)
	return sdm_GetColor(mTab.type, title)
end

function sdm_AddFolderContents(mTabs, offsets, contents, offset) --Populates mTabs with the elements of contents and all its subfolders.  Populates offsets with the amount of indentation for each item.
	for i,ID in ipairs(contents) do
		local mTab = sdm_macros[ID]
		if sdm_IncludeInList(mTab) then
			table.insert(mTabs, mTab)
			table.insert(offsets, offset)
			if mTab.type=="c" and mTab.open then -- If it's an open container, add its contents too.
				sdm_AddFolderContents(mTabs, offsets, mTab.contents, offset+1)
			end
		end
	end
end

function sdm_IncludeInList(mTab) --checks the filters to see if the item should be in the scrolling list
	if mTab.type=="c" then -- always show folders (aka containers)
		return true
	end
	if not sdm_listFilters[mTab.type] then -- if this item's type is not included in the filter, don't show it!
		return false
	end
	if not mTab.characters then -- if this item is global and globals are not included in the filter, don't show it!
		return sdm_listFilters["global"]
	end
	return sdm_listFilters[tostring(sdm_UsedByThisChar(mTab))] -- take care of this character's and other character's items
end

function sdm_MakeTextWhite(listItem)
	local t = listItem.text:GetText()
	listItem.text:SetText("|cffffffff"..t.."|r")
end

function sdm_MakeTextNotWhite(listItem)
	local t = listItem.text:GetText()
	if t:sub(1,2)=="|c" then
		listItem.text:SetText(t:sub(11, t:len()-2))
	end
end

function sdm_ListItemEntered(f) -- makes the text white when the mouse is over it
	if sdm_macros[f.index].type=="c" then
		sdm_MakeTextWhite(f)
	end
end

function sdm_ListItemLeft(f) -- reverts the text to its normal color when the mouse leaves it
	sdm_MakeTextNotWhite(f)
end

function sdm_GetColor(type, plainString)--if inputString is passed, it will return a new colored string.  If it's not passed, we will return three values.
	local r,g,b
	if type==nil then
		r,g,b= 1,1,1 --selected items
	elseif type=="b" then
		r,g,b= 1,1,.65 --button macros
	elseif type=="f" then
		r,g,b= 1,.62,.74 --floating macros
	elseif type=="s" then
		r,g,b= .76,.51,.29 --scripts
	elseif type=="true" then
		r,g,b= .7,.7,.7 --this character
	elseif type=="false" then
		r,g,b= .3,.3,.3 --other characters
	elseif type=="c" or type=="global" then
		r,g,b= NORMAL_FONT_COLOR.r,NORMAL_FONT_COLOR.g,NORMAL_FONT_COLOR.b --global or containers
	end
	if (not plainString) or r==nil then
		return r,g,b
	else
		local t = {r,g,b}
		local hex = ""
		for i,v in ipairs(t) do
			t[i] = string.format("%x", t[i]*255)
			while t[i]:len()<2 do
				t[i]="0"..t[i]
			end
			hex = hex..t[i]
		end
		return "|c00"..hex..plainString.."|r"
	end
end

function sdm_OnShow_changeIconFrame(f)
	if not sdm_macroUILoaded then
		MacroFrame_LoadUI()
		MacroPopupFrame:Show()
	else
		RefreshPlayerSpellIconInfo() -- You gotta do this, or there will be lots of errors!
	end
	local mTab = sdm_macros[sdm_currentEdit]
	MacroPopupFrame.selectedIcon = nil -- NYI: here would be a good place to select the current icon and scroll to that place in the list
	f.prevonshow=MacroPopupFrame:GetScript("OnShow")
	MacroPopupFrame:SetScript("OnShow", MacroPopupFrame_Update)
	f.prevonenter=MacroPopupEditBox:GetScript("OnEnterPressed")
	MacroPopupEditBox:SetScript("OnEnterPressed", sdm_ChangeIconOkayed)
	f.prevonesc=MacroPopupEditBox:GetScript("OnEscapePressed")
	MacroPopupEditBox:SetScript("OnEscapePressed", function() MacroPopupEditBox:ClearFocus() end)
	MacroPopupEditBox:SetAutoFocus(false)
	MacroFrame:Hide()
	f.prevmode=MacroPopupFrame.mode
	MacroPopupFrame.mode="sdm"
	f.prevpoints={}
	for i=1,MacroPopupFrame:GetNumPoints() do
		f.prevpoints[i]={MacroPopupFrame:GetPoint(i)}
	end
	MacroPopupFrame:ClearAllPoints()
	f.prevParent = MacroPopupFrame:GetParent()
	MacroPopupFrame:SetParent(f)
	MacroPopupFrame:SetPoint("TOP", f, "BOTTOM", 0,15)
	MacroPopupFrame:Show()
	_,_,_,_,f.fontstring = MacroPopupFrame:GetRegions()

  -- https://github.com/a08381 says:
  --   I don't know what is it now, and I try print all returns in MacroPopupFrame:GetRegions() but none of them has 'SetText' method.
  --   https://github.com/spiralofhope/SuperDuperMacro/pull/6
	--f.fontstring:SetText("        Different name on button:")

	MacroPopupOkayButton:Hide()
	MacroPopupCancelButton:Hide()
	MacroPopupFrame_sdmOkayButton:Show()
	MacroPopupFrame_sdmCancelButton:Show()
	if mTab.type=="b" then
		if (not mTab.buttonName) then
			MacroPopupFrame_buttonTextCheckBox:SetChecked(nil)
		else
			MacroPopupFrame_buttonTextCheckBox:SetChecked(1)
		end
		MacroPopupFrame_buttonTextCheckBox:Show()
		f.fontstring:Show()
	else
		MacroPopupFrame_buttonTextCheckBox:SetChecked(nil)
		MacroPopupFrame_buttonTextCheckBox:Hide()
		f.fontstring:Hide()
	end
	MacroPopupFrame_buttonTextCheckBox:GetScript("OnClick")(MacroPopupFrame_buttonTextCheckBox)
	sdm_changeNameInput:SetText(mTab.name or "")
end

function sdm_OnHide_changeIconFrame(f)
	MacroPopupFrame:SetScript("OnShow", f.prevonshow)
	MacroPopupEditBox:SetScript("OnEnterPressed", f.prevonenter)
	MacroPopupEditBox:SetScript("OnEscapePressed", f.prevonesc)
	MacroPopupEditBox:SetAutoFocus(true)
	MacroPopupFrame.mode=f.prevmode
	MacroPopupFrame:ClearAllPoints()
	MacroPopupFrame:SetParent(f.prevParent)
	for _,point in ipairs(f.prevpoints) do
		MacroPopupFrame:SetPoint(point[1], point[2], point[3], point[4], point[5])
	end

  -- See comment above, by a08381
	--f.fontstring:SetText(MACRO_POPUP_TEXT)

	f.fontstring:Show()
	MacroPopupEditBox:Show()
	MacroPopupOkayButton:Show()
	MacroPopupCancelButton:Show()
	MacroPopupFrame_sdmOkayButton:Hide()
	MacroPopupFrame_sdmCancelButton:Hide()
	MacroPopupFrame:Hide()
	MacroPopupFrame_buttonTextCheckBox:Hide()
end

function sdm_GetSelectedIcon()
	return GetSpellorMacroIconInfo(MacroPopupFrame.selectedIcon)
end

function sdm_ChangeIconOkayed()
	local mTab = sdm_macros[sdm_currentEdit]
	local nameInputted = sdm_changeNameInput:GetText()
	local iconInputted = sdm_GetSelectedIcon() or mTab.icon
	if (not nameInputted) or nameInputted=="" then
		return
	end
	if (mTab.type=="b" or mTab.type=="f") and sdm_ContainsIllegalChars(nameInputted, true) then return end
	if sdm_DoesNameConflict(nameInputted, mTab.type, mTab.characters, sdm_currentEdit, true) then
		return
	end
	local oldName = mTab.name
	local oldButtonName = mTab.buttonName
	local oldIcon = mTab.icon
	mTab.name = nameInputted
	sdm_ChangeContainer(mTab, mTab.container) --place the item in itself.  This is so that it gets re-sorted.
	if MacroPopupFrame_buttonTextCheckBox:GetChecked() then
		mTab.buttonName = MacroPopupEditBox:GetText()
		if mTab.buttonName=="" then
			mTab.buttonName=" "
		end
	else
		mTab.buttonName=nil
	end
	if mTab.type~="c" then
		mTab.icon = iconInputted
	end
	sdm_changeIconFrame:Hide()
	if sdm_UsedByThisChar(mTab) and (mTab.type=="b" or mTab.type=="f") then
		if mTab.name~=oldName then
			local pref = "sd"..mTab.type.."_"
			local txt = getglobal(pref..oldName):GetAttribute("macrotext")
			sdm_DoOrQueue("getglobal("..sdm_Stringer(pref..oldName).."):SetAttribute(\"type\", nil)")
			sdm_MakeMacroFrame("sd"..mTab.type.."_"..mTab.name, txt)
		end
		if mTab.type=="b" and ((mTab.buttonName or mTab.name)~=(oldButtonName or oldName) or mTab.icon~=oldIcon) then
			sdm_MakeBlizzardMacro(mTab.ID, (mTab.buttonName or mTab.name), mTab.icon)
		end
	end
	sdm_UpdateCurrentTitle()
	sdm_UpdateList()
end

function sdm_buttonTextCheckBoxClicked(checked)
	if checked then
		MacroPopupEditBox:Show()
		if sdm_macros[sdm_currentEdit].buttonName and sdm_macros[sdm_currentEdit].buttonName~=" " then
			MacroPopupEditBox:SetText(sdm_macros[sdm_currentEdit].buttonName)
		else
			MacroPopupEditBox:SetText("")
		end
	else
		MacroPopupEditBox:Hide()
	end
end

function sdm_CollapseAllButtonClicked(self)
	local allOpenOrClosed = not self:GetChecked()
	for _,v in ipairs(sdm_macros) do
		if v.type=="c" then
			v.open = allOpenOrClosed
		end
	end
	sdm_UpdateList()
end

function sdm_freezeEditFrame()
	sdm_descendants = {sdm_mainFrame:GetChildren()}
	sdm_mouseStates = {}
	local i=1
	for i,v in ipairs(sdm_descendants) do
		for j,w in ipairs({v:GetChildren()}) do
			table.insert(sdm_descendants, w)
		end
		sdm_mouseStates[i] = v:IsMouseEnabled()
		v:EnableMouse(false)
		i=i+1
	end
end

function sdm_thawEditFrame()
	for i,v in ipairs(sdm_descendants) do
		v:EnableMouse(sdm_mouseStates[i])
	end
end

function sdm_SaveConfirmationBox(postponed)
	if (not sdm_currentEdit) or sdm_macros[sdm_currentEdit].type=="c" or sdm_macros[sdm_currentEdit].text==sdm_bodyBox:GetText() then
		RunScript(postponed)
	else
		sdm_bodyBox:ClearFocus()
		StaticPopupDialogs["SDM_CONFIRM"] = {
			text = "Do you want to save your changes to "..sdm_currentTitle:GetText().."?",
			button1 = "Save", --left button
			button3 = "Don't Save", --middle button
			button2 = "Cancel", -- right button
			OnAccept = function() 
				sdm_Edit(sdm_macros[sdm_currentEdit], sdm_bodyBox:GetText()) 
				RunScript(postponed) 
			end, --button1 (left)
			OnAlt = function() 
				RunScript(postponed) 
			end, --button3 (middle)
			--OnCancel = , --button2 (right)
			OnShow = sdm_freezeEditFrame,
			OnHide = sdm_thawEditFrame,
			timeout = 0,
			whileDead =1
		}
		StaticPopup_Show("SDM_CONFIRM"):SetPoint("CENTER", "sdm_mainFrame", "CENTER")
	end
end

function sdm_ShowUsage(mTab)
	if sdm_UsedByThisChar(mTab) then
		if mTab.type=="b" then
			print(sdm_printPrefix.."To run this macro, drag the button from the list and place it on your action bar, or use "..string.format("%q", "/click sdb_"..mTab.name).." (case-sensitive).")
		elseif mTab.type=="f" then
			print(sdm_printPrefix.."To run this macro, use "..string.format("%q", "/click sdf_"..mTab.name).." (case-sensitive).")
		elseif mTab.type=="s" then
			print(sdm_printPrefix.."To run this script, use "..string.format("%q", "/sdm run "..mTab.name).." or use the function sdm_RunScript("..string.format("%q", mTab.name)..") (case-sensitive).")
		end
	else
		print(sdm_printPrefix.."You must be logged in as the appropriate character to run this.")
	end
end

function sdm_PickupMacro(ID)
	if sdm_macros[ID].type=="b" then
		PickupMacro(sdm_GetMacroIndex(ID))
	end
end

function sdm_Quit(append)
	local scriptOnQuit = "sdm_mainFrame:Hide() sdm_changeIconFrame:Hide()"
	if (not sdm_receiving) then
		scriptOnQuit = scriptOnQuit.." sdm_newFrame:Hide()"
		if (not sdm_sending) then
			scriptOnQuit = scriptOnQuit.." sdm_sendReceiveFrame:Hide()"
		end
	end
	if append then
		scriptOnQuit = scriptOnQuit..append
	end
	sdm_SaveConfirmationBox(scriptOnQuit)
end

function sdm_AddToRadioGroup(button, groupName)
	sdm_radioGroups = sdm_radioGroups or {}
	local group = sdm_radioGroups[groupName]
	if not group then
		sdm_radioGroups[groupName] = {}
		group = sdm_radioGroups[groupName]
	end
	tinsert(group, button)
	button.radioGroupName = groupName
	button:SetScript("OnClick", sdm_RadioButtonClicked)
end

function sdm_RadioButtonClicked(button)
	local group = sdm_radioGroups[button.radioGroupName]
	for _,b in pairs(group) do
		b:SetChecked(nil)
	end
	button:SetChecked(1)

	if button.radioGroupName == "NewType" then
		for _,b in pairs(sdm_radioGroups.NewChar) do
			if button == sdm_folderRadio then
				b:Hide()
			else
				b:Show()
			end
		end

	elseif button.radioGroupName == "SendTo" then
		if button == sdm_sendArbitraryRadio then
			sdm_sendInput:SetFocus()
		else
			sdm_sendInput:ClearFocus()
		end
	elseif button.radioGroupName == "ReceiveFrom" then
		if button == sdm_receiveArbitraryRadio then
			sdm_receiveInput:SetFocus()
		else
			sdm_receiveInput:ClearFocus()
		end
	end
end

function sdm_CreateMacroButtonClicked()
	local name = sdm_newMacroNameInput:GetText()
	local character
	if sdm_charspecRadio:GetChecked() then
		character = sdm_thisChar
	end

	local type
	if sdm_buttonRadio:GetChecked() then
		type="b"
	elseif sdm_floatingRadio:GetChecked() then
		type="f"
	elseif sdm_scriptRadio:GetChecked() then
		type="s"
	elseif sdm_folderRadio:GetChecked() then
		type="c"
		character = nil
	end

	if sdm_CheckCreationSafety(type, name, character) then
		local newMacro = sdm_CreateNew(type, name, character)
		sdm_newFrame:Hide()
		sdm_SelectItem(newMacro.ID)
	end
end

-- When any non-button frame in a given group is opened, all buttons in that group are disabled.
function sdm_AddToExclusiveGroup(f, group, isButton) --f is the frame, group is a key, button is a boolean that tells if it's a button or a window
	sdm_exclusiveGroups = sdm_exclusiveGroups or {} --contains groups of mutually exclusive frames
	if not sdm_exclusiveGroups[group] then
		sdm_exclusiveGroups[group] = {buttons={}, windows={}}
	end
	if isButton then
		table.insert(sdm_exclusiveGroups[group].buttons, f)
	else
		table.insert(sdm_exclusiveGroups[group].windows, f)
		f.exclusiveGroupKey = group
		f:HookScript("OnShow", sdm_ExclusiveWindowShown)
		f:HookScript("OnHide", sdm_ExclusiveWindowHidden)
	end
end

function sdm_ExclusiveWindowShown(f) --when a window in the group is shown, disable all buttons in the group, remembering which ones were disabled
	local t = sdm_exclusiveGroups[f.exclusiveGroupKey]
	t.isEnabled={}
	for _,button in pairs(t.buttons) do
		if button:IsEnabled()==1 then
			t.isEnabled[button]=true
			button:Disable()
		end
	end
	if f.exclusiveGroupKey=="centerwindows" then
		sdm_listLocked = true
	end
end

function sdm_ExclusiveWindowHidden(f) --reenable the buttons
	local t = sdm_exclusiveGroups[f.exclusiveGroupKey]
	for button in pairs(t.isEnabled) do
		button:Enable()
	end
	if f.exclusiveGroupKey=="centerwindows" then
		sdm_listLocked = false
	end
end

function sdm_MakeDraggable(f)
	f:EnableMouse(true)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", sdm_StartMove)
	f:SetScript("OnDragStop", sdm_StopMove)
end

function sdm_StartMove()
	if not sdm_mainFrameIsMoving then
		sdm_mainFrameIsMoving = true
		sdm_mainFrame:StartMoving()
	end
end

function sdm_StopMove()
	if sdm_mainFrameIsMoving then
		sdm_mainFrameIsMoving = false
		sdm_mainFrame:StopMovingOrSizing()
	end
end

function sdm_DefaultMacroFrameLoaded()
	sdm_macroUILoaded=true
	--select(6, MacroFrame:GetRegions()):SetPoint("TOP",MacroFrame, "TOP", 76, -17) -- Move the text "Create Macros" 76 units to the right.

	sdm_CreateDefaultMacroFrameButtons()

	hooksecurefunc("MacroFrame_Update", function() --This function prevents the user from messing with macros created by SDM.
		local selectedIsSDM = nil
		local globalTab = (MacroFrame.macroBase==0) --Is this the global tab or the character-specific tab?
		for i,v in pairs(sdm_macros) do
			if v.type=="b" and sdm_UsedByThisChar(v) and ((globalTab and v.characters==nil) or ((not globalTab) and v.characters)) then -- if this item is supposed to have a macro in this tab
				local index = sdm_GetMacroIndex(v.ID)
				local prefix = "MacroButton"..index-MacroFrame.macroBase
				if index == MacroFrame.selectedMacro then --The currently selected macro is a SDM macro.  Deselect it for now, then later select another one.
					selectedIsSDM = index-MacroFrame.macroBase
					_G[prefix]:SetChecked(nil)
					MacroFrame.selectedMacro = nil
					MacroFrame_HideDetails()
				end
				_G[prefix]:Disable()
				_G[prefix.."Icon"]:SetTexture("Interface\\AddOns\\SuperDuperMacro\\SDM-Icon.tga")
				_G[prefix.."Name"]:SetText("|cff000000SDM|r")
			end
		end
		if selectedIsSDM then
			local index=selectedIsSDM+1
			while index<=MacroFrame.macroMax do --if index exceeds this value, we know should stop because we've exceeded the number of slots on this pane.
				local buttonToCheck = _G["MacroButton"..index]
				if buttonToCheck:IsEnabled()==1 then
					buttonToCheck:Click()
					break
				end
				index=index+1
			end
		end
	end)
end

--[[ Interface-related Variables ]]--

sdm_iconSpacing=5/36
sdm_listLocked=false --if this is true, clicking on a macro in the SDM list will not select it.
if (IsAddOnLoaded("Blizzard_MacroUI")) then
	sdm_macroUILoaded=true --the default macro UI, which normally loads when you type /macro
	sdm_DefaultMacroFrameLoaded()
else
	sdm_macroUILoaded=false --the default macro UI, which normally loads when you type /macro
	sdm_eventFrame:RegisterEvent("ADDON_LOADED")
end
sdm_unusedListItems={}
sdm_listItems,sdm_unusedListItems[true],sdm_unusedListItems[false]={},{},{}
sdm_listItemPrefix = "sdm_macroListItem"

sdm_containerInstructionsString = [[
Left-click on a folder to open or close it.


To place an item into a folder, right-click on the item and then left-click on or in the folder.


To change the name of a folder, click the "Change Name/Icon" button (folders do not have icons).


Deleting a folder will move all of its contents into its parent folder.


To bring up these instructions and folder options, alt-click on a folder in the list.
]]
