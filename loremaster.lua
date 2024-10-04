
-- A simple lore-narrator for WoW 1.12.1. Version 1.0.
---------------------------------------------------------
-- Index
-- -TABLES
-- -BUTTON
-- -FUNCTIONS
-- -EXTRA
---------------------------------------------------------
-- loremaster.lua

-- This function should contain all the code you want to execute from loremaster.lua
local function main()
    -- Your existing code here
	
local f1 = CreateFrame("Frame")

f1:RegisterEvent("PLAYER_TARGET_CHANGED")
f1:RegisterEvent("ZONE_CHANGED")
f1:RegisterEvent("ZONE_CHANGED_NEW_AREA")
f1:RegisterEvent("ZONE_CHANGED_INDOORS")
f1:RegisterEvent("PLAYER_LOGOUT")

-- Welcome message
DEFAULT_CHAT_FRAME:AddMessage("Loremaster loaded. Use /replay in order to repeat the last played zone-lore.")

-- Load playedSounds from SavedVariables
if playedSounds == nil then
    playedSounds = {}  -- Initialize if it doesn't exist
end

-- TABLES ---------------------------------------------------------------------
-------------------------------------------------------------------------------

-- Temporary table for the last played sound
local lastPlayedSound = {}

-- Table to map target names (NPCs) to sound files
local targetSounds = {
	-- NPCs
    ["Chief Hawkwind"] = "Interface\\AddOns\\Loremaster\\Sounds\\Targets\\chief_hawkwind.mp3",
    ["Grull Hawkwind"] = "Interface\\AddOns\\Loremaster\\Sounds\\Targets\\grull_hawkwind.mp3",
    ["Seer Graytongue"] = "Interface\\AddOns\\Loremaster\\Sounds\\Targets\\seer_graytongue.mp3",
	["Baine Bloodhoof"] = "Interface\\AddOns\\Loremaster\\Sounds\\Targets\\baine_bloodhoof.mp3",
	["Cairne Bloodhoof"] = "Interface\\AddOns\\Loremaster\\Sounds\\Targets\\cairne_bloodhoof.mp3",
	["Greatmother Hawkwind"] = "Interface\\AddOns\\Loremaster\\Sounds\\Targets\\greatmother_hawkwind.mp3",
	["Arch Druid Hamuul Runetotem"] = "Interface\\AddOns\\Loremaster\\Sounds\\Targets\\hamuul_runetotem.mp3",
	-- Mobs
	["Kodo Matriarch"] = "Interface\\AddOns\\Loremaster\\Sounds\\Enemies\\kodos.mp3",
	["Kodo Calf"] = "Interface\\AddOns\\Loremaster\\Sounds\\Enemies\\kodos.mp3",
	["Kodo Bull"] = "Interface\\AddOns\\Loremaster\\Sounds\\Enemies\\kodos.mp3",
	["Mazzranache"] = "Interface\\AddOns\\Loremaster\\Sounds\\Enemies\\mazznarache.mp3",
	["Arra'chea"] = "Interface\\AddOns\\Loremaster\\Sounds\\Enemies\\arrachea.mp3",
	["Ghost Howl"] = "Interface\\AddOns\\Loremaster\\Sounds\\Enemies\\ghost_howl.mp3",
	-- Enemies
	["Chief Sharptusk Thornmantle"] = "Interface\\AddOns\\Loremaster\\Sounds\\Enemies\\chief_sharptusk_thornmantle.mp3",
    ["\"Squealer\" Thornmantle"] = "Interface\\AddOns\\Loremaster\\Sounds\\Enemies\\squealer_thornmantle.mp3",
	["Supervisor Fizsprocket"] = "Interface\\AddOns\\Loremaster\\Sounds\\Enemies\\supervisor_fizsprocket.mp3",
	-- Add more targets here
}
-- Table to map zone names to sound files
local zoneSounds = {
    ["Red Cloud Mesa"] = "Interface\\AddOns\\Loremaster\\Sounds\\Zones\\red_cloud_mesa.mp3",
    ["Camp Narache"] = "Interface\\AddOns\\Loremaster\\Sounds\\Zones\\camp_narache.mp3",
	["Brambleblade Ravine"] = "Interface\\AddOns\\Loremaster\\Sounds\\Zones\\brambleblade_ravine.mp3",
	["Bloodhoof Village"] = "Interface\\AddOns\\Loremaster\\Sounds\\Zones\\bloodhoof_village.mp3",
	["Thunder Bluff"] = "Interface\\AddOns\\Loremaster\\Sounds\\Zones\\thunderbluff.mp3",
	["Palemane Rock"] = "Interface\\AddOns\\Loremaster\\Sounds\\Zones\\palemane_rock.mp3",
	["The Venture Co. Mine"] = "Interface\\AddOns\\Loremaster\\Sounds\\Zones\\venture_company.mp3",
	["Red Rocks"] = "Interface\\AddOns\\Loremaster\\Sounds\\Zones\\red_rocks.mp3",
    -- Add more zones here
}

-- BUTTON ---------------------------------------------------------------------
-------------------------------------------------------------------------------

-- The Button
local btn = CreateFrame("Button", nil, UIParent, "UIPanelButtonTemplate")
btn:SetWidth(100)
btn:SetHeight(30)
btn:Hide()  -- Hide the button initially

-- Set the button's initial position
btn:SetPoint("TOP", UIParent, "TOP", 0, 0)

-- Create a backdrop frame
local backdrop = CreateFrame("Frame", nil, btn)
backdrop:SetAllPoints(btn)  -- Make it cover the entire button
backdrop:SetFrameLevel(btn:GetFrameLevel() - 1)  -- Set backdrop behind the button

-- Set the backdrop color (black with some transparency)
backdrop:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",  -- Background texture
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",  -- Border texture
    tile = true,  -- True to tile the background texture
    tileSize = 16,  -- Size of the tile
    edgeSize = 0.1,  -- Size of the border
    insets = { left = 4, right = 4, top = 4, bottom = 4 }  -- Insets
})
backdrop:SetBackdropColor(0, 0, 0, 0.8)  -- Set backdrop color to black with some transparency (RGBA)

-- Create a font string and set its properties
local fontString = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")  -- Use a predefined font or create your own
fontString:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")  -- Set your desired font, size, and style
fontString:SetPoint("CENTER", btn, "CENTER")  -- Center the text in the button
fontString:SetText("Lore")  -- Set the text

-- Change the text color (RGB values range from 0 to 1)
fontString:SetTextColor(1, 1, 1)  -- Set color to white (RGB: 1, 1, 1)

-- Strip textures
btn:SetNormalTexture(nil)
btn:SetPushedTexture(nil)
btn:SetHighlightTexture(nil)
btn:SetDisabledTexture(nil)

-- Function to save the button position
local function SaveButtonPosition()
    if not MyAddonSavedVars then
        MyAddonSavedVars = {}
    end
    local point, relativeTo, relativePoint, xOfs, yOfs = btn:GetPoint()
    MyAddonSavedVars.btnPoint = point
    MyAddonSavedVars.btnRelativePoint = relativePoint
    MyAddonSavedVars.btnXOfs = xOfs
    MyAddonSavedVars.btnYOfs = yOfs
end

-- Function to restore the button position
local function RestoreButtonPosition()
    if MyAddonSavedVars and MyAddonSavedVars.btnPoint then
        btn:ClearAllPoints()
        btn:SetPoint(MyAddonSavedVars.btnPoint, UIParent, MyAddonSavedVars.btnRelativePoint, MyAddonSavedVars.btnXOfs, MyAddonSavedVars.btnYOfs)
    else
        -- Set a default position if no saved position is found
        btn:SetPoint("TOP", UIParent, "TOP", 0, 0)
    end
end

-- Make the button draggable only with Shift + LeftClick
btn:SetMovable(true)
btn:EnableMouse(true)
btn:RegisterForDrag("LeftButton")

btn:SetScript("OnDragStart", function(self)
    if IsShiftKeyDown() then  -- Check if Shift key is pressed
        this:StartMoving()
    end
end)

btn:SetScript("OnDragStop", function(self)
    this:StopMovingOrSizing()
    SaveButtonPosition()  -- Save the position after dragging stops
end)

-- OnClick script to handle button press
btn:SetScript("OnClick", function(self)
    local targetName = UnitName("target")
    if targetSounds[targetName] then
        PlaySoundFile(targetSounds[targetName], "Master")  -- Play sound for the targeted NPC
    end
end)

-- Restore button position when the addon loads
RestoreButtonPosition()

-- FUNCTIONS ------------------------------------------------------------------
-------------------------------------------------------------------------------

f1:SetScript("OnEvent", function(self, event)
    local playerName = UnitName("player")
    local targetName = UnitName("target")
    local zoneName = GetZoneText()
    local subzoneName = GetSubZoneText()

    -- Initialize player's entry in the table if it doesn't exist
    if not playedSounds[playerName] then
        playedSounds[playerName] = {}
    end

    -- Show or hide button based on target
    if targetSounds[targetName] then
        btn:Show()
    else
        btn:Hide()
    end

    -- Check if zone or subzone has an associated sound
    if (zoneSounds[zoneName] or zoneSounds[subzoneName]) and not (playedSounds[playerName][zoneName] or playedSounds[playerName][subzoneName]) then
        local soundToPlay = zoneSounds[zoneName] or zoneSounds[subzoneName]
        PlaySoundFile(soundToPlay, "Master")
        if zoneSounds[zoneName] then
            playedSounds[playerName][zoneName] = true  -- Mark as played for the zone
        end
        if zoneSounds[subzoneName] then
            playedSounds[playerName][subzoneName] = true  -- Mark as played for the subzone
        end
        lastPlayedSound[playerName] = soundToPlay  -- Store the last played sound
    end

    -- Handle PLAYER_LOGOUT event to save data
    if event == "PLAYER_LOGOUT" then
        -- No additional code needed for saving playedSounds since it's handled automatically
    end
end)


-- EXTRA ----------------------------------------------------------------------
-------------------------------------------------------------------------------

-- Register slash command /replay
SLASH_REPLAY1 = "/replay"
SlashCmdList["REPLAY"] = function()
    local playerName = UnitName("player")
    if lastPlayedSound[playerName] then
        PlaySoundFile(lastPlayedSound[playerName], "Master")
        DEFAULT_CHAT_FRAME:AddMessage("Replaying last zone-lore: " .. lastPlayedSound[playerName])
    else
        DEFAULT_CHAT_FRAME:AddMessage("No zone-lore has been played yet.")
    end
end

end

loremaster = main  -- Assign the main function to a global variable to make it callable