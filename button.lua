
    local _G = getfenv(0)

    Minimap.moddkp = CreateFrame('Button', 'Minimap_moddkp', Minimap)
    Minimap.moddkp:SetWidth(20) Minimap.moddkp:SetHeight(20)
    Minimap.moddkp:SetPoint('BOTTOMLEFT', Minimap, -6, 7)

    Minimap.moddkp.icon = Minimap.moddkp:CreateTexture(nil, 'ARTWORK')
    Minimap.moddkp.icon:SetAllPoints()
    SetPortraitToTexture(Minimap.moddkp.icon, [[Interface\ICONS\Inv_ingot_03]])

    Minimap.moddkp.border = Minimap.moddkp:CreateTexture(nil, 'OVERLAY')
    Minimap.moddkp.border:SetPoint('TOPLEFT', Minimap.moddkp, -6, 6)
    Minimap.moddkp.border:SetPoint('BOTTOMRIGHT', Minimap.moddkp, 30, -30)
    Minimap.moddkp.border:SetTexture[[Interface\Minimap\MiniMap-TrackingBorder]]

    --
