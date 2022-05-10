_G.DOTA_DAMAGE_FLAG_LAST = 2 ^ 15
_G.DOTA_DAMAGE_FLAG_DIRECT = DOTA_DAMAGE_FLAG_LAST * 2--直接伤害
_G.DOTA_DAMAGE_FLAG_INDIRECT = DOTA_DAMAGE_FLAG_DIRECT * 2--持续伤害
_G.DOTA_DAMAGE_FLAG_FIERY_SOUL_COMBO = DOTA_DAMAGE_FLAG_INDIRECT * 2--炽魂连击瞬发光击阵或神灭斩

require('common.combat.managers.heal_manager')

LinkLuaModifier( "modifier_stun_custom", "common/combat/modifiers/modifier_stun_custom.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_combat", "common/combat/modifiers/modifier_combat.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_taunt_custom", "common/combat/modifiers/modifier_taunt_custom.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_disable_autoattack_custom", "common/combat/modifiers/modifier_disable_autoattack_custom.lua", LUA_MODIFIER_MOTION_NONE )

function CDOTA_BaseNPC:InCombat()
    if self:HasModifier("modifier_combat") then
        return true
    end
    return false
end
function CDOTA_BaseNPC:GetDPS()
    if not IsServer() then
        return 0
    end
    if self:HasModifier("modifier_combat") then
        return self:FindModifierByName("modifier_combat").damage / (GameRules:GetGameTime() - self:FindModifierByName("modifier_combat").combat_start_time)
    else
        return 0
    end
end
function CDOTA_BaseNPC:GetHPS()
    if not IsServer() then
        return 0
    end
    if self:HasModifier("modifier_combat") then
        return self:FindModifierByName("modifier_combat").heal / (GameRules:GetGameTime() - self:FindModifierByName("modifier_combat").combat_start_time) or 0
    else
        return 0
    end
end
function CDOTA_BaseNPC:GetAggroFactor()
    return schools[self:GetUnitName()] or 0
end
function AbilityBehaviorFilter(iBehavior_group, iBehavior)
    if bit.band(iBehavior_group, iBehavior) == iBehavior then
        return true
    else
        return false
    end
end