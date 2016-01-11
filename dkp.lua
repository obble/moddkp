

    local _G = getfenv(0)

    local useOfficerNotes = false
    local TEXTURE = [[Interface\AddOns\modui\statusbar\texture\sb.tga]]
    local BACKDROP = {bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],}
    MODDKP_GUILDMEMBERS = {}

    -- data for use after use:
    -- array: [1] = name, [2] = dkp value, [3] = class, [4] = guildnote, [5] = isonline

    -- toggle "show offline members" during fetch sequence
    -- dkp values next to rolls in ChatFrame
    -- DKP upper threshold in "/dkp add" command
    -- "sort" by:
        -- most to least DKP
        -- alphabetical
        -- guild rank
    -- search ?

    -- print = function(m) DEFAULT_CHAT_FRAME:AddMessage(m) end

    local fetch = function()
        local f = _G['moddkp_container']
        local max = 0
        MODDKP_GUILDMEMBERS = {}                                     -- wipe
        SetGuildRosterShowOffline(true)
        local total, online_max, online = GetNumGuildMembers()
        for i = 1, total do
            local note, v
        	local name, _, _, _, class, _, publicnote, officernote, online = GetGuildRosterInfo(i)

            if useOfficerNotes then note = officernote else note = publicnote end

            if not note or note == '' then note = '<0>' end
            local _, _, dkp = string.find(note, '<(-?%d*)>')
            if not dkp then dkp = 0 end
    		if dkp and tonumber(dkp) then v = (1*dkp) end

            MODDKP_GUILDMEMBERS[i] = {name, v, class, note, online} -- iteration will always be based on position in guild ranking
                                                                    -- to-do: acclimatise for guild members joining/leaving
        end
    end

    local list = function()
        local f = _G['moddkp_body']
        local max, h, j = 0, 0, 1
        for i = 1, tlength(MODDKP_GUILDMEMBERS) do
            local info =  MODDKP_GUILDMEMBERS[i]

            if info[2] > max then max = info[2] end

            if not _G['moddkp_unit'..j] then
                local colour = RAID_CLASS_COLORS[string.upper(info[3])]

                local bu = CreateFrame('Statusbar', 'moddkp_unit'..j, f)
                bu:SetWidth(300) bu:SetHeight(18)
                bu:SetStatusBarTexture(TEXTURE)
                bu:SetMinMaxValues(0, max)
                bu:SetBackdrop(BACKDROP)
                bu:SetBackdropColor(colour.r*.4, colour.g*.4, colour.b*.4, 1)
                bu:SetValue(info[2])
                bu:SetStatusBarColor(colour.r, colour.g, colour.b)

                bu.name = bu:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
                bu.name:SetPoint('LEFT', bu, 5, 0)
                bu.name:SetText(info[1])
                bu.name:SetTextColor(colour.r, colour.g, colour.b)

                bu.dkp = bu:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
                bu.dkp:SetPoint('RIGHT', bu, -10, 0)
                bu.dkp:SetText(info[2]..' dkp')

                if i == 1 then
                    bu:SetPoint('TOP', f)
                else
                    bu:SetPoint('TOPLEFT', _G['moddkp_unit'..(i - 1)], 'BOTTOMLEFT', 0, -4)
                end

                h = bu:GetHeight()
                j = j + 1
            end
        end
        f:SetHeight(h*j)
    end

    --[[local arrangeby_HIGHEST = function()
        for i = 1, tlength(guild) do
            local hierarchy = {}
            print(i)
        end
    end ]]

    --[[ local list_RAID = function()
        for i = 1, GetNumRaidMembers() do
            local name, _, _, _, class = GetRaidRosterInfo(i)
            for j = 1, GetNumGuildMembers() do
                local info = MODDKP_GUILDMEMBERS[j]
                if name == info[1] then
                    local dkp = info[2]
                end
            end
        end
    end ]]

    local toggle = function()
        local f = _G['moddkp_container']
        if f:IsShown() then f:Hide() else f:Show() end
    end

    _G['moddkp_container']:SetScript('OnShow', function()
        GuildRoster()   -- update info
        fetch()
        list()
    end)
    _G['Minimap_moddkp']:SetScript('OnClick', toggle)

    SLASH_MODDKP1 = '/moddkp'
    SlashCmdList['MODDKP'] = function(msg)
        toggle()
    end


    --
