require('modifiers.Cmodifier')
local BaseNPC
if IsServer() then
    BaseNPC = CDOTA_BaseNPC
end
if IsClient() then
    BaseNPC = C_DOTA_BaseNPC
end
--根据字段获取属性
function BaseNPC:GetUnitAttribute(attrName, params)
    local buffs = self:FindAllModifiers()
    local attr = 30
    local func_constant = _G["CMODIFIER_PROPERTY_"..attrName.."_CONSTANT"]
    local func_percent = _G["CMODIFIER_PROPERTY_"..attrName.."_PERCENT"]

    --计算固定值部分
    for _, buff in pairs(buffs) do
        if buff[func_constant] ~= nil and type(buff[func_constant]) == "function" then
            attr = attr + buff[func_constant](buff, params)
        end
    end
    --计算百分比部分
    for _, buff in pairs(buffs) do
        if buff[func_percent] ~= nil and type(buff[func_percent]) == "function" then
            attr = attr * ( 100 + buff[func_percent](buff, params)) * 0.01
        end
    end
    
    return attr
end

--获取技能伤害基数
function BaseNPC:GetDamageforAbility( bIsAP )
    local dmg = self:GetAverageTrueAttackDamage(self)
    --TODO判断计算攻击力还是法强
    if bIsAP then
        dmg = self:GetAverageTrueAttackDamage(self)
    else
        dmg = 50
    end

    return dmg
end