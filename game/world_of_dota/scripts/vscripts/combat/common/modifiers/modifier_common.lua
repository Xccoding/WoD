COMBAT_STATUS_TIME = 6--战斗状态持续时间

require('modifiers.Cmodifier')
require('units.attribute_manager')

--通用modifiers
if modifier_common == nil then
	modifier_common = class({})
end
function modifier_common:IsHidden()
    return true
end
function modifier_common:IsDebuff()
    return false
end 
function modifier_common:IsPurgable()
    return false
end
function modifier_common:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
    }
end
function modifier_common:RemoveOnDeath()
    return false
end
function modifier_common:OnCreated(params)
    self.damage_records = {}
end
function modifier_common:OnTakeDamage(params)
    local hAttacker = params.attacker
    local hVictim = params.unit
    local number_length = math.log(math.floor(params.damage),10) + 1

    hAttacker:AddNewModifier(hAttacker, nil, "modifier_combat", {duration = COMBAT_STATUS_TIME})
    hVictim:AddNewModifier(hVictim, nil, "modifier_combat", {duration = COMBAT_STATUS_TIME})

    for index = 1, #self.damage_records do
        local msg_type = 0
        local paticle_name
        
        if self.damage_records[index].crit == true then
            --暴击特效
            paticle_name = "particles/msg_fx/msg_crit.vpcf"
            msg_type = 4
        else
            paticle_name = "particles/msg_fx/msg_damage.vpcf"
            --普通伤害特效
            msg_type = 9 
        end
        local particleID = ParticleManager:CreateParticleForPlayer(paticle_name, PATTACH_OVERHEAD_FOLLOW, hVictim, hAttacker:GetPlayerOwner())
        ParticleManager:SetParticleControl(particleID, 1, Vector(0, params.damage, msg_type))
        ParticleManager:SetParticleControl(particleID, 2, Vector(1, number_length + 1, 0))
        if params.damage_type == DAMAGE_TYPE_PHYSICAL then
            ParticleManager:SetParticleControl(particleID, 3, Vector(216, 13, 13))
        elseif params.damage_type == DAMAGE_TYPE_MAGICAL then
            ParticleManager:SetParticleControl(particleID, 3, Vector(0, 191, 255))
        end
        ParticleManager:ReleaseParticleIndex(particleID)
        table.remove(self.damage_records, index)
        break
    end

end
function modifier_common:GetModifierTotalDamageOutgoing_Percentage( params )
    if not IsServer() then return end

    local hAttacker = params.attacker
    local hVictim = params.target

    --普通攻击伤害
    if params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK then
        local crit_chance = 0
        if params.damage_type == DAMAGE_TYPE_PHYSICAL then
            crit_chance = hAttacker:GetUnitAttribute(CMODIFIER_PROPERTY_BONUS_PHYSICAL_CRIT, params)
        else
            crit_chance = hAttacker:GetUnitAttribute(CMODIFIER_PROPERTY_BONUS_MAGICAL_CRIT, params)
        end
        if RandomFloat(0, 100) < crit_chance then
            table.insert(self.damage_records, {crit = true, record = params.record})
            CFireModifierEvent(hAttacker, CMODIFIER_EVENT_ON_ATTACK_CRIT, params)
            CFireModifierEvent(hVictim, CMODIFIER_EVENT_ON_ATTACK_CRIT, params)
            return 50
        else
            table.insert(self.damage_records, {crit = false, record = params.record})
            return 0
        end
    end

    --技能攻击伤害
    if params.damage_category == DOTA_DAMAGE_CATEGORY_SPELL then
        local crit_chance = 0
        if params.damage_type == DAMAGE_TYPE_PHYSICAL then
            crit_chance = hAttacker:GetUnitAttribute(CMODIFIER_PROPERTY_BONUS_PHYSICAL_CRIT, params)
        else
            crit_chance = hAttacker:GetUnitAttribute(CMODIFIER_PROPERTY_BONUS_MAGICAL_CRIT, params)
        end
        if RandomFloat(0, 100) < crit_chance then
            table.insert(self.damage_records, {crit = true, record = params.record})
            CFireModifierEvent(hAttacker, CMODIFIER_EVENT_ON_SPELL_CRIT, params)
            CFireModifierEvent(hVictim, CMODIFIER_EVENT_ON_SPELL_CRIT, params)
            return 50
        else
            table.insert(self.damage_records, {crit = false, record = params.record})
            return 0
        end
    end

end
