--modifiers
if modifier_taunt_custom == nil then
	modifier_taunt_custom = class({})
end
function modifier_taunt_custom:IsHidden()
    return true
end
function modifier_taunt_custom:IsDebuff()
    return true
end 
function modifier_taunt_custom:IsPurgable()
    return true
end
function modifier_taunt_custom:CheckState()
    return {
        [MODIFIER_STATE_TAUNTED] = true
    }
end
-- function modifier_taunt_custom:DeclareFunctions()
--     return {
--         MODIFIER_PROPERTY_OVERRIDE_ANIMATION
--     }
-- end
-- function modifier_taunt_custom:GetEffectAttachType()
--     return PATTACH_OVERHEAD_FOLLOW
-- end
-- function modifier_taunt_custom:GetEffectName()
--     return "particles/generic_gameplay/generic_stunned.vpcf"
-- end
-- function modifier_taunt_custom:GetOverrideAnimation()
--     return ACT_DOTA_DISABLED
-- end