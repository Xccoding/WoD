LinkLuaModifier( "modifier_death_knight_reality_rift", "heroes/abilities/death_knight/frost/death_knight_reality_rift.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if death_knight_reality_rift == nil then
	death_knight_reality_rift = class({})
end
function death_knight_reality_rift:GetIntrinsicModifierName()
	return "modifier_death_knight_reality_rift"
end
---------------------------------------------------------------------
--Modifiers
if modifier_death_knight_reality_rift == nil then
	modifier_death_knight_reality_rift = class({})
end
function modifier_death_knight_reality_rift:OnCreated(params)
	if IsServer() then
	end
end
function modifier_death_knight_reality_rift:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_death_knight_reality_rift:OnDestroy()
	if IsServer() then
	end
end
function modifier_death_knight_reality_rift:DeclareFunctions()
	return {
	}
end