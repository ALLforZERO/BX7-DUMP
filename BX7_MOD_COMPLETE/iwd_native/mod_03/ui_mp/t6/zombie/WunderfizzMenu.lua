require("T6.CoDBase")

CoD.WunderfizzMenu = {}
CoD.WunderfizzMenu.ActiveMenu = nil

LUI.createMenu.wunderfizz_menu = function(controller)
    local menu = CoD.Menu.New("wunderfizz_menu")
    if not menu then return nil end

    menu.isPopup = true
    if CoD.Menu.MakePopup then
        CoD.Menu.MakePopup(menu)
    end

    menu:setOwner(controller)
    menu:setHandleMouse(true)
    menu:registerEventHandler("mousemove", CoD.Menu.MouseMove)
    menu:registerEventHandler("mousedown", CoD.Menu.MouseDown)

    local function closeMenu(ctrl)
        Engine.SendMenuResponse(ctrl, "wunderfizz_menu", "close")
        CoD.Menu.goBack(menu, ctrl)
        CoD.WunderfizzMenu.ActiveMenu = nil
    end

    -- Close via ESC Key (PC)
    menu:registerEventHandler("key_down", function(element, event)
        if event.key == 27 then
            closeMenu(event.controller)
            return true
        end
    end)

    -- Close via Controller Back / B Button (Engine Event)
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

    -- Custom Background Material
    local bg = LUI.UIImage.new()
    bg:setLeftRight(true, true, 0, 0)
    bg:setTopBottom(true, true, 0, 0)
    pcall(function()
        bg:setImage(RegisterMaterial("ui_menu_wonderfizz"))
    end)
    bg:setRGB(1, 1, 1)
    bg:setAlpha(1.0)
    frame:addElement(bg)

    -- Main Title (Dark Charcoal for stamped paper aesthetic)
    local title = LUI.UIText.new()
    title:setLeftRight(true, true, 12, -12)
    title:setTopBottom(true, false, 8, 28)
    title:setText("DER WUNDERFIZZ X7")
    title:setFont(CoD.fonts.Big)
    title:setAlignment(LUI.Alignment.Center)
    title:setRGB(0.2, 0.2, 0.2)
    frame:addElement(title)

    -- Preview Header: Perk Name (Warm Gold Accent)
    local perkNameHeader = LUI.UIText.new()
    perkNameHeader:setLeftRight(true, true, 12, -12)
    perkNameHeader:setTopBottom(true, false, 32, 50)
    perkNameHeader:setText("SELECIONE UM PERK")
    perkNameHeader:setFont(CoD.fonts.Condensed)
    perkNameHeader:setAlignment(LUI.Alignment.Center)
    perkNameHeader:setRGB(0.85, 0.65, 0.12)
    frame:addElement(perkNameHeader)

    -- Preview Header: Perk Price
    local perkCostHeader = LUI.UIText.new()
    perkCostHeader:setLeftRight(true, true, 12, -12)
    perkCostHeader:setTopBottom(true, false, 50, 66)
    perkCostHeader:setText("")
    perkCostHeader:setFont(CoD.fonts.Condensed)
    perkCostHeader:setAlignment(LUI.Alignment.Center)
    perkCostHeader:setRGB(0.85, 0.70, 0.15)
    frame:addElement(perkCostHeader)

    -- CW Score
    local scoreText = LUI.UIText.new()
    scoreText:setLeftRight(true, true, 0, 0)
    scoreText:setTopBottom(false, true, -28, -8)
    scoreText:setFont(CoD.fonts.Condensed)
    scoreText:setAlignment(LUI.Alignment.Center)
    scoreText:setRGB(0.85, 0.70, 0.15)
    frame:addElement(scoreText)

    -- ==========================================================
    -- MAP PERK FILTERING & OWNED CHECK
    -- ==========================================================
    local perkMasterList = {
        { name = "Juggernog",       cost = 2500, code = "specialty_armorvest",               icon = "specialty_juggernaut_zombies" },
        { name = "Speed Cola",      cost = 3000, code = "specialty_fastreload",              icon = "specialty_fastreload_zombies" },
        { name = "Double Tap",      cost = 2000, code = "specialty_rof",                     icon = "specialty_doubletap_zombies" },
        { name = "Quick Revive",    cost = 1500, code = "specialty_quickrevive",             icon = "specialty_quickrevive_zombies" },
        { name = "Stamin-Up",       cost = 2000, code = "specialty_longersprint",            icon = "specialty_marathon_zombies" },
        { name = "Mule Kick",       cost = 4000, code = "specialty_additionalprimaryweapon", icon = "specialty_additionalprimaryweapon_zombies" },
        { name = "PHD Flopper",     cost = 2000, code = "specialty_flakjacket",              icon = "specialty_divetonuke_zombies" },
        { name = "Electric Cherry", cost = 2000, code = "specialty_grenadepulldeath",        icon = "specialty_electric_cherry_zombie" },
        { name = "Vulture Aid",     cost = 3000, code = "specialty_nomotionsensor",           icon = "specialty_vulture_zombies" },
        { name = "Who's Who's",     cost = 2000, code = "specialty_finalstand",              icon = "specialty_chugabud_zombies" },
        { name = "Tombstone",       cost = 3500, code = "specialty_scavenger",               icon = "specialty_tombstone_zombies" },
        { name = "Deadshot",        cost = 1500, code = "specialty_deadshot",                icon = "specialty_ads_zombies" }
    }

    local activeDvar = UIExpression.DvarString(nil, "ui_wunderfizz_perks") or ""
    local activeMap = {}
    for code in string.gmatch(activeDvar, "([^,]+)") do
        activeMap[code] = true
    end

    local ownedDvar = UIExpression.DvarString(nil, "ui_wunderfizz_owned_perks") or ""
    local ownedMap = {}
    for code in string.gmatch(ownedDvar, "([^,]+)") do
        ownedMap[code] = true
    end

    local perkOptions = {}
    for _, perk in ipairs(perkMasterList) do
        if activeMap[perk.code] then
            table.insert(perkOptions, perk)
        end
    end
    
    table.insert(perkOptions, { name = "Fechar", cost = nil, code = "close", icon = nil })

    -- Grid positioning logic
    local cols = 6
    local cardW, cardH = 54, 54
    local gapX, gapY = 6, 6
    local startY = 75

    local cards = {}
    local focusedIndex = 0

    for i, perk in ipairs(perkOptions) do
        local col = (i - 1) % cols
        local row = math.floor((i - 1) / cols)

        local xL = 23 + col * (cardW + gapX)
        local yT = startY + row * (cardH + gapY)

        local card = LUI.UIButton.new()
        card:setLeftRight(true, false, xL, xL + cardW)
        card:setTopBottom(true, false, yT, yT + cardH)
        card:setHandleMouse(true)

        -- Wipe engine default auto-focus SFX
        card:clearGainFocusSFX()

        -- Dynamic Properties Attached to Card
        card.perk = perk
        card.isOwned = ownedMap[perk.code] or false

        -- Bright off-white / light grey card background behind icons
        local cardBG = LUI.UIImage.new()
        cardBG:setLeftRight(true, true, 0, 0)
        cardBG:setTopBottom(true, true, 0, 0)
        cardBG:setImage(RegisterMaterial("white"))
        cardBG:setRGB(0.50, 0.50, 0.50)
        cardBG:setAlpha(0.95)
        cardBG:setHandleMouse(false)
        card:addElement(cardBG)

        -- Icon / Close X
        if perk.icon then
            local iconImage = LUI.UIImage.new()
            iconImage:setLeftRight(true, true, 4, -4)
            iconImage:setTopBottom(true, true, 4, -4)
            iconImage:setImage(RegisterMaterial(perk.icon))
            iconImage:setHandleMouse(false)
            
            if card.isOwned then
                iconImage:setRGB(0.25, 0.25, 0.25)
                iconImage:setAlpha(0.35)
            else
                iconImage:setRGB(1, 1, 1)
                iconImage:setAlpha(1.0)
            end

            card:addElement(iconImage)
            card.iconImage = iconImage
        else
            local closeTxt = LUI.UIText.new()
            closeTxt:setLeftRight(true, true, 0, 0)
            closeTxt:setTopBottom(false, false, -10, 10)
            closeTxt:setText("X")
            closeTxt:setFont(CoD.fonts.Condensed)
            closeTxt:setAlignment(LUI.Alignment.Center)
            closeTxt:setRGB(0.8, 0.2, 0.2)
            closeTxt:setHandleMouse(false)
            card:addElement(closeTxt)
        end

        card:registerEventHandler("gain_focus", function(element, event)
            -- 1. Play sound ONLY if moving to a completely NEW card
            if focusedIndex ~= i then
                Engine.PlaySound("cac_grid_nav")
                focusedIndex = i
            end

            -- 2. ALWAYS update gold highlight & text (Fixes yellow icon flashing)
            cardBG:setRGB(0.82, 0.62, 0.12)
            cardBG:setAlpha(0.95)

            perkNameHeader:setText(string.upper(perk.name))

            if card.isOwned then
                perkCostHeader:setText("ADQUIRIDO")
                perkCostHeader:setRGB(0.5, 0.5, 0.5)
            elseif perk.cost then
                perkCostHeader:setText("$" .. tostring(perk.cost))
                perkCostHeader:setRGB(0.85, 0.70, 0.15)
            else
                perkCostHeader:setText("")
            end
            return true
        end)

        card:registerEventHandler("lose_focus", function(element, event)
            -- Simply reset card back to gray (do NOT clear focusedIndex here!)
            cardBG:setRGB(0.50, 0.50, 0.50)
            cardBG:setAlpha(0.95)
            return true
        end)

        card:registerEventHandler("button_action", function(element, event)
            if perk.code == "close" then
                closeMenu(event.controller)
            else
                if not card.isOwned then
                    Engine.SendMenuResponse(event.controller, "wunderfizz_menu", perk.code)
                end
            end
            return true
        end)

        frame:addElement(card)
        table.insert(cards, card)
    end

    -- ==========================================================
    -- REAL-TIME STATE & SCORE REFRESH LOGIC
    -- ==========================================================
    menu.updateState = function()
        -- 1. Refresh Owned Perks
        local latestOwnedDvar = UIExpression.DvarString(nil, "ui_wunderfizz_owned_perks") or ""
        local latestOwnedMap = {}
        for code in string.gmatch(latestOwnedDvar, "([^,]+)") do
            latestOwnedMap[code] = true
        end

        for _, card in ipairs(cards) do
            if card.perk and card.perk.code ~= "close" then
                card.isOwned = latestOwnedMap[card.perk.code] or false
                if card.iconImage then
                    if card.isOwned then
                        card.iconImage:setRGB(0.25, 0.25, 0.25)
                        card.iconImage:setAlpha(0.35)
                    else
                        card.iconImage:setRGB(1, 1, 1)
                        card.iconImage:setAlpha(1.0)
                    end
                end
            end
        end

        -- 2. Refresh Player Score
        local currentScore = UIExpression.DvarInt(nil, "ui_wunderfizz_player_score") or 0
        scoreText:setText("$" .. tostring(currentScore))

        -- 3. Update active card focus header if purchased
        if focusedIndex > 0 and cards[focusedIndex] then
            cards[focusedIndex]:processEvent({ name = "gain_focus" })
        end
    end

    -- Initial score load on menu creation
    menu:updateState()

    menu:registerEventHandler("wunderfizz_update", function(element, event)
        menu:updateState()
        return true
    end)

    -- Block engine automatic focus propagation to child elements on open
    menu:registerEventHandler("gain_focus", function(element, event)
        if focusedIndex == 0 then
            return true
        end
    end)

    -- Focus switching helper (Controller / Keyboard D-Pad)
    local function changeFocus(newIndex, ctrl)
        if newIndex < 1 or newIndex > #cards or newIndex == focusedIndex then return end
        if focusedIndex > 0 and cards[focusedIndex] then
            cards[focusedIndex]:processEvent({ name = "lose_focus", controller = ctrl })
        end
        if cards[newIndex] then
            cards[newIndex]:processEvent({ name = "gain_focus", controller = ctrl })
        end
    end

    -- Navigation movement logic
    local function moveLeft(ctrl)
        if focusedIndex == 0 then changeFocus(1, ctrl) return end
        if (focusedIndex - 1) % cols ~= 0 then
            changeFocus(focusedIndex - 1, ctrl)
        end
    end

    local function moveRight(ctrl)
        if focusedIndex == 0 then changeFocus(1, ctrl) return end
        if focusedIndex % cols ~= 0 and (focusedIndex + 1) <= #cards then
            changeFocus(focusedIndex + 1, ctrl)
        end
    end

    local function moveUp(ctrl)
        if focusedIndex == 0 then changeFocus(1, ctrl) return end
        if (focusedIndex - cols) >= 1 then
            changeFocus(focusedIndex - cols, ctrl)
        end
    end

    local function moveDown(ctrl)
        if focusedIndex == 0 then changeFocus(1, ctrl) return end
        local total = #cards
        local target = focusedIndex + cols
        if target <= total then
            changeFocus(target, ctrl)
        else
            local lastRowStart = math.floor((total - 1) / cols) * cols + 1
            if focusedIndex < lastRowStart then
                changeFocus(total, ctrl)
            end
        end
    end

    -- Dedicated directional event handlers
    menu:registerEventHandler("left", function(element, event) moveLeft(event.controller) return true end)
    menu:registerEventHandler("right", function(element, event) moveRight(event.controller) return true end)
    menu:registerEventHandler("up", function(element, event) moveUp(event.controller) return true end)
    menu:registerEventHandler("down", function(element, event) moveDown(event.controller) return true end)

    -- Universal gamepad button handler fallback
    menu:registerEventHandler("gamepad_button", function(element, event)
        if not event.down then return end

        local btn = event.button
        if btn == "left" then moveLeft(event.controller) return true
        elseif btn == "right" then moveRight(event.controller) return true
        elseif btn == "up" then moveUp(event.controller) return true
        elseif btn == "down" then moveDown(event.controller) return true
        elseif btn == "primary" then
            if focusedIndex > 0 and cards[focusedIndex] then
                cards[focusedIndex]:processEvent({ name = "button_action", controller = event.controller })
                return true
            end
        elseif btn == "secondary" or btn == "back" then
            closeMenu(event.controller)
            return true
        end
    end)

    return menu
end

CoD.WunderfizzMenu.Register = function(hudWidget, controller)
    hudWidget:registerEventHandler("wunderfizz_toggle", function(widget, event)
        local currentController = event.controller or controller or 0
        local popup = CoD.Menu.openPopup(widget, "wunderfizz_menu", currentController)
        if popup then
            CoD.WunderfizzMenu.ActiveMenu = popup
        end
    end)

    hudWidget:registerEventHandler("wunderfizz_update", function(widget, event)
        if CoD.WunderfizzMenu.ActiveMenu and CoD.WunderfizzMenu.ActiveMenu.updateState then
            CoD.WunderfizzMenu.ActiveMenu:updateState()
        end
    end)

    hudWidget:registerEventHandler("wunderfizz_close", function(widget, event)
        if CoD.WunderfizzMenu.ActiveMenu then
            local currentController = event.controller or controller or 0
            CoD.Menu.goBack(CoD.WunderfizzMenu.ActiveMenu, currentController)
            CoD.WunderfizzMenu.ActiveMenu = nil
        end
    end)
end