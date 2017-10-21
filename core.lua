------------------------------------------------------
-- Configuration variables have moved to config.lua --
--        Do not change anything in this file       --
------------------------------------------------------

-- List globals here for Mikk's FindGlobals script
-- GLOBALS: UnitGUID, UnitIsFriend, print

local addon, ns = ...
local FRIENDLY, HOSTILE = ns.CONFIG.FRIENDLY, ns.CONFIG.HOSTILE

local TNI = CreateFrame("Frame", "TargetNameplateIndicator")

LibStub("LibNameplateRegistry-1.0"):Embed(TNI)

local texture = TNI:CreateTexture("$parentTexture", "OVERLAY")

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

	local config = UnitIsFriend("player", "target") and FRIENDLY or HOSTILE
	
	if nameplate then
		texture:Show()
		texture:SetTexture(config.TEXTURE_PATH)
		texture:SetSize(config.TEXTURE_WIDTH, config.TEXTURE_HEIGHT)
		texture:SetPoint(config.TEXTURE_POINT, nameplate, config.ANCHOR_POINT, config.OFFSET_X, config.OFFSET_Y)
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
