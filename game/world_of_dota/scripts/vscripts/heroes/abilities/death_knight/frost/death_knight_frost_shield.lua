LinkLuaModifier( "modifier_death_knight_frost_shield", "heroes/abilities/death_knight/frost/death_knight_frost_shield.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if death_knight_frost_shield == nil then
	death_knight_frost_shield = class({})
end
function death_knight_frost_shield:GetIntrinsicModifierName()
	return "modifier_death_knight_frost_shield"
end
---------------------------------------------------------------------
--Modifiers
if modifier_death_knight_frost_shield == nil then
	modifier_death_knight_frost_shield = class({})
end
function modifier_death_knight_frost_shield:OnCreated(params)
	if IsServer() then
	end
end
function modifier_death_knight_frost_shield:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_death_knight_frost_shield:OnDestroy()
	if IsServer() then
	end
end
function modifier_death_knight_frost_shield:DeclareFunctions()
	return {
	}
end