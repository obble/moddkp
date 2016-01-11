

    local _G = getfenv(0)

    local useOfficerNotes = false
    local TEXTURE = [[Interface\AddOns\modui\statusbar\texture\sb.tga]]
    local BACKDROP = {bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],}
    local guild = {}

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
        local index, max = 0, 0
        guild = {}   -- wipe
        SetGuildRosterShowOffline(true)
        local total, online_max, online = GetNumGuildMembers()
        for i = 1, total do
            local note, v
        	local name, _, _, _, class, _, publicnote, officernote, online = GetGuildRosterInfo(i)
            local bu = _G['moddkp_guild'..i]

            if useOfficerNotes then note = officernote else note = publicnote end

            if not note or note == '' then note = '<0>' end
            local _, _, dkp = string.find(note, '<(-?%d*)>')
            if not dkp then dkp = 0 end
    		if dkp and tonumber(dkp) then v = (1*dkp) end

            if v > max then max = v end

            guild[index] = {name, v, class, note, online}

            index = index + 1

            bu:SetMinMaxValues(0, max)
            bu:SetValue(v)
            bu.dkp:SetText(v..' dkp')
        end
    end

    local arrangeby_HIGHEST = function()
        for i = 1, tlength(guild) do
            local hierarchy = {}
            print(i)
        end
    end

    local list = function()
        for i = 1, GetNumRaidMembers() do
            local name, _, _, _, class = GetRaidRosterInfo(i)
            for j = 1, GetNumGuildMembers() do
                local info = guild[j]
                if name == info[1] then
                    local dkp = info[2]
                end
            end
        end
    end

    local toggle = function()
        local f = _G['moddkp_container']
        if f:IsShown() then f:Hide() else f:Show() end
    end

    _G['moddkp_container']:SetScript('OnShow', function()
        GuildRoster()   -- update info
        fetch()
    end)
    _G['Minimap_moddkp']:SetScript('OnClick', toggle)

    SLASH_MODDKP1 = '/moddkp'
    SlashCmdList['MODDKP'] = function(msg)
        toggle()
    end


    --
