if  death_knight_frost_nova == nil then
    death_knight_frost_nova = class({})
end
LinkLuaModifier( "modifier_death_knight_frost_nova", "heroes/abilities/death_knight/frost/death_knight_frost_nova.lua", LUA_MODIFIER_MOTION_NONE )
--ability
function death_knight_frost_nova:OnAbilityPhaseStart()
    local hCaster = self:GetCaster()

    return true
end
function death_knight_frost_nova:OnAbilityPhaseInterrupted()
    local hCaster = self:GetCaster()

    return true
end
function death_knight_frost_nova:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end
function death_knight_frost_nova:GetManaCost(iLevel)
    if self:GetCaster():HasModifier("modifier_death_knight_mortal_strike_free_nova") then
        return 0
    else
        return self.BaseClass.GetManaCost(self, iLevel)
    end
end
function death_knight_frost_nova:OnSpellStart()
    local hCaster = self:GetCaster()
    local hTarget = self:GetCursorTarget()
    local radius = self:GetSpecialValueFor("radius")
    local main_target_damage_pct = self:GetSpecialValueFor("main_target_damage_pct")
    local damage_hit = self:GetSpecialValueFor("damage_hit")
    local ap_factor_hit = self:GetSpecialValueFor("ap_factor_hit")
    local duration = self:GetSpecialValueFor("duration")
    local nova_bonus_damage_pct = self:GetSpecialValueFor("nova_bonus_damage_pct")
    local fDamage = damage_hit + ap_factor_hit

    if hCaster:HasModifier("modifier_death_knight_mortal_strike_free_nova") then
        fDamage = fDamage * (100 + nova_bonus_damage_pct) * 0.01
    end

    local particleID = ParticleManager:CreateParticle("particles/units/heroes/death_knight/death_knight_frost_nova.vpcf", PATTACH_ABSORIGIN_FOLLOW, hTarget)
    ParticleManager:ReleaseParticleIndex(particleID)

    EmitSoundOn("Ability.FrostNova", hTarget)
    
    if IsServer() then
        local enemies = FindUnitsInRadius(hCaster:GetTeamNumber(), hTarget:GetAbsOrigin(), nil, radius, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
        for _, enemy in pairs(enemies) do
            if enemy ~= nil and enemy:IsAlive()then
                local this_damage = fDamage
                if enemy == hTarget then
                    this_damage = this_damage * (100 + main_target_damage_pct) * 0.01
                end

                ApplyDamage({
                    victim = enemy,
                    attacker = hCaster,
                    damage = this_damage,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    ability = self,
                    damage_flags = DOTA_DAMAGE_FLAG_DIRECT,
                })

                enemy:AddNewModifier(hCaster, self, "modifier_death_knight_frost_nova", {duration = duration})
            end
        end
    end

    if hCaster:HasModifier("modifier_death_knight_mortal_strike_free_nova") then
       hCaster:RemoveModifierByName("modifier_death_knight_mortal_strike_free_nova")
    end

end
--modifiers
if modifier_death_knight_frost_nova == nil then
	modifier_death_knight_frost_nova = class({})
end
function modifier_death_knight_frost_nova:IsHidden()
    return false
end
function modifier_death_knight_frost_nova:IsDebuff()
    return true
end 
function modifier_death_knight_frost_nova:IsPurgable()
    return false
end
function modifier_death_knight_frost_nova:GetStatusEffectName()
    return "particles/status_fx/status_effect_iceblast.vpcf"
end
function modifier_death_knight_frost_nova:StatusEffectPriority()
    return 1
end
function modifier_death_knight_frost_nova:OnCreated(params)
    self.damage_dot = self:GetAbility():GetSpecialValueFor("damage_dot")
    self.ap_factor_dot = self:GetAbility():GetSpecialValueFor("ap_factor_dot")
    self.dot_interval = self:GetAbility():GetSpecialValueFor("dot_interval")
    self.mana_get_pct = self:GetAbility():GetSpecialValueFor("mana_get_pct")

    if IsServer() then
        self:StartIntervalThink(self.dot_interval)
    end
end
function modifier_death_knight_frost_nova:OnRefresh(params)
    self.damage_dot = self:GetAbility():GetSpecialValueFor("damage_dot")
    self.ap_factor_dot = self:GetAbility():GetSpecialValueFor("ap_factor_dot")
    self.dot_interval = self:GetAbility():GetSpecialValueFor("dot_interval")
    self.mana_get_pct = self:GetAbility():GetSpecialValueFor("mana_get_pct")
end
function modifier_death_knight_frost_nova:OnIntervalThink()
    if IsServer() then
        local hCaster = self:GetCaster()
        local hTarget = self:GetParent()
        local damage_dot = self:GetAbility():GetSpecialValueFor("damage_dot")
        local ap_factor_dot = self:GetAbility():GetSpecialValueFor("ap_factor_dot")
        local fDamage = damage_dot + ap_factor_dot

        ApplyDamage({
            victim = hTarget,
            attacker = hCaster,
            damage = fDamage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self:GetAbility(),
            damage_flags = DOTA_DAMAGE_FLAG_DIRECT,
        })
        hCaster:CGiveMana(hCaster:GetMaxMana() * self.mana_get_pct * 0.01, self:GetAbility(), hCaster)
    end
end