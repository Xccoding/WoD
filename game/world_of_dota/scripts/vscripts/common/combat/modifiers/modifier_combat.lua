--标记战斗用modifiers
if modifier_combat == nil then
	modifier_combat = class({})
end
function modifier_combat:IsHidden()
    return false
end
function modifier_combat:IsDebuff()
    return false
end 
function modifier_combat:IsPurgable()
    return false
end
function modifier_combat:OnCreated(params)
    if IsServer() then
        self.combat_start_time = GameRules:GetGameTime()
        self.damage = 0
        self.heal = 0
    end
end
function modifier_combat:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
end
function modifier_combat:CDeclareFunctions()
    return {
        CMODIFIER_EVENT_ON_HEAL,
    }
end
function modifier_combat:OnTakeDamage( params )
    if not IsServer() then
        return
    end
    if params.attacker == self:GetParent() then
        self.damage = self.damage + params.damage
    end
end
function modifier_combat:OnHeal( params )
    if not IsServer() then
        return
    end
    if params.source == self:GetParent() then
        self.heal = self.heal + params.amount
    end
end