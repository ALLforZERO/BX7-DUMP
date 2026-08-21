require("T6.CoDBase")
require("T6.Lobby")
require("T6.EdgeShadow")
require("T6.Menus.Playercard")
require("T6.JoinableList")
require("T6.Error")
require("T6.Menus.CODTv")
require("T6.Menus.SignOutPopup")
require("T6.Menus.RejoinSessionPopup")
require("T6.Mods")

if CoD.isWIIU then
    require("T6.WiiUControllerSettings")
end

if CoD.isZombie == false and (CoD.isXBOX or CoD.isPS3) then
    require("T6.Menus.EliteAppPopup")
end

CoD.MainLobby = {}

CoD.MainLobby.ShouldPreventCreateLobby = function()
    if UIExpression.AcceptingInvite() == 1 or 1 == Engine.IsJoiningAnotherParty() or UIExpression.PrivatePartyHost() == 0 or Engine.IsGameLobbyRunning() then
        return true
    else
        return false
    end
end

CoD.MainLobby.OnlinePlayAvailable = function(a, b, c)
    local d = b.controller
    if c == nil then
        c = false
    end
    if CoD.isPC and Engine.IsVacBanned() then
        local e = a:openPopup("Error", d)
        e:setMessage(Engine.Localize("PLATFORM_VACBANNED"))
        e.anyControllerAllowed = true
        e.callingMenu = a
        return 0
    elseif CoD.isWIIU and Engine.IsSignedInToDemonware(contoller) == false then
        if UIExpression.IsPrimaryLocalClient(d) == 1 then
            Engine.Exec(d, "xsigninlive")
        end
        return 0
    elseif UIExpression.IsGuest(d) == 1 then
        local e = a:openPopup("Error", d)
        e:setMessage(Engine.Localize("XBOXLIVE_NOGUESTACCOUNTS"))
        e.anyControllerAllowed = true
    elseif UIExpression.DvarBool(d, "live_betaexpired") == 1 then
        local e = a:openPopup("Error", d)
        e:setMessage(Engine.Localize("MP_BETACLOSED"))
    elseif UIExpression.IsSignedInToLive(d) == 0 then
        if CoD.isPS3 or CoD.isWIIU then
            if UIExpression.IsPrimaryLocalClient(d) == 1 then
                Engine.Exec(d, "xsigninlive")
            else
                Engine.Exec(d, "signclientin")
            end
        elseif CoD.isPC then
            if 0 == UIExpression.GetUsedControllerCount() then
                Engine.Exec(d, "xsigninlivenoguests")
            else
                Engine.Exec(d, "xsigninlive")
            end
        elseif 0 == UIExpression.GetUsedControllerCount() then
            Engine.Exec(d, "xsigninlivenoguests")
        elseif UIExpression.IsSignedIn(d) == 1 then
            a:openPopup("popup_signintolive", d)
        else
            Engine.Exec(d, "xsigninlive")
        end
    elseif (UIExpression.IsContentRatingAllowed(d) == 0 or UIExpression.IsAnyControllerMPRestricted() == 1) and not c then
        local e = a:openPopup("Error", d)
        e:setMessage(Engine.Localize("XBOXLIVE_MPNOTALLOWED"))
        e.anyControllerAllowed = true
    elseif UIExpression.IsDemonwareFetchingDone(d) == 1 then
        local e = Engine.GetPlayerStats(d)
        e = e.cacLoadouts.resetWarningDisplayed
        local f = Engine.GetPlayerStats(d)
        f = f.cacLoadouts.classWarningDisplayed
        if e:get() == 0 then
            e:set(1)
            if f ~= nil then
                f:set(1)
            end
            local g = a:openPopup("Error", d)
            g:setMessage(Engine.Localize("MENU_STATS_RESET"))
            g.anyControllerAllowed = true
        elseif CoD.isZombie == false and f:get() == 0 then
            f:set(1)
            local g = a:openPopup("Error", d)
            g:setMessage(Engine.Localize("MENU_RESETCUSTOMCLASSES"))
            g.anyControllerAllowed = true
        else
            return 1
        end
    else
        Engine.ExecNow(nil, "initiatedemonwareconnect")
        local e = a:openPopup("popup_connectingdw", d)
        e.openingStore = c
        e.callingMenu = a
    end
    return 0
end

CoD.MainLobby.IsControllerCountValid = function(h, i, j)
    if j < UIExpression.GetUsedControllerCount() then
        local k = h:openPopup("Error", i)
        k:setMessage(Engine.Localize("XBOXLIVE_TOOMANYCONTROLLERS"))
        k.anyControllerAllowed = true
        return 0
    else
        return 1
    end
end

CoD.MainLobby.OpenPlayerMatchPartyLobby = function(l, m)
    if CoD.MainLobby.ShouldPreventCreateLobby() then
        return
    elseif CoD.MainLobby.OnlinePlayAvailable(l, m) == 1 then
        Engine.ProbationCheckForDashboardWarning(CoD.GAMEMODE_PUBLIC_MATCH)
        local n, o = Engine.ProbationCheckInProbation(CoD.GAMEMODE_PUBLIC_MATCH)
        if n == true then
            l:openPopup("popup_public_inprobation", o)
            return
        end
        local p, q = Engine.ProbationCheckForProbation(CoD.GAMEMODE_PUBLIC_MATCH)
        o = q
        if p == true then
            l:openPopup("popup_public_givenprobation", o)
            return
        elseif Engine.ProbationCheckParty(CoD.GAMEMODE_PUBLIC_MATCH, m.controller) == true then
            l:openPopup("popup_public_partyprobation", m.controller)
            return
        end
        p = UIExpression.DvarInt(o, "party_maxlocalplayers_playermatch")
        if CoD.MainLobby.IsControllerCountValid(l, m.controller, p) == 1 then
            l.lobbyPane.body.lobbyList.maxLocalPlayers = p
            CoD.SwitchToPlayerMatchLobby(m.controller)
            if CoD.isZombie == true then
                Engine.PartyHostSetUIState(CoD.PARTYHOST_STATE_SELECTING_PLAYLIST)
                CoD.PlaylistCategoryFilter = "playermatch"
                l:openMenu("SelectMapZM", m.controller)
                CoD.GameGlobeZombie.MoveToCenter(m.controller)
            else
                l:openMenu("PlayerMatchPartyLobby", m.controller)
            end
            l:close()
        end
    end
end

CoD.MainLobby.OpenLeagueSelectionPopup = function(r, s)
    if CoD.MainLobby.ShouldPreventCreateLobby() then
        return
    elseif CoD.MainLobby.OnlinePlayAvailable(r, s) == 1 then
        Engine.ProbationCheckForDashboardWarning(CoD.GAMEMODE_PUBLIC_MATCH)
        local t, u = Engine.ProbationCheckInProbation(CoD.GAMEMODE_LEAGUE_MATCH)
        if t == true then
            r:openPopup("popup_league_inprobation", u)
            return
        end
        local v, w = Engine.ProbationCheckForProbation(CoD.GAMEMODE_LEAGUE_MATCH)
        u = w
        if v == true then
            r:openPopup("popup_league_givenprobation", u)
            return
        elseif Engine.ProbationCheckParty(CoD.GAMEMODE_LEAGUE_MATCH, s.controller) == true then
            r:openPopup("popup_league_partyprobation", s.controller)
            return
        end
        Engine.PartyHostSetUIState(CoD.PARTYHOST_STATE_SELECTING_PLAYLIST)
        CoD.PlaylistCategoryFilter = "leaguematch"
        v = r:openPopup("PlaylistSelection", s.controller)
        v:addCategoryButtons(s.controller)
        Engine.PlaySound("cac_screen_fade")
    end
end

CoD.MainLobby.OpenLeaguePlayPartyLobby = function(x, y)
    if CoD.MainLobby.ShouldPreventCreateLobby() then
        return
    elseif CoD.MainLobby.OnlinePlayAvailable(x, y) == 1 then
        local z = UIExpression.DvarInt(controller, "party_maxlocalplayers_playermatch")
        if CoD.MainLobby.IsControllerCountValid(x, y.controller, z) == 1 then
            x.lobbyPane.body.lobbyList.maxLocalPlayers = z
            CoD.SwitchToLeagueMatchLobby(y.controller)
            x:openMenu("LeaguePlayPartyLobby", y.controller)
            x:close()
        end
    end
end

CoD.MainLobby.OpenCustomGamesLobby = function(A, B)
    if CoD.MainLobby.ShouldPreventCreateLobby() then
        return
    elseif CoD.MainLobby.OnlinePlayAvailable(A, B) == 1 and CoD.MainLobby.IsControllerCountValid(A, B.controller, UIExpression.DvarInt(controller, "party_maxlocalplayers_privatematch")) == 1 then
        CoD.SwitchToPrivateLobby(B.controller)
        if CoD.isZombie == true then
            Engine.SetDvar("ui_zm_mapstartlocation", "")
            A:openMenu("SelectMapZM", B.controller)
            CoD.GameGlobeZombie.MoveToCenter(B.controller)
        else
            local C = A:openMenu("PrivateOnlineGameLobby", B.controller)
        end
        A:close()
    end
end

CoD.MainLobby.OpenSoloLobby_Zombie = function(D, E)
    if CoD.MainLobby.ShouldPreventCreateLobby() then
        return
    elseif CoD.MainLobby.OnlinePlayAvailable(D, E) == 1 then
        local F = 1
        if CoD.MainLobby.IsControllerCountValid(D, E.controller, F) == 1 then
            D.lobbyPane.body.lobbyList.maxLocalPlayers = F
            CoD.SwitchToPlayerMatchLobby(E.controller)
            Engine.PartyHostSetUIState(CoD.PARTYHOST_STATE_SELECTING_PLAYLIST)
            Dvar.party_maxplayers:set(1)
            CoD.PlaylistCategoryFilter = CoD.Zombie.PLAYLIST_CATEGORY_FILTER_SOLOMATCH
            D:openMenu("SelectMapZM", E.controller)
            CoD.GameGlobeZombie.MoveToCenter(E.controller)
            D:close()
        end
    end
end

CoD.MainLobby.OpenTheaterLobby = function(G, H)
    if CoD.MainLobby.ShouldPreventCreateLobby() then
        return
    elseif UIExpression.CanSwitchToLobby(H.controller, Dvar.party_maxplayers_theater:get(), Dvar.party_maxlocalplayers_theater:get()) == 0 then
        Dvar.ui_errorTitle:set(Engine.Localize("MENU_NOTICE_CAPS"))
        Dvar.ui_errorMessage:set(Engine.Localize("MENU_FILESHARE_MAX_LOCAL_PLAYERS"))
        CoD.Menu.OpenErrorPopup(G, {controller = H.controller})
        return
    elseif Engine.CanViewContent() == false then
        G:openPopup("popup_contentrestricted", H.controller)
        return
    elseif CoD.MainLobby.OnlinePlayAvailable(G, H) == 1 and CoD.MainLobby.IsControllerCountValid(G, H.controller, UIExpression.DvarInt(controller, "party_maxlocalplayers_theater")) == 1 then
        CoD.SwitchToTheaterLobby(H.controller)
        local I = G:openMenu("TheaterLobby", H.controller, {parent = "MainLobby"})
        G:close()
    end
end

CoD.MainLobby.OpenCODTV = function(J, K)
    if Engine.CanViewContent() == false then
        J:openPopup("popup_contentrestricted", K.controller)
        return
    elseif Engine.IsLivestreamEnabled() then
        J:openPopup("CODTv_Error", K.controller)
        return
    elseif CoD.MainLobby.OnlinePlayAvailable(J, K) == 1 and Engine.IsCodtvContentLoaded() == true then
        CoD.perController[K.controller].codtvRoot = "community"
        J:openPopup("CODTv", K.controller)
    end
end

CoD.MainLobby.OpenBarracks = function(L, M)
    if UIExpression.IsGuest(M.controller) == 1 then
        L:openPopup("popup_guest_contentrestricted", M.controller)
        return
    elseif CoD.MainLobby.OnlinePlayAvailable(L, M) == 1 then
        if CoD.isZombie == true then
            Engine.Exec(M.controller, "party_setHostUIString ZMUI_VIEWING_LEADERBOARD")
            L:openPopup("LeaderboardCarouselZM", M.controller)
        else
            Engine.Exec(M.controller, "party_setHostUIString MENU_VIEWING_PLAYERCARD")
            L:openPopup("Barracks", M.controller)
        end
    end
end

CoD.MainLobby.OpenStore = function(N, O)
    if N.occludedBy then
        return
    end
    Engine.SetDvar("ui_openStoreForMTX", 0)
    if Engine.CheckNetConnection() == false then
        local P = N:openPopup("popup_net_connection_store", O.controller)
        P.callingMenu = N
        return
    elseif N.id == "Menu.MainMenu" then
        Engine.Exec(O.controller, "setclientbeingusedandprimary")
    end
    if CoD.MainLobby.OnlinePlayAvailable(N, O, true) == 1 then
        if not CoD.isPS3 or UIExpression.IsSubUser(O.controller) ~= 1 then
            Dvar.ui_storeButtonPressed:set(true)
            CoD.perController[O.controller].codtvRoot = "ingamestore"
            if CoD.isPC then
                Engine.ShowMarketplaceUI(O.controller)
            else
                N:openPopup("CODTv", O.controller)
            end
        else
            local P = N:openPopup("Error", O.controller)
            P:setMessage(Engine.Localize("MENU_SUBUSERS_NOTALLOWED"))
            P.anyControllerAllowed = true
        end
    end
end

CoD.MainLobby.OpenControlsMenu = function(Q, R)
    Q:openPopup("WiiUControllerSettings", R.controller, true)
end

CoD.MainLobby.OpenOptionsMenu = function(S, T)
    S:openPopup("OptionsMenu", T.controller)
end

CoD.MainLobby.UpdateButtonPaneButtonVisibilty_Multiplayer = function(U)
    if CoD.isPartyHost() then
        U.body.buttonList:addElement(U.body.matchmakingButton)
        U.body.buttonList:addElement(U.body.leaguePlayButton)
        if not Engine.IsBetaBuild() then
            U.body.buttonList:addElement(U.body.customGamesButton)
        end
        U.body.buttonList:addElement(U.body.theaterButton)
        U.body.buttonList:addElement(U.body.postTheaterSpacer)
    else
        U.body.matchmakingButton:closeAndRefocus(U.body.codtvButton)
        U.body.leaguePlayButton:closeAndRefocus(U.body.codtvButton)
        if not Engine.IsBetaBuild() then
            U.body.customGamesButton:closeAndRefocus(U.body.codtvButton)
        end
        U.body.theaterButton:closeAndRefocus(U.body.codtvButton)
        U.body.postTheaterSpacer:closeAndRefocus(U.body.codtvButton)
    end
end

CoD.MainLobby.UpdateButtonPaneButtonVisibilty_Zombie = function(V)
    V.body.buttonList:addElement(V.body.modsButton)
end

CoD.MainLobby.UpdateButtonPaneButtonVisibilty = function(W)
    if W == nil or W.body == nil then
        return
    elseif CoD.isZombie == true then
        CoD.MainLobby.UpdateButtonPaneButtonVisibilty_Zombie(W)
    else
        CoD.MainLobby.UpdateButtonPaneButtonVisibilty_Multiplayer(W)
    end
    W:setLayoutCached(false)
end

CoD.MainLobby.UpdateButtonPromptVisibility = function(X)
    if X == nil then
        return
    end
    X:removeBackButton()
    local Y = false
    if X.joinButton ~= nil then
        X.joinButton:close()
        Y = true
    end
    X.friendsButton:close()
    if X.partyPrivacyButton ~= nil then
        X.partyPrivacyButton:close()
    end
    X:addBackButton()
    X:addFriendsButton()
    if Y then
        X:addJoinButton()
    end
    if X.panelManager.slidingEnabled ~= true then
        X.friendsButton:disable()
    end
    if X.panelManager:isPanelOnscreen("buttonPane") then
        X:addPartyPrivacyButton()
    end
    X:addNATType()
end

CoD.MainLobby.PopulateButtons_Multiplayer = function(Z)
    if Engine.IsBetaBuild() then
        Z.body.matchmakingButton = Z.body.buttonList:addButton(Engine.Localize("MENU_MATCHMAKING_CAPS"), nil, 2)
        Z.body.leaguePlayButton = Z.body.buttonList:addButton(Engine.Localize("MENU_LEAGUE_PLAY_CAPS"), nil, 1)
    else
        Z.body.matchmakingButton = Z.body.buttonList:addButton(Engine.Localize("MENU_MATCHMAKING_CAPS"), nil, 1)
        Z.body.leaguePlayButton = Z.body.buttonList:addButton(Engine.Localize("MENU_LEAGUE_PLAY_CAPS"), nil, 2)
    end
    Z.body.matchmakingButton.hintText = Engine.Localize(CoD.MPZM("MPUI_PLAYER_MATCH_DESC", "ZMUI_PLAYER_MATCH_DESC"))
    Z.body.matchmakingButton:setActionEventName("open_player_match_party_lobby")
    CoD.SetupMatchmakingLock(Z.body.matchmakingButton)
    Z.body.leaguePlayButton.hintText = Engine.Localize("MPUI_LEAGUE_PLAY_DESC")
    Z.body.leaguePlayButton:setActionEventName("open_league_play_party_lobby")
    if not Engine.IsBetaBuild() then
        Z.body.customGamesButton = Z.body.buttonList:addButton(Engine.Localize("MENU_CUSTOMGAMES_CAPS"), nil, 3)
        Z.body.customGamesButton.hintText = Engine.Localize(CoD.MPZM("MPUI_CUSTOM_MATCH_DESC", "ZMUI_CUSTOM_MATCH_DESC"))
        Z.body.customGamesButton:setActionEventName("open_custom_games_lobby")
        CoD.SetupCustomGamesLock(Z.body.customGamesButton)
    end
    Z.body.theaterButton = Z.body.buttonList:addButton(Engine.Localize("MENU_THEATER_CAPS"), nil, 4)
    Z.body.theaterButton:setActionEventName("open_theater_lobby")
    Z.body.theaterButton.hintText = Engine.Localize(CoD.MPZM("MPUI_THEATER_DESC", "ZMUI_THEATER_DESC"))
    Z.body.postTheaterSpacer = Z.body.buttonList:addSpacer(CoD.CoD9Button.Height / 2, 5)
    if Engine.IsBetaBuild() then
        Z.body.codtvButton = Z.body.buttonList:addButton(Engine.Localize("MENU_FILESHARE_COMMUNITY_CAPS"), nil, 6)
    else
        Z.body.codtvButton = Z.body.buttonList:addButton(Engine.Localize("MENU_COD_TV_CAPS"), nil, 6)
    end
    Z.body.codtvButton.hintText = Engine.Localize("MPUI_COD_TV_DESC")
    Z.body.codtvButton:setActionEventName("open_cod_tv")
    if not Engine.IsBetaBuild() then
        Z.body.barracksButton = Z.body.buttonList:addButton(Engine.Localize("MENU_BARRACKS_CAPS"), nil, 7)
        Z.body.barracksButton.id = "CoD9Button" .. "." .. "MainLobby" .. "." .. Engine.Localize("MENU_BARRACKS_CAPS")
        CoD.SetupBarracksLock(Z.body.barracksButton)
        CoD.SetupBarracksNew(Z.body.barracksButton)
        Z.body.barracksButton:setActionEventName("open_barracks")
    end
    if CoD.isZombie == false and not Engine.IsBetaBuild() and (CoD.isXBOX or CoD.isPS3) and Engine.IsEliteAvailable() and Engine.IsEliteButtonAvailable() then
        Z.body.eliteAppButton = Z.body.buttonList:addButton(Engine.Localize("MENU_ELITE_CAPS"), nil, 8)
        Z.body.eliteAppButton.hintText = Engine.Localize("MENU_ELITE_DESC")
        Z.body.eliteAppButton:setActionEventName("open_eliteapp_popup")
    end
    Z.body.buttonList:addSpacer(CoD.CoD9Button.Height / 2, 8)
    Z.body.optionsButton = Z.body.buttonList:addButton(Engine.Localize("MENU_OPTIONS_CAPS"), nil, 11)
    Z.body.optionsButton.hintText = Engine.Localize("MPUI_OPTIONS_DESC")
    Z.body.optionsButton:setActionEventName("open_options_menu")
    if not CoD.isWIIU and Dvar.ui_inGameStoreVisible:get() == true and (CoD.isPS3 ~= true or CoD.isZombie ~= true) then
        Z.body.ingameStoreButton = Z.body.buttonList:addButton(Engine.Localize("MENU_INGAMESTORE"), nil, 12)
        if CoD.isPC then
            Z.body.ingameStoreButton.hintText = Engine.Localize("PLATFORM_STORE_DESC")
        else
            Z.body.ingameStoreButton.hintText = Engine.Localize("MENU_STORE_DESC")
        end
        Z.body.ingameStoreButton:setActionEventName("open_store")
    end
end

CoD.MainLobby.PopulateButtons_Zombie = function(_)
    local a0 = UIExpression.DvarString(nil, "plfr_lang")
    local a1
    if a0 == "en" then
        a1 = true
    elseif a0 == "fr" then
        a1 = false
    else
        local a2 = UIExpression.DvarString(nil, "loc_language")
        a1 = a2 ~= "1" and a2 ~= "2"
    end
    pcall(function()
        Engine.Exec(0, "seta plfr_load_supporters \"KNT11|BigoEvans|Ternus|leonardo_san|06_Night_04|BeastLDC|Zeyrix7|ashtonscamu|ArtemisIcee|SaiAikoV|Pablustuni|MPE8|Natrix Is Here|Braisecho|Don.Jamones|Cee___|C_wz|kylr|DayraLove|prulx|Smoke4020|E-Q-E-Q|iLoveAmber^7\"")
    end)
    _.body.theaterSpacer = _.body.buttonList:addSpacer(CoD.CoD9Button.Height / 2 * 1)
    _.body.Server1 = _.body.buttonList:addButton(a1 and "Join TOWN 8P (Community)" or "Rejoindre TOWN 8P (Communautaire)", nil, 0)
    _.body.Server1:setActionEventName("town_direct_connect")
    _.body.Server1.hintText = a1 and "The heart of the VOID. 8 players, records, gobblegums... and a black hole watching over the town." or "Le coeur du VOID. 8 joueurs, records, gobblegums... et un trou noir qui veille sur la ville."
    _.body.Server1b = _.body.buttonList:addButton(a1 and "Join TOWN #2 (Community)" or "Rejoindre TOWN #2 (Communautaire)", nil, 0)
    _.body.Server1b:setActionEventName("town2_direct_connect")
    _.body.Server1b.hintText = a1 and "The second Town. Same rules, same records, more room for everyone." or "Le deuxieme Town. Memes regles, memes records, plus de place pour tout le monde."
    _.body.Server2 = _.body.buttonList:addButton(a1 and "Join ORIGINS (High Rounds / EE)" or "Rejoindre ORIGINS (High Rounds / EE)", nil, 0)
    _.body.Server2:setActionEventName("origins_direct_connect")
    _.body.Server2.hintText = a1 and "The original battlefield. Mud, giants, staffs - and something far older beneath." or "Le champ de bataille originel. La boue, les geants, les baguettes - et quelque chose de bien plus vieux en dessous."
    _.body.Server3 = _.body.buttonList:addButton(a1 and "Join MOTD (High Rounds / EE)" or "Rejoindre MOTD (High Rounds / EE)", nil, 0)
    _.body.Server3:setActionEventName("motd_direct_connect")
    _.body.Server3.hintText = a1 and "Alcatraz. Survive, unlock the Afterlife, break the Cycle... or repeat it forever." or "Alcatraz. Survis, debloque l Au-dela, brise le Cycle... ou repete-le pour toujours."
    _.body.Server4 = _.body.buttonList:addButton(a1 and "Join TRANZIT (High Rounds / EE)" or "Rejoindre TRANZIT (High Rounds / EE)", nil, 0)
    _.body.Server4:setActionEventName("tranzit_direct_connect")
    _.body.Server4.hintText = a1 and "Board the bus, brave the fog, survive the wasteland." or "Monte dans le bus, affronte le brouillard, survis au terrain vague."
    _.body.Server5 = _.body.buttonList:addButton(a1 and "Join NUKETOWN (High Rounds)" or "Rejoindre NUKETOWN (High Rounds)", nil, 0)
    _.body.Server5:setActionEventName("nuketown_direct_connect")
    _.body.Server5.hintText = a1 and "A suburban nightmare frozen in nuclear fallout. They come from every direction." or "Un cauchemar de banlieue fige dans les retombees nucleaires. Ils arrivent de partout."
    _.body.Server6 = _.body.buttonList:addButton(a1 and "Join BURIED (High Rounds / EE)" or "Rejoindre BURIED (High Rounds / EE)", nil, 0)
    _.body.Server6:setActionEventName("buried_direct_connect")
    _.body.Server6.hintText = a1 and "The swallowed town. Tight tunnels, a ghost, a giant... look up." or "La ville engloutie. Tunnels etroits, un fantome, un geant... leve les yeux."
    _.body.Server7 = _.body.buttonList:addButton(a1 and "Join DIE RISE (High Rounds / EE)" or "Rejoindre DIE RISE (High Rounds / EE)", nil, 0)
    _.body.Server7:setActionEventName("dierise_direct_connect")
    _.body.Server7.hintText = a1 and "Skyscrapers, elevators and a very long way down. Mind the gap." or "Gratte-ciels, ascenseurs et une longue chute. Attention au vide."
    _.body.theaterSpacer = _.body.buttonList:addSpacer(CoD.CoD9Button.Height / 2 * 1)
    _.body.customSpacer = _.body.buttonList:addSpacer(CoD.CoD9Button.Height / 2, 3)
    _.body.customGamesButton = _.body.buttonList:addButton(Engine.Localize("MENU_CUSTOMGAMES_CAPS"), nil, 4)
    _.body.customGamesButton.hintText = Engine.Localize(CoD.MPZM("MPUI_CUSTOM_MATCH_DESC", "ZMUI_CUSTOM_MATCH_DESC"))
    _.body.customGamesButton:setActionEventName("open_custom_games_lobby")
    CoD.SetupCustomGamesLock(_.body.customGamesButton)
    _.body.optionsButton = _.body.buttonList:addButton(Engine.Localize("MENU_OPTIONS_CAPS"), nil, 10)
    _.body.optionsButton.hintText = Engine.Localize("MPUI_OPTIONS_DESC")
    _.body.optionsButton:setActionEventName("open_options_menu")
    _.body.modsButton = _.body.buttonList:addButton(Engine.Localize("MENU_MODS_CAPS"), nil, 12)
    _.body.modsButton.hintText = Engine.Localize("MENU_SELECT_MOD_NAME_TO_LAUNCH")
    _.body.modsButton:setActionEventName("open_mods_menu")
    _.body.serverBrowserButton = _.body.buttonList:addButton(Engine.Localize("MENU_SERVER_BROWSER_CAPS"), nil, 1)
    _.body.serverBrowserButton.hintText = Engine.Localize("MENU_SERVER_BROWSER_DESC")
    _.body.serverBrowserButton:setActionEventName("open_server_browser_mainlobby")
end

CoD.MainLobby.PopulateButtons = function(a3)
    if CoD.isZombie == true then
        CoD.MainLobby.PopulateButtons_Zombie(a3)
    else
        CoD.MainLobby.PopulateButtons_Multiplayer(a3)
    end
    if CoD.isWIIU then
        a3.body.controlsButton = a3.body.buttonList:addButton(Engine.Localize("MENU_CONTROLLER_SETTINGS_CAPS"), nil, 9)
        a3.body.controlsButton.hintText = Engine.Localize("MENU_CONTROLLER_SETTINGS_DESC")
        a3.body.controlsButton:setActionEventName("open_controls_menu")
    end
end

CoD.MainLobby.UpdateOnlinePlayerCount = function(a4)
    if CoD.isOnlineGame() then
        local a5 = CoD.Menu.GetOnlinePlayerCountText()
        if a5 ~= "" then
            a4:setText(a5)
            a4.timer.interval = 60000
            a4.timer:reset()
        end
    end
end

CoD.MainLobby.FirstSignedInToLive = function(a6)
    if a6 ~= nil then
        if CoD.isXBOX then
            a6.anyControllerAllowed = false
        end
        if a6.friendsButton == nil then
            a6:addFriendsButton()
        end
    end
end

CoD.MainLobby.LastSignedOutOfLive = function(a7)
    if a7 ~= nil and CoD.isXBOX then
        a7.anyControllerAllowed = true
    end
end

CoD.MainLobby.PlayerSelected = function(a8, a9)
    if a9.joinable ~= nil and CoD.canJoinSession(UIExpression.GetPrimaryController(), a9.playerXuid) then
        if a8.joinButton == nil and not a8.m_blockJoinButton then
            a8:addJoinButton()
            a8:addNATType()
        end
    elseif a8.joinButton ~= nil then
        a8.joinButton:close()
        a8.joinButton = nil
    end
    a8:dispatchEventToChildren(a9)
end

CoD.MainLobby.PlayerDeselected = function(aa, ab)
    if aa.joinButton ~= nil then
        aa.joinButton:close()
        aa.joinButton = nil
    end
    aa:dispatchEventToChildren(ab)
end

CoD.MainLobby.CurrentPanelChanged = function(ac, ad)
    if CoD.isPC then
        ac.m_blockJoinButton = ad.id ~= "PanelManager.lobbyPane"
    end
end

CoD.MainLobby.BusyList_Update = function(ae, af, ag, ah, ai)
end

CoD.MainLobby.Update = function(aj, ak)
    if aj == nil then
        return
    elseif UIExpression.IsDemonwareFetchingDone(ak.controller) == 1 == true then
        aj.panelManager:processEvent({name = "fetching_done"})
    end
    CoD.MainLobby.UpdateButtonPaneButtonVisibilty(aj.buttonPane)
    CoD.MainLobby.UpdateButtonPromptVisibility(aj)
    aj:dispatchEventToChildren(ak)
end

CoD.MainLobby.ClientLeave = function(al, am)
    Engine.ExecNow(am.controller, "leaveAllParties")
    Engine.PartyHostClearUIState()
    CoD.StartMainLobby(am.controller)
    CoD.MainLobby.UpdateButtonPaneButtonVisibilty(al.buttonPane)
    CoD.MainLobby.UpdateButtonPromptVisibility()
end

CoD.MainLobby.GoBack = function(an, ao)
    Engine.SessionModeResetModes()
    Engine.Exec(controller, "xstopprivateparty")
    if CoD.isPS3 then
        Engine.Exec(ao.controller, "signoutSubUsers")
    end
    an:setPreviousMenu("MainMenu")
    CoD.Menu.goBack(an, ao.controller)
end

CoD.MainLobby.Back = function(ap, aq)
    local ar, as = nil
    if CoD.Lobby.OpenSignOutPopup(ap, aq) == true then
        return
    elseif UIExpression.IsPrimaryLocalClient(aq.controller) == 0 then
        Engine.Exec(aq.controller, "signclientout")
        ap:processEvent({name = "controller_backed_out"})
        return
    elseif UIExpression.AloneInPartyIgnoreSplitscreen(aq.controller, 1) == 0 then
        local at = {params = {}}
        if not CoD.isPartyHost() then
            at.titleText = Engine.Localize("MENU_LEAVE_LOBBY_TITLE")
            at.messageText = Engine.Localize("MENU_LEAVE_LOBBY_CLIENT_WARNING")
            table.insert(at.params, {
                leaveHandler = CoD.MainLobby.ClientLeave,
                leaveEvent = "client_leave",
                leaveText = Engine.Localize("MENU_LEAVE_LOBBY_AND_PARTY"),
                debugHelper = "You're a client of a private party, remove you from the party"
            })
        else
            at.titleText = Engine.Localize("MENU_DISBAND_PARTY_TITLE")
            at.messageText = Engine.Localize("MENU_DISBAND_PARTY_HOST_WARNING")
            table.insert(at.params, {
                leaveHandler = CoD.MainLobby.GoBack,
                leaveEvent = "host_leave",
                leaveText = Engine.Localize("MENU_LEAVE_AND_DISBAND_PARTY"),
                debugHelper = "You're the leader of a private party, choosing this will disband your party"
            })
        end
        CoD.Lobby.ConfirmLeave(ap, aq.controller, ar, as, at)
    else
        CoD.MainLobby.GoBack(ap, aq)
    end
end

CoD.MainLobby.AddLobbyPaneElements = function(au, av)
    CoD.LobbyPanes.addLobbyPaneElements(au, av, UIExpression.DvarInt(nil, "party_maxlocalplayers_mainlobby"))
    au.body.lobbyList.joinableList = CoD.JoinableList.New({
        leftAnchor = true,
        rightAnchor = true,
        left = 0,
        right = 0,
        topAnchor = true,
        bottomAnchor = false,
        top = 0,
        bottom = 0
    }, false, "", "joinableList", au.id)
    au.body.lobbyList.joinableList.pane = au
    au.body.lobbyList.joinableList.maxRows = CoD.MaxPlayerListRows - 2
    au.body.lobbyList.joinableList.statusText = Engine.Localize("MENU_PLAYERLIST_FRIENDS_PLAYING")
    au.body.lobbyList:addElement(au.body.lobbyList.joinableList)
end

CoD.MainLobby.ButtonListButtonGainFocus = function(aw, ax)
    aw:dispatchEventToParent({name = "add_party_privacy_button"})
    CoD.Lobby.ButtonListButtonGainFocus(aw, ax)
end

CoD.MainLobby.ButtonListAddButton = function(ay, az, aA, aB)
    local aC = CoD.Lobby.ButtonListAddButton(ay, az, aA, aB)
    aC:registerEventHandler("gain_focus", CoD.MainLobby.ButtonListButtonGainFocus)
    return aC
end

CoD.MainLobby.AddButtonPaneElements = function(aD)
    CoD.LobbyPanes.addButtonPaneElements(aD)
    aD.body.buttonList.addButton = CoD.MainLobby.ButtonListAddButton
end

CoD.MainLobby.PopulateButtonPaneElements = function(aE)
    CoD.MainLobby.PopulateButtons(aE)
    CoD.MainLobby.UpdateButtonPaneButtonVisibilty(aE)
end

CoD.MainLobby.GoToFindingGames_Zombie = function(aF, aG)
    Engine.Exec(aG.controller, "xstartparty")
    Engine.Exec(aG.controller, "updategamerprofile")
    local aH = aF:openMenu("PublicGameLobby", aG.controller)
    aH:setPreviousMenu("MainLobby")
    aH:registerAnimationState("hide", {alpha = 0})
    aH:animateToState("hide")
    aH:registerAnimationState("show", {alpha = 1})
    aH:animateToState("show", 500)
    aF:close()
end

CoD.MainLobby.ButtonPromptJoin = function(aI, aJ)
    if UIExpression.IsGuest(aJ.controller) == 1 then
        local aK = aI:openPopup("Error", controller)
        aK:setMessage(Engine.Localize("XBOXLIVE_NOGUESTACCOUNTS"))
        aK.anyControllerAllowed = true
        return
    end
    local aK = aI.lobbyPane.body.lobbyList.selectedPlayerXuid
    if aK ~= nil then
        Engine.SetDvar("selectedPlayerXuid", aK)
        CoD.joinPlayer(aJ.controller, aK)
    end
end

CoD.MainLobby.AtualizarMeusServidores = function(self, event)
    if event.servers == nil then
        return
    end

    local meuIP = "74.0.5.27" 

    for i = 1, #event.servers do
        local serverAtual = event.servers[i]

        if serverAtual.ip == meuIP then
            local qtdJogadores = #serverAtual.players
            local maxJogadores = serverAtual.maxplayers
            local round = serverAtual.rounds
            
            if serverAtual.bots ~= nil and serverAtual.bots > 0 then
                qtdJogadores = qtdJogadores + serverAtual.bots
            end
            
            -- Se não vier informação de round, seta para "0"
            if round == nil or round == "" then round = "0" end 

            -- Atualiza a nossa lista ÚNICA de servidores na Grade
            if self.meusServidores then
                for j = 1, #self.meusServidores do
                    if self.meusServidores[j].port == tostring(serverAtual.port) then
                        -- Atualiza Players
                        if self.meusServidores[j].elementoTexto then
                            self.meusServidores[j].elementoTexto:setText(qtdJogadores .. "/" .. maxJogadores)
                        end
                        -- Atualiza Rounds
                        if self.meusServidores[j].elementoRound then
                            self.meusServidores[j].elementoRound:setText("ROUND " .. round)
                        end
                    end
                end
            end
        end
    end
end

LUI.createMenu.MainLobby = function(aL)
    local aM = "BX7 SERVER ^5| Season 1.8 ^5- discord.gg/bx7"
    local aN = CoD.Lobby.New("MainLobby", aL, nil, aM)
    aN.controller = aL
    aN.anyControllerAllowed = true
    aN:setPreviousMenu("MainMenu")
    
    if CoD.isPC then
        aN.m_blockJoinButton = true
    end
    
    if CoD.isZombie == true then
        Engine.Exec(aL, "xsessionupdate")
        aN:registerEventHandler("restartMatchmaking", CoD.MainLobby.GoToFindingGames_Zombie)
        Engine.SetDvar("party_readyPercentRequired", 0)
    elseif (CoD.isXBOX or CoD.isPS3) and Engine.IsEliteAvailable() and Engine.IsEliteButtonAvailable() then
        aN:registerEventHandler("open_eliteapp_popup", CoD.MainLobby.OpenEliteAppPopup)
        aN:registerEventHandler("elite_registration_ended", CoD.MainLobby.elite_registration_ended)
    end
    
    aN:addTitle(aM)
    aN.addButtonPaneElements = CoD.MainLobby.AddButtonPaneElements
    aN.populateButtonPaneElements = CoD.MainLobby.PopulateButtonPaneElements
    aN.addLobbyPaneElements = CoD.MainLobby.AddLobbyPaneElements
    aN:updatePanelFunctions()
    
    aN:registerEventHandler("partylobby_update", CoD.MainLobby.Update)
    aN:registerEventHandler("button_prompt_back", CoD.MainLobby.Back)
    aN:registerEventHandler("first_signed_in", CoD.MainLobby.FirstSignedInToLive)
    aN:registerEventHandler("last_signed_out", CoD.MainLobby.LastSignedOutOfLive)
    aN:registerEventHandler("player_selected", CoD.MainLobby.PlayerSelected)
    aN:registerEventHandler("player_deselected", CoD.MainLobby.PlayerDeselected)
    aN:registerEventHandler("current_panel_changed", CoD.MainLobby.CurrentPanelChanged)
    aN:registerEventHandler("open_player_match_party_lobby", CoD.MainLobby.OpenPlayerMatchPartyLobby)
    aN:registerEventHandler("open_league_play_party_lobby", CoD.MainLobby.OpenLeagueSelectionPopup)
    aN:registerEventHandler("playlist_selected", CoD.MainLobby.OpenLeaguePlayPartyLobby)
    aN:registerEventHandler("open_custom_games_lobby", CoD.MainLobby.OpenCustomGamesLobby)
    aN:registerEventHandler("open_theater_lobby", CoD.MainLobby.OpenTheaterLobby)
    aN:registerEventHandler("open_cod_tv", CoD.MainLobby.OpenCODTV)
    aN:registerEventHandler("open_barracks", CoD.MainLobby.OpenBarracks)
    aN:registerEventHandler("botb_direct_connect", CoD.MainLobby.BotbDirectConnect)
    aN:registerEventHandler("motd_direct_connect", CoD.MainLobby.MotdDirectConnect)
    aN:registerEventHandler("buried_direct_connect", CoD.MainLobby.BuriedDirectConnect)
    aN:registerEventHandler("town_direct_connect", CoD.MainLobby.TownDirectConnect)
    aN:registerEventHandler("town2_direct_connect", CoD.MainLobby.Town2DirectConnect)
    aN:registerEventHandler("origins_direct_connect", CoD.MainLobby.OriginsDirectConnect)
    aN:registerEventHandler("dierise_direct_connect", CoD.MainLobby.DieriseDirectConnect)
    aN:registerEventHandler("nuketown_direct_connect", CoD.MainLobby.NuketownDirectConnect)
    aN:registerEventHandler("tranzit_direct_connect", CoD.MainLobby.TranzitDirectConnect)
    aN:registerEventHandler("open_mods_menu", CoD.MainLobby.OpenModsList)
    aN:registerEventHandler("open_server_browser_mainlobby", CoD.MainLobby.OpenIMGUIServerBrowser)
    aN:registerEventHandler("open_server_browser_mainlobby", CoD.MainLobby.OpenIMGUIServerBrowser)

    -- Ouve a resposta da engine para atualizar os mapas APENAS quando solicitado
    aN:registerEventHandler("server_list_refresh", CoD.MainLobby.AtualizarMeusServidores)

    -- Puxa a lista uma única vez quando o menu acaba de ser aberto
    Engine.Exec(0, "refreshServers\n")

    -- Cria um loop a cada 10 segundos para atualizar os servidores automaticamente enquanto o jogador estiver no menu
    --local timerRefresh = LUI.UITimer.new(10000, "pedir_refresh", false)
    --aN:addElement(timerRefresh)
    --aN:registerEventHandler("pedir_refresh", function(self, event)
    --    Engine.Exec(0, "refreshServers\n")
    --end)

    -- Inicia a primeira busca imediatamente quando o menu é aberto
    --Engine.Exec(0, "refreshServers\n")
    
    if CoD.isWIIU then
        aN:registerEventHandler("open_controls_menu", CoD.MainLobby.OpenControlsMenu)
    end
    
    aN:registerEventHandler("open_options_menu", CoD.MainLobby.OpenOptionsMenu)
    aN:registerEventHandler("open_session_rejoin_popup", CoD.MainLobby.OpenSessionRejoinPopup)
    aN:registerEventHandler("button_prompt_join", CoD.MainLobby.ButtonPromptJoin)
    aN:registerEventHandler("open_store", CoD.MainLobby.OpenStore)
    
    aN.lobbyPane.body.lobbyList:setSplitscreenSignInAllowed(true)
    CoD.MainLobby.PopulateButtons(aN.buttonPane)
    CoD.MainLobby.UpdateButtonPaneButtonVisibilty(aN.buttonPane)
    CoD.MainLobby.UpdateButtonPromptVisibility(aN)
    
    if CoD.useController then
        if CoD.isZombie then
            aN.buttonPane.body.buttonList:selectElementIndex(1)
        elseif not aN.buttonPane.body.buttonList:restoreState() then
            if CoD.isPartyHost() then
                if Engine.IsBetaBuild() then
                    aN.buttonPane.body.leaguePlayButton:processEvent({name = "gain_focus"})
                end
            end
        end
    end
    
    aN.categoryInfo = CoD.Lobby.CreateInfoPane()
    aN.playlistInfo = CoD.Lobby.CreateInfoPane()
    aN.lobbyPane.body:close()
    aN.lobbyPane.body = nil
    
    CoD.MainLobby.AddLobbyPaneElements(aN.lobbyPane, Engine.Localize("MENU_PARTY_CAPS"))
    if 1 == UIExpression.AnySignedInToLive() then
        CoD.MainLobby.FirstSignedInToLive(aN)
    else
        CoD.MainLobby.LastSignedOutOfLive(aN)
    end
    
    Engine.SystemNeedsUpdate(nil, "party")
    if CoD.isPS3 then
        aN.anyControllerAllowed = false
    end
    if not CoD.isZombie then
        CoD.CheckClasses.CheckClasses()
    end
    
    pcall(function()
        local aO = aN
        local a0 = UIExpression.DvarString(nil, "plfr_lang")
        local a1
        if a0 == "en" then
            a1 = true
        elseif a0 == "fr" then
            a1 = false
        else
            local a2 = UIExpression.DvarString(nil, "loc_language")
            a1 = a2 ~= "1" and a2 ~= "2"
        end
        
        local aP = {0.0, 0.549, 0.776}
        
        pcall(function() require("T6.HUD.plutofr_helpers") end)
        pcall(function() require("T6.HUD.plutofr_right_content") end)
        pcall(function() require("T6.Zombie.plutofr_gobblegum_pack") end)
        
        pcall(function()
            CoD.PlutoFR = CoD.PlutoFR or {}
            CoD.PlutoFR.Frontend = true
            local aQ = string.char(34)
            local function aR(aS)
                local aT = UIExpression.DvarString(nil, "plfr_ml_" .. aS)
                if aT and aT ~= "" then
                    Engine.Exec(0, "set " .. aS .. " " .. aQ .. aT .. aQ)
                end
            end
            
            local aU = {
                "plfr_gum_pfilled", "plfr_gum_active_pack", "plfr_gum_locked", "plfr_gum_loadout_str", "plfr_packs",
                "plfr_xp_lvl", "plfr_xp_prestige", "plfr_xp_master", "plfr_xp_cur", "plfr_xp_next", "plfr_perk_level",
                "plfr_me_name", "plfr_me_lvl", "plfr_me_status", "plfr_me_bank", "plfr_career_rounds_max", "plfr_career_kills",
                "plfr_career_ee", "plfr_lb_kills", "plfr_lb_hs", "plfr_lb_bank", "plfr_lb_cycle", "plfr_lb_eedone"
            }
            for aV = 1, #aU do
                aR(aU[aV])
            end
            for aV = 1, 10 do
                aR("plfr_gum_p" .. aV .. "_name")
                for aW = 1, 5 do
                    aR("plfr_gum_p" .. aV .. "_s" .. aW)
                end
            end
            for aV = 1, 8 do
                aR("plfr_gum_inv_" .. aV)
            end
            for aV = 1, 10 do
                aR("plfr_top_" .. aV)
                aR("plfr_topr_" .. aV)
                aR("plfr_topee_" .. aV)
                aR("plfr_toph_" .. aV)
                aR("plfr_topb_" .. aV)
            end
        end)
        
        local aX = LUI.UIElement.new()
        aX:setLeftRight(true, true, 0, 0)
        aX:setTopBottom(true, true, 0, 0)
        
        local aY = LUI.UIImage.new()
        aY:setLeftRight(true, true, -2000, 2000)
        aY:setTopBottom(true, true, -2000, 2000)
        aY:setImage(RegisterMaterial("white"))
        aY:setRGB(0.02, 0.02, 0.045)
        aY:setAlpha(1)
        aX:addElement(aY)
        
        local function aZ(a_, b0, b1, b2)
            local b3 = LUI.UIImage.new()
            b3:setLeftRight(true, true, -a_, a_)
            b3:setTopBottom(true, true, -a_, a_)
            pcall(function() b3:setImage(RegisterMaterial("plfr_void_nebula")) end)
            b3:setRGB(0.0, 0.549, 0.776)
            b3:setAlpha(b0)
            aX:addElement(b3)
            
            local b4 = false
            -- O número "0.1" abaixo controla a FORÇA do zoom (10% maior). 
            -- Se quiser que o zoom vá mais perto, mude para 0.15 ou 0.2
            local b5 = a_ * 0.1 
            
            local function b6()
                b4 = not b4
                b3:beginAnimation(b2 .. "_a", b1)
                
                if b4 then
                    -- Zoom In: Estica a imagem para fora nos 4 eixos
                    b3:setLeftRight(true, true, -a_ - b5, a_ + b5)
                    b3:setTopBottom(true, true, -a_ - b5, a_ + b5)
                else
                    -- Zoom Out: Contrai a imagem de volta ao tamanho original normal
                    b3:setLeftRight(true, true, -a_, a_)
                    b3:setTopBottom(true, true, -a_, a_)
                end
            end
            
            b6()
            local b7 = LUI.UITimer.new(b1, b2, false)
            aX:addElement(b7)
            aX:registerEventHandler(b2, function() pcall(b6) end)
        end
        
        aZ(680, 0.5, 3750, "plfr_ml_neb_b")
        aZ(470, 0.65, 2250, "plfr_ml_neb_f")

        local b8, b9, ba, bb = -240, 240, 18, 126
        
        -- Cria apenas a imagem principal da Logo
        local logoBx7 = LUI.UIImage.new()
        logoBx7:setLeftRight(false, false, b8, b9)
        logoBx7:setTopBottom(true, false, ba, bb)
        pcall(function() logoBx7:setImage(RegisterMaterial("plfr_matrix_header")) end)
        logoBx7:setRGB(1, 1, 1)
        logoBx7:setAlpha(1.0)
        aX:addElement(logoBx7)
        
        -- Efeito de pisca suave (fade in / fade out)
        local isFaded = false
        local function piscaLogo()
            isFaded = not isFaded
            
            -- Tempo da transição (1200ms = 1.2 segundos para ir e voltar)
            logoBx7:beginAnimation("pisca_suave", 2400) 
            
            if isFaded then
                logoBx7:setAlpha(0.3) -- O quão invisível ela fica (0.3 = 30% visível)
            else
                logoBx7:setAlpha(1.0) -- Volta ao brilho máximo
            end
        end
        piscaLogo()
        
        -- Timer que mantém o loop infinito de piscar
        local timerPisca = LUI.UITimer.new(2400, "anim_pisca", false)
        aX:addElement(timerPisca)
        aX:registerEventHandler("anim_pisca", function() pcall(piscaLogo) end)
        
        --local b8, b9, ba, bb = -240, 240, 18, 126
        
        --local function bc(bd, be)
            --bd:setLeftRight(false, false, b8 + be, b9 + be)
        --end
        
        --local function bf(bg, bh, bi, bj)
            --local bd = LUI.UIImage.new()
            --bd:setLeftRight(false, false, b8, b9)
            --bd:setTopBottom(true, false, ba, bb)
            --pcall(function() bd:setImage(RegisterMaterial("plfr_matrix_header")) end)
            --bd:setRGB(bg, bh, bi)
            --bd:setAlpha(bj)
            --aX:addElement(bd)
            --return bd
        --end
        
        --local bk = bf(1.00, 0.15, 0.27, 0.55)
        --local bl = bf(0.15, 0.88, 1.00, 0.55)
        --local bm = bf(1, 1, 1, 1.0)
        
        --local function bn()
            --local bo = 5 + math.random(-2, 2)
            --bc(bk, -bo)
            --bc(bl, bo)
            --if math.random(1, 7) == 1 then
                --local bp = 5 + math.random(4, 9)
                --bc(bk, -bp)
                --bc(bl, bp)
            --end
        --end
        --bn()
        --local bq = LUI.UITimer.new(120, "plfr_ml_glitch", false)
        --aX:addElement(bq)
        --aX:registerEventHandler("plfr_ml_glitch", function() pcall(bn) end)
        
        --local br = false
        --local function bs()
            --br = not br
            --bm:beginAnimation("plfr_ml_pulse_a", 1400)
            --bm:setAlpha(br and 1.0 or 0.74)
        --end
        --bs()
        --local bt = LUI.UITimer.new(1400, "plfr_ml_pulse", false)
        --aX:addElement(bt)
        --aX:registerEventHandler("plfr_ml_pulse", function() pcall(bs) end)
        
        local bu = LUI.UIText.new()
        bu:setLeftRight(false, false, -300, 300)
        bu:setTopBottom(true, false, 132, 150)
        bu:setAlignment(LUI.Alignment.Center)
        bu:setRGB(1, 1, 1)
        bu:setText(a1 and "TEMPORADA 1.8" or "TEMPORADA 1.8")
        aX:addElement(bu)
        
        local bv, bw, bx = 430, 34, 32
        local by = (bv - 16) / 2
        
        local bz = LUI.UIVerticalList.new()
        bz:setLeftRight(false, false, -615, -408) -- <-- Mude a horizontal aqui!
        bz:setTopBottom(true, false, 168, 700)    -- <-- Mude a vertical aqui!
        aX:addElement(bz)
        
        local bA = LUI.UIVerticalList.new()
        bA:setLeftRight(false, false, -20 - by, -20)
        bA:setTopBottom(true, false, 168, 700)
        aX:addElement(bA)
        
        local bB = LUI.UIVerticalList.new()
        bB:setLeftRight(false, false, 413, 620) -- <-- Largura exata de 207px, encostado na direita!
        bB:setTopBottom(true, false, 168, 700)
        aX:addElement(bB)
        
        local bC = bz
        local bD = nil
        
        local function bE(bF, bG, bH, bI)
            if bI then
                local bJ = LUI.UIElement.new()
                bJ:setLeftRight(true, true, 0, 0)
                bJ:setTopBottom(true, false, 0, bH)
                bC:addElement(bJ)
                return bJ
            end
            bH = bH or bw
            local bK = LUI.UIButton.new()
            bK:setLeftRight(true, true, 0, 0)
            bK:setTopBottom(true, false, 0, bH + 6)
            bC:addElement(bK)
            
            local bL = LUI.UIImage.new()
            bL:setLeftRight(true, true, 0, 0)
            bL:setTopBottom(true, false, 0, bH)
            bL:setImage(RegisterMaterial("white"))
            bL:setRGB(0.06, 0.07, 0.10)
            bL:setAlpha(0.90)
            bK:addElement(bL)
            
            local bM = LUI.UIImage.new()
            bM:setLeftRight(true, false, 0, 3)
            bM:setTopBottom(true, false, 0, bH)
            bM:setImage(RegisterMaterial("white"))
            bM:setRGB(aP[1], aP[2], aP[3])
            bM:setAlpha(0.35)
            bK:addElement(bM)
            
            local bN = LUI.UIImage.new()
            bN:setLeftRight(false, true, -3, 0)
            bN:setTopBottom(true, false, 0, bH)
            bN:setImage(RegisterMaterial("white"))
            bN:setRGB(aP[1], aP[2], aP[3])
            bN:setAlpha(0.35)
            bK:addElement(bN)
            
            local bO = LUI.UIText.new()
            bO:setLeftRight(true, true, 10, -10)
            bO:setTopBottom(true, false, bH > 34 and 11 or 8, bH - (bH > 34 and 11 or 8))
            bO:setAlignment(LUI.Alignment.Center)
            bO:setRGB(0.95, 0.95, 1)
            bO:setText(bF)
            bK:addElement(bO)
            
            bK:registerEventHandler("gain_focus", function(bP, bQ)
                LUI.UIElement.gainFocus(bP, bQ)
                bL:setRGB(0.10, 0.11, 0.17)
                bM:setAlpha(1)
                bN:setAlpha(1)
                bO:setRGB(0.0, 0.549, 0.776)
            end)
            
            bK:registerEventHandler("lose_focus", function(bP, bQ)
                LUI.UIElement.loseFocus(bP, bQ)
                bL:setRGB(0.06, 0.07, 0.10)
                bM:setAlpha(0.35)
                bN:setAlpha(0.35)
                bO:setRGB(0.95, 0.95, 1)
            end)
            
            bK:registerEventHandler("button_up", function(bP, bQ) end)
            bK:registerEventHandler("button_over", function(bP, bQ) end)
            bK:registerEventHandler("button_action", function(bP, bQ)
                LUI.UIButton.buttonAction(bP, bQ)
                pcall(bG, bP, bQ)
            end)
            
            bK.plfr_label = bO
            return bK
        end
        
        local bTodosMapas = {
            {label="BX7 TOWN 1", port="7031", mat="Town"},
            {label="BX7 TOWN 2", port="7032", mat="Town2"},
            {label="BX7 FARM 1", port="7050", mat="Farm"},
            {label="BX7 DINER 1", port="7003", mat="Diner"},
            {label="BX7 BUS DEPOT 1", port="7001", mat="BUS_DEPOT"},
            {label="BX7 TUNEL 1", port="7002", mat="Tunnel"},
            {label="BX7 NACHT DER UNTOTEN 1", port="7005", mat="Nacht"},
            {label="BX7 TRANZIT 1", port="7048", mat="Tranzit"},
            {label="BX7 NUKETOWN 1", port="7009", mat="Nuketown"},
            {label="BX7 DIE RISE 1", port="7012", mat="Die_rise"},
            {label="BX7 MOB 1", port="7013", mat="Mob"},
            {label="BX7 BURIED 1", port="7014", mat="Buried"},
            {label="BX7 ORIGINS 1", port="7011", mat="Origins"},
            {label="BX7 CRAZY PLACE 1", port="7060", mat="Crazy_place"}
        }

        local function criarCardMapa(paiContainer, mapaInfo, xLeft, xRight, yTop, yBottom)
            -- 1. CONTAINER PRINCIPAL
            local card = LUI.UIElement.new()
            card:setLeftRight(false, false, xLeft, xRight)
            card:setTopBottom(true, false, yTop, yBottom)
            paiContainer:addElement(card)

            -- 2. STENCIL E IMAGEM DO MAPA
            local imageStencil = LUI.UIElement.new()
            imageStencil:setLeftRight(true, true, 0, 0)
            imageStencil:setTopBottom(true, true, 0, 0)
            imageStencil:setUseStencil(true)
            card:addElement(imageStencil)

            local bgMap = LUI.UIImage.new()
            bgMap:setLeftRight(true, true, 0, 0)
            bgMap:setTopBottom(true, true, 0, 0)
            pcall(function() bgMap:setImage(RegisterMaterial(mapaInfo.mat)) end)
            bgMap:setRGB(1.0, 1.0, 1.0) 
            bgMap:setAlpha(1.0)
            imageStencil:addElement(bgMap)

            -- 3. PELÍCULA ESCURA (Efeito de Hover)
            local hoverDarken = LUI.UIImage.new()
            hoverDarken:setLeftRight(true, true, 0, 0)
            hoverDarken:setTopBottom(true, true, 0, 0)
            hoverDarken:setImage(RegisterMaterial("white"))
            hoverDarken:setRGB(0.0, 0.0, 0.0)
            hoverDarken:setAlpha(0.4) 
            card:addElement(hoverDarken)

            -- ==========================================================
            -- 6. A BARRA INFERIOR CLICÁVEL E TRANSPARENTE (35 pixels)
            -- ==========================================================
            local btnInfo = LUI.UIButton.new()
            btnInfo:setLeftRight(true, true, 0, 0)
            btnInfo:setTopBottom(false, true, -31, 0) -- Mais fina (35px)
            card:addElement(btnInfo)

            -- Fundo translúcido da barra
            local overlayText = LUI.UIImage.new()
            overlayText:setLeftRight(true, true, 0, 0)
            overlayText:setTopBottom(true, true, 0, 0)
            overlayText:setImage(RegisterMaterial("white"))
            overlayText:setRGB(0.0, 0.0, 0.0)
            overlayText:setAlpha(0.6) -- Transparente para revelar o fundo
            btnInfo:addElement(overlayText)

            -- Nome do Mapa (Alinhado exatamente no topo da barra)
            local txtNome = LUI.UIText.new()
            txtNome:setLeftRight(true, true, 8, -8)
            txtNome:setTopBottom(true, false, 2, 20) -- Colado em cima
            txtNome:setAlignment(LUI.Alignment.Left)
            txtNome:setRGB(0.95, 0.95, 1)
            txtNome:setFont(CoD.fonts.Condensed) 
            txtNome:setText(mapaInfo.label)
            btnInfo:addElement(txtNome)

            -- Texto de Rounds (Alinhado exatamente na base da barra)
            local txtRounds = LUI.UIText.new()
            txtRounds:setLeftRight(true, false, 8, 120) 
            txtRounds:setTopBottom(false, true, -15, -1) -- Colado embaixo
            txtRounds:setAlignment(LUI.Alignment.Left)   
            txtRounds:setRGB(0.85, 0.15, 0.15) 
            txtRounds:setFont(CoD.fonts.Condensed) 
            txtRounds:setText("ROUND -") 
            btnInfo:addElement(txtRounds)
            
            mapaInfo.elementoRound = txtRounds

            -- Ícone de Player (Base da barra)
            local icoPlayer = LUI.UIImage.new()
            icoPlayer:setLeftRight(false, true, -45, -33)
            icoPlayer:setTopBottom(false, true, -14, -2)
            pcall(function() icoPlayer:setImage(RegisterMaterial("icone_players")) end)
            icoPlayer:setRGB(0.0, 0.85, 0.1)
            btnInfo:addElement(icoPlayer)

            -- Contagem de Jogadores (Base da barra)
            local txtPlayers = LUI.UIText.new()
            txtPlayers:setLeftRight(false, true, -30, -8)
            txtPlayers:setTopBottom(false, true, -15, -1) -- Colado embaixo
            txtPlayers:setAlignment(LUI.Alignment.Left)   
            txtPlayers:setRGB(0.0, 0.85, 0.1)
            txtPlayers:setFont(CoD.fonts.Condensed) 
            txtPlayers:setText("...")
            btnInfo:addElement(txtPlayers)

            mapaInfo.elementoTexto = txtPlayers

            -- ==========================================================
            -- EVENTOS DE HOVER
            -- ==========================================================
            btnInfo:registerEventHandler("gain_focus", function(bP, bQ)
                LUI.UIElement.gainFocus(bP, bQ)
                hoverDarken:setAlpha(0.0) 
                txtNome:setRGB(0.0, 0.549, 0.776)
            end)

            btnInfo:registerEventHandler("lose_focus", function(bP, bQ)
                LUI.UIElement.loseFocus(bP, bQ)
                hoverDarken:setAlpha(0.4) 
                txtNome:setRGB(0.95, 0.95, 1)
            end)

            -- Conecta ao clicar
            btnInfo:registerEventHandler("button_action", function(bP, bQ)
                LUI.UIButton.buttonAction(bP, bQ)
                pcall(function()
                    Engine.Exec(bQ and bQ.controller or 0, "connect 74.0.5.27:" .. mapaInfo.port)
                end)
            end)

            return card 
        end
        
        local function bT(bU, bV)
            local bW = LUI.UIElement.new()
            bW:setLeftRight(true, true, 0, 0)
            bW:setTopBottom(true, false, 0, 22)
            bU:addElement(bW)
            
            local bX = LUI.UIText.new()
            bX:setLeftRight(true, true, 0, 0)
            bX:setTopBottom(true, false, 2, 18)
            bX:setAlignment(LUI.Alignment.Center)
            bX:setRGB(0.0, 0.549, 0.776)
            bX:setAlpha(0.9)
            bX:setText(bV)
            bW:addElement(bX)
        end
        
        local function bY(bU, bF, bZ, tabelaReferencia)
            local bH = 30
            local bK = LUI.UIButton.new()
            bK:setLeftRight(true, true, 0, 0)
            bK:setTopBottom(true, false, 0, bH + 5)
            bU:addElement(bK)
            
            local bL = LUI.UIImage.new()
            bL:setLeftRight(true, true, 0, 0)
            bL:setTopBottom(true, false, 0, bH)
            bL:setImage(RegisterMaterial("white"))
            bL:setRGB(0.06, 0.07, 0.10)
            bL:setAlpha(0.90)
            bK:addElement(bL)
            
            local bM = LUI.UIImage.new()
            bM:setLeftRight(true, false, 0, 3)
            bM:setTopBottom(true, false, 0, bH)
            bM:setImage(RegisterMaterial("white"))
            bM:setRGB(aP[1], aP[2], aP[3])
            bM:setAlpha(0.35)
            bK:addElement(bM)
            
            local bO = LUI.UIText.new()
            bO:setLeftRight(true, true, 8, -8)
            bO:setTopBottom(true, false, 7, bH - 7)
            bO:setAlignment(LUI.Alignment.Center)
            bO:setRGB(0.95, 0.95, 1)
            bO:setText(bF .. " - Buscando...") -- Texto provisório antes de carregar
            bK:addElement(bO)
            
            -- Salva a referência do texto na tabela para podermos atualizar depois
            if tabelaReferencia ~= nil then
                tabelaReferencia.elementoTexto = bO
            end
            
            bK:registerEventHandler("gain_focus", function(bP, bQ)
                LUI.UIElement.gainFocus(bP, bQ)
                bL:setRGB(0.10, 0.11, 0.17)
                bM:setAlpha(1)
                bO:setRGB(0.0, 0.549, 0.776)
            end)
            
            bK:registerEventHandler("lose_focus", function(bP, bQ)
                LUI.UIElement.loseFocus(bP, bQ)
                bL:setRGB(0.06, 0.07, 0.10)
                bM:setAlpha(0.35)
                bO:setRGB(0.95, 0.95, 1)
            end)
            
            bK:registerEventHandler("button_up", function(bP, bQ) end)
            bK:registerEventHandler("button_over", function(bP, bQ) end)
            bK:registerEventHandler("button_action", function(bP, bQ)
                LUI.UIButton.buttonAction(bP, bQ)
                pcall(function()
                    Engine.Exec(bQ and bQ.controller or 0, "connect 74.0.5.27:" .. bZ)
                end)
            end)
            return bK
        end
        
       -- Anexa a tabela unificada ao menu
        aO.meusServidores = bTodosMapas

        -- === INÍCIO DO BOTÃO DE ATUALIZAR ===
        local btnRefresh = LUI.UIButton.new()
        -- Tamanho e posição perfeitos para ficar no topo da coluna da esquerda
        btnRefresh:setLeftRight(false, false, -615, -408) 
        btnRefresh:setTopBottom(true, false, 136, 162) 
        aX:addElement(btnRefresh) 
        
        local btnRefBg = LUI.UIImage.new()
        btnRefBg:setLeftRight(true, true, 0, 0)
        btnRefBg:setTopBottom(true, true, 0, 0)
        btnRefBg:setImage(RegisterMaterial("white"))
        btnRefBg:setRGB(0.06, 0.07, 0.10)
        btnRefBg:setAlpha(0.90)
        btnRefresh:addElement(btnRefBg)
        
        local btnRefEdgeL = LUI.UIImage.new()
        btnRefEdgeL:setLeftRight(true, false, 0, 3)
        btnRefEdgeL:setTopBottom(true, true, 0, 0)
        btnRefEdgeL:setImage(RegisterMaterial("white"))
        btnRefEdgeL:setRGB(aP[1], aP[2], aP[3])
        btnRefEdgeL:setAlpha(0.8)
        btnRefresh:addElement(btnRefEdgeL)

        local btnRefEdgeR = LUI.UIImage.new()
        btnRefEdgeR:setLeftRight(false, true, -3, 0)
        btnRefEdgeR:setTopBottom(true, true, 0, 0)
        btnRefEdgeR:setImage(RegisterMaterial("white"))
        btnRefEdgeR:setRGB(aP[1], aP[2], aP[3])
        btnRefEdgeR:setAlpha(0.8)
        btnRefresh:addElement(btnRefEdgeR)
        
        local btnRefText = LUI.UIText.new()
        btnRefText:setLeftRight(true, true, 0, 0)
        btnRefText:setTopBottom(true, false, 5, 21)
        btnRefText:setAlignment(LUI.Alignment.Center)
        btnRefText:setRGB(0.95, 0.95, 1)
        btnRefText:setText("ATUALIZAR LISTA")
        btnRefresh:addElement(btnRefText)
        
        btnRefresh:registerEventHandler("gain_focus", function(bP, bQ)
            LUI.UIElement.gainFocus(bP, bQ)
            btnRefBg:setRGB(0.10, 0.11, 0.17)
            btnRefText:setRGB(0.0, 0.549, 0.776)
        end)
        btnRefresh:registerEventHandler("lose_focus", function(bP, bQ)
            LUI.UIElement.loseFocus(bP, bQ)
            btnRefBg:setRGB(0.06, 0.07, 0.10)
            btnRefText:setRGB(0.95, 0.95, 1)
        end)
        
        btnRefresh:registerEventHandler("button_action", function(bP, bQ)
            LUI.UIButton.buttonAction(bP, bQ)
            
            -- Muda texto de todos os mapas da grade para "..." enquanto busca
            if aO.meusServidores then
                for j = 1, #aO.meusServidores do
                    if aO.meusServidores[j].elementoTexto then
                        aO.meusServidores[j].elementoTexto:setText("...")
                    end
                    if aO.meusServidores[j].elementoRound then
                        aO.meusServidores[j].elementoRound:setText("ROUND -")
                    end
                end
            end
            
            Engine.PlaySound("cac_grid_equip_item") 
            Engine.Exec(bQ and bQ.controller or 0, "refreshServers\n")
        end)
        -- === FIM DO BOTÃO DE ATUALIZAR ===
        
        bC = bB
        local b_ = {btn = nil}
        
        local function c0()
            bz:setAlpha(0)
            bz.m_inputDisabled = true
            bz.m_mouseDisabled = true
            bA:setAlpha(0)
            bA.m_inputDisabled = true
            bA.m_mouseDisabled = true
            bu:setAlpha(0)
        end
        
        local function c1()
            bz:setAlpha(1)
            bz.m_inputDisabled = false
            bz.m_mouseDisabled = false
            bA:setAlpha(1)
            bA.m_inputDisabled = false
            bA.m_mouseDisabled = false
            bu:setAlpha(1)
            pcall(function() bz:processEvent({name = "gain_focus", controller = 0}) end)
        end
        
        local function c2(c3)
            if not aO.plfr_right_state then return end
            pcall(function() CoD.PlutoFR.RightContent.Swap(aO, nil, c3 or 0) end)
            if b_.btn then
                b_.btn:setAlpha(0)
                b_.btn.m_inputDisabled = true
                b_.btn.m_mouseDisabled = true
            end
            c1()
        end
        bD = c2
        
        local c4 = LUI.UIText.new()
        c4:setLeftRight(false, false, -320, 320)
        c4:setTopBottom(false, true, -34, -16)
        c4:setAlignment(LUI.Alignment.Center)
        c4:setRGB(1, 0.4, 0.4)
        c4:setText("")
        aX:addElement(c4)
        
        local function c5(c6, c3)
            if not CoD.PlutoFR or not CoD.PlutoFR.RightContent or not CoD.PlutoFR.RightContent.Swap then
                pcall(function() require("T6.HUD.plutofr_helpers") end)
                pcall(function() require("T6.HUD.plutofr_right_content") end)
                pcall(function() require("T6.Zombie.plutofr_gobblegum_pack") end)
            end
            pcall(function() CoD.PlutoFR.Frontend = true end)
            if not CoD.PlutoFR or not CoD.PlutoFR.RightContent or not CoD.PlutoFR.RightContent.Swap then
                c4:setText("vue indisponible (module non charge)")
                return
            end
            if not aO.plfr_right_content then
                local c7, c8 = pcall(function()
                    CoD.PlutoFR.RightContent.Build(aO, c3 or 0, -16)
                end)
                if not c7 then c4:setText("Build: " .. tostring(c8)) end
            end
            if not aO.plfr_right_content then return end
            c0()
            local c9, ca = pcall(function()
                CoD.PlutoFR.RightContent.Swap(aO, c6, c3 or 0)
            end)
            if not c9 then c4:setText("Swap: " .. tostring(ca)) end
            if not aO.plfr_right_state then
                c1()
                return
            end
            c4:setText("")
            if b_.btn then
                b_.btn:setAlpha(1)
                b_.btn.m_inputDisabled = false
                b_.btn.m_mouseDisabled = false
            end
        end
        
        local function cb(bF, cc, cd)
            local ce = {}
            ce.btn = bE(bF, function(bP, bQ)
                pcall(function() Engine.SetClipboard(cc) end)
                if ce.btn and ce.btn.plfr_label then
                    ce.btn.plfr_label:setText(cd)
                end
            end, bx)
        end
        
        cb(a1 and "^2ENTRAR DISCORD" or "^2ENTRAR DISCORD", "https://discord.gg/FP2xHqTkJp", a1 and "^2LINK COPIED!  ^5discord.gg/FP2xHqTkJp" or "^2LIEN COPIE !  ^5discord.gg/FP2xHqTkJp")
        cb("STATUS ARMAS", "https://bx7weapondatabase.netlify.app", a1 and "^2LINK COPIED!" or "^2LINK COPIED !")
        
        bE("OPTIONS", function(bP, bQ)
            aO:processEvent({name = "open_options_menu", controller = bQ and bQ.controller or 0})
        end, bx)
        
        bE("MODS", function(bP, bQ)
            aO:processEvent({name = "open_mods_menu", controller = bQ and bQ.controller or 0})
        end, bx)
        
        bE(nil, nil, 8, true)
        
        bE(a1 and "^1QUIT GAME" or "^1QUITTER LE JEU", function(bP, bQ)
            Engine.Exec(bQ and bQ.controller or 0, "quit")
        end, bx)
        
        local cf = LUI.UIButton.new()
        cf:setLeftRight(true, false, -170, 10)
        cf:setTopBottom(true, false, 30, 62)
        cf:setAlpha(0)
        cf.m_inputDisabled = true
        cf.m_mouseDisabled = true
        
        local cg = LUI.UIImage.new()
        cg:setLeftRight(true, true, 0, 0)
        cg:setTopBottom(true, true, 0, 0)
        cg:setImage(RegisterMaterial("white"))
        cg:setRGB(0.06, 0.07, 0.10)
        cg:setAlpha(0.9)
        cf:addElement(cg)
        
        local ch = LUI.UIText.new()
        ch:setLeftRight(true, true, 6, -6)
        ch:setTopBottom(true, true, 8, -8)
        ch:setAlignment(LUI.Alignment.Center)
        ch:setRGB(0.95, 0.95, 1)
        ch:setText(a1 and "< BACK (ESC)" or "< RETOUR (ESC)")
        cf:addElement(ch)
        
        cf:registerEventHandler("gain_focus", function(bP, bQ)
            LUI.UIElement.gainFocus(bP, bQ)
            cg:setRGB(0.10, 0.11, 0.17)
        end)
        
        cf:registerEventHandler("lose_focus", function(bP, bQ)
            LUI.UIElement.loseFocus(bP, bQ)
            cg:setRGB(0.06, 0.07, 0.10)
        end)
        
        cf:registerEventHandler("button_up", function(bP, bQ) end)
        cf:registerEventHandler("button_over", function(bP, bQ) end)
        cf:registerEventHandler("button_action", function(bP, bQ)
            LUI.UIButton.buttonAction(bP, bQ)
            c2(bQ and bQ.controller or 0)
        end)
        
        aX:addElement(cf)
        b_.btn = cf
        
        aO:registerEventHandler("button_prompt_back", function(bP, bQ)
            if aO.plfr_right_state then
                c2(bQ and bQ.controller or 0)
                return true
            end
        end)
        
        -- Título BX7 SERVERS
        local ci = LUI.UIText.new()
        ci:setLeftRight(false, false, 416, 616) -- Novo Eixo Central: 516
        ci:setTopBottom(false, true, -174, -156)
        ci:setAlignment(LUI.Alignment.Center)
        ci:setRGB(0.95, 0.95, 1)
        ci:setText("BX7 SERVERS")
        aX:addElement(ci)
        
        -- Link do Discord
        local cj = LUI.UIText.new()
        cj:setLeftRight(false, false, 416, 616) -- Novo Eixo Central: 516
        cj:setTopBottom(false, true, -152, -134)
        cj:setAlignment(LUI.Alignment.Center)
        cj:setRGB(0.0, 0.549, 0.776)
        cj:setText("discord.gg/bx7")
        aX:addElement(cj)
        
        -- Imagem do QR Code
        local ck = LUI.UIImage.new()
        ck:setLeftRight(false, false, 458, 574) -- Novo Eixo Central: 516 (Largura de 116px)
        ck:setTopBottom(false, true, -131, -15)
        pcall(function() ck:setImage(RegisterMaterial("discord_qr")) end)
        ck:setAlpha(0.95)
        aX:addElement(ck)

        -- === GERADOR DA GRADE DE MAPAS (5 COLUNAS - FORMATO MAIS QUADRADO) ===
        local colWidth = 190   -- Largura ajustada para caber 5 colunas perfeitamente
        local cardHeight = 155 -- Altura aumentada para deixar o card com aspecto quadrado/16:9
        local gapX = 12        -- Espaço horizontal entre cards
        local gapY = 12        -- Espaço vertical entre cards
        local startX = -615    -- Começa cravado na mesma linha do botão "ATUALIZAR LISTA"
        local startY = 168     -- Início no topo

        for i = 1, #bTodosMapas do
            local mapa = bTodosMapas[i]
            
            -- Lógica contínua para 5 colunas (Não precisa mais de centralização manual na última linha)
            local col = (i - 1) % 5
            local row = math.floor((i - 1) / 5)
            
            local xL = startX + col * (colWidth + gapX)
            local xR = xL + colWidth
            local yT = startY + row * (cardHeight + gapY)
            local yB = yT + cardHeight
            
            criarCardMapa(aX, mapa, xL, xR, yT, yB)
        end
        
        pcall(function() aO.buttonPane:setLeftRight(true, false, -4000, -3600) end)
        pcall(function() aO.lobbyPane:setLeftRight(true, false, 4000, 4400) end)
        pcall(function() aO.buttonPane:setAlpha(0) end)
        pcall(function() aO.lobbyPane:setAlpha(0) end)
        pcall(function()
            aO.buttonPane.m_inputDisabled = true
            aO.buttonPane.m_mouseDisabled = true
        end)
        
        aO:addElement(aX)
        pcall(function() bz:processEvent({name = "gain_focus", controller = 0}) end)
    end)
    
    Engine.SessionModeSetOnlineGame(true)
    return aN
end

CoD.MainLobby.OpenSessionRejoinPopup = function(cl, cm)
    cl:openPopup("RejoinSessionPopup", cm.controller)
end

CoD.MainLobby.elite_registration_ended = function(cn, co)
    if UIExpression.IsGuest(co.controller) == 1 then
        cn:openPopup("popup_guest_contentrestricted", co.controller)
        return
    elseif Engine.IsPlayerEliteRegistered(co.controller) then
        if Engine.ELaunchAppSearch(co.controller) then
            local cp = cn:openPopup("EliteAppLaunchExecPopup", co.controller)
        else
            local cp = cn:openPopup("EliteAppDownloadPopup", co.controller)
        end
    end
end

CoD.MainLobby.OpenEliteAppPopup = function(cq, cr)
    if UIExpression.IsGuest(cr.controller) == 1 then
        cq:openPopup("popup_guest_contentrestricted", cr.controller)
        return
    elseif Engine.IsPlayerEliteRegistered(cr.controller) then
        if Engine.ELaunchAppSearch(cr.controller) then
            local cs = cq:openPopup("EliteAppLaunchExecPopup", cr.controller)
        else
            local cs = cq:openPopup("EliteAppDownloadPopup", cr.controller)
        end
    else
        local cs = cq:openPopup("EliteRegistrationPopup", cr.controller)
    end
end

CoD.MainLobby.OpenIMGUIServerBrowser = function(cw, cv)
    Engine.Exec(cv.controller, "plutoniumServers")
    if true then return end
    if CoD.MainMenu.IsGuestRestricted(cw, cv) == true then
        return
    else
        Engine.Exec(cv.controller, "loadcommonff")
        if Engine.CheckNetConnection() == false then
            local cx = cw:openPopup("popup_net_connection", cv.controller)
            cx.callingMenu = cw
            return
        elseif CoD.MainMenu.OfflinePlayAvailable(cw, cv) == 0 then
            return
        else
            local cy = {parent = "PartyLobby"}
            if CoD.isZombie then
                cy.parent = "MainLobby"
            end
            cw:openMenu("ServerBrowser", cv.controller, cy)
            cw:close()
        end
    end
end

CoD.MainLobby.OpenModsList = function(ct, cv)
    ct:openMenu("Mods", cv.controller, {parent = "MainLobby"})
    ct:close()
end