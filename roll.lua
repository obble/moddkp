

    local _G = getfenv(0)
    local ____AddMessage = ChatFrame1.AddMessage
    local blacklist = {[ChatFrame2] = true,}

    local AddMessage = function(f, t, r, g, b, id)
        if t == nil then return ____AddMessage(f, t, r, g, b, id) end
        local name = gsub(t, '^(.+) rolls (%d+) %((%d+)%-(%d+)%)$', '%1')
        if name then
            for i = 1, tlength(MODDKP_GUILDMEMBERS) do
                local info = MODDKP_GUILDMEMBERS[i]
                if string.find(name, info[1]) then
                    t = gsub(t, '^(.+) rolls (%d+) %((%d+)%-(%d+)%)$', t..' — '..info[3]..' with '..info[2]..'dkp')
                end
            end
        end
        return ____AddMessage(f, t, r, g, b, id)
    end

    for i = 1, 7 do if not blacklist[chat] then _G['ChatFrame'..i].AddMessage = AddMessage end end

    --
