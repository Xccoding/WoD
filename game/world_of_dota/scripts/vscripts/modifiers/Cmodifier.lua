CMODIFIER_EVENT_ON_ATTACK_CRIT = "C_OnAttackCrit"
CMODIFIER_EVENT_ON_SPELL_CRIT = "C_OnSpellCrit"

CMODIFIER_PROPERTY_BONUS_PHYSICAL_CRIT = "C_GetModifierBonusPhysicalCritChance_Constant"
CMODIFIER_PROPERTY_BONUS_MAGICAL_CRIT = "C_GetModifierBonusMagicalCritChance_Constant"

if IsServer() then
    function CDOTA_Modifier_Lua:HasDeclare(funcName)
        if self.CDeclareFunctions ~= nil and type(self.CDeclareFunctions) == "function" then
            if self.CDeclares[funcName] ~= nil and type(self.CDeclares[funcName]) == "function" then
                return true
            end
        end
        return false
    end
    
    function CFireModifierEvent(hUnit, iEvent, params)
        local buffs = hUnit:FindAllModifiers()
        for _, buff in pairs(buffs) do
            if buff.HasDeclare ~= nil and type(buff.HasDeclare) == "function" then
                if buff:HasDeclare(iEvent) then
                    buff[iEvent](buff, params)
                end
            end
        end
    end
    function CDOTA_Modifier_Lua:CheckUseOrb(iRecord)
        if self.records == nil then
            self.records = {}
        end
        for index = 1, #self.records do
            if self.records[index].iRecord == iRecord and self.records[index].bOrb == true then
                return true
            end
        end
        return false
    end

    function CDOTA_Modifier_Lua:RemoveRecord(iRecord)
        if self.records == nil then
            self.records = {}
        end
        for index = 1, #self.records do
            if self.records[index].iRecord == iRecord then
                table.remove(self.records, index)
                break
            end
        end
    end

end

