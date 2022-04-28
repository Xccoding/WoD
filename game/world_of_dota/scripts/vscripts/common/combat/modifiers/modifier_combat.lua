--标记战斗用modifiers
if modifier_combat == nil then
	modifier_combat = class({})
end
function modifier_combat:IsHidden()
    return true
end
function modifier_combat:IsDebuff()
    return false
end 
function modifier_combat:IsPurgable()
    return false
end
function modifier_combat:OnCreated(params)
    
end