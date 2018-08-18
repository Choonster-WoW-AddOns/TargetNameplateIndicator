------------------------------------------------------
-- Configuration variables have moved to config.lua --
--        Do not change anything in this file       --
------------------------------------------------------

-- List globals here for Mikk's FindGlobals script
-- GLOBALS: LibStub, UnitIsUnit, UnitGUID, UnitIsFriend, UnitExists, CreateFrame, Mixin, print, pairs

local addon, TNI = ...

local LNR = LibStub("LibNameplateRegistry-1.0")

LibStub("AceAddon-3.0"):NewAddon(TNI, addon, "AceConsole-3.0")


--@debug@
local DEBUG = false

local function debugprint(...)
	if DEBUG then
		print("TNI DEBUG:", ...)
	end
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

------
-- Initialisation
------

local defaults

do
	local function CreateUnitReactionTypeDefaults()
		return {
			enable = true,
			texture = "Interface\\AddOns\\TargetNameplateIndicator\\Textures\\Reticule",
			height = 50,
			width = 50,
			opacity = 1,
			texturePoint = "BOTTOM",
			anchorPoint = "TOP",
			xOffset = 0,
			yOffset = 5,
		}
	end
	
	local function CreateUnitDefaults()
		return {
			enable = true,
			self = CreateUnitReactionTypeDefaults(),
			friendly = CreateUnitReactionTypeDefaults(),
			hostile = CreateUnitReactionTypeDefaults(),
		}
	end
	
	defaults = {
		profile = {
			target = CreateUnitDefaults(),
			mouseover = CreateUnitDefaults(),
			focus = CreateUnitDefaults(),
		}
	}
end

function TNI:OnInitialize()
	LNR:Embed(self)
	self.db = LibStub("AceDB-3.0"):New("TargetNameplateIndicatorDB", defaults, true)
	self:RegisterOptions() -- Defined in options.lua
	
	self:LNR_RegisterCallback("LNR_ERROR_FATAL_INCOMPATIBILITY", "OnError_FatalIncompatibility")
	
	--@debug@
	if DEBUG then
		TNI:LNR_RegisterCallback("LNR_DEBUG", debugprint)
	end
	--@end-debug@
end

function TNI:OnEnable()
	for unit, indicator in pairs(self.Indicators) do
		indicator:Show()
	end
end

function TNI:OnDisable()
	for unit, indicator in pairs(self.Indicators) do
		indicator:Hide()
	end
end

function TNI:RefreshIndicator(unit)
	local indicator = self.Indicators[unit]
	
	if not indicator then
		error("Invalid unit \"" + unit + "\"")
	end
	
	indicator:Refresh()
end

------
-- Indicator functions
------
TNI.Indicators = {}

local Indicator = {}

function Indicator:Update(nameplate)
	self.currentNameplate = nameplate
	self.Texture:ClearAllPoints()
	
	local unitConfig = TNI.db.profile[self.unit]
	local config = UnitIsUnit("player", self.unit) and unitConfig.self or UnitIsFriend("player", self.unit) and unitConfig.friendly or unitConfig.hostile

	self:SetShown(unitConfig.enable)

	if nameplate and config.enable then
		self.Texture:Show()
		self.Texture:SetTexture(config.texture)
		self.Texture:SetSize(config.width, config.height)
		self.Texture:SetAlpha(config.opacity)
		self.Texture:SetPoint(config.texturePoint, nameplate, config.anchorPoint, config.xOffset, config.yOffset)
	else
		self.Texture:Hide()
	end
end

function Indicator:Refresh()
	self:Update(self.currentNameplate)
end

function Indicator:OnRecyclePlate(callback, nameplate, plateData)
	--@debug@
	debugprint("Callback fired (recycle)", self.unit, nameplate == self.currentNameplate)
	--@end-debug@

	if nameplate == self.currentNameplate then
		self:Update()
	end
end

-- Are other indicators already displaying on this indicator's unit?
function Indicator:AreOtherIndicatorsDisplayed()
	for unit, indicator in pairs(TNI.Indicators) do
		if self.unit ~= indicator.unit and UnitIsUnit(self.unit, unit) then -- If the indicator is for a different unit token but it's the same unit, return true
			return true
		end
	end
	
	return false
end

local function CreateIndicator(unit)
	local indicator = CreateFrame("Frame", "TargetNameplateIndicator_" .. unit)
	indicator:SetFrameStrata("BACKGROUND")
	indicator.Texture = indicator:CreateTexture("$parentTexture", "OVERLAY")

	indicator.unit = unit

	LNR:Embed(indicator)
	Mixin(indicator, Indicator)

	indicator:LNR_RegisterCallback("LNR_ON_RECYCLE_PLATE", "OnRecyclePlate")

	indicator:SetScript("OnEvent", function(self, event, ...)
		self[event](self, ...)
	end)
	
	TNI.Indicators[unit] = indicator

	return indicator
end

------
-- Target Indicator
------

-- if ns.TARGET_CONFIG.ENABLED then
	local TargetIndicator = CreateIndicator("target", ns.TARGET_CONFIG)

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
-- end

------
-- Mouseover Indicator
------

-- if ns.MOUSEOVER_CONFIG.ENABLED then
	local MouseoverIndicator = CreateIndicator("mouseover", ns.MOUSEOVER_CONFIG)

	function MouseoverIndicator:OnUpdate()
		-- If there's a current nameplate and it's still the mouseover unit, do nothing
		if self.currentNameplate and UnitIsUnit("mouseover", self.currentNameplate.namePlateUnitToken) then return end

		-- If there isn't a current nameplate and there's no mouseover unit, do nothing
		if not self.currentNameplate and not UnitExists("mouseover") then return end

		local nameplate, plateData = self:GetPlateByGUID(UnitGUID("mouseover"))

		local areOtherIndicatorsDisplayed = self:AreOtherIndicatorsDisplayed()

		--@debug@
		debugprint("Player mouseover changed", nameplate, "areOtherIndicatorsDisplayed?", areOtherIndicatorsDisplayed)
		--@end-debug@

		-- If the player has their mouse over a unit that doesn't already have an indicator displaying on it, update the mouseover indicator; otherwise hide it 
		if not areOtherIndicatorsDisplayed then
			self:Update(nameplate)
		else
			self:Update(nil)
		end
	end

	MouseoverIndicator:SetScript("OnUpdate", MouseoverIndicator.OnUpdate)
-- end

------
-- Focuus Indicator
------

-- if ns.FOCUS_CONFIG.ENABLED then
	local FocusIndicator = CreateIndicator("focus", ns.FOCUS_CONFIG)
	
	function FocusIndicator:OnUpdate()
		-- If there's a current nameplate and it's still the focus unit, do nothing
		if self.currentNameplate and UnitIsUnit("focus", self.currentNameplate.namePlateUnitToken) then return end

		-- If there isn't a current nameplate and there's no focus unit, do nothing
		if not self.currentNameplate and not UnitExists("focus") then return end

		local nameplate, plateData = self:GetPlateByGUID(UnitGUID("focus"))

		local areOtherIndicatorsDisplayed = self:AreOtherIndicatorsDisplayed()

		--@debug@
		debugprint("Player focus changed", nameplate, "areOtherIndicatorsDisplayed?", areOtherIndicatorsDisplayed)
		--@end-debug@

		-- If the player has their focus set to a unit that doesn't already have an indicator displaying on it, update the focus indicator; otherwise hide it
		if not areOtherIndicatorsDisplayed then
			self:Update(nameplate)
		else
			self:Update(nil)
		end
	end
	
	FocusIndicator:SetScript("OnUpdate", FocusIndicator.OnUpdate)
-- end
