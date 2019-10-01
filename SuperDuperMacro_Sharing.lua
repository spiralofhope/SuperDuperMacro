sdm_msgPrefix = 'SupDupMac'
sdm_msgPrefixLength = string.len( sdm_msgPrefix )
sdm_msgCommandLength = 1
sdm_msgLengthLimit = 254
sdm_msgCommands = {
	SendFirst = '1', -- I'm sending you the first part of a macro
	SendMore = '2', -- I'm sending you more of the macro
	SendFailed = '3', -- I failed to send you the macro
	Receiving = '4', -- I just received the first part of your macro
	ReceivingDone = '5', -- I just saved the macro that you sent me
	ReceivingFailed = '6', -- I failed to receive your macro
}

function sdm_OnUpdate(gself, elapsed ) -- used for sending macros
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed
	if self.TimeSinceLastUpdate > sdm_updateInterval then
		if sdm_sending.i == 2 then
			sdm_sending.command = sdm_msgCommands.SendMore
		end
		SendAddonMessage( sdm_msgPrefix, sdm_sending.command .. sdm_sending.lines[ sdm_sending.i ], sdm_sending.channel, sdm_sending.target )
		sdm_sendStatusBar:SetValue( sdm_sending.i )
		sdm_sending.i = sdm_sending.i+1
		if sdm_sending.i>sdm_sending.numLines then
			sdm_EndSending( "|cff44ff00Sent to " .. ( sdm_sending.target or sdm_sending.channel ) .. "|r" )
		end
		self.TimeSinceLastUpdate = 0
	end
end

function sdm_RegisterMessages()
	sdm_eventFrame:RegisterEvent( 'CHAT_MSG_ADDON' )
	local success = RegisterAddonMessagePrefix( sdm_msgPrefix )
	if not success then
		print( sdm_printPrefix .. 'You have too many addon prefixes registered. SDM will not be able to send or receive macros.' )
	end
end

-- create an invisible frame that is used to measure time
local f = CreateFrame( 'Frame', 'sdm_updateFrame', UIParent )
f:Hide()
f:SetScript( 'OnShow', function( self )
	self.TimeSinceLastUpdate = 0
end)
f:SetScript( 'OnUpdate', sdm_OnUpdate )

function sdm_SendMacro( mTab, chan, tar )
	if sdm_sending then
		print( sdm_printPrefix .. 'You are already sending something.' )
		return
	end
	print( sdm_printPrefix .. 'Sending to the following people (if nobody is listed, then nobody is waiting):' )
	sdm_RegisterMessages()
	local perCharacter = nil
	--make the string that will be split up and sent.  It consists of a bunch of values separated by commas.  They are, in order: the version the sender is running, the minimum version the receiver must have, the type of macro, the index of the icon, the perCharacter status ("<table value>" or "nil"), the length of the name, the length of the text, the name, and the text.  There is no comma between the name and the text.
	local textToSend = (
       sdm_version
    .. ','
    .. sdm_minVersion
    .. ','
    .. mTab.type
    .. ','
    .. tostring( mTab.icon )
    .. ','
    .. tostring( mTab.characters )
    .. ','
    .. mTab.name:len()
    .. ','
    .. mTab.text:len()
    .. ','
    .. mTab.name
    .. mTab.text
  )
	local comm = sdm_msgCommands.SendFirst -- if the command is SendFirst, it's the first part.  If it's SendMore, it's any part after the first.
	local lineLen = sdm_msgLengthLimit - sdm_msgPrefixLength - sdm_msgCommandLength
	local linesToSend={}
	local pos = 1
	while pos <= textToSend:len() do
		table.insert( linesToSend, textToSend:sub( pos, pos + lineLen - 1 ) )
		pos = pos+lineLen
	end
	sdm_sending={
		i=1,
		lines = linesToSend,
		numLines = getn( linesToSend ),
		channel = chan,
		target = tar,
		command = comm
	}
	sdm_sendStatusBar:SetMinMaxValues( 0, sdm_sending.numLines )
	sdm_sendStatusBar:SetValue( 0 )
	sdm_sendStatusBar_text:SetText( "|cffffccffSending to " .. (sdm_sending.target or sdm_sending.channel) .. "|r" )
	sdm_cancelSendButton:Enable()
	sdm_sendButton:Disable()
	sdm_sendPartyRadio:Disable()
	sdm_sendRaidRadio:Disable()
	sdm_sendBattlegroundRadio:Disable()
	sdm_sendGuildRadio:Disable()
	sdm_sendTargetRadio:Disable()
	sdm_sendArbitraryRadio:Disable()
	sdm_sendInput:EnableMouse( nil )
	sdm_updateFrame:Show()
end

function sdm_EndSending( text )
	sdm_updateFrame:Hide()
	sdm_sendStatusBar_text:SetText( text )
	sdm_sending = nil
	sdm_cancelSendButton:Disable()
	if sdm_currentEdit then
		sdm_sendButton:Enable()
	end
	sdm_sendPartyRadio:Enable()
	sdm_sendRaidRadio:Enable()
	sdm_sendBattlegroundRadio:Enable()
	sdm_sendGuildRadio:Enable()
	sdm_sendTargetRadio:Enable()
	sdm_sendArbitraryRadio:Enable()
	sdm_sendInput:EnableMouse( 1 )
end

function sdm_WaitForMacro( name )
	if sdm_receiving then
		print( sdm_printPrefix .. 'You are already receiving or waiting.' )
		return
	end
	sdm_RegisterMessages()
	sdm_receiving = { playerName=name, first = true }
	sdm_receiveStatusBar:SetValue( 0 )
	sdm_receiveStatusBar_text:SetText( "|cffffccffWaiting for " .. sdm_receiving.playerName .. "|r" )
	sdm_cancelReceiveButton:Enable()
	sdm_receiveButton:Disable()
	sdm_receiveTargetRadio:Disable()
	sdm_receiveArbitraryRadio:Disable()
	sdm_receiveAnyoneRadio:Disable()
	sdm_receiveInput:EnableMouse( nil )
	sdm_SelectItem( nil )
	sdm_newFrame:Show()
	sdm_newMacroNameInput:ClearFocus()
	sdm_newMacroNameInput:SetText( 'Receiving macro...' )
	sdm_newMacroNameInput:EnableMouse( nil )
	sdm_buttonRadio:Disable()
	sdm_floatingRadio:Disable()
	sdm_scriptRadio:Disable()
	sdm_globalRadio:Disable()
	sdm_charspecRadio:Disable()
	sdm_createMacroButton:Disable()
	sdm_saveAsText = nil
	sdm_saveAsIcon = nil
end

function sdm_InterpretAddonMessage( ... )
	--print( 'debug: interpreting' )
	local prefix, message, _, sender = ...
	if prefix ~= sdm_msgPrefix or sender == sdm_thisChar.name then
		return
	end
	local command = message:sub( 1, 1 )
	local txt=message:sub( 2 )
	if sdm_receiving and not sdm_receiving.text then
		if sdm_receiving.playerName == '<ANYONE>' and command == sdm_msgCommands.SendFirst then
			sdm_receiving.playerName = sender
		end
		if sender:upper() ~= sdm_receiving.playerName:upper() then
			return
		end
		if command == sdm_msgCommands.SendFirst then -- this is the first part of the macro (also contains data such as name and type)
			sdm_ReceiveLine( txt, true )
		elseif command == sdm_msgCommands.SendMore then -- this is some part other than the first
			sdm_ReceiveLine( txt, false )
		elseif command == sdm_msgCommands.SendFailed then -- this is a reason why the sender failed to send us the macro
			print( sdm_printPrefix .. sender .. ' failed to send the macro.  Reason: ' .. txt )
			sdm_EndReceiving( "|cffff0000Failed|r" )
		end
	elseif command == sdm_msgCommands.Receiving then
		print( sdm_printPrefix .. sender .. ' has begun to receive your macro...' )
	elseif command == sdm_msgCommands.ReceivingDone then -- the target has finished receiving
		print( sdm_printPrefix .. sender .. ' has accepted your macro.' )
	elseif command == sdm_msgCommands.ReceivingFailed then -- this is a reason why the recipient failed to receive our macro
		local version, reason = sdm_SplitString( txt, ',', 1 )
		print( sdm_printPrefix .. sender .. ' did not receive your macro.  Reason: ' .. reason )
	end
end

function sdm_ReceiveLine( line, send1 )
	--print( 'debug: in recline' )
	if sdm_receiving.first and send1 then --this is the first line
		sdm_receiving.nameAndText, sdm_receiving.textLen, sdm_receiving.playerNameLen, sdm_receiving.perCharacter, sdm_receiving.icon, sdm_receiving.type, sdm_receiving.minVersion, sdm_receiving.sendersVersion = sdm_SplitString( line, ',', 7 )
		sdm_receiving.perCharacter = ( sdm_receiving.perCharacter ~= 'nil' )
		if sdm_receiving.icon == 'nil' then
			sdm_receiving.icon = nil
		else
			sdm_receiving.icon = sdm_receiving.icon
		end
		sdm_receiving.textLen = 0 + sdm_receiving.textLen
		sdm_receiving.playerNameLen = 0 + sdm_receiving.playerNameLen
		sdm_receiving.first = false
		sdm_receiveStatusBar:SetMinMaxValues( 0, sdm_receiving.playerNameLen + sdm_receiving.textLen )
		sdm_receiveStatusBar_text:SetText( "|cffffccffReceiving|r" )
		if sdm_CompareVersions( sdm_receiving.sendersVersion, sdm_minVersion ) == 2
    or sdm_CompareVersions( sdm_version, sdm_receiving.minVersion ) == 2
    then
			print( sdm_printPrefix .. 'You failed to recieve the macro due to a version incompatibility.' )
			SendAddonMessage( sdm_msgPrefix, sdm_msgCommands.ReceivingFailed .. 'Incompatible Versions,' .. sdm_version, 'WHISPER', sdm_receiving.playerName )
			sdm_EndReceiving( "|cffff0000Failed|r" )
			return
		else
			SendAddonMessage( sdm_msgPrefix, sdm_msgCommands.Receiving .. sdm_version, 'WHISPER', sdm_receiving.playerName )
		end
	elseif ( not sdm_receiving.first ) and ( not send1 ) then
		sdm_receiving.nameAndText = sdm_receiving.nameAndText .. line
	else
		return
	end
	local currLen = sdm_receiving.nameAndText:len()
	sdm_receiveStatusBar:SetValue( currLen )
	if currLen == ( sdm_receiving.playerNameLen + sdm_receiving.textLen ) then
		sdm_receiveStatusBar_text:SetText( "|cffff9900Click \"Create\" to save|r" )
		UIFrameFlash( sdm_createMacroButton_flash, 0.5, 0.5, 1e6, false )
		sdm_newMacroNameInput:EnableMouse( 1 )
		sdm_buttonRadio:Enable()
		sdm_floatingRadio:Enable()
		sdm_scriptRadio:Enable()
		sdm_globalRadio:Enable()
		sdm_charspecRadio:Enable()
		sdm_createMacroButton:Enable()
		if sdm_receiving.type == 'b' then
			sdm_buttonRadio:Click()
		elseif sdm_receiving.type == 'f' then
			sdm_floatingRadio:Click()
		elseif sdm_receiving.type == 's' then
			sdm_scriptRadio:Click()
		end
		if sdm_receiving.perCharacter then
			sdm_charspecRadio:Click()
		else
			sdm_globalRadio:Click()
		end
		sdm_receiving.name=sdm_receiving.nameAndText:sub( 1, sdm_receiving.playerNameLen )
		sdm_newMacroNameInput:SetText( sdm_receiving.name )
		sdm_receiving.text=sdm_receiving.nameAndText:sub( sdm_receiving.playerNameLen+1,sdm_receiving.playerNameLen+sdm_receiving.textLen )
	end
end

function sdm_EndReceiving( text )
	sdm_receiveStatusBar_text:SetText( text )
	sdm_cancelReceiveButton:Disable()
	sdm_receiveButton:Enable()
	sdm_newButton:Enable()
	sdm_receiveTargetRadio:Enable()
	sdm_receiveArbitraryRadio:Enable()
	sdm_receiveAnyoneRadio:Enable()
	sdm_receiveInput:EnableMouse( 1 )
	sdm_newMacroNameInput:SetText( '' )
	sdm_newMacroNameInput:EnableMouse( 1 )
	sdm_buttonRadio:Enable()
	sdm_floatingRadio:Enable()
	sdm_scriptRadio:Enable()
	sdm_globalRadio:Enable()
	sdm_charspecRadio:Enable()
	sdm_createMacroButton:Enable()
	sdm_receiving = nil
end

function sdm_CancelSend()
	SendAddonMessage( sdm_msgPrefix, sdm_msgCommands.SendFailed .. 'Cancelled', sdm_sending.channel, sdm_sending.target )
	sdm_EndSending( "|cffff0000Cancelled|r" )
end

function sdm_CancelReceive()
	if sdm_receiving.playerName ~= '<ANYONE>' then
		SendAddonMessage( sdm_msgPrefix, sdm_msgCommands.ReceivingFailed .. 'Cancelled,' .. sdm_version, 'WHISPER', sdm_receiving.playerName )
	end
	sdm_EndReceiving( "|cffff0000Cancelled|r" )
	sdm_newFrame:Hide()
end

function sdm_SplitString( s, pattern, limit, ... ) -- iterates through "s", splitting it between occurrences of "pattern", and returning the split portions IN BACKWARDS ORDER. Splits a maximum of <limit> times (optional)
	if limit == 0 then
		return s, ...
	end
	local index = s:find( pattern )
	if ( not index ) then
		return s, ...
	end
	return sdm_SplitString( s:sub( index+pattern:len() ), pattern, limit - 1, s:sub( 1, index - 1 ), ... )
end

function sdm_SendButtonClicked()
	local channel
	local target
	if sdm_sendPartyRadio:GetChecked() then
		channel='PARTY'
	elseif sdm_sendRaidRadio:GetChecked() then
		channel='RAID'
	elseif sdm_sendBattlegroundRadio:GetChecked() then
		channel='BATTLEGROUND'
	elseif sdm_sendGuildRadio:GetChecked() then
		channel='GUILD'
	elseif sdm_sendTargetRadio:GetChecked() then
		channel='WHISPER'
		if UnitIsPlayer( 'target' ) then
			target, realm = UnitName( 'target' )
			if realm and realm ~= '' then
				target = target .. '-' .. realm
			end
		end
	elseif sdm_sendArbitraryRadio:GetChecked() then
		channel='WHISPER'
		target=sdm_sendInput:GetText()
	end
	if channel == 'WHISPER' and ( ( not target ) or target == '' or target == sdm_thisChar.name ) then
		return
	end
	sdm_sendInput:ClearFocus()
	sdm_SendMacro( sdm_macros[ sdm_currentEdit ], channel, target )
end

function sdm_ReceiveButtonClicked()
	local sender
	if sdm_receiveTargetRadio:GetChecked() then
		if UnitIsPlayer( 'target' ) then
			sender, realm = UnitName( 'target' )
			if realm and realm ~= '' then
				sender = sender .. '-' .. realm
			end
		end
	elseif sdm_receiveArbitraryRadio:GetChecked() then
		sender=sdm_receiveInput:GetText()
	elseif sdm_receiveAnyoneRadio:GetChecked() then
		sender = '<ANYONE>'
	end
	if ( ( not sender ) or sender == '' or sender == sdm_thisChar.name ) then return end
	sdm_receiveInput:ClearFocus()
	sdm_SaveConfirmationBox( 'sdm_WaitForMacro(' .. sdm_Stringer(sender) .. ')' )
end

sdm_sending = nil --info about the macro you're trying to send
sdm_receiving = nil --info about the macro you're receiving (or waiting to receive)
sdm_updateInterval=0.25 --can be as low as 0.01 and still work, but it might disconnect you if there are other addons sending out messages too.  0.25 is slower but safer.
sdm_minVersion='2.4' --the oldest version that is compatible with this one for exchanging macros
