Combuctor_CustomSets = {}
local cSets = Combuctor_CustomSets
local CombuctorSet, LIS
local BagData, Temp, allbags = {}, {}, {KEYRING_CONTAINER, BACKPACK_CONTAINER, 1, 2, 3, 4, BANK_CONTAINER, 5, 6, 7, 8, 9, 10}
local MAX_SETS, SELECTED_SET, ScrollShift = 1, 1, 1

local L = COMBUCTOR_CUSTOMSETS_LOCALE

StaticPopupDialogs["COMBUCTOR_CUSTOMSETS_POPUP"] = {
  text = L.notice,
  button1 = L.ok,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
  showAlert = true,
}

function cSets:Initialize()
	if (Combuctor and Combuctor ~= nil) then
		CombuctorSet = Combuctor:GetModule('Sets')	
		LIS = LibStub('LibItemSearch-1.0')
		local f = CreateFrame('Frame', nil)
		f:SetScript("OnEvent", function(self, event, arg1) 
			if (arg1=="Combuctor_Config") then 
				cSets:CreateOptions() 
			elseif (arg1=="Combuctor_CustomSets") then
				MAX_SETS = #CustomSetsDB["sets"]
				for i=1,MAX_SETS do
					if (CustomSetsDB["sets"][i]["enabled"] == true) then
						cSets:EnableSet(i)
					end
				end
				print(L.load)
			end 
			end)
		f:RegisterEvent("ADDON_LOADED")
	else
		print(L.notfound)
	end
end

function cSets:CreateOptions()
	if not cSets.options then
		cSets.options = true
		local opt = CreateFrame("Frame")
		opt.name = L.custom
		opt.parent = "Combuctor"
		opt:SetScript("OnShow", function(self)
			cSets:CreateFrames(self)
			self:SetScript("OnShow", nil)
		end)
		InterfaceOptions_AddCategory(opt)
	end
end

function cSets:GetItemId(link)
	if link and link ~= nil then
		local found, _, itemString = string.find(link, "^|c%x+|H(.+)|h%[.*%]")
		local _, itemId, enchantId, jewelId1, jewelId2, jewelId3, jewelId4, suffixId, uniqueId, linkLevel = strsplit(":", itemString)
		return tonumber(itemId)
	else
		return nil
	end
end

function cSets:MakeEditBox(name, parent, relativeto, x, y, w, tooltip, disabletexture)
	local edit = CreateFrame("EditBox", name, parent)
	edit:SetHeight(32)
	edit:SetWidth(w)
	edit:SetAutoFocus(false)
	edit:SetPoint("TOPLEFT", relativeto, "TOPLEFT", x, y)
	edit:SetMaxLetters(128)
	edit:ClearFocus()
	if (tooltip) then
		edit:SetScript( "OnEnter", function()
				GameTooltip:SetOwner( edit, "ANCHOR_RIGHT" )
				GameTooltip:SetText( tooltip, nil, nil, nil, nil, 1 )
			end )
		edit:SetScript( "OnLeave", function() GameTooltip:Hide() end )
	end
	edit:SetFontObject(ChatFontNormal)
	if (not disabletexture) then
		local left = edit:CreateTexture(nil, "ARTWORK")
		left:SetWidth(8) left:SetHeight(20)
		left:SetPoint("LEFT", -5, 0)
		left:SetTexture("Interface\\Common\\Common-Input-Border")
		left:SetTexCoord(0, 0.0625, 0, 0.625)
		local right = edit:CreateTexture(nil, "ARTWORK")
		right:SetWidth(8) right:SetHeight(20)
		right:SetPoint("RIGHT", 0, 0)
		right:SetTexture("Interface\\Common\\Common-Input-Border")
		right:SetTexCoord(0.9375, 1, 0, 0.625)
		local center = edit:CreateTexture(nil, "ARTWORK")
		center:SetHeight(20)
		center:SetPoint("RIGHT", right, "LEFT", 0, 0)
		center:SetPoint("LEFT", left, "RIGHT", 0, 0)
		center:SetTexture("Interface\\Common\\Common-Input-Border")
		center:SetTexCoord(0.0625, 0.9375, 0, 0.625)
	end
	return edit
end

function cSets:MakeItemIcon( name, w, h, parent, rto, xof, yof, tex )
	local b = CreateFrame( "Button", name, parent )
	b:SetPoint("TOPLEFT", rto, "TOPLEFT", xof, yof)
	b:SetHeight(h+2)
	b:SetWidth(w+2)
	b.bg = b:CreateTexture(nil, "ARTWORK")
	b.bg:SetWidth(w) b.bg:SetHeight(h)
	b.bg:SetPoint("TOPLEFT", 1, -1)
	b.bg:SetTexture(tex)
	b.bg.ico = b
	b:SetHighlightTexture("Interface\\Buttons\\CheckButtonHilight")
	b:RegisterForClicks( "AnyUp" )
	return b
end

function cSets:MakeItemWide( name, w, h, parent, rto, xof, yof, tex, text )
	local b = CreateFrame( "Button", name, parent )
	b:SetPoint("TOPLEFT", rto, "TOPLEFT", xof, yof)
	b:SetHeight(h)
	b:SetWidth(w)
	b.bg = b:CreateTexture(nil, "ARTWORK")
	b.bg:SetWidth(h) b.bg:SetHeight(h)
	b.bg:SetPoint("TOPLEFT", 1, -1)
	b.bg:SetTexture(tex)
	b:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight")
	b.text = b:CreateFontString(nil, "ARTWORK", "GameFontWhite")
	b.text:SetPoint("TOPLEFT", b, "TOPLEFT", h+2, -2)
	b.text:SetText(text)
	b.text:SetWidth(w-h)
	b.text:SetHeight(h-2)
	b.text:SetJustifyH("LEFT")
	b:RegisterForClicks( "AnyUp" )
	return b
end

function cSets:ShowSearchHelp()
	-- yeah, this is bad and not localized!
	GameTooltip:AddLine("Search Syntax")
	GameTooltip:AddLine("Keyword Search")
	GameTooltip:AddDoubleLine("word", "Returns all items with \"word\"", 1,1,1, 0.5,0.5,1)
	GameTooltip:AddDoubleLine("  ", "in item name, quality or type", 1,1,1, 0.5,0.5,1)
	GameTooltip:AddLine("Other Searches")
	GameTooltip:AddDoubleLine("t:<key>", "Type Search, \"Trade Goods\" etc.", 1,1,1, 0.5,0.5,1)
	GameTooltip:AddDoubleLine("q:<key>", "Quality, 1 = Poor, 2 = Common, etc.", 1,1,1, 0.5,0.5,1)
	GameTooltip:AddDoubleLine("ilvl:<key>", "Search by item level", 1,1,1, 0.5,0.5,1)
	GameTooltip:AddDoubleLine("s:<key>", "Search in a equipment set", 1,1,1, 0.5,0.5,1)
	GameTooltip:AddLine("Combined searches")
	GameTooltip:AddDoubleLine("!<search>", "Negation", 1,1,1, 0.5,0.5,1)
	GameTooltip:AddDoubleLine("<search> & <search>", "Intersection", 1,1,1, 0.5,0.5,1)
	GameTooltip:AddDoubleLine("<search> | <search>", "Union", 1,1,1, 0.5,0.5,1)
	GameTooltip:AddLine("Operators (Can be used within searches)")
	GameTooltip:AddDoubleLine(": or = or ==", "equals to", 1,1,1, 0.5,0.5,1)
	GameTooltip:AddDoubleLine("!= or ~=", "doesn't equal to", 1,1,1, 0.5,0.5,1)
	GameTooltip:AddDoubleLine("< ( or <= )", "smaller than (or equals to)", 1,1,1, 0.5,0.5,1)
	GameTooltip:AddDoubleLine("> ( or >= )", "larger than (or equals to)", 1,1,1, 0.5,0.5,1)
	GameTooltip:AddLine("Examples")
	GameTooltip:AddDoubleLine("q:4", "All epics", 1,1,1, 0.5,0.5,1)
	GameTooltip:AddDoubleLine("ilvl>213", "Items with ilevel larger than 213", 1,1,1, 0.5,0.5,1)
	GameTooltip:AddDoubleLine("t:consumable&q:5", "All legendary consumables", 1,1,1, 0.5,0.5,1)
	GameTooltip:AddDoubleLine("q:0|q:4", "Items with poor or epic quality ", 1,1,1, 0.5,0.5,1)
	GameTooltip:AddDoubleLine("q:4&!Solace", "All epics exept the ones with", 1,1,1, 0.5,0.5,1);
	GameTooltip:AddDoubleLine("  ", "\"Solace\" in their names", 1,1,1, 0.5,0.5,1)
	GameTooltip:AddLine("Better help will be included in a later version")
end

local function ClipTextures(button)
	local r = {button:GetRegions()}
	for i=1,#r do
	   if r[i]:IsObjectType("Texture") then
		  r[i]:SetTexCoord(0.2, 0.8, 0.2, 0.8)
	   end
	end
end

function cSets:InitDropDown(dropDown)
    UIDropDownMenu_Initialize( dropDown,
        function()
            for i=1,MAX_SETS do
                local info = UIDropDownMenu_CreateInfo()
                info.text = CustomSetsDB["sets"][i]["name"]
                info.value = i
                info.owner = dropDown
                info.func = function()
                                UIDropDownMenu_SetSelectedValue( dropDown, i )
                                cSets:UpdateOptionsFrame(i)
								cSets:UpdateSetContents(i, ScrollShift)
                            end
                UIDropDownMenu_AddButton( info, 1 )
            end
        end )
end

function cSets:CreateFrames(self)
	cSets.option = {}
	local text = self:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	text:SetPoint("TOPLEFT", 16, -16, self)
	text:SetText("Combuctor "..L.custom)

	-- set drop down and new/delete buttons...
	local t2 = self:CreateFontString(nil, "ARTWORK", "GameFontWhite")
	t2:SetPoint("TOPLEFT", text, "BOTTOMLEFT", 0, -10)
	t2:SetText(L.choose)
	local dropDown = CreateFrame( "Frame", "cCSetsDropDown", self, "UIDropDownMenuTemplate" )
    dropDown:SetPoint( "TOPLEFT", t2, "BOTTOMLEFT", 5, -5 )
    dropDown:SetWidth( 120 )
    dropDown:SetHeight( 22 )
	cSets:InitDropDown(dropDown)	
    UIDropDownMenu_SetSelectedValue( dropDown, 1 )
	local newSet = CreateFrame( "Button", "cSetsAddButton", self, "GameMenuButtonTemplate" )
	newSet:SetPoint("TOPLEFT", dropDown, "TOPRIGHT", 40, -2)
	newSet:SetText(L.setNew)
	newSet:SetWidth(newSet:GetTextWidth() + 40)
	newSet:SetHeight(newSet:GetTextHeight() + 12)
    newSet:SetScript( "OnEnter", function()
            GameTooltip:SetOwner( newSet, "ANCHOR_RIGHT" )
            GameTooltip:SetText( L.tipSetNew , nil, nil, nil, nil, 1 )
        end )
	newSet:SetScript( "OnClick",
        function()
			if ( cSets:AppendSet() ) then
				cSets:InitDropDown(dropDown)
				UIDropDownMenu_SetSelectedValue(dropDown, MAX_SETS)
				cSets:UpdateOptionsFrame(MAX_SETS)
				cSets:UpdateSetContents(MAX_SETS, ScrollShift)
			end
        end )	
	local deleteSet = CreateFrame( "Button", "cSetsDeleteButton", self, "GameMenuButtonTemplate" )
	deleteSet:SetPoint("TOPLEFT", newSet, "TOPRIGHT", 5, 0)
	deleteSet:SetText(L.setDelete)
	deleteSet:SetWidth(deleteSet:GetTextWidth() + 40)
	deleteSet:SetHeight(deleteSet:GetTextHeight() + 12)
    deleteSet:SetScript( "OnEnter", function()
            GameTooltip:SetOwner( deleteSet, "ANCHOR_RIGHT" )
            GameTooltip:SetText( L.tipSetDelete , nil, nil, nil, nil, 1 )
        end )
	deleteSet:SetScript( "OnClick",
        function()
			if ( cSets:DeleteSet(SELECTED_SET) ) then
				cSets:InitDropDown(dropDown)
				if ( SELECTED_SET > MAX_SETS ) then
					SELECTED_SET = MAX_SETS
				end
				UIDropDownMenu_SetSelectedValue(dropDown, SELECTED_SET)
				cSets:UpdateOptionsFrame(SELECTED_SET)
				cSets:UpdateSetContents(SELECTED_SET, ScrollShift)
			end
        end )	

	local f = CreateFrame("Frame", "cSetsBgFrame", self)
	f:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
	        edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
	        tile = true, tileSize = 16, edgeSize = 16, 
	        insets = { left = 4, right = 4, top = 4, bottom = 4 }})
	f:SetBackdropColor(1,1,1,0.2)
	f:SetBackdropBorderColor(1,1,1,0.3)
	f:SetPoint("TOPLEFT", self, "TOPLEFT", 10, -95)
	f:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -10, 10)
	local b1 = cSets:MakeItemIcon( "cCSetsIcon", 32, 32, self, f, 10, -10, "Interface\\Icons\\INV_Misc_QuestionMark" )
	b1:SetScript( "OnEnter", function()
            GameTooltip:SetOwner( b1, "ANCHOR_RIGHT" )
            GameTooltip:SetText( L.tipicon , nil, nil, nil, nil, 1 )
		end )
	b1:SetScript( "OnLeave", function() GameTooltip:Hide() end )

	-- name frame
	local t3 = f:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	t3:SetPoint("TOPLEFT", b1, "TOPRIGHT", 8, 0)
	t3:SetText(L.name)
	local editBox = cSets:MakeEditBox("cSetsEditBox", self, t3, 4, -9, 140, L.name2)
	editBox:SetText(CustomSetsDB["sets"][SELECTED_SET]["name"])
	editBox:SetScript("OnEnterPressed", function(self) CustomSetsDB["sets"][SELECTED_SET]["name"] = self:GetText() self:ClearFocus() end)
	editBox:SetScript("OnEscapePressed", function(self) CustomSetsDB["sets"][SELECTED_SET]["name"] = self:GetText() self:ClearFocus() end)
	editBox:SetScript("OnTextChanged", function(self) 
		if (CustomSetsDB["sets"][SELECTED_SET]["enabled"] == true) then
			self:SetText(CustomSetsDB["sets"][SELECTED_SET]["name"])
			if (self:HasFocus()) then
				StaticPopup_Show("COMBUCTOR_CUSTOMSETS_POPUP",L.error1)
			end
		else
			CustomSetsDB["sets"][SELECTED_SET]["name"] = self:GetText() 
		end
	end)
	editBox:SetMaxLetters(30)
	local checkBox = CreateFrame( "CheckButton", "cCSetsEnabledBox", self, "OptionsCheckButtonTemplate" )
    checkBox:SetWidth( 30 )
    checkBox:SetHeight( 30 )
    checkBox:SetChecked( CustomSetsDB["sets"][SELECTED_SET]["enabled"] )
    checkBox:SetPoint( "TOPLEFT", t3, "TOPLEFT", 160, 0 )
	local eText = _G["cCSetsEnabledBoxText"]
    eText:SetText( L.enabled )
    checkBox:RegisterForClicks( "AnyUp" )
    checkBox:SetScript( "OnEnter", function()
            GameTooltip:SetOwner( checkBox, "ANCHOR_RIGHT" )
            GameTooltip:SetText( L.tipset , nil, nil, nil, nil, 1 )
        end )
    checkBox:SetScript( "OnLeave", function() GameTooltip:Hide() end )
	checkBox:SetScript( "OnClick",
        function()
			if (checkBox:GetChecked() == 1) then
				if not CombuctorSet:Get(CustomSetsDB["sets"][SELECTED_SET]["name"]) then
					CustomSetsDB["sets"][SELECTED_SET]["enabled"] = true
					cSets:EnableSet(SELECTED_SET)
				else
					checkBox:SetChecked(false)
					StaticPopup_Show("COMBUCTOR_CUSTOMSETS_POPUP", format("There is already a set named %s!",CustomSetsDB["sets"][SELECTED_SET]["name"]))
				end
			else
				CustomSetsDB["sets"][SELECTED_SET]["enabled"] = false
				cSets:DisableSet(SELECTED_SET)
			end
        end )	
	
	-- item search frame
	local f2 = CreateFrame("Frame", "cSetsSearchFrame", self)
	f2:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
	        edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
	        tile = true, tileSize = 16, edgeSize = 16, 
	        insets = { left = 4, right = 4, top = 4, bottom = 4 }})
	f2:SetBackdropColor(0,0,0,0.2)
	f2:SetBackdropBorderColor(1,1,1,0.3)
	f2:SetPoint("TOPLEFT", f, "TOPLEFT", 5, -70)
	f2:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -5, 5)
	f2:SetFrameLevel(f:GetFrameLevel()+1)
	local editBox2 = cSets:MakeEditBox("cSetsEditBox", f2, f2, 14, -13, 200, L.search2)
	editBox2:SetScript("OnEnterPressed", function(self) cSets:SearchBagData(self) self:ClearFocus() end)
	editBox2:SetScript("OnEscapePressed", function(self) cSets:SearchBagData(self) self:ClearFocus() end)
	editBox2:SetScript("OnTextChanged", function(self) cSets:SearchBagData(self) end)
	local info = CreateFrame( "Button", "cSetsInfoButton", f2, "GameMenuButtonTemplate" )
	info:SetPoint("TOPLEFT", editBox2, "TOPRIGHT", 6, -6)
	info:SetHeight(22)
	info:SetWidth(22)
	info:SetText("?")
	info:SetScript( "OnEnter", function()
            GameTooltip:SetOwner( info, "ANCHOR_RIGHT" )
			GameTooltip:ClearLines()
            cSets:ShowSearchHelp()
			GameTooltip:Show()
        end )
    info:SetScript( "OnLeave", function() GameTooltip:Hide() end )
	local t4 = f2:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	t4:SetPoint("TOPLEFT", f2, "TOPLEFT", 8, -6)
	t4:SetText(L.search)
	
	-- item search results
	icons = {}
	texts = {}
	for i=1,18 do
		local o,y
		if i > 9 then o = 180 else o = 0 end
		if i > 9 then y = i-9 else y = i end
		local ii = cSets:MakeItemWide( format("cCSetsItemIcon%d", i), 175, 20, f2, f2, 10+o, -((1+y)*22), "Interface\\Icons\\INV_Misc_QuestionMark", "ph" )
		ii:SetScript( "OnClick", function(self, btn)
			if (btn == "LeftButton") then
				cSets:AddItem(SELECTED_SET, cSets:GetItemId(self.link))	
				cSets:SearchBagData(editBox2)
				cSets:UpdateSetContents(SELECTED_SET, ScrollShift)
			elseif (btn == "RightButton") then
				local icon = self.bg:GetTexture()
				cSets:SetCurrentIcon(icon)
			end
		end )
		ii:SetScript( "OnEnter", function()
				GameTooltip:SetOwner( ii, "ANCHOR_LEFT" )
				GameTooltip:SetHyperlink( ii.link )
				GameTooltip:AddLine(format(L.tipadd,CustomSetsDB["sets"][SELECTED_SET]["name"]))
				GameTooltip:AddLine(L.tipadd2)
				GameTooltip:Show()
		end )
		ii:SetScript( "OnLeave", function() GameTooltip:Hide() end )		
		ii:Hide()
		icons[i] = ii
		texts[i] = ii.text
	end
	
	-- item delete frame
	local f3 = CreateFrame("Frame", "cSetsDeleteFrame", self)
	f3:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
	        edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
	        tile = true, tileSize = 16, edgeSize = 16, 
	        insets = { left = 4, right = 4, top = 4, bottom = 4 }})
	f3:SetBackdropColor(0,0,0,0.2)
	f3:SetBackdropBorderColor(1,1,1,0.3)
	f3:SetPoint("TOPLEFT", f, "TOPLEFT", 5, -70)
	f3:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -5, 5)
	f3:SetFrameLevel(f:GetFrameLevel()+1)
	f3:Hide()
	
	--set contents
	f3t = f3:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	f3t:SetPoint("TOPLEFT", f3, "TOPLEFT", 6, -6)
	f3t:SetText(L.delitem)
	local wides = {}
	for i=1, 13 do
		local iw = cSets:MakeItemWide( format("cCSetsSetItem%d", i), 330, 16, f3, f3, 5, -5-(i*17), "Interface\\Icons\\INV_Misc_QuestionMark", "Item name slot asd" )
		iw:SetScript( "OnClick", function(self, btn)
			if (btn == "LeftButton") then
				cSets:DelItem(SELECTED_SET, cSets:GetItemId(self.link))
				cSets:UpdateSetContents(SELECTED_SET, ScrollShift)	
				cSets:SearchBagData(editBox2)
			elseif (btn == "RightButton") then
				local icon = self.bg:GetTexture()
				cSets:SetCurrentIcon(icon)
			end
			end )
		iw:SetScript( "OnEnter", function()
				GameTooltip:SetOwner( iw, "ANCHOR_LEFT" )
				GameTooltip:SetHyperlink( iw.link )
				GameTooltip:AddLine(format(L.tipdel,CustomSetsDB["sets"][SELECTED_SET]["name"]))
				GameTooltip:AddLine(L.tipadd2)
				GameTooltip:Show()
			end )
		iw:SetScript( "OnLeave", function() GameTooltip:Hide() end )
		iw:EnableMouseWheel(true) 
		iw:SetScript("OnMouseWheel",function(self,dir) cSets:OnMouseWheel(self,dir) end)
		wides[i] = iw
		iw:Hide()
	end
	
	--scrollbar (yeah, using slider and weird stuff, easier to handle)
	local scrollBar = CreateFrame("Slider", "cSetsScrollBar", f3)
	scrollBar:SetPoint("TOPLEFT", f3, "TOPLEFT", 330, -33)
	scrollBar:SetMinMaxValues(1, 10)
	scrollBar:SetValueStep(1)
	scrollBar:SetValue(1)
	scrollBar:SetOrientation("VERTICAL")
	scrollBar:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
	scrollBar:SetHeight(200)
	scrollBar:SetWidth(22)
	scrollBar:Disable()
	scrollBar:Show()
	scrollBar:EnableMouseWheel(true) 
	scrollBar:SetScript("OnValueChanged",function(self) cSets:ScrollBarUpdate(self) end)
	scrollBar:SetScript("OnMouseWheel",function(self,dir) cSets:OnMouseWheel(self,dir) end)
	local up = CreateFrame("Button", "cSetsUpSlider", f3, "UIPanelButtonTemplate")
	up:SetHeight(22)
	up:SetWidth(22)
	up:SetPoint("BOTTOM", scrollBar, "TOP", 0, -8)
	up:SetNormalTexture("Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Up")
	up:SetPushedTexture("Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Down")
	up:SetHighlightTexture("Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Highlight")
	up:SetDisabledTexture("Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Disabled")
	local down = CreateFrame("Button", "cSetsDownSlider", f3, "UIPanelButtonTemplate")
	down:SetHeight(22)
	down:SetWidth(22)
	down:SetPoint("TOP", scrollBar, "BOTTOM", 0, 8)
	down:SetNormalTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Up")
	down:SetPushedTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Down")
	down:SetHighlightTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Highlight")
	down:SetDisabledTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Disabled")
	ClipTextures(up)
	ClipTextures(down)
	scrollBar.down = down
	scrollBar.up = up
	up:RegisterForClicks( "AnyUp" )
	down:RegisterForClicks( "AnyUp" )
	up:SetScript("OnClick",function(self) cSets:OnMouseWheel(self,1) end)
	down:SetScript("OnClick",function(self) cSets:OnMouseWheel(self,-1) end)
	
	-- item search string frame
	local f4 = CreateFrame("Frame", "cSetsStringFrame", self)
	f4:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
	        edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
	        tile = true, tileSize = 16, edgeSize = 16, 
	        insets = { left = 4, right = 4, top = 4, bottom = 4 }})
	f4:SetBackdropColor(0,0,0,0.2)
	f4:SetBackdropBorderColor(1,1,1,0.3)
	f4:SetPoint("TOPLEFT", f, "TOPLEFT", 5, -70)
	f4:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -5, 5)
	f4:SetFrameLevel(f:GetFrameLevel()+1)
	f4:Hide()
	
	-- definition frame contents
	local scrollf = CreateFrame("ScrollFrame", "cSetsDefineScroll", f4, "UIPanelScrollFrameTemplate")
	scrollf:SetPoint("TOPLEFT", f4, "TOPLEFT", 10, -10)
	scrollf:SetPoint("BOTTOMRIGHT", f4, "TOPLEFT", 320, -80)
	scrollf:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
	        edgeFile = nil, 
	        tile = true, tileSize = 16, edgeSize = 16, 
	        insets = { left = 0, right = 0, top = 0, bottom = 0 }})
	scrollf:SetBackdropColor(0,0,0,0.8)
	scrollf:SetBackdropBorderColor(1,1,1,0.8)
	local editBox3 = cSets:MakeEditBox("cSetsDefineBox", scrollf, scrollf, 0, 0, 320, nil, true)
	editBox3:SetMultiLine(true)
	editBox3:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
	editBox3:SetScript("OnTextChanged", function(self) 
		if (CustomSetsDB["sets"][SELECTED_SET]["enabled"] == true) then
			self:SetText(CustomSetsDB["sets"][SELECTED_SET]["define"])
			if (self:HasFocus()) then
				StaticPopup_Show("COMBUCTOR_CUSTOMSETS_POPUP",L.error2)
			end
		else
			cSets:UpdateExample(self)
		end
	end)
	scrollf:SetScrollChild(editBox3)
	editBox3:SetMaxLetters(12800)
	scrollf:EnableMouse(true)
	scrollf:SetScript( "OnMouseDown", function() editBox3:SetFocus() end )
	local info2 = CreateFrame( "Button", "cSetsInfoButton2", f4, "GameMenuButtonTemplate" )
	info2:SetPoint("TOPLEFT", scrollf, "TOPRIGHT", 30, 3)
	info2:SetHeight(22)
	info2:SetWidth(22)
	info2:SetText("?")
	info2:SetScript( "OnEnter", function()
            GameTooltip:SetOwner( info2, "ANCHOR_RIGHT" )
			GameTooltip:ClearLines()
            cSets:ShowSearchHelp()
			GameTooltip:Show()
        end )
    info2:SetScript( "OnLeave", function() GameTooltip:Hide() end )
	local dtext = f4:CreateFontString(nil, "ARTWORK", "GameFontWhiteSmall")
	dtext:SetPoint("TOPLEFT", scrollf, "BOTTOMLEFT", 5, -5)
	dtext:SetText(L.definehelp)
	dtext:SetWidth(360)
	dtext:SetJustifyH("LEFT")
	dtext:SetJustifyV("TOP")
	local dtext2 = f4:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	dtext2:SetPoint("TOPLEFT", dtext, "BOTTOMLEFT", 0, -3)
	dtext2:SetText(L.test)
	icons2 = {}
	texts2 = {}
	for i=1,8 do
		local o,y
		if i > 4 then o = 180 else o = 0 end
		if i > 4 then y = i-4 else y = i end
		local ii = cSets:MakeItemWide( format("cCSetsItemIcon%d", i), 175, 20, f4, dtext2, o+3, 4-(y*22), "Interface\\Icons\\INV_Misc_QuestionMark", "ph" )
		ii:SetScript( "OnClick", function(self, btn)
			if (btn == "RightButton") then
				local icon = self.bg:GetTexture()
				cSets:SetCurrentIcon(icon)
			end
		end )
		ii:SetScript( "OnEnter", function()
				GameTooltip:SetOwner( ii, "ANCHOR_LEFT" )
				GameTooltip:SetHyperlink( ii.link )
				GameTooltip:AddLine(L.tipadd2)
				GameTooltip:Show()
		end )
		ii:SetScript( "OnLeave", function() GameTooltip:Hide() end )		
		ii:Hide()
		icons2[i] = ii
		texts2[i] = ii.text
	end
	
	-- tabs
	local tab3 = CreateFrame("Button", "cSetsTab3", self, "OptionsFrameTabButtonTemplate")
	tab3:SetPoint("TOPLEFT", f, "TOPLEFT", 10, -47)
	tab3:SetFrameLevel(f:GetFrameLevel()+1)
	tab3:SetText(L.tab3)
	local tab1 = CreateFrame("Button", "cSetsTab1", self, "OptionsFrameTabButtonTemplate")
	tab1:SetPoint("LEFT", tab3, "RIGHT", -5, 0)
	tab1:SetFrameLevel(f:GetFrameLevel()+1)
	tab1:SetText(L.tab1)
	local tab2 = CreateFrame("Button", "cSetsTab2", self, "OptionsFrameTabButtonTemplate")
	tab2:SetPoint("LEFT", tab1, "RIGHT", -5, 0)
	tab2:SetFrameLevel(f:GetFrameLevel()+1)
	tab2:SetText(L.tab2)
	PanelTemplates_TabResize(tab3, 0)
	PanelTemplates_TabResize(tab1, 0)
	PanelTemplates_TabResize(tab2, 0)
	tab1:RegisterForClicks( "AnyUp" ) tab2:RegisterForClicks( "AnyUp" ) tab3:RegisterForClicks( "AnyUp" )
	tab1:SetScript( "OnClick",
        function()
            PanelTemplates_SelectTab(tab1)
			PanelTemplates_DeselectTab(tab2)
			PanelTemplates_DeselectTab(tab3)
			f2:Show()
			f3:Hide()
			f4:Hide()
			PlaySound("igCharacterInfoTab")
        end )
	tab2:SetScript( "OnClick",
        function()
            PanelTemplates_SelectTab(tab2)
			PanelTemplates_DeselectTab(tab1)
			PanelTemplates_DeselectTab(tab3)
			f3:Show()
			f2:Hide()
			f4:Hide()
			PlaySound("igCharacterInfoTab")
			cSets:ScrollBarUpdate(scrollBar)
        end )
	tab3:SetScript( "OnClick",
        function()
            PanelTemplates_SelectTab(tab3)
			PanelTemplates_DeselectTab(tab1)
			PanelTemplates_DeselectTab(tab2)
			f4:Show()
			f2:Hide()
			f3:Hide()
			PlaySound("igCharacterInfoTab")
        end )
	PanelTemplates_DeselectTab(tab2)
	PanelTemplates_DeselectTab(tab1)
	-- end stuff	
	cSets.option["name"] = editBox
	cSets.option["define"] = editBox3
	cSets.option["enabled"] = checkBox
	cSets.option["icon"] = b1.bg
	cSets.option["icons"] = icons
	cSets.option["texts"] = texts
	cSets.option["icons2"] = icons2
	cSets.option["texts2"] = texts2
	cSets.option["wides"] = wides
	cSets.option["tabs"] = {tab1,tab2,tab3}
	cSets.option["frames"] = {f2,f3,f4}
	cSets.option["scroll"] = scrollBar
	cSets:UpdateOptionsFrame(1)
	cSets:UpdateSetContents(1, ScrollShift)
end

function cSets:SetCurrentIcon(icon)
	if (CustomSetsDB["sets"][SELECTED_SET]["enabled"] == true) then
		StaticPopup_Show("COMBUCTOR_CUSTOMSETS_POPUP",L.error1)
	else
		CustomSetsDB["sets"][SELECTED_SET]["icon"] = icon
		cSets.option["icon"]:SetTexture(icon)
	end
end

function cSets:OnMouseWheel(self, dir)
	local setc = CustomSetsDB["sets"][SELECTED_SET]["items"]
	if (#setc > 13) then
		if (ScrollShift-dir)>=1 and (ScrollShift-dir)<=(#setc-12) then
			ScrollShift = ScrollShift-dir
			cSets.option["scroll"]:SetValue(ScrollShift)
		end
	end
end

function cSets:ScrollBarUpdate(self)
	local setc = CustomSetsDB["sets"][SELECTED_SET]["items"]
	if (#setc < 14) then
		self:SetValue(1)
		self:Disable()
		self.up:Disable()
		self.down:Disable()
		self:SetMinMaxValues(1, 2)
	else
		self:Enable()
		self.up:Enable()
		self.down:Enable()
		self:SetMinMaxValues(1, #setc-12)
	end
	ScrollShift = self:GetValue()
	cSets:UpdateSetContents(SELECTED_SET, ScrollShift)
end

function cSets:UpdateOptionsFrame(set)
	SELECTED_SET = set
	cSets:UpdateBagData()
	cSets.option["name"]:ClearFocus()
	cSets.option["name"]:SetText(CustomSetsDB["sets"][set]["name"])
	cSets.option["enabled"]:SetChecked(CustomSetsDB["sets"][set]["enabled"])
	cSets.option["icon"]:SetTexture(CustomSetsDB["sets"][set]["icon"])
	cSets.option["define"]:ClearFocus()
	cSets.option["define"]:SetText(CustomSetsDB["sets"][set]["define"])
	PanelTemplates_SelectTab(cSets.option["tabs"][3])
	PanelTemplates_DeselectTab(cSets.option["tabs"][2])
	PanelTemplates_DeselectTab(cSets.option["tabs"][1])
	cSets.option["frames"][3]:Show()
	cSets.option["frames"][2]:Hide()
	cSets.option["frames"][1]:Hide()
	cSets:ScrollBarUpdate(cSets.option["scroll"])
end

function cSets:UpdateBagData()
	wipe(BagData)
	--bags
	for _, bag in ipairs(allbags) do
		for slot = 1, GetContainerNumSlots(bag) do
			local link = GetContainerItemLink(bag, slot)
			if link and link~=nil then
				local idi = cSets:GetItemId(link)
				if not Temp[idi] then
					Temp[idi] = true
					table.insert(BagData, link)
				end
			end
		end
	end
	--equipped
	for i=1,23 do
		local link = GetInventoryItemLink("player", i)
		if link and link~=nil then
			local idi = cSets:GetItemId(link)
			if not Temp[idi] then
				Temp[idi] = true
				table.insert(BagData, link)
			end
		end
	end
	wipe(Temp)
end

function cSets:SearchBagData(self)
	local found, what = 0, self:GetText()
	if what == "" then what = "ilvl>0" end
	for i=1,18 do
		cSets.option["icons"][i]:Hide()
		cSets.option["texts"][i]:Hide()
	end
	for i=1,#BagData do
		if BagData[i] and found<18 and cSets:SearchByTerm(what,BagData[i]) and not cSets:SearchByItem(SELECTED_SET, BagData[i]) then
			--match!
			found = found + 1
			local itemName, _, itemRarity, _, _, _, _, _, _, itemTexture = GetItemInfo(BagData[i])
			local r, g, b = GetItemQualityColor(itemRarity)
			cSets.option["icons"][found]:Show()
			cSets.option["icons"][found].link = BagData[i]
			cSets.option["icons"][found].bg:SetTexture(itemTexture)
			cSets.option["texts"][found]:Show()
			cSets.option["texts"][found]:SetText(itemName)
			cSets.option["texts"][found]:SetTextColor(r,g,b,1)
		end
	end
end

function cSets:UpdateExample(self)
	local found, what = 0, self:GetText()
	CustomSetsDB["sets"][SELECTED_SET]["define"] = what
	what = string.gsub(what, "\n", "|")
	if what == "" then what = "ilvl>0" end
	for i=1,8 do
		cSets.option["icons2"][i]:Hide()
		cSets.option["texts2"][i]:Hide()
	end
	for i=1,#BagData do
		if BagData[i] and found<8 and cSets:SearchByTerm(what,BagData[i]) and not cSets:SearchByItem(SELECTED_SET, BagData[i]) then
			--match!
			found = found + 1
			local itemName, _, itemRarity, _, _, _, _, _, _, itemTexture = GetItemInfo(BagData[i])
			local r, g, b = GetItemQualityColor(itemRarity)
			cSets.option["icons2"][found]:Show()
			cSets.option["icons2"][found].link = BagData[i]
			cSets.option["icons2"][found].bg:SetTexture(itemTexture)
			cSets.option["texts2"][found]:Show()
			cSets.option["texts2"][found]:SetText(itemName)
			cSets.option["texts2"][found]:SetTextColor(r,g,b,1)
		end
	end
end

function cSets:UpdateSetContents(set, shift)
	for i=1,13 do
		cSets.option["wides"][i]:Hide()
	end
	local setc = CustomSetsDB["sets"][set]["items"]
	for i=shift, min(shift+12,#setc) do
		local id = CustomSetsDB["sets"][set]["items"][i]
		local itemName, itemLink, itemRarity, _, _, _, _, _, _, itemTexture = GetItemInfo(id)
		local r, g, b = GetItemQualityColor(itemRarity)
		cSets.option["wides"][1+i-shift].bg:SetTexture(itemTexture)
		cSets.option["wides"][1+i-shift].text:SetText(itemName)
		cSets.option["wides"][1+i-shift].text:SetTextColor(r,g,b,1)
		cSets.option["wides"][1+i-shift].link = itemLink
		cSets.option["wides"][1+i-shift]:Show()
	end
end

function cSets:SearchByItem(setid, link)
	local itemId = cSets:GetItemId(link)
	local items = CustomSetsDB["sets"][setid]["items"]
	for i=1,#items do
		if items[i] == itemId then
			return i
		end
	end
	return nil
end

function cSets:SearchByTerm(term, link)
	if LIS:Find(link, term) then
		return true
	end
	return nil
end

function cSets:AddItem(setid, item)
	if (not cSets:SearchByItem(setid, item)) then
		table.insert(CustomSetsDB["sets"][setid]["items"], item)
	end
end

function cSets:DelItem(setid, item)
	local s = cSets:SearchByItem(setid, item)
	if s and s ~= nil then
		table.remove(CustomSetsDB["sets"][setid]["items"], s)
		cSets:ScrollBarUpdate(cSets.option["scroll"])
	end
end

function cSets:Strip( ... )
	local str = ""
	for i = 1, select('#', ...) do
		local term = select(i, ...)
		if term and term ~= '' then
			if term:match('\038') then
				str = str .. cSets:Strip(strsplit('\038', term))
			else
				for _, searchInfo in LIS:GetTypedSearches() do
					local capture1, capture2, capture3 = searchInfo:isSearch(term)
		
					if capture1 then
						term = string.format("%s%s%s", capture1 or "", capture2 or "", capture3 or "")
						break
					end
				end

				str = str .. term
			end
		end
	end

	return str
end

function cSets:EnableSet(num)
	local name, icon = CustomSetsDB["sets"][num]["name"], CustomSetsDB["sets"][num]["icon"]
	local term = string.gsub(CustomSetsDB["sets"][num]["define"], "\n", "|")
	local function rule(player, bagType, name, link, ...)
		return link and (cSets:SearchByTerm(term, link) or cSets:SearchByItem(num, link))
	end
	CombuctorSet:Register(name, icon, rule)
	CombuctorSet:RegisterSubSet("All", name)

	-- split up the search term and create a subset for each union...
	if ( term:match('\124') ) then
		local terms = { strsplit('\124', term) }

		for idx = 1, #terms do
			if terms[idx] and terms[idx] ~= "" then
				local function subset(player, bagType, name, link, ...)
					return link and (cSets:SearchByTerm(terms[idx], link) or cSets:SearchByItem(num, link))
				end
				CombuctorSet:RegisterSubSet(cSets:Strip(terms[idx]), name, nil, subset)
			end
		end
	end
end

function cSets:DisableSet(num)
	CombuctorSet:Unregister(CustomSetsDB["sets"][num]["name"])
end

function cSets:AppendSet()
	MAX_SETS = MAX_SETS + 1
	CustomSetsDB["sets"][MAX_SETS] = {
		["name"] = format(L.setid,MAX_SETS),
		["enabled"] = false,
		["define"] = "",
		["icon"] = "Interface\\Icons\\INV_Misc_QuestionMark",
		["items"] = {}
	}
	return true
end

function cSets:DeleteSet(setId)
	if ( setId >= 1 and setId <= MAX_SETS ) then
		CombuctorSet:Unregister(CustomSetsDB["sets"][setId]["name"])

		if ( MAX_SETS > 1 ) then
			-- there has to be a better way of doin this...
			local tmpSets = { }
			local i = 1
			for idx = 1, MAX_SETS do
				if ( idx ~= setId ) then
					tmpSets[i] = CustomSetsDB["sets"][idx]
					i = i + 1
				end
			end

			wipe(CustomSetsDB["sets"])
			CustomSetsDB["sets"] = tmpSets

			MAX_SETS = MAX_SETS - 1
		else
			wipe(CustomSetsDB["sets"])
			MAX_SETS = 0
			-- never allow the set list to be empty
			cSets:AppendSet()
		end

		return true
	end

	return false
end

function cSets:WipeDataz()
	if (CustomSetsDB ~= nil) then
		wipe(CustomSetsDB)
	end

	MAX_SETS = 0
	CustomSetsDB = { ["format"] = 1, ["sets"] = {} } --defaults
	cSets:AppendSet()

	if cSets.options then
		cSets:UpdateOptionsFrame(1)
	end
end

if not CustomSetsDB then
	cSets:WipeDataz()
end

cSets:Initialize()