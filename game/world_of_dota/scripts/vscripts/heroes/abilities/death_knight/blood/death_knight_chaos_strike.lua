LinkLuaModifier( "modifier_death_knight_chaos_strike", "heroes/abilities/death_knight/blood/death_knight_chaos_strike.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_death_knight_chaos_strike_shield", "heroes/abilities/death_knight/blood/death_knight_chaos_strike.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if death_knight_chaos_strike == nil then
	death_knight_chaos_strike = class({})
end
function death_knight_chaos_strike:GetIntrinsicModifierName()
    return "modifier_death_knight_chaos_strike"
end
function death_knight_chaos_strike:GetCastRange(vLocation, hTarget)
	return self:GetCaster():Script_GetAttackRange() + self:GetCaster():GetHullRadius()
end
--被动modifier
if modifier_death_knight_chaos_strike == nil then
	modifier_death_knight_chaos_strike = class({})
end
function modifier_death_knight_chaos_strike:IsDebuff()
	return false
end
function modifier_death_knight_chaos_strike:IsHidden()
	return true
end
function modifier_death_knight_chaos_strike:IsPurgable()
	return false
end
function modifier_death_knight_chaos_strike:OnCreated(params)
    self.records = {}
    self.damage_records = {}
    self.damage = self:GetAbility():GetSpecialValueFor("damage")
    self.ap_factor = self:GetAbility():GetSpecialValueFor("ap_factor")
    self.heal_percent = self:GetAbility():GetSpecialValueFor("heal_percent")
    self.min_heal_percent = self:GetAbility():GetSpecialValueFor("min_heal_percent")
    self.damage_record_time = self:GetAbility():GetSpecialValueFor("damage_record_time")
    self.shield_percent = self:GetAbility():GetSpecialValueFor("shield_percent")
    self.shield_duration = self:GetAbility():GetSpecialValueFor("shield_duration")
end
function modifier_death_knight_chaos_strike:OnRefresh(params)
    self.damage = self:GetAbility():GetSpecialValueFor("damage")
    self.ap_factor = self:GetAbility():GetSpecialValueFor("ap_factor")
    self.heal_percent = self:GetAbility():GetSpecialValueFor("heal_percent")
    self.min_heal_percent = self:GetAbility():GetSpecialValueFor("min_heal_percent")
    self.damage_record_time = self:GetAbility():GetSpecialValueFor("damage_record_time")
    self.shield_percent = self:GetAbility():GetSpecialValueFor("shield_percent")
    self.shield_duration = self:GetAbility():GetSpecialValueFor("shield_duration")
end
function modifier_death_knight_chaos_strike:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_START,
		MODIFIER_EVENT_ON_ATTACK_RECORD,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end
function modifier_death_knight_chaos_strike:OnAttackStart(params)
    if params.attacker == self:GetParent() then  
    end
end
function modifier_death_knight_chaos_strike:OnAttack(params)
    if params.attacker == self:GetParent() then
        if self:CheckUseOrb(params.record) then
            local hCaster = self:GetCaster()
            self:GetAbility():UseResources(true, true, true)

            local particleID = ParticleManager:CreateParticle("particles/units/heroes/death_knight/death_knight_chaos_strike.vpcf", PATTACH_ABSORIGIN_FOLLOW, hCaster)
            ParticleManager:ReleaseParticleIndex(particleID)
        end
    end
end
function modifier_death_knight_chaos_strike:OnAttackRecord(params)
    if params.attacker == self:GetParent() then
        local hCaster = self:GetCaster()
        local hAbility = self:GetAbility()
        local hTarget = params.target

        if not IsValidEntity(hTarget)  or hAbility:CastFilterResultTarget(hTarget) ~= UF_SUCCESS then
            return
        end

        if (not hCaster:IsSilenced()) and hAbility:IsCooldownReady() and hAbility:IsOwnersManaEnough() and (hCaster:GetCurrentActiveAbility() == hAbility or hAbility:GetAutoCastState()) then
            table.insert( self.records, {iRecord = params.record, bOrb = true})
        end
    end
end
function modifier_death_knight_chaos_strike:OnAttackLanded(params)
    if params.attacker == self:GetParent() then
        if self:CheckUseOrb(params.record) then
            local hCaster = self:GetCaster()
            local hAbility = self:GetAbility()
            local hTarget = params.target
            local fAmount = 0
            --print(self.damage + self.ap_factor)
            ApplyDamage({
				victim = hTarget,
				attacker = hCaster,
				damage = self.damage + self.ap_factor,
				damage_type = DAMAGE_TYPE_PHYSICAL,
				ability = hAbility,
				damage_flags = DOTA_DAMAGE_FLAG_DIRECT,
			})

            EmitSoundOn("Hero_ChaosKnight.ChaosStrike", hCaster)

            for index, damage_record in pairs(self.damage_records) do
                --print(index, damage_record.fEndtime)
                if damage_record ~= nil then
                    if damage_record.fEndtime > GameRules:GetGameTime() then
                        fAmount = fAmount + damage_record.fAmount
                    else
                        self.damage_records[index] = nil
                    end
                end
            end
            

            fAmount = fAmount * self.heal_percent * 0.01
            fAmount = math.max(fAmount, hCaster:GetMaxHealth() * self.min_heal_percent * 0.01)

            hCaster:CHeal(fAmount, hAbility, false, true, hCaster, false)

            hCaster:AddNewModifier(hCaster, hAbility, "modifier_death_knight_chaos_strike_shield", {shield = fAmount * self.shield_percent * 0.01,duration = self.shield_duration})

        end
    end
end
function modifier_death_knight_chaos_strike:OnAttackRecordDestroy(params)
    if params.attacker == self:GetParent() then
        if params.record then
            self:RemoveRecord(params.record)
        end
    end
end
function modifier_death_knight_chaos_strike:OnTakeDamage(params)
    if self:GetParent() == params.unit then
        local hCaster = params.unit
        local damage_record = {fAmount = params.damage, fEndtime = GameRules:GetGameTime() + self.damage_record_time}

        table.insert(self.damage_records, damage_record)
    end
end
--护盾modifier
if modifier_death_knight_chaos_strike_shield == nil then
	modifier_death_knight_chaos_strike_shield = class({})
end
function modifier_death_knight_chaos_strike_shield:IsDebuff()
	return false
end
function modifier_death_knight_chaos_strike_shield:IsHidden()
	return false
end
function modifier_death_knight_chaos_strike_shield:IsPurgable()
	return false
end
function modifier_death_knight_chaos_strike_shield:GetTexture()
	return "abaddon_aphotic_shield"
end
function modifier_death_knight_chaos_strike_shield:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
	}
end
function modifier_death_knight_chaos_strike_shield:OnCreated(params)
    local hCaster = self:GetParent()
    if IsServer() then
        self.shield = params.shield
        local particleID = ParticleManager:CreateParticle("particles/units/heroes/hero_abaddon/abaddon_aphotic_shield.vpcf", PATTACH_ABSORIGIN_FOLLOW, hCaster)
        ParticleManager:SetParticleControlEnt(particleID, 0, hCaster, PATTACH_POINT_FOLLOW, "attach_hitloc", hCaster:GetAbsOrigin(), false)
        ParticleManager:SetParticleControl(particleID, 1, Vector(75, 75, 75))
        self:AddParticle(particleID, false, false, -1, false, false)

        EmitSoundOn("Hero_Abaddon.AphoticShield.Cast", hCaster)
    end
end
function modifier_death_knight_chaos_strike_shield:OnRefresh(params)
    local hCaster = self:GetParent()
    if IsServer() then
        self.shield = self.shield + params.shield
    end
end
function modifier_death_knight_chaos_strike_shield:GetModifierTotal_ConstantBlock(params)
    if params.damage_type == DAMAGE_TYPE_PHYSICAL then
        if IsServer() then
            if params.damage >= self.shield then
                self:Destroy()
                return self.shield
            else
                self.shield = self.shield - params.damage
                return params.damage
            end
        end
    end
end
