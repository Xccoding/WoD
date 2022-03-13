if  mage_fireblast == nil then
    mage_fireblast = class({})
end
LinkLuaModifier( "modifier_mage_fireblast", "heroes/abilities/mage/fire/mage_fireblast.lua", LUA_MODIFIER_MOTION_NONE )
--ability
function mage_fireblast:OnAbilityPhaseStart()
    local caster = self:GetCaster()

    EmitSoundOn("Hero_OgreMagi.Fireblast.Cast", caster)

    return true
end
function mage_fireblast:OnAbilityPhaseInterrupted()
    local caster = self:GetCaster()

    StopSoundOn("Hero_OgreMagi.Fireblast.Cast", caster)

    return true
end
function mage_fireblast:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local duration = self:GetSpecialValueFor("duration")
    local damage = self:GetSpecialValueFor("damage")
    local sp_factor = self:GetSpecialValueFor("sp_factor")

    local iParticleID = ParticleManager:CreateParticle("particles/units/heroes/hero_ogre_magi/ogre_magi_fireblast.vpcf", PATTACH_ABSORIGIN, target)
    ParticleManager:SetParticleControlEnt(iParticleID, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0, 0, 0), false)
    ParticleManager:SetParticleControlEnt(iParticleID, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0, 0, 0), false)
    ParticleManager:ReleaseParticleIndex(iParticleID)

    EmitSoundOn("Hero_OgreMagi.Fireblast.Target", target)
    
    target:AddNewModifier(caster, self, "modifier_mage_fireblast", {duration = duration})
    ApplyDamage(
        {
            victim = target,
			attacker = caster,
			damage = damage + sp_factor,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self,
			damage_flags = DOTA_DAMAGE_FLAG_DIRECT,
        }
    )


end
--modifiers
if modifier_mage_fireblast == nil then
	modifier_mage_fireblast = class({})
end
function modifier_mage_fireblast:IsHidden()
    return false
end
function modifier_mage_fireblast:IsDebuff()
    return true
end 
function modifier_mage_fireblast:IsPurgable()
    return true
end
function modifier_mage_fireblast:CheckState()
    return {
        [MODIFIER_STATE_STUNNED] = true
    }
end
function modifier_mage_fireblast:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION
    }
end
function modifier_mage_fireblast:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end
function modifier_mage_fireblast:GetEffectName()
    return "particles/generic_gameplay/generic_stunned.vpcf"
end
function modifier_mage_fireblast:GetOverrideAnimation()
    return ACT_DOTA_DISABLED
end
