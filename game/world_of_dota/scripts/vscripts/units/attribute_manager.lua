require('modifiers.Cmodifier')
local BaseNPC
if IsServer() then
    BaseNPC = CDOTA_BaseNPC
end
if IsClient() then
    BaseNPC = C_DOTA_BaseNPC
end
function BaseNPC:GetUnitAttribute(attrName, params)
    local buffs = self:FindAllModifiers()
    local attr = 50

    for _, buff in pairs(buffs) do
        if buff:HasDeclare(attrName) then
            attr = attr + buff[attrName](buff, params)
        end
    end
    
    return attr
end