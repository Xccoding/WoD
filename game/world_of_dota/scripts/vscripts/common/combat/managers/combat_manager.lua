_G.DOTA_DAMAGE_FLAG_LAST = 2 ^ 15
_G.DOTA_DAMAGE_FLAG_DIRECT = DOTA_DAMAGE_FLAG_LAST * 2--直接伤害
_G.DOTA_DAMAGE_FLAG_INDIRECT = DOTA_DAMAGE_FLAG_DIRECT * 2--持续伤害
_G.DOTA_DAMAGE_FLAG_FIERY_SOUL_COMBO = DOTA_DAMAGE_FLAG_INDIRECT * 2--炽魂连击瞬发光击阵或神灭斩

require('common.combat.managers.heal_manager')

LinkLuaModifier( "modifier_stun_custom", "common/combat/modifiers/modifier_stun_custom.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_combat", "common/combat/modifiers/modifier_combat.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_taunt_custom", "common/combat/modifiers/modifier_taunt_custom.lua", LUA_MODIFIER_MOTION_NONE )

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