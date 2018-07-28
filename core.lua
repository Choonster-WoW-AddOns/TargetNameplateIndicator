------------------------------------------------------
-- Configuration variables have moved to config.lua --
--        Do not change anything in this file       --
------------------------------------------------------

-- List globals here for Mikk's FindGlobals script
-- GLOBALS: UnitIsUnit, UnitGUID, UnitIsFriend, UnitExists, CreateFrame, Mixin, print

local addon, ns = ...
local CONFIG = ns.CONFIG
local SELF, FRIENDLY, HOSTILE = CONFIG.SELF, CONFIG.FRIENDLY, CONFIG.HOSTILE

local TNI = CreateFrame("Frame", "TargetNameplateIndicator")
local LNR = LibStub("LibNameplateRegistry-1.0")

LNR:Embed(TNI)

--@debug@
local DEBUG = true

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
local Indicator = {}

function Indicator:Update(nameplate)
	self.currentNameplate = nameplate
	self.Texture:ClearAllPoints()

	local config = UnitIsUnit("player", self.unit) and SELF or UnitIsFriend("player", self.unit) and FRIENDLY or HOSTILE

	if nameplate and config.ENABLED then
		self.Texture:Show()
		self.Texture:SetTexture(config.TEXTURE_PATH)
		self.Texture:SetSize(config.TEXTURE_WIDTH, config.TEXTURE_HEIGHT)
		self.Texture:SetPoint(config.TEXTURE_POINT, nameplate, config.ANCHOR_POINT, config.OFFSET_X, config.OFFSET_Y)
	else
		self.Texture:Hide()
	end
end

function Indicator:OnRecyclePlate(callback, nameplate, plateData)
	--@debug@
	debugprint("Callback fired (recycle)", self.unit, nameplate == self.currentNameplate)
	--@end-debug@

	if nameplate == self.currentNameplate then
		self:Update()
	end
end

local function CreateIndicator(unit)
	local indicator = CreateFrame("Frame", "TargetNameplateIndicator_" .. unit)
	indicator.Texture = indicator:CreateTexture("$parentTexture", "OVERLAY")

	indicator.unit = unit

	LNR:Embed(indicator)
	Mixin(indicator, Indicator)

	indicator:LNR_RegisterCallback("LNR_ON_RECYCLE_PLATE", "OnRecyclePlate")

	indicator:SetScript("OnEvent", function(self, event, ...)
		self[event](self, ...)
	end)

	return indicator
end

------
-- Target Indicator
------

if CONFIG.TARGET_ENABLED then
	local TargetIndicator = CreateIndicator("target")

	function TargetIndicator:PLAYER_TARGET_CHANGED()
		local nameplate, plateData = self:GetPlateByGUID(UnitGUID("target"))

		--@debug@
		debugprint("Player target changed", nameplate)
		--@end-debug@

		if not nameplate then
			self:Update()
		end
	end

	function TargetIndicator:OnTargetPlateOnScreen(callback, nameplate, plateData)
		--@debug@
		debugprint("Callback fired (target found)")
		--@end-debug@

		self:Update(nameplate)
	end

	TargetIndicator:RegisterEvent("PLAYER_TARGET_CHANGED")
	TargetIndicator:LNR_RegisterCallback("LNR_ON_TARGET_PLATE_ON_SCREEN", "OnTargetPlateOnScreen")
end

------
-- Mouseover Indicator
------

if CONFIG.MOUSEOVER_ENABLED then
	local MouseoverIndicator = CreateIndicator("mouseover")

	function MouseoverIndicator:OnUpdate()
		-- If there's a current nameplate and it's still the mouseover unit, do nothing
		if self.currentNameplate and UnitIsUnit("mouseover", self.currentNameplate.namePlateUnitToken) then return end

		-- If there isn't a current nameplate and there's no mouseover unit, do nothing
		if not self.currentNameplate and not UnitExists("mouseover") then return end

		local nameplate, plateData = self:GetPlateByGUID(UnitGUID("mouseover"))

		local isMouseoverTarget = UnitIsUnit("mouseover", "target")

		--@debug@
		debugprint("Player mouseover changed", nameplate, "isMouseoverTarget?", isMouseoverTarget)
		--@end-debug@

		-- If the player has their mouse over a unit other than their target or the target indicator is disabled, update the mouseover indicator; otherwise hide it
		if not isMouseoverTarget or not CONFIG.TARGET_ENABLED then
			self:Update(nameplate)
		else
			self:Update(nil)
		end
	end

	MouseoverIndicator:SetScript("OnUpdate", MouseoverIndicator.OnUpdate)
end

------
-- Focuus Indicator
------

if CONFIG.FOCUS_ENABLED then
	local FocusIndicator = CreateIndicator("focus")
	
	function FocusIndicator:OnUpdate()
		-- If there's a current nameplate and it's still the focus unit, do nothing
		if self.currentNameplate and UnitIsUnit("focus", self.currentNameplate.namePlateUnitToken) then return end

		-- If there isn't a current nameplate and there's no focus unit, do nothing
		if not self.currentNameplate and not UnitExists("focus") then return end

		local nameplate, plateData = self:GetPlateByGUID(UnitGUID("focus"))

		local isFocusTarget = UnitIsUnit("focus", "target")

		--@debug@
		debugprint("Player focus changed", nameplate, "isFocusTargetTarget?", isFocusTarget)
		--@end-debug@

		-- If the player has their focus set to a unit other than their target or the target indicator is disabled, update the focus indicator; otherwise hide it
		if not isFocusTarget or not CONFIG.TARGET_ENABLED then
			self:Update(nameplate)
		else
			self:Update(nil)
		end
	end
	
	FocusIndicator:SetScript("OnUpdate", FocusIndicator.OnUpdate)
end