--[[

    Metrostroi Context Menu
    Добавляет контекстное меню для удобного телепорта между станциями и выполнении команд. 

    Author: Alexey
    Steam: http://steamcommunity.com/profiles/76561198235732946
    Discord: 257516660431257600 (Alexey#3650)

]]

Alexey = Alexey or {}
Alexey.MetrostroiContextMenu = Alexey.MetrostroiContextMenu or {}

local stationtable = {}

for k, v in pairs(Metrostroi.StationConfigurations) do
    if isnumber(k) then
        if v.names[name_num] then
            table.insert(stationtable, {tonumber(k), tostring(v.names[name_num])})
        else
            table.insert(stationtable, {tonumber(k), tostring(v.names[1])})
        end
    end
end

table.sort(stationtable, function(a, b)
    if a[1] ~= nil and b[1] ~= nil then return a[1] < b[1] end
end)

for k, v in pairs(Metrostroi.StationConfigurations) do
    if isstring(k) then
        if v.names[name_num] then
            table.insert(stationtable, {k, tostring(v.names[name_num])})
        else
            table.insert(stationtable, {k, tostring(v.names[1])})
        end
    end
end

local function can(ulxcommand)
    return ULib.ucl.query(LocalPlayer(), "ulx "..ulxcommand)
end

local function textbox(strTitle, strBtn, strDefaultText, cbfunc)
    local confFrame = vgui.Create ("DFrame")
    confFrame:SetTitle (strTitle)
    confFrame:ShowCloseButton(true)
    confFrame:MakePopup()
    confFrame:SetSize (512, 108)
    confFrame:Center()
    confFrame:SetKeyboardInputEnabled(true)
    confFrame:SetMouseInputEnabled(true)

    local TextEntr = vgui.Create( "DTextEntry", confFrame)
    TextEntr:SetPos(64,32)
    TextEntr:SetSize(384, 28)
    TextEntr:SetMultiline(false)
    TextEntr:SetAllowNonAsciiCharacters( true )
    TextEntr:SetText(strDefaultText || "")
    TextEntr:SetEnterAllowed(true)

    local Btn = vgui.Create("DButton", confFrame)
    Btn:SetText(strBtn)
    Btn:SetSize(128, 28)
    Btn:SetPos(confFrame:GetWide()/2-Btn:GetWide()/2, 68)
    Btn.DoClick = function()
            cbfunc(TextEntr:GetValue())
            confFrame:Remove()
    end
end

local headbgc, bodybgc, footbgc = Color(234,237,255), Color(255,255,255), Color(255,255,255,255)

function Alexey.MetrostroiContextMenu:openmenu()
    local cm = DermaMenu()

    cm.Paint = function(self, w,h)
        draw.RoundedBox(0,0,0,w,h,bodybgc)
    end

    local hostname = vgui.Create( "DPanel", cm )
    hostname:SetSize( cm:GetWide(), 20 )
    hostname.Paint = function(self, w,h)
        draw.RoundedBox(0,0,0,w,h,headbgc)
    end
    local hostnamel = vgui.Create("DLabel", hostname)
    hostnamel:SetTextColor(Color(87,87,87))
    hostnamel:Dock(FILL)
    hostnamel:SetText(" "..GetHostName())

    cm:AddPanel( hostname )

    cm:AddOption("Профиль", function() 
        RunConsoleCommand("ulx", "pr", "^") 
    end):SetImage("icon16/vcard.png")

    cm:AddSpacer()

    -- Телепорт меню

    local tpmenu, option = cm:AddSubMenu("Телепорт меню")
    option:SetImage("icon16/lightning_go.png")

    if can("goto") then
        local tptoplayer, option = tpmenu:AddSubMenu("Телепорт к игроку")
        option:SetImage("icon16/user.png")

        for id, pl in pairs(player.GetAll()) do
            if pl == LocalPlayer() then continue end

            tptoplayer:AddOption(tostring(pl:GetName()), function()
                RunConsoleCommand("ulx", "goto", tostring(pl:GetName()))
            end)
        end
    end

    if can("bring") then
        local bringplayer, option = tpmenu:AddSubMenu("Телепортировать игрока к себе")
        option:SetImage("icon16/arrow_left.png")

        for id, pl in pairs(player.GetAll()) do
            if pl == LocalPlayer() then continue end

            bringplayer:AddOption(tostring(pl:GetName()), function()
                RunConsoleCommand("ulx", "bring", tostring(pl:GetName()))
            end)
        end
    end

    if can("station") and stationtable then
        local tptostation, option = tpmenu:AddSubMenu("Телепорт на станцию")
        option:SetImage("icon16/building.png")

        for num, v in pairs(stationtable) do
            tptostation:AddOption(v[1] .. " | " .. v[2], function()
                RunConsoleCommand("ulx", "station", tostring(v[1]))
            end):SetImage("icon16/bullet_green.png")
        end
    end

    if can("traintp") then
        tpmenu:AddOption("Телепорт в свой состав", function()
            RunConsoleCommand("ulx", "traintp", "^")
        end):SetImage("icon16/car.png")
    end

    if can("return") then
        tpmenu:AddOption("Вернуться назад", function()
            RunConsoleCommand("ulx", "return", "^")
        end):SetImage("icon16/arrow_undo.png")
    end
    --Управление составом

    local trainmenu, option = cm:AddSubMenu("Управление составом")
    option:SetImage("icon16/car.png")

    if can("trainstart") then 
        trainmenu:AddOption("Авто-запуск кабины", function()
            RunConsoleCommand("ulx", "trainstart")
        end):SetImage("icon16/wand.png")
    end

    if can("trainstop") then
        trainmenu:AddOption("Авто-стоп кабины", function()
            RunConsoleCommand("ulx", "trainstop")
        end):SetImage("icon16/wand.png")
    end

    if can("sch") then
        trainmenu:AddOption("\"Умная\" смена кабины", function()
            RunConsoleCommand("ulx", "sch")
        end):SetImage("icon16/wand.png")
    end

    if can("expass") then
        trainmenu:AddOption("Высадить пассажиров", function()
            RunConsoleCommand("ulx", "expass")
        end):SetImage("icon16/user_delete.png")
    end

    if LocalPlayer():IsAdmin() then
        trainmenu:AddOption("Отключение систем АРС (срывает пломбы)", function()
            RunConsoleCommand("metrostroi_disablears")
        end):SetImage("icon16/exclamation.png")
    end

    trainmenu:AddOption("Случайная неисправность", function()
        RunConsoleCommand("metrostroi_fail")
    end):SetImage("icon16/error.png")

    if can("asay") then
        cm:AddOption("Написать администратору", function()
            textbox("Введите сообщение администратору", "Отправить", "сообщение", function(message)
                RunConsoleCommand("ulx", "asay", message)
            end)
        end):SetImage("icon16/shield.png")
    end

    cm:AddSpacer()
    
    if can("kick") then
        local adminm = vgui.Create( "DPanel", cm )
        adminm:SetSize( cm:GetWide(), 20 )
        adminm.Paint = function(self, w,h)
            draw.RoundedBox(0,0,0,w,h,headbgc)
        end
        local adminl = vgui.Create("DLabel", adminm)
        adminl:SetTextColor(Color(87,87,87))
        adminl:Dock(FILL)
        adminl:SetText(" Админ-меню ")
        cm:AddPanel( adminm ) 

        cm:AddSpacer()

    end
        
    if can("kick") then
        local kickmenu, option = cm:AddSubMenu("Кикнуть игрока")
        option:SetImage("icon16/status_away.png")

        for num, v in pairs(player.GetAll()) do
            kickmenu:AddOption(v:Nick(), function()
                textbox("Кикнуть игрока "..v:Nick(), "Кикнуть", "причина", function(reason)
                    RunConsoleCommand("ulx", "kick", v:Nick(), reason)
                end)
            end):SetImage("icon16/bullet_red.png")
        end
    end

    if can("banid") then
        local banmenu, option = cm:AddSubMenu("Забанить игрока")
        option:SetImage("icon16/status_busy.png")

        for num, ply in pairs(player.GetAll()) do
            local user, option = banmenu:AddSubMenu(ply:Name())
            option:SetImage("icon16/user_red.png")

            local banlenght = {{"1 час", 60}, {"2 часа", 120}, {"6 часов", 360}, {"1 день", 1440}, {"2 дня", 2880}, {"Навсегда",0}}

            for k, v in pairs(banlenght) do
                user:AddOption(tostring(v[1]), function()
                    textbox("Забанить игрока "..ply:Nick(), "Забанить", "причина", function(reason)
                        RunConsoleCommand("ulx", "banid", ply:SteamID(), tostring(v[2]), reason)
                    end)
                end)
            end
        end
    end
    
    cm:Open(0,ScrH()/2-cm:GetTall())
end

concommand.Add("metrostroi_contextmenu", function() 
    Alexey.MetrostroiContextMenu:openmenu() 
end)

hook.Add("OnContextMenuOpen", "MetrostroiContextMenu", function()
    LocalPlayer():ConCommand("metrostroi_contextmenu")
end)
