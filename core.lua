-- IMPORTANT: If you make any changes to this file, make sure you back it up before installing a new version.
-- This will allow you to restore your custom configuration with ease.
-- Also back up any custom textures you add.

-------
-- The first three variables control the appearance of the texture.
-------

-- The path of the texture file you want to use relative to the main WoW directory (without the texture's file extension).
-- The AddOn includes twenty textures:
--	Reticule				-- Red targeting reticule (contributed by Dridzt of WoWI)
--	RedArrow				-- Red arrow pointing downwards (contributed by DohNotAgain of WoWI)
--	NeonReticule			-- Neon version of the reticule (contributed by mezmorizedck of Curse)
--	NeonRedArrow			-- Neon version of the red arrow (contributed by mezmorizedck of Curse)
--	RedChevronArrow			-- Red inverted triple chevron (contributed by OligoFriends of WoWI)
--	PaleRedChevronArrow		-- Pale red version of the chevron (contributed by OligoFriends of Curse/WoWI)
--	arrow_tip_green			-- Green 3D arrow (contributed by OligoFriends of Curse/WoWI)
--	arrow_tip_red			-- Red 3D arrow (contributed by OligoFriends of Curse/WoWI)
--	skull					-- Skull and crossbones (contributed by OligoFriends of Curse/WoWI)
--	circles_target			-- Red concentric circles in the style of a target (contributed by OligoFriends of Curse/WoWI)
--	red_star				-- Red star with gold outline (contributed by OligoFriends of Curse/WoWI)
--	greenarrowtarget		-- Neon green arrow with a red target (contributed by mezmorizedck of Curse)
--	BlueArrow				-- Blue arrow pointing downwards (contributed by Imithat of WoWI)
--	bluearrow1				-- Abstract style blue arrow pointing downwards (contributed by Imithat of WoWI)
--	gearsofwar				-- Gears of War logo (contributed by Imithat of WoWI)
--	malthael				-- Malthael (Diablo) logo (contributed by Imithat of WoWI)
--	NewRedArrow				-- Red arrow pointing downwards, same style as BlueArrow (contributed by Imithat of WoWI)
--	NewSkull				-- Skull with gas mask (contributed by Imithat of WoWI)
--	PurpleArrow				-- Abstract style purple arrow pointing downwards, same style as bluearrow1 (contributed by Imithat of WoWI)
--	Shield					-- Kite shield with sword and crossed spears/polearms (contributed by Imithat of WoWI)

-- All of the textures listed above need to be prefixed with "Interface\\AddOns\\TargetNameplateIndicator\\" like the default value below.
local TEXTURE_PATH = "Interface\\AddOns\\TargetNameplateIndicator\\Reticule"

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

-- List globals here for Mikk's FindGlobals script
-- GLOBALS: UnitGUID

local addon, ns = ...

local TNI = CreateFrame("Frame", "TargetNameplateIndicator")

LibStub("LibNameplateRegistry-1.0"):Embed(TNI)

local texture = TNI:CreateTexture("$parentTexture", "OVERLAY")
texture:SetTexture(TEXTURE_PATH)
texture:SetSize(TEXTURE_WIDTH, TEXTURE_HEIGHT)


--@debug@
local DEBUG = false

local function debugprint(...)
	if DEBUG then
		print("TNI DEBUG:", ...)
	end
end

if DEBUG then
	TNI:LNR_RegisterCallback("LNR_DEBUG", debugprint)
end
--@end-debug@

-----
-- Error callbacks
-----
local print, format = print, string.format

local function errorPrint(fatal, formatString, ...)
	local message = "|cffFF0000LibNameplateRegistry has encountered a" .. (fatal and " fatal" or "n") .. " error:|r"
	print("TargetNameplateIndicator:", message, format(formatString, ...))
end

function TNI:OnError_FatalIncompatibility(callback, incompatibilityType)
	local detailedMessage
	if incompatibilityType == "TRACKING: OnHide" or incompatibilityType == "TRACKING: OnShow" then
		detailedMessage = "LibNameplateRegistry missed several nameplate show and hide events."
	elseif incompatibilityType == "TRACKING: OnShow missed" then
		detailedMessage = "A nameplate was hidden but never shown."
	else
		detailedMessage = "Something has gone terribly wrong!"
	end

	errorPrint(true, "(Error Code: %s) %s", incompatibilityType, detailedMessage)
end

TNI:LNR_RegisterCallback("LNR_ERROR_FATAL_INCOMPATIBILITY", "OnError_FatalIncompatibility")

------
-- Nameplate callbacks
------
local CurrentNameplate

function TNI:UpdateIndicator(nameplate)
	CurrentNameplate = nameplate
	texture:ClearAllPoints()

	if nameplate then
		texture:Show()
		texture:SetPoint(TEXTURE_POINT, nameplate, ANCHOR_POINT, OFFSET_X, OFFSET_Y)
	else
		texture:Hide()
	end
end

function TNI:OnTargetPlateOnScreen(callback, nameplate, plateData)
	--@debug@
	debugprint("Callback fired (target found)")
	--@end-debug@

	self:UpdateIndicator(nameplate)
end

function TNI:OnRecyclePlate(callback, nameplate, plateData)
	--@debug@
	debugprint("Callback fired (recycle)", nameplate == CurrentNameplate)
	--@end-debug@

	if nameplate == CurrentNameplate then
		self:UpdateIndicator()
	end
end

function TNI:PLAYER_TARGET_CHANGED()
	local nameplate, plateData = TNI:GetPlateByGUID(UnitGUID("target"))

	--@debug@
	debugprint("Player target changed", nameplate)
	--@end-debug@

	if not nameplate then
		TNI:UpdateIndicator()
	end
end

TNI:LNR_RegisterCallback("LNR_ON_TARGET_PLATE_ON_SCREEN", "OnTargetPlateOnScreen")
TNI:LNR_RegisterCallback("LNR_ON_RECYCLE_PLATE", "OnRecyclePlate")

TNI:RegisterEvent("PLAYER_TARGET_CHANGED")
TNI:SetScript("OnEvent", function(self, event, ...)
	self[event](self, ...)
end)
