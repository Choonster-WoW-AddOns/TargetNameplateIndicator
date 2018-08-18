-- List globals here for Mikk's FindGlobals script
-- GLOBALS: LibStub, InterfaceOptionsFrame_OpenToCategory, unpack, ipairs

local addon, TNI = ...
local ACR = LibStub("AceConfigRegistry-3.0")
local ACD = LibStub("AceConfigDialog-3.0")
local ACC = LibStub("AceConfigCmd-3.0")
local frameref

-- The indicator textures provided by the AddOn. Used for the texture dropdowns.
local TEXTURES = {
	["Reticule"]             = "Reticule - Red targeting reticule",
	["RedArrow"]             = "RedArrow - Red arrow pointing downwards",
	["NeonReticule"]         = "NeonReticule - Neon version of the reticule",
	["NeonRedArrow"]         = "NeonRedArrow - Neon version of the red arrow",
	["RedChevronArrow"]      = "RedChevronArrow - Red inverted triple chevron",
	["PaleRedChevronArrow"]  = "PaleRedChevronArrow - Pale red version of the chevron",
	["arrow_tip_green"]      = "arrow_tip_green - Green 3D arrow",
	["arrow_tip_red"]        = "arrow_tip_red - Red 3D arrow",
	["skull"]                = "skull - Skull and crossbones",
	["circles_target"]       = "circles_target - Red concentric circles in the style of a target",
	["red_star"]             = "red_star - Red star with gold outline",
	["greenarrowtarget"]     = "greenarrowtarget - Neon green arrow with a red target",
	["BlueArrow"]            = "BlueArrow - Blue arrow pointing downwards",
	["bluearrow1"]           = "bluearrow1 - Abstract style blue arrow pointing downwards",
	["gearsofwar"]           = "gearsofwar - Gears of War logo",
	["malthael"]             = "malthael - Malthael (Diablo) logo",
	["NewRedArrow"]          = "NewRedArrow - Red arrow pointing downwards",
	["NewSkull"]             = "NewSkull - Skull with gas mask",
	["PurpleArrow"]          = "PurpleArrow - Abstract style purple arrow pointing downwards",
	["Shield"]               = "Shield - Kite shield with sword and crossed spears/polearms",
	["NeonGreenArrow"]       = "NeonGreenArrow - Green version of the neon red arrow",
	["Q_FelFlamingSkull"]    = "Q_FelFlamingSkull - Fel green flaming skull",
	["Q_RedFlamingSkull"]    = "Q_RedFlamingSkull - Red flaming skull",
	["Q_ShadowFlamingSkull"] = "Q_ShadowFlamingSkull - Shadow purple flaming skull",
	["Q_GreenGPS"]           = "Q_GreenGPS - Green map pin/GPS symbol",
	["Q_RedGPS"]             = "Q_RedGPS - Red map pin/GPS symbol",
	["Q_WhiteGPS"]           = "Q_WhiteGPS - White map pin/GPS symbol",
	["Q_GreenTarget"]        = "Q_GreenTarget - Green target arrow",
	["Q_RedTarget"]          = "Q_RedTarget - Red target arrow",
	["Q_WhiteTarget"]        = "Q_WhiteTarget - White target arrow",
	["Hunters_Mark"]         = "Hunters_Mark - Red Hunter's Mark Arrow",
}

-- Add the directory prefix to the texture names
do
	local oldTextures = TEXTURES
	TEXTURES = {}

	for texture, description in pairs(oldTextures) do
		TEXTURES["Interface\\AddOns\\TargetNameplateIndicator\\Textures\\" .. texture] = description
	end
end

-- The points that regions can be anchored to/by. Used for the texture and anchor point dropdowns.
local REGION_POINTS = {
	["TOP"]         = "Top - The centre-point of the top side of the rectange",
	["RIGHT"]       = "Right - The centre-point of the right side of the rectange",
	["BOTTOM"]      = "Bottom - The centre-point of the bottom side of the rectange",
	["LEFT"]        = "Left - The centre-point of the left side of the rectange",
	["TOPRIGHT"]    = "Top Right - The top right corner of the rectange",
	["TOPLEFT"]     = "Top Left - The top left corner of the rectange",
	["BOTTOMLEFT"]  = "Bottom Left - The bottom left corner of the rectange",
	["BOTTOMRIGHT"] = "Bottom Right - The bottom right corner of the rectange",
	["CENTER"]      = "Centre - The centre-point of the rectange",
}

-- A pattern that matches a number with an optional decimal part
local NUMBER_PATTERN = "^%d+%.?%d*$"

local function get(info)

end

local function set(info, val)

end

local function CreateUnitRectionTypeConfigTable(unitReactionType)
	return {
		name = unitReactionType,
		type = "group",
		args = {
			enable = {
				name = "Enable",
				desc = "Enables/disables the indicator for this unit reaction type",
				type = "toggle",
			},
			texture = {
				name = "Texture",
				desc = "The texture to use for the indicator",
				width = "full",
				type = "select",
				values = TEXTURES,
				style = "dropdown",
			},
			height = {
				name = "Texture Height",
				desc = "The height of the texture",
				type = "input",
				pattern = NUMBER_PATTERN,
			}
			width = {
				name = "Texture Width",
				desc = "The width of the texture",
				type = "input",
				pattern = NUMBER_PATTERN,
			},
			opacity = {
				name = "Texture Opacity",
				desc = "The opacity of the texture. 1 is fully opaque, 0 is transparent.",
				type = "input",
				pattern = NUMBER_PATTERN,
			},
			texturePoint = {
				name = "Texture Point",
				desc = "The point of the texture that should be anchored to the nameplate",
				width = "full",
				type = "select",
				values = REGION_POINTS,
				style = "dropdown",
			},
			anchorPoint = {
				name = "Anchor Point",
				desc = "The point of the nameplate the texture should be anchored to",
				type = "select",
				width = "full",
				values = REGION_POINTS,
				style = "dropdown",
			},
			xOffset = {
				name = "X Offset",
				desc = "The x offset of the texture relative to the anchor point",
				type = "input",
				pattern = NUMBER_PATTERN,
			},
			yOffset = {
				name = "Y Offset",
				desc = "The y offset of the texture relative to the anchor point",
				type = "input",
				pattern = NUMBER_PATTERN,				
			},
		}
	}
end

local function CreateUnitConfigTable(unit)
	return {
		name = unit,
		type = "group",
		childGroups = "tab",
		args = {
			enable = {
				name = "Enable",
				desc = "Enables/disables the indicator for this unit",
				type = "toggle",
			}
			self = CreateUnitRectionTypeConfigTable("self"),
			friendly = CreateUnitRectionTypeConfigTable("friendly"),
			hostile = CreateUnitRectionTypeConfigTable("hostile"),
		},
	}
end

local options = {
	name = "Target Nameplate Indicator",
	type = "group",
	args = {
		target = CreateUnitConfigTable("target"),
		mouseover = CreateUnitConfigTable("mouseover"),
		focus = CreateUnitConfigTable("focus"),
	},
	get = get,
	set = set,
}

local slashes = {
	"targetnameplateindicator",
	"tni",
}

TNI.ACC_HandleCommand = ACC.HandleCommand

local slash = slashes[1]
function TNI:HandleChatCommand(input)
	if input:trim() == "" then
		InterfaceOptionsFrame_OpenToCategory(frameref)
	else
		self:ACC_HandleCommand(slash, addon, input)
	end
end

function TNI:RegisterOptions()
	options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	ACR:RegisterOptionsTable(addon, options)
	frameref = ACD:AddToBlizOptions(addon)
	for _, cmd in ipairs(slashes) do
		self:RegisterChatCommand(cmd, "HandleChatCommand")
	end
end
