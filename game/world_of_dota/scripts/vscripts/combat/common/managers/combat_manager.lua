require('combat.common.managers.heal_manager')

LinkLuaModifier( "modifier_stun_custom", "combat/common/modifiers/modifier_stun_custom.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_combat", "combat/common/modifiers/modifier_combat.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_taunt_custom", "combat/common/modifiers/modifier_taunt_custom.lua", LUA_MODIFIER_MOTION_NONE )

local BaseNPC

if IsServer() then
    BaseNPC = CDOTA_BaseNPC
end

if IsClient() then
    BaseNPC = C_DOTA_BaseNPC
end

function BaseNPC:InCombat()
    if self:HasModifier("modifier_combat") then
        return true
    end
    return false
end