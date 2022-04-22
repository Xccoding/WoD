LinkLuaModifier( "modifier_death_knight_mortal_strike", "heroes/abilities/death_knight/blood/death_knight_mortal_strike.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if death_knight_mortal_strike == nil then
	death_knight_mortal_strike = class({})
end
function death_knight_mortal_strike:GetIntrinsicModifierName()
	return "modifier_death_knight_mortal_strike"
end
---------------------------------------------------------------------
--Modifiers
if modifier_death_knight_mortal_strike == nil then
	modifier_death_knight_mortal_strike = class({})
end
function modifier_death_knight_mortal_strike:OnCreated(params)
	if IsServer() then
	end
end
function modifier_death_knight_mortal_strike:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_death_knight_mortal_strike:OnDestroy()
	if IsServer() then
	end
end
function modifier_death_knight_mortal_strike:DeclareFunctions()
	return {
	}
end