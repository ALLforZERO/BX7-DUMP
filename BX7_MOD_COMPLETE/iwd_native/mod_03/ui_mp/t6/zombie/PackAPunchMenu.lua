require("T6.CoDBase")

CoD.PackAPunchMenu = {}
CoD.PackAPunchMenu.ActiveMenu = nil

local aatIndexMap = {
    [1] = "aat_turned",
    [2] = "aat_blastfurnace",
    [3] = "aat_shatterblast",
    [4] = "aat_cryofreeze",
    [5] = "aat_deadwire",
    [6] = "aat_overgrowth"
}

LUI.createMenu.pack_a_punch_menu = function(controller)
    local menu = CoD.Menu.New("pack_a_punch_menu")
    if not menu then return nil end

    menu.isPopup = true
    if CoD.Menu.MakePopup then
        CoD.Menu.MakePopup(menu)
    end

    menu:setOwner(controller)
    menu:setHandleMouse(true)
    menu:registerEventHandler("mousemove", CoD.Menu.MouseMove)
    menu:registerEventHandler("mousedown", CoD.Menu.MouseDown)

    -- Default State Properties
    menu.currentTier    = 0
    menu.atMaxTier      = false
    menu.nextTierCost   = 0
    menu.aatCost        = 3000
    menu.currentAatCode = ""

    local function closeMenu(ctrl)
        Engine.SendMenuResponse(ctrl, "pack_a_punch_menu", "close")
        CoD.Menu.goBack(menu, ctrl)
        CoD.PackAPunchMenu.ActiveMenu = nil
    end

    -- Close via ESC Key (PC)
    menu:registerEventHandler("key_down", function(element, event)
        if event.key == 27 then
            closeMenu(event.controller)
            return true
        end
    end)

    -- Close via Controller Back / B Button
    menu:registerEventHandler("button_prompt_back", function(element, event)
        closeMenu(event.controller)
        return true
    end)

    if menu.addBackButton then
        menu:addBackButton()
    else
        CoD.Menu.AddBackButton(menu)
    end

    -- ==========================================================
    -- MAIN PANEL CANVAS (400x270 Centered)
    -- ==========================================================
    local frame = LUI.UIElement.new()
    frame:setLeftRight(false, false, -200, 200)
    frame:setTopBottom(false, false, -135, 135)
    menu:addElement(frame)

    local bg = LUI.UIImage.new()
    bg:setLeftRight(true, true, 0, 0)
    bg:setTopBottom(true, true, 0, 0)
    pcall(function()
        bg:setImage(RegisterMaterial("ui_menu_wonderfizz"))
    end)
    bg:setRGB(1, 1, 1)
    bg:setAlpha(1.0)
    frame:addElement(bg)

    -- Main Header Title
    local title = LUI.UIText.new()
    title:setLeftRight(true, true, 12, -12)
    title:setTopBottom(true, false, 4, 26)
    title:setText("PACK-A-PUNCH")
    title:setFont(CoD.fonts.Big)
    title:setAlignment(LUI.Alignment.Center)
    title:setRGB(0.2, 0.2, 0.2)
    frame:addElement(title)

    -- Round Cost Scaling Subtitle (Larger & Yellow)
    local subTitle = LUI.UIText.new()
    subTitle:setLeftRight(true, true, 12, -12)
    subTitle:setTopBottom(true, false, 30, 48)
    subTitle:setText("Custos diminuem até o Round 40")
    subTitle:setFont(CoD.fonts.Condensed)
    subTitle:setAlignment(LUI.Alignment.Center)
    subTitle:setRGB(1.0, 0.85, 0.15)
    frame:addElement(subTitle)

    -- Context Info Header (Shifted down past the background dashed line)
    local infoHeader = LUI.UIText.new()
    infoHeader:setLeftRight(true, true, 12, -12)
    infoHeader:setTopBottom(true, false, 52, 68)
    infoHeader:setText("SELECIONE UMA OPÇÃO")
    infoHeader:setFont(CoD.fonts.Condensed)
    infoHeader:setAlignment(LUI.Alignment.Center)
    infoHeader:setRGB(0.85, 0.65, 0.12)
    frame:addElement(infoHeader)

    -- Cost / State Display
    local costHeader = LUI.UIText.new()
    costHeader:setLeftRight(true, true, 12, -12)
    costHeader:setTopBottom(true, false, 68, 82)
    costHeader:setText("")
    costHeader:setFont(CoD.fonts.Condensed)
    costHeader:setAlignment(LUI.Alignment.Center)
    costHeader:setRGB(0.85, 0.70, 0.15)
    frame:addElement(costHeader)

    -- ==========================================================
    -- SCOPED NAVIGATION VARIABLES
    -- ==========================================================
    local focusRow, focusCol = 0, 0
    local rows = {}

    local function focusCard(r, c, ctrl)
        if focusRow > 0 and rows[focusRow] and rows[focusRow][focusCol] then
            rows[focusRow][focusCol]:processEvent({ name = "lose_focus", controller = ctrl })
        end
        focusRow, focusCol = r, c
        if rows[focusRow] and rows[focusRow][focusCol] then
            rows[focusRow][focusCol]:processEvent({ name = "gain_focus", controller = ctrl })
        end
    end

    -- Grid Parameters (Adjusted startY to 84 for clean clearance under costHeader)
    local cardW, cardH = 54, 48
    local gapX, gapY = 6, 6
    local startY = 84
    local startX = 23

    -- ==========================================================
    -- ROW 1: TIER LEVELS
    -- ==========================================================
    local romanNumerals = { "I", "II", "III", "IV", "V", "VI" }
    local tierRow = {}

    for tier = 1, 6 do
        local col = tier - 1
        local xL = startX + col * (cardW + gapX)

        local card = LUI.UIButton.new()
        card:setLeftRight(true, false, xL, xL + cardW)
        card:setTopBottom(true, false, startY, startY + cardH)
        card:setHandleMouse(true)
        card.tier = tier

        local cardBG = LUI.UIImage.new()
        cardBG:setLeftRight(true, true, 0, 0)
        cardBG:setTopBottom(true, true, 0, 0)
        cardBG:setImage(RegisterMaterial("white"))
        cardBG:setAlpha(0.95)
        cardBG:setHandleMouse(false)
        card:addElement(cardBG)

        local icon = LUI.UIImage.new()
        icon:setLeftRight(true, true, 4, -4)
        icon:setTopBottom(true, true, 4, -4)
        pcall(function()
            icon:setImage(RegisterMaterial("tier"))
        end)
        icon:setHandleMouse(false)
        card:addElement(icon)

        local label = LUI.UIText.new()
        label:setLeftRight(true, true, 0, 0)
        label:setTopBottom(false, true, -18, -2)
        label:setText(romanNumerals[tier] or tostring(tier))
        label:setFont(CoD.fonts.Condensed)
        label:setAlignment(LUI.Alignment.Center)
        label:setHandleMouse(false)
        card:addElement(label)

        -- In-place dynamic state evaluator
        card.updateVisuals = function()
            if card.tier <= menu.currentTier then
                card.kind = "owned"
                cardBG:setRGB(0.25, 0.25, 0.25)
                icon:setAlpha(0.35)
                label:setRGB(0.6, 0.6, 0.6)
                label:setAlpha(0.6)
            elseif card.tier == menu.currentTier + 1 and not menu.atMaxTier then
                card.kind = "next"
                cardBG:setRGB(0.45, 0.45, 0.45)
                icon:setAlpha(1.0)
                label:setRGB(1, 0.9, 0.5)
                label:setAlpha(1.0)
            else
                card.kind = "locked"
                cardBG:setRGB(0.18, 0.18, 0.18)
                icon:setAlpha(0.20)
                label:setRGB(0.4, 0.4, 0.4)
                label:setAlpha(0.4)
            end
        end
        card:updateVisuals()

        card:registerEventHandler("gain_focus", function(element, event)
            focusRow, focusCol = 1, tier
            
            if card.kind == "owned" then
                infoHeader:setText("TIER " .. tier)
                costHeader:setText("JÁ ADQUIRIDO")
                costHeader:setRGB(0.5, 0.5, 0.5)
            elseif card.kind == "next" then
                infoHeader:setText("UPGRADE PARA TIER " .. tier)
                costHeader:setText("$" .. tostring(menu.nextTierCost))
                costHeader:setRGB(0.85, 0.70, 0.15)
                cardBG:setRGB(0.82, 0.62, 0.12)
            else
                infoHeader:setText("TIER " .. tier)
                costHeader:setText("BLOQUEADO")
                costHeader:setRGB(0.5, 0.5, 0.5)
            end
            return true
        end)

        card:registerEventHandler("lose_focus", function(element, event)
            if card.kind == "owned" then 
                cardBG:setRGB(0.25, 0.25, 0.25)
            elseif card.kind == "next" then 
                cardBG:setRGB(0.45, 0.45, 0.45)
            else 
                cardBG:setRGB(0.18, 0.18, 0.18) 
            end
            return true
        end)

        card:registerEventHandler("button_action", function(element, event)
            if card.kind == "next" then
                Engine.SendMenuResponse(event.controller, "pack_a_punch_menu", "tier")
            end
            return true
        end)

        table.insert(tierRow, card)
        frame:addElement(card)
    end
    table.insert(rows, tierRow)

    -- ==========================================================
    -- ROW 2: AAT AMMO MODS
    -- ==========================================================
    local aatMasterList = {
        { name = "Turned",        material = "turned",        code = "aat_turned" },
        { name = "Blast Furnace", material = "blastfurnace",  code = "aat_blastfurnace" },
        { name = "Shatter Blast", material = "shatterblast",  code = "aat_shatterblast" },
        { name = "Cryo Freeze",   material = "cryofreeze",    code = "aat_cryofreeze" },
        { name = "Dead Wire",     material = "deadwire",      code = "aat_deadwire" },
        { name = "Overgrowth",    material = "overgrowth",    code = "aat_overgrowth" },
    }

    local aatRow = {}
    local row2Y = startY + cardH + gapY

    for i, mod in ipairs(aatMasterList) do
        local col = i - 1
        local xL = startX + col * (cardW + gapX)

        local card = LUI.UIButton.new()
        card:setLeftRight(true, false, xL, xL + cardW)
        card:setTopBottom(true, false, row2Y, row2Y + cardH)
        card:setHandleMouse(true)
        card.mod = mod

        local cardBG = LUI.UIImage.new()
        cardBG:setLeftRight(true, true, 0, 0)
        cardBG:setTopBottom(true, true, 0, 0)
        cardBG:setImage(RegisterMaterial("white"))
        cardBG:setAlpha(0.95)
        cardBG:setHandleMouse(false)
        card:addElement(cardBG)

        local icon = LUI.UIImage.new()
        icon:setLeftRight(true, true, 4, -4)
        icon:setTopBottom(true, true, 4, -4)
        pcall(function()
            icon:setImage(RegisterMaterial(mod.material))
        end)
        icon:setHandleMouse(false)
        card:addElement(icon)

        card.updateVisuals = function()
            card.isCurrent = (menu.currentAatCode == mod.code)
            if card.isCurrent then
                cardBG:setRGB(0.25, 0.25, 0.25)
                icon:setAlpha(0.4)
            else
                cardBG:setRGB(0.45, 0.45, 0.45)
                icon:setAlpha(1.0)
            end
        end
        card:updateVisuals()

        card:registerEventHandler("gain_focus", function(element, event)
            focusRow, focusCol = 2, i
            
            infoHeader:setText(string.upper(mod.name))
            if card.isCurrent then
                costHeader:setText("EQUIPADO")
                costHeader:setRGB(0.5, 0.5, 0.5)
            else
                costHeader:setText("$" .. tostring(menu.aatCost))
                costHeader:setRGB(0.85, 0.70, 0.15)
                cardBG:setRGB(0.82, 0.62, 0.12)
            end
            return true
        end)

        card:registerEventHandler("lose_focus", function(element, event)
            if card.isCurrent then 
                cardBG:setRGB(0.25, 0.25, 0.25)
                icon:setAlpha(0.4)
            else 
                cardBG:setRGB(0.45, 0.45, 0.45)
                icon:setAlpha(1.0)
            end
            return true
        end)

        card:registerEventHandler("button_action", function(element, event)
            if not card.isCurrent then
                Engine.SendMenuResponse(event.controller, "pack_a_punch_menu", mod.code)
            end
            return true
        end)

        frame:addElement(card)
        table.insert(aatRow, card)
    end
    table.insert(rows, aatRow)

    -- ==========================================================
    -- ROW 3: CLOSE BUTTON
    -- ==========================================================
    local closeRow = {}
    local row3Y = row2Y + cardH + gapY
    local closeW = 140
    local totalRowWidth = (cardW * 6) + (gapX * 5)
    local closeX = startX + (totalRowWidth - closeW) / 2

    local closeCard = LUI.UIButton.new()
    closeCard:setLeftRight(true, false, closeX, closeX + closeW)
    closeCard:setTopBottom(true, false, row3Y, row3Y + cardH)
    closeCard:setHandleMouse(true)

    local closeBG = LUI.UIImage.new()
    closeBG:setLeftRight(true, true, 0, 0)
    closeBG:setTopBottom(true, true, 0, 0)
    closeBG:setImage(RegisterMaterial("white"))
    closeBG:setRGB(0.50, 0.50, 0.50)
    closeBG:setAlpha(0.95)
    closeBG:setHandleMouse(false)
    closeCard:addElement(closeBG)

    local closeTxt = LUI.UIText.new()
    closeTxt:setLeftRight(true, true, 0, 0)
    closeTxt:setTopBottom(false, false, -10, 10)
    closeTxt:setText("FECHAR")
    closeTxt:setFont(CoD.fonts.Condensed)
    closeTxt:setAlignment(LUI.Alignment.Center)
    closeTxt:setRGB(0.8, 0.2, 0.2)
    closeTxt:setHandleMouse(false)
    closeCard:addElement(closeTxt)

    closeCard:registerEventHandler("gain_focus", function(element, event)
        focusRow, focusCol = 3, 1
        
        infoHeader:setText("FECHAR")
        costHeader:setText("")
        closeBG:setRGB(0.82, 0.62, 0.12)
        return true
    end)

    closeCard:registerEventHandler("lose_focus", function(element, event)
        closeBG:setRGB(0.50, 0.50, 0.50)
        return true
    end)

    closeCard:registerEventHandler("button_action", function(element, event)
        closeMenu(event.controller)
        return true
    end)

    frame:addElement(closeCard)
    table.insert(closeRow, closeCard)
    table.insert(rows, closeRow)

    -- ==========================================================
    -- MENU DYNAMIC UPDATE EVENT HANDLER (FROM GSC PAYLOAD)
    -- ==========================================================
    menu:registerEventHandler("update_pap_menu", function(element, event)
        if event and event.data then
            menu.currentTier    = event.data[1] or 0
            menu.atMaxTier      = (event.data[2] == 1)
            menu.nextTierCost   = event.data[3] or 0
            menu.aatCost        = event.data[4] or 0
            
            local aatIndex      = event.data[5] or 0
            menu.currentAatCode = aatIndexMap[aatIndex] or ""
        end
        
        -- Refresh Tier cards
        for _, card in ipairs(rows[1]) do
            card:updateVisuals()
        end
        -- Refresh AAT cards
        for _, card in ipairs(rows[2]) do
            card:updateVisuals()
        end

        -- Re-trigger gain_focus on currently focused element to update headers instantly
        if focusRow > 0 and rows[focusRow] and rows[focusRow][focusCol] then
            rows[focusRow][focusCol]:processEvent({ 
                name = "gain_focus", 
                controller = event and event.controller or 0 
            })
        end
    end)

    -- Block engine automatic focus propagation to child elements on open
    menu:registerEventHandler("gain_focus", function(element, event)
        if focusRow == 0 then
            return true
        end
    end)

    -- ==========================================================
    -- NAVIGATION HELPERS
    -- ==========================================================
    local function moveLeft(ctrl)
        if focusRow == 0 then focusCard(1, 1, ctrl) return end
        if focusCol > 1 then focusCard(focusRow, focusCol - 1, ctrl) end
    end

    local function moveRight(ctrl)
        if focusRow == 0 then focusCard(1, 1, ctrl) return end
        if focusCol < #rows[focusRow] then focusCard(focusRow, focusCol + 1, ctrl) end
    end

    local function moveUp(ctrl)
        if focusRow == 0 then focusCard(1, 1, ctrl) return end
        if focusRow > 1 then
            local newRow = focusRow - 1
            focusCard(newRow, math.min(focusCol, #rows[newRow]), ctrl)
        end
    end

    local function moveDown(ctrl)
        if focusRow == 0 then focusCard(1, 1, ctrl) return end
        if focusRow < #rows then
            local newRow = focusRow + 1
            focusCard(newRow, math.min(focusCol, #rows[newRow]), ctrl)
        end
    end

    menu:registerEventHandler("left", function(element, event) moveLeft(event.controller) return true end)
    menu:registerEventHandler("right", function(element, event) moveRight(event.controller) return true end)
    menu:registerEventHandler("up", function(element, event) moveUp(event.controller) return true end)
    menu:registerEventHandler("down", function(element, event) moveDown(event.controller) return true end)

    menu:registerEventHandler("gamepad_button", function(element, event)
        if not event.down then return end

        local btn = event.button
        if btn == "left" then moveLeft(event.controller) return true
        elseif btn == "right" then moveRight(event.controller) return true
        elseif btn == "up" then moveUp(event.controller) return true
        elseif btn == "down" then moveDown(event.controller) return true
        elseif btn == "primary" then
            if focusRow == 0 then
                focusCard(1, 1, event.controller)
                return true
            elseif focusRow > 0 and rows[focusRow] and rows[focusRow][focusCol] then
                rows[focusRow][focusCol]:processEvent({ name = "button_action", controller = event.controller })
                return true
            end
        elseif btn == "secondary" or btn == "back" then
            closeMenu(event.controller)
            return true
        end
    end)

    return menu
end

CoD.PackAPunchMenu.Register = function(hudWidget, controller)
    hudWidget:registerEventHandler("pap_toggle", function(widget, event)
        local currentController = event.controller or controller or 0
        
        if CoD.PackAPunchMenu.ActiveMenu then
            CoD.Menu.goBack(CoD.PackAPunchMenu.ActiveMenu, currentController)
            CoD.PackAPunchMenu.ActiveMenu = nil
        end

        local popup = CoD.Menu.openPopup(widget, "pack_a_punch_menu", currentController)
        if popup then
            CoD.PackAPunchMenu.ActiveMenu = popup
        end
    end)

    hudWidget:registerEventHandler("pap_close", function(widget, event)
        if CoD.PackAPunchMenu.ActiveMenu then
            local currentController = event.controller or controller or 0
            CoD.Menu.goBack(CoD.PackAPunchMenu.ActiveMenu, currentController)
            CoD.PackAPunchMenu.ActiveMenu = nil
        end
    end)

    hudWidget:registerEventHandler("pap_update", function(widget, event)
        if CoD.PackAPunchMenu.ActiveMenu then
            local currentController = event.controller or controller or 0
            CoD.PackAPunchMenu.ActiveMenu:processEvent({
                name = "update_pap_menu",
                controller = currentController,
                data = event.data
            })
        end
    end)
end