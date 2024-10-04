-- loremaster-init.lua

-- Declare a global table for SavedVariables
MyAddon_CharacterSaved = MyAddon_CharacterSaved or { FirstTimeLoaded = false }

-- Function to load loremaster.lua
local function LoadLoremaster()
    if loremaster then
        loremaster()  -- Call the main function from loremaster.lua if it exists
    end
end

-- Function to initialize the addon
local function InitializeAddon()
    -- Check if this character has loaded the addon for the first time
    if not MyAddon_CharacterSaved.FirstTimeLoaded then
        -- Create the Start button
		local btn = CreateFrame("Button", nil, UIParent, "UIPanelButtonTemplate")
        btn:SetPoint("TOP", UIParent, "TOP", 0, 0)
        btn:SetWidth(100)
        btn:SetHeight(30)
        btn:Show()
		
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
			edgeSize = 1,  -- Size of the border
			insets = { left = 4, right = 4, top = 4, bottom = 4 }  -- Insets
		})
		backdrop:SetBackdropColor(0, 0, 0, 0.8)  -- Set backdrop color to black with some transparency (RGBA)

		-- Create a font string and set its properties
		local fontString = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")  -- Use a predefined font or create your own
		fontString:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")  -- Set your desired font, size, and style
		fontString:SetPoint("CENTER", btn, "CENTER")  -- Center the text in the button
		fontString:SetText("Start")  -- Set the text

		-- Change the text color (RGB values range from 0 to 1)
		fontString:SetTextColor(1, 1, 1)  -- Set color to yellow (RGB: 1, 1, 0)

		-- Strip textures
		btn:SetNormalTexture(nil)
		btn:SetPushedTexture(nil)
		btn:SetHighlightTexture(nil)
		btn:SetDisabledTexture(nil)

        -- OnClick script to handle button press
        btn:SetScript("OnClick", function()
            -- Save that the addon has been started for this character
            MyAddon_CharacterSaved.FirstTimeLoaded = true
            -- Hide the button
            btn:Hide()
			ReloadUI()
            -- Welcome message
            LoadLoremaster()  -- Load the loremaster functions
        end)
    else
        -- If not the first time, execute the welcome message immediately
        LoadLoremaster()  -- Load the loremaster functions
    end
end

-- Event handler for when the addon is loaded
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN") -- Trigger after login
frame:SetScript("OnEvent", function()
    InitializeAddon()
end)
