AI_WANDER_TYPE_ACTIVE = 1
AI_WANDER_TYPE_PASSIVE = 2

local BaseNPC
if IsServer() then
    BaseNPC = CDOTA_BaseNPC
end
if IsClient() then
    BaseNPC = C_DOTA_BaseNPC
end
function CDOTA_BaseNPC:C_GetAggroTarget()
    --如果被嘲讽了，选他做目标
    if self:HasModifier("modifier_taunt_custom")  then
        return self:FindModifierByName("modifier_taunt_custom"):GetCaster()
    end
    local max_hatred = 0
    local aggro_target = nil
    local units = FindUnitsInRadius(self:GetTeamNumber(), self:GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_ANY_ORDER, false)
    for _, unit in pairs(units) do
        if unit ~= nil and unit:IsAlive() then
            print(unit:GetDPS())
            if unit:GetDPS() > 0 or unit:GetHPS() > 0 then
                
                if unit:GetDPS() * unit:GetAggroFactor() + unit:GetHPS() * unit:GetAggroFactor() > max_hatred then
                    max_hatred = unit:GetDPS() * unit:GetAggroFactor() + unit:GetHPS() * unit:GetAggroFactor()
                    aggro_target = unit
                end
            end
        end
    end

    if aggro_target == nil and self:GetAcquisitionRange() > 0 then
        local units = FindUnitsInRadius(self:GetTeamNumber(), self:GetAbsOrigin(), nil, self:GetAcquisitionRange(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_ANY_ORDER, false)
        for _, unit in pairs(units) do
            if unit ~= nil and unit:IsAlive() then
                aggro_target = unit
            end
        end
    end
    return aggro_target
end