-- AI_BEHAVIOR_NONE = 1--能施放时直接施放
-- AI_BEHAVIOR_CAN_KILL = AI_BEHAVIOR_NONE * 2--能完成击杀时优先施放
-- AI_BEHAVIOR_LOW_HEALTH = AI_BEHAVIOR_CAN_KILL * 2--低血量时优先施放

-- local behavior = {
--     AI_BEHAVIOR_NONE = 5,
--     AI_BEHAVIOR_CAN_KILL = 100
-- }

function Spawn()
    if not IsServer() then
		return
	end

    if thisEntity == nil then
        return
    end
    thisEntity.current_order = {order = nil, fEndtime = nil}
    thisEntity:SetContextThink(DoUniqueString("NormalThink"), NormalThink, 1)
end

function NormalThink()
    local unit = thisEntity
    if not IsServer() then
        return
    end
    --存在判断
    if unit == nil then
        --print("unit == nil")
        return
    end
    --存活判断
    if not unit:IsAlive() then
        --print("unit is dead")
        return
    end
    --战斗判断
    if not unit:InCombat() then
        if unit.wander_type ~= nil then
            if unit.wander_type == AI_WANDER_TYPE_ACTIVE then
                if unit.current_order.order == nil then
                    -- print("new wander")
                    NewWander()
                elseif unit.current_order.fEndtime < GameRules:GetGameTime() then
                    -- print("new wander")
                    NewWander()
                end
            end
        end
        return 0.25
    end
    ------------------无旧行为执行中-----------------
    if unit.current_order.order == nil or (unit.current_order.order ~= nil and unit.current_order.fEndtime < GameRules:GetGameTime()) or unit.current_order.order == DOTA_UNIT_ORDER_MOVE_TO_POSITION then
        ------------------需要新行为-------------------
        local desires = {}
        local max_desires = {}
        local max_desire = 0
        local ability_can_cast = 0
        --计算主动技能数量
        for index = 0, unit:GetAbilityCount() - 1 do
            local hAbility = unit:GetAbilityByIndex(index)
            if hAbility ~= nil and (not hAbility:IsPassive()) then
                ability_can_cast = ability_can_cast + 1
            end
        end
        --寻找能放的技能
        if ability_can_cast > 0 then
            for index = 0, unit:GetAbilityCount() - 1 do
                local hAbility = unit:GetAbilityByIndex(index)
                --local behaviors = hAbility:GetAIBehavior()
                -- if desires[index] == nil then
                --     desires[index] = 0
                -- end
                if hAbility ~= nil and (not hAbility:IsPassive()) then
                    if hAbility:IsFullyCastable() then
                        local find_radius = 0
                        local param_target = false
                        local param_position = false
                        local has_target = false
                        local order_type = nil
                        if AbilityBehaviorFilter(hAbility:GetBehaviorInt(), DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) then
                            --单体技能
                            find_radius = hAbility:GetCastRange(unit:GetAbsOrigin(), nil)
                            param_target = true
                        elseif AbilityBehaviorFilter(hAbility:GetBehaviorInt(), DOTA_ABILITY_BEHAVIOR_NO_TARGET) then
                            --无目标范围技能
                            find_radius = hAbility:GetCastRange(unit:GetAbsOrigin(), nil)
                        elseif AbilityBehaviorFilter(hAbility:GetBehaviorInt(), DOTA_ABILITY_BEHAVIOR_POINT_TARGET) then
                            --点目标范围技能
                            find_radius = hAbility:GetCastRange(unit:GetAbsOrigin(), nil) - hAbility:GetAOERadius()
                            param_position = true
                        end
    
                        local tTargets = FindUnitsInRadius(unit:GetTeamNumber(), unit:GetAbsOrigin(), nil, find_radius, hAbility:GetAbilityTargetTeam(), hAbility:GetAbilityTargetType(), hAbility:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
                        if #tTargets > 0 then
                            for _, target in pairs(tTargets) do
                                if target ~= nil and target:IsAlive() then
                                    if param_target and (not param_position) then
                                        param_target = target:entindex()
                                        param_position = nil
                                        order_type = DOTA_UNIT_ORDER_CAST_TARGET
                                    elseif (not param_target) and param_position then
                                        param_target = nil
                                        param_position = target:GetAbsOrigin() + RandomVector(RandomFloat(0, hAbility:GetAOERadius()))
                                        order_type = DOTA_UNIT_ORDER_CAST_POSITION
                                    elseif (not param_target) and (not param_position) then
                                        param_target = nil
                                        param_position = nil
                                        order_type = DOTA_UNIT_ORDER_CAST_NO_TARGET
                                    end
                                    has_target = true
                                    break
                                end
                            end
                            if has_target then
                                table.insert(desires, {desire = 1 / ability_can_cast, ordertable = {
                                    UnitIndex = unit:entindex(),
                                    OrderType = order_type,
                                    TargetIndex = param_target,
                                    AbilityIndex = hAbility:entindex(),
                                    Position = param_position,
                                    Queue = false,
                            }})
                            else
                                --table.insert(desires,{desire = 0,})
                            end
                        else
                            --table.insert(desires,{desire = 0,})
                        end
    
                    end
                end
            end
        end

        --遍历desires，取最大的desire
        if #desires > 0 then
            for index = 1, #desires do
                if desires[index].desire ~= nil then
                    if desires[index].desire > max_desire and desires[index].desire > 0 then
                        max_desires = {}
                        table.insert(max_desires, desires[index])
                    elseif desires[index].desire == max_desire and desires[index].desire > 0 then
                        table.insert(max_desires, desires[index])
                    end
                end
            end
        end
        if #max_desires >= 1 then
            local order_table = max_desires[RandomInt(1, #max_desires)].ordertable
            ExecuteOrderFromTable(
                order_table
            )
            unit.current_order = {order = order_table.OrderType, fEndtime = GameRules:GetGameTime() + 2}
        elseif #max_desires == 0 then
            --找单位A
            if unit:GetAttackCapability() == DOTA_UNIT_CAP_NO_ATTACK then
                --不能攻击
                ExecuteOrderFromTable({
                    UnitIndex = unit:entindex(),
                    OrderType = DOTA_UNIT_ORDER_NONE,
                    Queue = false,
                })
                unit.current_order = {order = DOTA_UNIT_ORDER_ATTACK_TARGET, fEndtime = GameRules:GetGameTime() + 0.5}
            else
                --可以攻击
                if unit:C_GetAggroTarget() ~= nil then
                    ExecuteOrderFromTable({
                        UnitIndex = unit:entindex(),
                        OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
                        TargetIndex = unit:C_GetAggroTarget():entindex(),
                        Queue = false,
                    })
                    unit.current_order = {order = DOTA_UNIT_ORDER_ATTACK_TARGET, fEndtime = GameRules:GetGameTime() + 2}
                end
            end
        end
        return 0.25
    end

    return 0.25
end

function NewWander()
    local unit = thisEntity
    local spawn_entity = unit.spawn_entity
    local pos = spawn_entity:GetAbsOrigin() + RandomVector(RandomFloat(0, 500))
    local time = (pos - unit:GetAbsOrigin()):Length2D() / unit:GetIdealSpeed()
    ExecuteOrderFromTable({
        UnitIndex = unit:entindex(),
        OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
        Position = pos,
        Queue = true,
    })
    unit.current_order = {order = DOTA_UNIT_ORDER_MOVE_TO_POSITION, fEndtime = GameRules:GetGameTime() + time}
end

