LinkLuaModifier( "modifier_common", "combat/common/modifiers/modifier_common.lua", LUA_MODIFIER_MOTION_NONE )

function CAddonTemplateGameMode:OnNpcSpawned( params )
    local unit = EntIndexToHScript(params.entindex)

    print('spawn')

    unit:AddNewModifier(unit, nil, "modifier_common", {})


end



