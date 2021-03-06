

    local _G = getfenv(0)
    local f = CreateFrame'Frame'
    local useOfficerNotes = false
    local TEXTURE = [[Interface\AddOns\modui\statusbar\texture\sb.tga]]
    local BACKDROP = {bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],}
    MODDKP_GUILDMEMBERS = {}    MODDKP_GUILDMEMBERS_SHOWN = {}

    local armour = {
        ['Cloth']   = {'Mage', 'Priest', 'Warlock'},
        ['Leather'] = {'Druid', 'Rogue'},
        ['Mail']    = {'Hunter', 'Shaman'},
        ['Plate']   = {'Paladin', 'Warrior'},
    }

    local tlength = function(t)
        local count = 0
        for _ in pairs(t) do count = count + 1 end
        return count
    end

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
    -- move dropdown functions to bottom of menu

    -- print = function(m) DEFAULT_CHAT_FRAME:AddMessage(m) end

    local sort = function(a, b)
            -- show higher value first, or alphabetically within same priority
        return a[2] > b[2] or a[2] == b[2] and a[1] < b[1]
    end

    local fetch = function()
        local f = _G['moddkp_container']
        local max = 0
        local r = GetGuildRosterShowOffline()
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
        SetGuildRosterShowOffline(r)
    end

    local form = function(f)
        for i = 1, tlength(MODDKP_GUILDMEMBERS) do
            if not _G['moddkp_unit'..i] then
                local bu = CreateFrame('Statusbar', 'moddkp_unit'..i, f)
                bu:SetWidth(300) bu:SetHeight(18)
                bu:SetStatusBarTexture(TEXTURE)
                bu:SetMinMaxValues(0, 1)
                bu:SetBackdrop(BACKDROP)

                bu.name = bu:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
                bu.name:SetPoint('LEFT', bu, 5, 0)

                bu.dkp = bu:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
                bu.dkp:SetPoint('RIGHT', bu, -10, 0)
            end
        end
    end

    local list_RAID = function()
        MODDKP_GUILDMEMBERS_SHOWN = {}
        for i = 1, tlength(MODDKP_GUILDMEMBERS) do
            local info = MODDKP_GUILDMEMBERS[i]
            for j = 1, GetNumRaidMembers() do
                local name, _, _, _, class = GetRaidRosterInfo(j)
                if name == info[1] then
                    MODDKP_GUILDMEMBERS_SHOWN[j] = {info[1], info[2], info[3], info[4], info[5]}
                end
            end
        end
    end

    local list_CLASS = function(title)
        MODDKP_GUILDMEMBERS_SHOWN = {}
        local index = 1
        for i = 1, tlength(MODDKP_GUILDMEMBERS) do
            local info = MODDKP_GUILDMEMBERS[i]
            if info[3] == title.text:GetText() then
                MODDKP_GUILDMEMBERS_SHOWN[index] = {info[1], info[2], info[3], info[4], info[5]}
                index = index + 1
            end
        end
    end

    local list_ARMOUR = function(title)
        MODDKP_GUILDMEMBERS_SHOWN = {}
        local index = 1
        for i = 1, tlength(MODDKP_GUILDMEMBERS) do
            local info = MODDKP_GUILDMEMBERS[i]
            for k, v in pairs(armour) do
                if k == title.text:GetText() then
                    for _, j in pairs(v) do
                        if info[3] == j then
                            MODDKP_GUILDMEMBERS_SHOWN[index] = {info[1], info[2], info[3], info[4], info[5]}
                            index = index + 1
                        end
                    end
                end
            end
        end
    end

    local list = function(title)
        local f         = _G['moddkp_body']
        local container = _G['moddkp_container']
        local sf        = _G['moddkp_scrollframe']
        local max, h, j = 0, 0, 1

        if f.raid then list_RAID()
        elseif f.class then list_CLASS(title)
        elseif f.armour then list_ARMOUR(title)
        else MODDKP_GUILDMEMBERS_SHOWN = MODDKP_GUILDMEMBERS end

        table.sort(MODDKP_GUILDMEMBERS_SHOWN, sort)

        for i = 1, tlength(MODDKP_GUILDMEMBERS) do
            local bu = _G['moddkp_unit'..i]
            if bu then bu:Hide() end
        end

        form(f)

        for i = 1, tlength(MODDKP_GUILDMEMBERS_SHOWN) do
            local info = MODDKP_GUILDMEMBERS_SHOWN[i]

            if info and info[2] then
                local bu = _G['moddkp_unit'..i]
                local colour = RAID_CLASS_COLORS[string.upper(info[3])]

                if info[2] > max then max = info[2] end

                bu:SetMinMaxValues(0, max)
                bu:SetBackdropColor(colour.r*.4, colour.g*.4, colour.b*.4, 1)
                bu:SetValue(info[2])
                bu:SetStatusBarColor(colour.r, colour.g, colour.b)
                bu:Show()

                bu.name:SetText(info[1])
                bu.name:SetTextColor(colour.r, colour.g, colour.b)

                bu.dkp:SetText(info[2]..' dkp')
                if info[1] == 'Velkan' or info[1] == 'Stumpgrinder' then bu.dkp:SetText(info[2]..' dkp & |cff6c6c6c10 coal|r') end

                if i == 1 then
                    bu:SetPoint('TOP', f)
                else
                    bu:SetPoint('TOPLEFT', _G['moddkp_unit'..(i - 1)], 'BOTTOMLEFT', 0, -4)
                end

                h = bu:GetHeight()
                j = j + 1
            end
        end
        container.title:SetText(GetGuildInfo'player' and GetGuildInfo'player'..'\'s DKP' or 'DKP')
        f:SetHeight(h*j)
        sf.content = f
        sf:SetScrollChild(f)
    end

    local halfDKP = function()
        local r = GetGuildRosterShowOffline()
        SetGuildRosterShowOffline(true)
        local total, online_max, online = GetNumGuildMembers()
        for i = 1, total do
            local note
            local name, rank, _, _, _, _, publicnote, officernote = GetGuildRosterInfo(i)

            if useOfficerNotes then note = officernote else note = publicnote end
            local _, _, v = string.find(note, '<(-?%d*)>')

            local dkp = v

            if v then
                v = math.ceil(tonumber(v)/2)
                note = gsub(note, '<(-?%d*)>', '<'..v..'>')
                print(i..'     '..name..'   '..rank..'   '..dkp..'  >  '..v)
                if useOfficerNotes then
        			GuildRosterSetOfficerNote(i, note)
        		else
        			GuildRosterSetPublicNote(i, note)
        		end
            end
        end
        SetGuildRosterShowOffline(r)
    end

    local toggle = function()
        local f = _G['moddkp_container']
        if f:IsShown() then f:Hide() else f:Show() end
    end

    _G['moddkp_container']:SetScript('OnShow', function()
        local t = GetTime() + 3
        _G['moddkp_body'].raid   = false
        _G['moddkp_body'].class  = false
        _G['moddkp_body'].armour = false
        f:SetScript('OnUpdate', function()
            if GetTime() > t then GuildRoster() f:SetScript('OnUpdate', nil) end
        end)            -- update info from server
        fetch()         -- create table
        list()          -- build
    end)
    _G['Minimap_moddkp']:SetScript('OnClick', toggle)

    _G['moddkp_guild']:SetScript('OnClick', function()
        local t = GetTime() + 3
        _G['moddkp_body'].raid   = false
        _G['moddkp_body'].class  = false
        _G['moddkp_body'].armour = false
        f:SetScript('OnUpdate', function()
            if GetTime() > t then GuildRoster() f:SetScript('OnUpdate', nil) end
        end)
        fetch()
        list()
    end)

    _G['moddkp_raid']:SetScript('OnClick', function()
        local t = GetTime() + 3
        _G['moddkp_body'].raid   = true
        _G['moddkp_body'].class  = false
        _G['moddkp_body'].armour = false
        f:SetScript('OnUpdate', function()
            if GetTime() > t then GuildRoster() f:SetScript('OnUpdate', nil) end
        end)
        fetch()
        list()
    end)

    for i = 1, 8 do
        _G['moddkp_class'..i]:SetScript('OnClick', function()
            local t = GetTime() + 3
            _G['moddkp_body'].raid   = false
            _G['moddkp_body'].class  = true
            _G['moddkp_body'].armour = false
            f:SetScript('OnUpdate', function()
                if GetTime() > t then GuildRoster() f:SetScript('OnUpdate', nil) end
            end)
            fetch()
            list(this)
        end)
    end

    for i = 1, 4 do
        _G['moddkp_armour'..i]:SetScript('OnClick', function()
            local t = GetTime() + 3
            _G['moddkp_body'].raid   = false
            _G['moddkp_body'].class  = false
            _G['moddkp_body'].armour = true
            this.index = i
            f:SetScript('OnUpdate', function()
                if GetTime() > t then GuildRoster() f:SetScript('OnUpdate', nil) end
            end)
            fetch()
            list(this)
        end)
    end

    f:RegisterEvent'PLAYER_ENTERING_WORLD' f:RegisterEvent'CHAT_MSG_RAID_WARNING'
    f:SetScript('OnEvent', function()
        local t = GetTime() + 3
        f:SetScript('OnUpdate', function()
            if GetTime() > t then GuildRoster() f:SetScript('OnUpdate', nil) end
        end)
        fetch()
        f:UnregisterEvent'PLAYER_ENTERING_WORLD'
    end)

    StaticPopupDialogs['MODDKP_HALVE'] = {
    	text = '|cffd58200KITTY NOOOOOOOOOO!|r Are you sure you want to halve everybody in the guild\'s DKP? This is will be a permenant change.',
    	button1 = TEXT(ACCEPT),
    	button2 = TEXT(CANCEL),
    	OnAccept = function()
            halfDKP()
        end,
    	timeout = 0,
    	hideOnEscape = 1
    }

    SLASH_MODDKP1 = '/moddkp'
    SlashCmdList['MODDKP'] = function(msg)
        if msg == 'half' then
            if IsAddOnLoaded'GuildDKP' then
                StaticPopup_Show'MODDKP_HALVE'
            else
                print'moddkp: you do not have GuildDKP installed.'
            end
        else
            toggle()
        end
    end


    --
