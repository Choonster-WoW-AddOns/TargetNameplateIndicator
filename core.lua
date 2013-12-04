-- IMPORTANT: If you make any changes to this file, make sure you back it up before installing a new version.
-- This will allow you to restore your custom configuration with ease.
-- Also back up any custom textures you add.

-------
-- The first three variables control the appearance of the texture.
-------

-- The path of the texture file you want to use relative to the main WoW directory (without the texture's file extension).
-- The AddOn includes nine textures:
--	"Interface\\AddOns\\TargetNameplateIndicator\\Reticule"				-- Red targeting reticule (contributed by Dridzt of WoWI)
--	"Interface\\AddOns\\TargetNameplateIndicator\\RedArrow"				-- Red arrow pointing downwards (contributed by DohNotAgain of WoWI)
--	"Interface\\AddOns\\TargetNameplateIndicator\\NeonReticule"			-- Neon version of the reticule (contributed by mezmorizedck of Curse)
--	"Interface\\AddOns\\TargetNameplateIndicator\\NeonRedArrow"			-- Neon version of the red arrow (contributed by mezmorizedck of Curse)
--	"Interface\\AddOns\\TargetNameplateIndicator\\RedChevronArrow"		-- Red inverted triple chevron (contributed by OligoFriends of WoWI)
--	"Interface\\AddOns\\TargetNameplateIndicator\\PaleRedChevronArrow"	-- Pale red version of the chevron (contributed by OligoFriends of Curse/WoWI)
--	"Interface\\AddOns\\TargetNameplateIndicator\\arrow_tip_green"		-- Green 3D arrow (contributed by OligoFriends of Curse/WoWI)
--	"Interface\\AddOns\\TargetNameplateIndicator\\arrow_tip_red"		-- Red 3D arrow (contributed by OligoFriends of Curse/WoWI)
--	"Interface\\AddOns\\TargetNameplateIndicator\\skull"				-- Skull and crossbones (contributed by OligoFriends of Curse/WoWI)
local TEXTURE_PATH = "Interface\\AddOns\\TargetNameplateIndicator\\skull"

-- You can add your own texture by placing a TGA image in the WoW\Interface\AddOns\TargetNameplateIndicator directory and changing the string after TEXTURE_PATH to match its name.
-- See the "filename" argument on the following page for details on the required texture file format:
-- http://www.wowpedia.org/API_Texture_SetTexture
--
-- GIMP (www.gimp.org) is a free image editing program that can easily convert almost any image format to TGA as well as let you create your own TGA images.
-- If you want your texture to be packaged with the AddOn, just leave a comment on Curse or WoWI with the image embedded or a direct link to download the image.
-- I can convert PNG and other formats to TGA if needed.
-- Make sure that you have ownership rights of any image that you contribute.



-- The height/width of the texture. Using a height:width ratio different to that of the texture file may result in distortion.
local TEXTURE_HEIGHT = 50
local TEXTURE_WIDTH = 50


-------
-- These four variables control how the texture is anchored to the nameplate.
-------

-- Used in texture:SetPoint(TEXTURE_POINT, nameplate, ANCHOR_POINT, OFFSET_X, OFFSET_Y)
-- See http://www.wowpedia.org/API_Region_SetPoint for explanation.
local TEXTURE_POINT = "BOTTOM" -- The point of the texture that should be anchored to the nameplate.
local ANCHOR_POINT  = "TOP"	   -- The point of the nameplate the texture should be anchored to.
local OFFSET_X = 0 			   -- The x/y offset of the texture relative to the anchor point.
local OFFSET_Y = 5

-------------------
-- END OF CONFIG --
-------------------
-- Do not change anything below here.

local addon, ns = ...
local LibNameplate = LibStub("LibNameplate-1.0")

local UnitGUID = UnitGUID

local parent = CreateFrame("Frame")
local texture = parent:CreateTexture("TargetNameplateIndicatorTexture", "OVERLAY")
texture:SetTexture(TEXTURE_PATH)
texture:SetHeight(TEXTURE_HEIGHT)
texture:SetWidth(TEXTURE_WIDTH)

local TARGET_GUID;
local CURRENT_NAMEPLATE;
local CALLBACK_FIRED = false

local function UpdateIndicator(nameplate)
	CURRENT_NAMEPLATE = nameplate

	if nameplate then
		texture:Show()
		texture:ClearAllPoints()
		texture:SetPoint(TEXTURE_POINT, nameplate, ANCHOR_POINT, OFFSET_X, OFFSET_Y)
	else
		texture:Hide()
	end
	
	TARGET_GUID = UnitGUID("target")
end

local function OnTargetChanged(callback, nameplate)
	CALLBACK_FIRED = true
	UpdateIndicator(nameplate)
	-- print("TNI: Callback fired")
end

local function OnNameplateHidden(callback, nameplate)
	if nameplate == CURRENT_NAMEPLATE then
		UpdateIndicator()
	end
end

LibNameplate.RegisterCallback(addon, "LibNameplate_TargetNameplate", OnTargetChanged)
LibNameplate.RegisterCallback(addon, "LibNameplate_RecycleNameplate", OnNameplateHidden)

-- LibNameplate doesn't fire the TargetNameplate callback when the player targets a unit that doesn't have a nameplate or clears their target,
-- so we need to watch for PLAYER_TARGET_CHANGED and update the indicator's position manually if the callback hasn't fired.

local THROTTLE = 0.1
local timer = THROTTLE

local TIMEOUT = 1.0 -- If we haven't updated the indicator 1 second after PLAYER_TARGET_CHANGED fires, hide the OnUpdate frame.
local timeout = TIMEOUT

local function OnUpdate(self, elapsed)
	timer = timer - elapsed
	timeout = timeout - elapsed
	if timer > 0 then return end
	timer = THROTTLE
	
	if not CALLBACK_FIRED and UnitExists("target") and UnitGUID("target") ~= TARGET_GUID then
		local nameplate = LibNameplate:GetTargetNameplate()
		if nameplate ~= CURRENT_NAMEPLATE then
			self:Hide()
			UpdateIndicator(nameplate)
			-- print("TNI OnUpdate: Target Changed")
			return
		end
	end
	
	if timeout <= 0 then
		timeout = TIMEOUT
		self:Hide()
		-- print("TNI Timeout")
	end	
end

local function OnEvent(self, event, ...)
	if event == "PLAYER_TARGET_CHANGED" then
		timeout = TIMEOUT
		CALLBACK_FIRED = false
		if UnitExists("target") then
			self:Show()
		else
			self:Hide()
			UpdateIndicator()
		end
	end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_TARGET_CHANGED")
f:SetScript("OnEvent", OnEvent)
f:SetScript("OnUpdate", OnUpdate)
-- f:SetScript("OnShow", function() print("TNI Frame Shown") end)
-- f:SetScript("OnHide", function() print("TNI Frame Hidden") end)