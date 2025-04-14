-- Библиотеки
require("moonloader")
require("sampfuncs")
local f = require 'moonloader'.font_flag
local font = renderCreateFont('Arial', 15, f.BOLD + f.SHADOW)
local bass = require 'lib.bass'
local sampev = require("samp.events")

-- imgui
local imgui = require 'mimgui'
local encoding = require 'encoding'
encoding.default = 'CP1251'
local u8 = encoding.UTF8
local fa = require("fAwesome6")

-- Версия скрипта
local updateCheckUrl = "https://github.com/btrtmr18/azhelper/blob/bbd1d2b4137953db34c5b7aa9d13681d3af978c4/version.txt"
local scriptUrl = "https://raw.githubusercontent.com/btrtmr18/azhelper/main/azhelper.lua"
local scriptPath = thisScript().path
local currentVersion = "2.0.0"

-- Обновление
lua_thread.create(function()
    if doesFileExist("moonloader/lib/requests.lua") then
        local requests = require("lib.requests")
        local response = requests.get(updateCheckUrl)
        if response.status_code == 200 then
            local latestVersion = response.text:match("(%d+%.%d+%.%d+)")
            if latestVersion and latestVersion ~= currentVersion then
                sampAddChatMessage("[ARZ-Helper] Доступна новая версия: " .. latestVersion, 0x40FF40)
                sampAddChatMessage("[ARZ-Helper] Обновление начнётся через 3 секунды...", 0x40FF40)
                wait(3000)

                local update = requests.get(scriptUrl)
                if update.status_code == 200 and update.text then
                    local file = io.open(scriptPath, "w+")
                    file:write(update.text)
                    file:close()

                    sampAddChatMessage("[ARZ-Helper] Скрипт обновлён до версии " .. latestVersion .. ". Перезапускаем...", 0x40FF40)
                    lua_thread.create(function()
                        wait(1000)
                        thisScript():reload()
                    end)
                else
                    sampAddChatMessage("[ARZ-Helper] Ошибка загрузки обновления.", 0xFF4040)
                end
            else
                sampAddChatMessage("[ARZ-Helper] Установлена последняя версия ("..currentVersion..")", 0xAAAAAA)
            end
        else
            sampAddChatMessage("[ARZ-Helper] Ошибка проверки обновлений. Код: "..response.status_code, 0xFF4040)
        end
    else
        sampAddChatMessage("[ARZ-Helper] Требуется библиотека requests.lua в moonloader/lib", 0xFF4040)
    end
end)

-- Инициализация imgui
imgui.OnInitialize(function()
    imgui.GetIO().IniFilename = nil
    local config = imgui.ImFontConfig()
    config.MergeMode = true
    config.PixelSnapH = true
    iconRanges = imgui.new.ImWchar[3](fa.min_range, fa.max_range, 0)
    imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(fa.get_font_data_base85("solid"), 14, config, iconRanges)
end)

-- Утилиты imgui
function imgui.TextQuestion(text)
    imgui.TextDisabled("(?)")
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.PushTextWrapPos(450)
        imgui.TextUnformatted(text)
        imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end

function imgui.CenterText(text)
    imgui.SetCursorPosX(imgui.GetWindowWidth()/2-imgui.CalcTextSize(u8(text)).x/2)
    imgui.Text(u8(text))
end

-- GUI Переменные
local WinState = imgui.new.bool()
local tab = 1

-- Главная логика
function main()
    while not isSampAvailable() do wait(100) end

    sampAddChatMessage('[ARZ-Helper] Скрипт успешно запущен. Введите команду /test13.', 0xff0000)

    sampRegisterChatCommand('test13', function()
        WinState[0] = not WinState[0]
    end)

    while true do wait(0) end
end

-- Окно
imgui.OnFrame(function() return WinState[0] end, function(player)
    imgui.SetNextWindowPos(imgui.ImVec2(1000, 500), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(1100, 200), imgui.Cond.Always)

    imgui.Begin(fa('folder')..u8' [ARZ-Helper]: Помощь', WinState, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse)

    local button_bg_color = imgui.ImVec4(0.2, 0.2, 0.2, 1.0)
    local button_hover_color = imgui.ImVec4(0.3, 0.3, 0.3, 1.0)
    local button_active_color = imgui.ImVec4(0.4, 0.4, 0.4, 1.0)

    -- Кнопки вкладок
    imgui.PushStyleColor(imgui.Col.Button, button_bg_color)
    imgui.PushStyleColor(imgui.Col.ButtonHovered, button_hover_color)
    imgui.PushStyleColor(imgui.Col.ButtonActive, button_active_color)
    if imgui.Button(fa("shield-alt").." "..u8'Помощник для страховой компании', imgui.ImVec2(225, 30)) then tab = 1 end
    imgui.PopStyleColor(3)

    imgui.PushStyleColor(imgui.Col.Button, button_bg_color)
    imgui.PushStyleColor(imgui.Col.ButtonHovered, button_hover_color)
    imgui.PushStyleColor(imgui.Col.ButtonActive, button_active_color)
    if imgui.Button(fa("list").." "..u8'Команды', imgui.ImVec2(225, 30)) then tab = 2 end
    imgui.PopStyleColor(3)

    imgui.PushStyleColor(imgui.Col.Button, button_bg_color)
    imgui.PushStyleColor(imgui.Col.ButtonHovered, button_hover_color)
    imgui.PushStyleColor(imgui.Col.ButtonActive, button_active_color)
    if imgui.Button(fa("info-circle").." "..u8'О скрипте', imgui.ImVec2(225, 30)) then tab = 3 end
    imgui.PopStyleColor(3)

    imgui.SetCursorPos(imgui.ImVec2(240, 28))
    if imgui.BeginChild('Name##'..tab, imgui.ImVec2(850, 160), true) then
        if tab == 1 then
            imgui.CenterText('Описание')
            imgui.Separator()
            imgui.TextColored(imgui.ImVec4(255.40, 165.100, 0.100, 1.0), u8'Оповещение:')
            imgui.SameLine()
            imgui.Text(u8'При наличии игрока на пикапах оформления страховок скрипт активирует уведомление и звонок колокольчика.')
            imgui.Text(u8"Команда:")
            imgui.SameLine()
            imgui.TextColored(imgui.ImVec4(255.40, 165.100, 0.100, 1.0), u8'/ins')
        elseif tab == 2 then
            imgui.CenterText('Описание')
            imgui.Separator()
            imgui.Text(u8'Сокращение команды /findihouse [ID]')
            imgui.SameLine()
            imgui.TextQuestion(u8'/fh [ID]')
            imgui.Text(u8'Сокращение команды /findibiz [ID]')
            imgui.SameLine()
            imgui.TextQuestion(u8'/fib [ID]')
        elseif tab == 3 then
            imgui.Text(u8"Разработчик скрипта: Timur//.")
            imgui.Text(u8"Скрипт разработан персонально для ... .")
            if imgui.Button(fa('user')..u8' Связь с автором скрипта') then
                os.execute("start https://vk.com/id124779478")
            end
        end
        imgui.EndChild()
    end
    imgui.End()
end)
