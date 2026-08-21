CoD.Reimagined = {}

-- 1. GLOBAL DATA TABLES
CoD.Reimagined.CamoNames = 
{
    [1] = "Cyberpunk", [2] = "Crystallize", [3] = "Darkmatter", 
    [4] = "Interstellar", [5] = "Lightning", [6] = "Crystallize blue", 
    [7] = "Dragon", [8] = "PurpleMatter", [9] = "BX7", [10] = "VIP",
    [11] = "Gold", [12] = "Psychodelic", [13] = "BO1", [14] = "Purple Royalty",
    [15] = "Blossom", [16] = "Dragon Scale", [17] = "Mystic", [18] = "Cosmic",
    [19] = "Blast", [20] = "Cherry Fizz", [21] = "Cold War"
}

CoD.Reimagined.AatNames = { "Thunder Wall", "Turned", "Blast Furnace", "Shatter Blast", "Cryo Freeze", "Dead Wire", "Fireworks", "Overgrowth" }

CoD.Reimagined.AatColors = 
{
    [1] = {0.85, 0.95, 1}, -- Thunder (White/Blue)
    [2] = {0, 1, 0},       -- Turned (Green)
    [3] = {1, 0.5, 0},     -- Blast (Orange)
    [4] = {1, 0, 0},       -- Shatter (Red)
    [5] = {0, 1, 1},       -- Cryo (Cyan)
    [6] = {0.4, 0, 1},     -- Dead Wire (Purple)
    [7] = {1, 0.84, 0},    -- Fireworks (Yellow/Gold)
    [8] = {0, 1, 0}        -- Overgrowth (Green)
}

CoD.Reimagined.TierColors = 
{ 
    [1] = {0, 1, 0}, [2] = {1, 1, 0}, [3] = {0.2, 0.6, 1}, 
    [4] = {0.6, 0.1, 1}, [5] = {1, 0, 0}, [6] = {1, 0.5, 0} 
}

-- Static PAP hint strings (moved from GSC level.aat_text_max / trigger loop wording)
CoD.Reimagined.PapText = {
    staff_error     = "Cajados não podem entrar nesta máquina.",
    blacklist_error = "Esta arma não pode obter Tiers ou AATs",
    tier_max        = " Esta arma já está no Tier Máximo (^36^7)",
}

-- Comma formatting helper (Lua-side replacement for GSC format_number_with_commas)
local function formatNumberWithCommas(num)
    local formatted = tostring(math.floor(num))
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

LUI.createMenu.ReimaginedArea = function (LocalClientIndex)
    local safeArea = CoD.Menu.NewSafeAreaFromState("ReimaginedArea", LocalClientIndex)
    safeArea:setOwner(LocalClientIndex)

    --------------------------------------------------------
    -- 1. HEALTH BAR WIDGET
    --------------------------------------------------------

    local x = 7
    local y = -35
    local width = 169
    local height = 13
    local bgDiff = 2

    local healthBarWidget = LUI.UIElement.new()
    healthBarWidget:setLeftRight(true, false, x, x)
	healthBarWidget:setTopBottom(false, true, y, y)
    healthBarWidget.width = width
    healthBarWidget.height = height
    healthBarWidget.bgDiff = bgDiff
    safeArea:addElement(healthBarWidget)

    local healthBarBg = LUI.UIImage.new()
	healthBarBg:setLeftRight(true, false, 0, 0 + width)
	healthBarBg:setTopBottom(false, true, 0, 0 + height)
	healthBarBg:setImage(RegisterMaterial("white"))
    healthBarBg:setRGB(0, 0, 0)
    healthBarBg:setAlpha(0.5)
	healthBarWidget:addElement(healthBarBg)
    healthBarWidget.healthBarBg = healthBarBg

    local healthBar = LUI.UIImage.new()
	healthBar:setLeftRight(true, false, bgDiff, width - bgDiff)
	healthBar:setTopBottom(true, false, bgDiff, height - bgDiff)
	healthBar:setImage(RegisterMaterial("white"))
    healthBar:setAlpha(1)
	healthBarWidget:addElement(healthBar)
    healthBarWidget.healthBar = healthBar

    local shieldBar = LUI.UIImage.new()
	shieldBar:setLeftRight(true, false, bgDiff, width - bgDiff)
	shieldBar:setTopBottom(true, false, bgDiff, (height - bgDiff) / 2)
	shieldBar:setImage(RegisterMaterial("white"))
    shieldBar:setRGB(0.5, 0.5, 0.5)
    shieldBar:setAlpha(0)
	healthBarWidget:addElement(shieldBar)
    healthBarWidget.shieldBar = shieldBar

    local healthText = LUI.UIText.new()
    healthText:setLeftRight(true, false, width + bgDiff * 2, 0)
	healthText:setTopBottom(false, true, 0 - bgDiff, height + bgDiff)
    healthText:setFont(CoD.fonts.Big)
    healthText:setAlignment(LUI.Alignment.Left)
    healthBarWidget:addElement(healthText)
    healthBarWidget.healthText = healthText
	
	--------------------------------------------------------
    -- CAMO MENU WIDGET
    --------------------------------------------------------
    local camoMenu = LUI.UIElement.new()
    camoMenu:setLeftRight(false, false, -90, 90) -- Centered
    camoMenu:setTopBottom(true, false, 100, 554) -- FIX: 100 (top offset) + 454 (content height for 22 lines, matching original's topOffset+contentHeight formula) to fit all camos cleanly
    camoMenu:setAlpha(0) -- Hidden until .camo is typed
    safeArea:addElement(camoMenu)

    local menuBg = LUI.UIImage.new()
    menuBg:setLeftRight(true, true, -5, 5)
    menuBg:setTopBottom(true, true, -5, 10)
    menuBg:setRGB(0, 0, 0)
    menuBg:setAlpha(0.8)
    camoMenu:addElement(menuBg)

    local menuTitle = LUI.UIText.new()
    menuTitle:setLeftRight(true, true, 0, 0)
    menuTitle:setTopBottom(true, false, 5, 25)
    menuTitle:setText("^3CAMOS PERSONALIZADAS")
    menuTitle:setFont(CoD.fonts.Condensed)
    camoMenu:addElement(menuTitle)

    -- Create the option elements and store them in a list
    camoMenu.optionLines = {}
    for i = 0, 21 do -- FIX: Changed limit from 10 to 21 to allocate all 22 UI string blocks (0 = map default, 1-21 = camos)
        local opt = LUI.UIText.new()
        opt:setLeftRight(true, true, 8, 0) -- Indent a bit more
        opt:setTopBottom(true, false, 30 + (i * 19), 49 + (i * 19))
        opt:setFont(CoD.fonts.ExtraSmall)
        opt:setAlignment(LUI.Alignment.Left)
        camoMenu:addElement(opt)
        camoMenu.optionLines[i] = opt
    end
	
	--------------------------------------------------------
    -- 3. AAT / WEAPON TIER HUD
    --------------------------------------------------------
    local aatWidget = LUI.UIText.new()
    
    -- Map-Specific Positioning Logic
    local map = Dvar.mapname:get()
    if map == "zm_transit" or map == "zm_highrise" or map == "zm_nuked" then
        aatWidget:setLeftRight(false, true, -275, -110)
        aatWidget:setTopBottom(false, true, -57, -37)  -- Near bottom
    elseif map == "zm_tomb" then
        aatWidget:setLeftRight(false, true, -300, -110)
        aatWidget:setTopBottom(false, true, -135, -115)
    else
        aatWidget:setLeftRight(false, true, -315, -115)
        aatWidget:setTopBottom(false, true, -140, -120)
    end

    aatWidget:setFont(CoD.fonts.Default)
    aatWidget:setAlignment(LUI.Alignment.Right)
    aatWidget:setAlpha(0)
	aatWidget.activeData = false -- IMPORTANT: Tells the HUD if there is data to show
    aatWidget.visible = false    -- IMPORTANT: Syncs with the visibility handler
    safeArea:addElement(aatWidget)

    -- Event Handler
    aatWidget:registerEventHandler("bx7_aat_update", function(element, event)
        local tier, modID = event.data[1], event.data[2]

        if tier == 0 and modID == 0 then
            element:setAlpha(0)
            return
        end

        element:setAlpha(1)
        
        -- Set Text
        local str = ""
        if tier > 0 and modID > 0 then
            str = "TIER " .. tier .. " - " .. (aatNames[modID] or "")
        elseif tier > 0 then
            str = "TIER " .. tier
        else
            str = aatNames[modID] or ""
        end
        element:setText(str)

        -- Set Color (Priority to Mod Color, then Tier Color)
        if modID > 0 and aatColors[modID] then
            element:setRGB(aatColors[modID][1], aatColors[modID][2], aatColors[modID][3])
        elseif tier > 0 and tierColors[tier] then
            element:setRGB(tierColors[tier][1], tierColors[tier][2], tierColors[tier][3])
        else
            element:setRGB(1, 1, 1)
        end
    end)

	--------------------------------------------------------
    -- 3.5 PAP TIER / AAT INTERACTION PROMPT (NEW)
    --------------------------------------------------------
    local papHud = LUI.UIText.new()
    papHud:setLeftRight(false, false, -300, 300)   -- Wide centered box for multi-line prompts
    papHud:setTopBottom(false, true, -110, -75)    -- Roughly matches old newClientHudElem y = -80
    papHud:setFont(CoD.fonts.Default)
    papHud:setAlignment(LUI.Alignment.Center)
    papHud:setScale(1.2)
    papHud:setRGB(1, 1, 1)
    papHud:setAlpha(0)
    papHud.activeData = false
    papHud.visible = false
    safeArea:addElement(papHud)

    -- Event Handler: state, next_tier, cost
    papHud:registerEventHandler("bx7_pap_hud", function(element, event)
        local state = event.data[1] or 0
        local nextTier = event.data[2] or 0
        local cost = event.data[3] or 0

        if state == 0 then
            element.activeData = false
            element:setAlpha(0)
            element.visible = false
            return
        end

        element.activeData = true
        element:setRGB(1, 1, 1)

        local displayCost = formatNumberWithCommas(cost)
        local str = ""

        if state == 1 then
            str = CoD.Reimagined.PapText.staff_error
        elseif state == 2 then
            str = CoD.Reimagined.PapText.blacklist_error
        elseif state == 3 then
            str = CoD.Reimagined.PapText.tier_max .. " \n ^3[Facada/Melee para aplicar/trocar munição AAT]^7"
        elseif state == 4 then
            str = "^1CONFIRMAR TIER " .. nextTier .. "?^7 [Custo: " .. displayCost .. "] \n ^3[Facada/Melee para Cancelar]^7"
        elseif state == 5 then
            str = "Pressione ^3[USE]^7 para TIER " .. nextTier .. " [Custo: " .. displayCost .. "]\nCUSTOS diminuem conforme o Round. \n ^3[Facada/Melee para aplicar/trocar munição AAT]^7"
        elseif state == 6 then
            str = "Pressione ^3[USE]^7 para aplicar uma Munição AAT [Custo: " .. displayCost .. "] \n ^3[Facada/Melee para aplicar/trocar munição AAT]^7"
        end

        element:setText(str)
        CoD.Reimagined.HealthBarArea.UpdateVisibility(element, {controller = LocalClientIndex})
    end)

    --------------------------------------------------------
    -- 5. RANK / XP BAR & SPLASH
    --------------------------------------------------------
    local xpBarWidth = 300      -- RPG Style Width
    local xpBarHeight = 12
    local xStart = -(xpBarWidth / 2)
    local xEnd = (xpBarWidth / 2)
    local yPos = -60            -- 50 pixels from bottom center

    -- Parent Container
    local xpWidget = LUI.UIElement.new()
    xpWidget:setLeftRight(false, false, xStart, xEnd)
    xpWidget:setTopBottom(false, true, yPos, yPos + xpBarHeight)
    xpWidget.visible = true
    safeArea:addElement(xpWidget)

    -- 1. THE "LVL:" LABEL (Always Orange)
    local lvlLabel = LUI.UIText.new()
	lvlLabel:setScale(1.2)
    lvlLabel:setLeftRight(true, true, 0, 0)
    lvlLabel:setTopBottom(false, true, -32, -15) 
    lvlLabel:setFont(CoD.fonts.Big)
    lvlLabel:setRGB(1, 0.5, 0) 
    lvlLabel:setText("LVL: ")
    lvlLabel:setAlignment(LUI.Alignment.Center)
    xpWidget:addElement(lvlLabel)

    -- 2. THE LEVEL NUMBER (Always White)
    local lvlNumber = LUI.UIText.new()
	lvlNumber:setScale(1.3)
    lvlNumber:setLeftRight(true, true, 66, 0) -- Nudged right of center
    lvlNumber:setTopBottom(false, true, -33, -16)
    lvlNumber:setFont(CoD.fonts.Default)
    lvlNumber:setRGB(1, 1, 1)
    lvlNumber:setText("0")
    lvlNumber:setAlignment(LUI.Alignment.Center)
    xpWidget:addElement(lvlNumber)

    -- 3. XP Background
    local xpBg = LUI.UIImage.new()
    xpBg:setLeftRight(true, true, 0, 0)
    xpBg:setTopBottom(true, true, 0, 0)
    xpBg:setRGB(0.1, 0.1, 0.1)
    xpBg:setAlpha(0.7)
    xpWidget:addElement(xpBg)

    -- 4. XP Blue Bar (Foreground)
    local xpFg = LUI.UIImage.new()
    xpFg:setLeftRight(true, false, 0, 0)
    xpFg:setTopBottom(true, true, 0, 0)
    xpFg:setRGB(0, 0.6, 1)
    xpWidget:addElement(xpFg)

    --------------------------------------------------------
    -- 6. BIG RANK UP SPLASH (Treyarch-Style)
    --------------------------------------------------------
    -- Container to move everything together
    local splashGroup = LUI.UIElement.new()
    splashGroup:setLeftRight(false, false, -500, 500) -- Very wide to fit big text
    splashGroup:setTopBottom(false, false, -160, -100) -- Taller box for big scale
    splashGroup:setAlpha(0)
    safeArea:addElement(splashGroup)

    -- The Shadow (Black, offset slightly)
    local splashShadow = LUI.UIText.new()
    splashShadow:setLeftRight(true, true, 2, 2) -- Offset by 2 pixels
    splashShadow:setTopBottom(true, true, 2, 2) -- Offset by 2 pixels
    splashShadow:setFont(CoD.fonts.Big)
    splashShadow:setRGB(0, 0, 0)
    splashShadow:setAlpha(0.5)
    splashShadow:setScale(0.6) -- THE SCALE: Change this to make it bigger/smaller
    splashGroup:addElement(splashShadow)

    -- The Main Text (White)
    local splashMain = LUI.UIText.new()
    splashMain:setLeftRight(true, true, 0, 0)
    splashMain:setTopBottom(true, true, 0, 0)
    splashMain:setFont(CoD.fonts.Big)
    splashMain:setRGB(1, 1, 1)
    splashMain:setScale(0.6) -- MATCH the shadow scale
    splashGroup:addElement(splashMain)

    -- HANDLER: XP Bar Updates
    xpWidget:registerEventHandler("bx7_xp_update", function(element, event)
        -- event.data[1] = Level
        -- event.data[2] = Progress Fraction (multiplied by 1000 in GSC)
        local level = event.data[1] or 1
        local frac = (event.data[2] or 0) / 1000

        -- Update the white number element specifically
        lvlNumber:setText(level)

        -- Animate the blue bar filling up
        -- Using xpBarWidth here ensures it works for both 90px and 300px versions
        xpFg:beginAnimation("progress", 500)
        xpFg:setLeftRight(true, false, 0, xpBarWidth * frac)
    end)

    --------------------------------------------------------
    -- HANDLERS
    --------------------------------------------------------
    splashGroup:registerEventHandler("bx7_rank_up_splash", function(element, event)
        local newLevel = event.data[1] or 0
        local fullStr = "Você subiu para o nível ^5" .. newLevel
        
        -- Set text for both layers
        splashMain:setText(fullStr)
        splashShadow:setText(fullStr)
        
        -- Animation: Fade In
        element:beginAnimation("fade_in", 500)
        element:setAlpha(1)
        
        -- Timer for 6 seconds
        element:addElement(LUI.UITimer.new(6000, "start_fade_out", true))
    end)

    splashGroup:registerEventHandler("start_fade_out", function(element, event)
        element:beginAnimation("fade_out", 500)
        element:setAlpha(0)
    end)
	
	--------------------------------------------------------
    -- 4. POWERUP TRACKER WIDGET (NEW)
    --------------------------------------------------------
    local puTracker = LUI.UIElement.new()
    puTracker:setLeftRight(true, false, 7, 150) -- Anchored Left
    puTracker:setTopBottom(true, false, 525, 845)
    puTracker:setAlpha(0)
    safeArea:addElement(puTracker)

    local puTitle = LUI.UIText.new()
    puTitle:setLeftRight(true, true, 0, 0)
    puTitle:setTopBottom(true, false, 0, 15)
    puTitle:setText("^3POWERUP CYCLE")
    puTitle:setFont(CoD.fonts.Default)
    puTitle:setAlignment(LUI.Alignment.Left)
    puTracker:addElement(puTitle)

    local rdCounter = LUI.UIText.new()
    rdCounter:setLeftRight(true, true, 0, 0)
    rdCounter:setTopBottom(true, false, 16, 30)
    rdCounter:setText("Round Drops: 0/4")
    rdCounter:setFont(CoD.fonts.Default)
    rdCounter:setAlignment(LUI.Alignment.Left)
    puTracker:addElement(rdCounter)

    local puNames = {
        [1] = "Max Ammo", [2] = "Double Points", [3] = "Insta-Kill",
        [4] = "Fire Sale", [5] = "Zombie Blood", [6] = "Nuke", [7] = "Free Perk",
        [8] = "Bonus Points"
    }
    
    puTracker.lines = {}
    for i = 1, 9 do -- CHANGED FROM 7 TO 9
        local line = LUI.UIText.new()
        line:setLeftRight(true, true, 0, 0)
        line:setTopBottom(true, false, 0, 0) 
        line:setFont(CoD.fonts.Default)
        line:setAlignment(LUI.Alignment.Left)
        line:setAlpha(0)
        puTracker:addElement(line)
        puTracker.lines[i] = line
    end
	
	--------------------------------------------------------
    -- EVENT HANDLERS
    --------------------------------------------------------
	

    healthBarWidget:registerEventHandler("hud_update_refresh", CoD.Reimagined.HealthBarArea.UpdateVisibility)
	healthBarWidget:registerEventHandler("hud_update_bit_" .. CoD.BIT_HUD_VISIBLE, CoD.Reimagined.HealthBarArea.UpdateVisibility)
    healthBarWidget:registerEventHandler("hud_update_bit_" .. CoD.BIT_IS_PLAYER_IN_AFTERLIFE, CoD.Reimagined.HealthBarArea.UpdateVisibility)
	healthBarWidget:registerEventHandler("hud_update_bit_" .. CoD.BIT_EMP_ACTIVE, CoD.Reimagined.HealthBarArea.UpdateVisibility)
	healthBarWidget:registerEventHandler("hud_update_bit_" .. CoD.BIT_DEMO_CAMERA_MODE_MOVIECAM, CoD.Reimagined.HealthBarArea.UpdateVisibility)
	healthBarWidget:registerEventHandler("hud_update_bit_" .. CoD.BIT_DEMO_ALL_GAME_HUD_HIDDEN, CoD.Reimagined.HealthBarArea.UpdateVisibility)
	healthBarWidget:registerEventHandler("hud_update_bit_" .. CoD.BIT_IN_VEHICLE, CoD.Reimagined.HealthBarArea.UpdateVisibility)
	healthBarWidget:registerEventHandler("hud_update_bit_" .. CoD.BIT_IN_GUIDED_MISSILE, CoD.Reimagined.HealthBarArea.UpdateVisibility)
	healthBarWidget:registerEventHandler("hud_update_bit_" .. CoD.BIT_IN_REMOTE_KILLSTREAK_STATIC, CoD.Reimagined.HealthBarArea.UpdateVisibility)
	healthBarWidget:registerEventHandler("hud_update_bit_" .. CoD.BIT_AMMO_COUNTER_HIDE, CoD.Reimagined.HealthBarArea.UpdateVisibility)
	healthBarWidget:registerEventHandler("hud_update_bit_" .. CoD.BIT_IS_FLASH_BANGED, CoD.Reimagined.HealthBarArea.UpdateVisibility)
	healthBarWidget:registerEventHandler("hud_update_bit_" .. CoD.BIT_UI_ACTIVE, CoD.Reimagined.HealthBarArea.UpdateVisibility)
	healthBarWidget:registerEventHandler("hud_update_bit_" .. CoD.BIT_SPECTATING_CLIENT, CoD.Reimagined.HealthBarArea.UpdateVisibility)
	healthBarWidget:registerEventHandler("hud_update_bit_" .. CoD.BIT_SCOREBOARD_OPEN, CoD.Reimagined.HealthBarArea.UpdateVisibility)
	healthBarWidget:registerEventHandler("hud_update_bit_" .. CoD.BIT_PLAYER_DEAD, CoD.Reimagined.HealthBarArea.UpdateVisibility)
	healthBarWidget:registerEventHandler("hud_update_bit_" .. CoD.BIT_IS_SCOPED, CoD.Reimagined.HealthBarArea.UpdateVisibility)
	healthBarWidget:registerEventHandler("hud_update_bit_" .. CoD.BIT_IS_PLAYER_ZOMBIE, CoD.Reimagined.HealthBarArea.UpdateVisibility)
    healthBarWidget:registerEventHandler("hud_update_health_bar", CoD.Reimagined.HealthBarArea.UpdateHealthBar)
	
	-- AAT Visibility Listeners
    aatWidget:registerEventHandler("hud_update_refresh", CoD.Reimagined.HealthBarArea.UpdateVisibility)
    aatWidget:registerEventHandler("hud_update_bit_" .. CoD.BIT_HUD_VISIBLE, CoD.Reimagined.HealthBarArea.UpdateVisibility)
    aatWidget:registerEventHandler("hud_update_bit_" .. CoD.BIT_SCOREBOARD_OPEN, CoD.Reimagined.HealthBarArea.UpdateVisibility)
    aatWidget:registerEventHandler("hud_update_bit_" .. CoD.BIT_UI_ACTIVE, CoD.Reimagined.HealthBarArea.UpdateVisibility)
    aatWidget:registerEventHandler("hud_update_bit_" .. CoD.BIT_IS_PLAYER_IN_AFTERLIFE, CoD.Reimagined.HealthBarArea.UpdateVisibility)

    -- PAP HUD Visibility Listeners
    papHud:registerEventHandler("hud_update_refresh", CoD.Reimagined.HealthBarArea.UpdateVisibility)
    papHud:registerEventHandler("hud_update_bit_" .. CoD.BIT_HUD_VISIBLE, CoD.Reimagined.HealthBarArea.UpdateVisibility)
    papHud:registerEventHandler("hud_update_bit_" .. CoD.BIT_SCOREBOARD_OPEN, CoD.Reimagined.HealthBarArea.UpdateVisibility)
    papHud:registerEventHandler("hud_update_bit_" .. CoD.BIT_UI_ACTIVE, CoD.Reimagined.HealthBarArea.UpdateVisibility)
    papHud:registerEventHandler("hud_update_bit_" .. CoD.BIT_IS_PLAYER_IN_AFTERLIFE, CoD.Reimagined.HealthBarArea.UpdateVisibility)
	
	-- AAT Data Handler
    aatWidget:registerEventHandler("bx7_aat_update", function(element, event)
        local tier, modID = event.data[1], event.data[2]

        if (not tier or tier == 0) and (not modID or modID == 0) then
            element.activeData = false
            element:setAlpha(0)
            element.visible = false
            return
        end

        element.activeData = true
        
        local str = ""
        if tier > 0 and modID > 0 then 
            str = "TIER " .. tier .. " - " .. (CoD.Reimagined.AatNames[modID] or "")
        elseif tier > 0 then 
            str = "TIER " .. tier
        else 
            str = CoD.Reimagined.AatNames[modID] or "" 
        end
        element:setText(str)

        -- Color Logic using Global Tables
        if modID > 0 and CoD.Reimagined.AatColors[modID] then
            local c = CoD.Reimagined.AatColors[modID]
            element:setRGB(c[1], c[2], c[3])
        elseif tier > 0 and CoD.Reimagined.TierColors[tier] then
            local c = CoD.Reimagined.TierColors[tier]
            element:setRGB(c[1], c[2], c[3])
        end

        CoD.Reimagined.HealthBarArea.UpdateVisibility(element, {controller = LocalClientIndex})
    end)
	
    -- CAMO MENU EVENT HANDLER
    camoMenu:registerEventHandler("bx7_camo_menu_state", function(element, event)
        local state = event.data[1]
        local bitmask = event.data[2] or 0
        	
        if state == 1 then
            -- Update colors before showing
            for i = 0, 21 do -- FIX: Increased validation state loop bound to cover all 21 camos
                local name = (i == 0) and "Padrão do Mapa" or (CoD.Reimagined.CamoNames[i] or "Unknown")
                local color = "^1" -- Default Red (Locked)
                	
                -- Bitwise check: Is the i-th bit set?
                if i == 0 or math.floor(bitmask / math.pow(2, i-1)) % 2 == 1 then
                    color = "^2" -- Green (Owned)
                end
                	
                element.optionLines[i]:setText(color .. "[" .. i .. "] " .. name)
            end
            element:setAlpha(1)
        else
            element:setAlpha(0)
        end
    end)
	
	-- Powerup Tracker Event (NEW)
    puTracker:registerEventHandler("bx7_powerup_update", function(element, event)
        local state, rdCount, revealed, dropped = event.data[1], event.data[2], event.data[3], event.data[4]
        if state == 1 then
            element:setAlpha(1)
            rdCounter:setText("^7Round Drops: ^7" .. rdCount .. "^7/4")
            local visibleCount = 0
            
            for i = 1, 9 do -- CHANGED FROM 7 TO 9
                local isRevealed = math.floor(revealed / math.pow(2, i-1)) % 2 == 1
                local isDropped = math.floor(dropped / math.pow(2, i-1)) % 2 == 1
                if isRevealed then
                    visibleCount = visibleCount + 1
                    element.lines[i]:setAlpha(1)
                    element.lines[i]:setText(puNames[i])
                    element.lines[i]:setTopBottom(true, false, 32 + ((visibleCount - 1) * 14), 46 + ((visibleCount - 1) * 14))
                    if isDropped then element.lines[i]:setRGB(0, 0.6, 1) else element.lines[i]:setRGB(1, 1, 1) end
                else element.lines[i]:setAlpha(0) end
            end
        else element:setAlpha(0) end
    end)

    healthBarWidget.visible = true

    return safeArea
end

CoD.Reimagined.HealthBarArea = {}
CoD.Reimagined.HealthBarArea.UpdateVisibility = function (Menu, ClientInstance)
    -- 1. THE GATEKEEPER: If this is the AAT/PAP widget and it has no data (activeData is false), 
    -- force it to stay hidden and exit the function early.
    if Menu.activeData ~= nil and Menu.activeData == false then 
        Menu:setAlpha(0)
        Menu.visible = false
        return 
    end

    local controller = ClientInstance.controller

    -- 2. THE ENGINE CHECKS: Check all the game's visibility bits (Scoreboard, Dead, Afterlife, etc.)
    if UIExpression.IsVisibilityBitSet(controller, CoD.BIT_HUD_VISIBLE) == 1 
    and UIExpression.IsVisibilityBitSet(controller, CoD.BIT_IS_PLAYER_IN_AFTERLIFE) == 0 
    and UIExpression.IsVisibilityBitSet(controller, CoD.BIT_EMP_ACTIVE) == 0 
    and UIExpression.IsVisibilityBitSet(controller, CoD.BIT_DEMO_CAMERA_MODE_MOVIECAM) == 0 
    and UIExpression.IsVisibilityBitSet(controller, CoD.BIT_DEMO_ALL_GAME_HUD_HIDDEN) == 0 
    and UIExpression.IsVisibilityBitSet(controller, CoD.BIT_IN_VEHICLE) == 0 
    and UIExpression.IsVisibilityBitSet(controller, CoD.BIT_IN_GUIDED_MISSILE) == 0 
    and UIExpression.IsVisibilityBitSet(controller, CoD.BIT_IN_REMOTE_KILLSTREAK_STATIC) == 0 
    and UIExpression.IsVisibilityBitSet(controller, CoD.BIT_AMMO_COUNTER_HIDE) == 0 
    and UIExpression.IsVisibilityBitSet(controller, CoD.BIT_IS_FLASH_BANGED) == 0 
    and UIExpression.IsVisibilityBitSet(controller, CoD.BIT_UI_ACTIVE) == 0 
    and UIExpression.IsVisibilityBitSet(controller, CoD.BIT_SCOREBOARD_OPEN) == 0 
    and UIExpression.IsVisibilityBitSet(controller, CoD.BIT_IN_KILLCAM) == 0 
    and UIExpression.IsVisibilityBitSet(controller, CoD.BIT_IS_SCOPED) == 0 
    and UIExpression.IsVisibilityBitSet(controller, CoD.BIT_IS_PLAYER_ZOMBIE) == 0 
    and (not CoD.IsShoutcaster(controller) or CoD.ExeProfileVarBool(controller, "shoutcaster_scorestreaks") and Engine.IsSpectatingActiveClient(controller)) 
    and CoD.FSM_VISIBILITY(controller) == 0 then
        
        -- 3. SHOW THE HUD: If all checks passed and it's not already visible
        if Menu.visible ~= true then
            Menu:setAlpha(1)
            Menu.visible = true
        end
    
    -- 4. HIDE THE HUD: If any check above fails, hide the widget
    elseif Menu.visible == true then
        Menu:setAlpha(0)
        Menu.visible = false
    end
end

CoD.Reimagined.HealthBarArea.UpdateHealthBar = function(Menu, ClientInstance)
	local health = ClientInstance.data[1]
	local maxHealth = ClientInstance.data[2]
	local shieldHealth = ClientInstance.data[3]
	local healthPercent = health / maxHealth
	local shieldHealthPercent = shieldHealth / 100

	local healthWidth = math.max(3, (Menu.width * healthPercent) - Menu.bgDiff)

	if shieldHealthPercent > 0 then
		local shieldHealthWidth = math.max(3, (Menu.width * shieldHealthPercent) - Menu.bgDiff)

		Menu.shieldBar:setAlpha(1)

		Menu.shieldBar:beginAnimation("slide", 50, true, true)
		Menu.shieldBar:setLeftRight(true, false, Menu.bgDiff, shieldHealthWidth)

		Menu.healthBar:setTopBottom(true, false, (Menu.height + Menu.bgDiff) / 2, Menu.height - Menu.bgDiff)
		Menu.healthText:setText(health .. " | " .. shieldHealth)
	else
		Menu.shieldBar:setAlpha(0)

		Menu.healthBar:setTopBottom(true, false, Menu.bgDiff, Menu.height - Menu.bgDiff)
		Menu.healthText:setText(health)
	end

	Menu.healthBar:beginAnimation("slide", 50, true, true)
	Menu.healthBar:setLeftRight(true, false, Menu.bgDiff, healthWidth)
end