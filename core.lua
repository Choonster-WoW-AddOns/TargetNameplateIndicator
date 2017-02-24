------------------------------------------------------
-- Configuration variables have moved to config.lua --
--        Do not change anything in this file       --
------------------------------------------------------

-- List globals here for Mikk's FindGlobals script
-- GLOBALS: UnitGUID, print

local addon, ns = ...
local CONFIG = ns.CONFIG

local TNI = CreateFrame("Frame", "TargetNameplateIndicator")

LibStub("LibNameplateRegistry-1.0"):Embed(TNI)

local texture = TNI:CreateTexture("$parentTexture", "OVERLAY")
texture:SetTexture(CONFIG.TEXTURE_PATH)
texture:SetSize(CONFIG.TEXTURE_WIDTH, CONFIG.TEXTURE_HEIGHT)


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
		texture:SetPoint(CONFIG.TEXTURE_POINT, nameplate, CONFIG.ANCHOR_POINT, CONFIG.OFFSET_X, CONFIG.OFFSET_Y)
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
