if  mage_hellfire_blast == nil then
    mage_hellfire_blast = class({})
end
LinkLuaModifier( "modifier_mage_hellfire_blast", "heroes/abilities/mage/fire/mage_hellfire_blast.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_mage_hellfire_blast_debuff", "heroes/abilities/mage/fire/mage_hellfire_blast.lua", LUA_MODIFIER_MOTION_NONE )
--ability
function mage_hellfire_blast:GetIntrinsicModifierName()
    return "modifier_mage_hellfire_blast"
end
function mage_hellfire_blast:OnSpellStart()
    local hCaster = self:GetCaster()
    local hTarget = self:GetCursorTarget()

    self:blast(hTarget)
end
function mage_hellfire_blast:blast(hTarget)
    local hCaster = self:GetCaster()
    local blast_Target = hTarget
    local speed = self:GetSpecialValueFor("speed")

    local info = {
        Target = blast_Target,
        Source = hCaster,
        Ability = self,		
        EffectName = "particles/econ/items/wraith_king/wraith_king_ti6_bracer/wraith_king_ti6_hellfireblast.vpcf",
        iMoveSpeed = speed,
        bDodgeable = true,                           
        vSourceLoc = hCaster:GetAbsOrigin(),               
        bIsAttack = false,                                
        ExtraData = {},
        }

    ProjectileManager:CreateTrackingProjectile(info)

    EmitSoundOn("Hero_SkeletonKing.Hellfire_Blast", hCaster)
end
function mage_hellfire_blast:OnProjectileHit_ExtraData(hTarget, vLocation, ExtraData)
    if not IsServer() then
        return
    end
    local hCaster = self:GetCaster()
    local sp_factor = self:GetSpecialValueFor("sp_factor")
    local radius = self:GetSpecialValueFor("radius")
    local duration = self:GetSpecialValueFor("duration")

    local enemies = FindUnitsInRadius(hCaster:GetTeamNumber(), hTarget:GetAbsOrigin(), nil, radius, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
    for _, enemy in pairs(enemies) do
        if enemy ~= nil and enemy:IsAlive() then
            ApplyDamage({
                victim = hTarget,
                attacker = hCaster,
                damage = hCaster:GetDamageforAbility(false) * sp_factor * 0.01,
                damage_type = DAMAGE_TYPE_MAGICAL,
                ability = self,
                damage_flags = DOTA_DAMAGE_FLAG_DIRECT,
            })
        end
    end

    local debuff = hTarget:FindModifierByNameAndCaster("modifier_mage_hellfire_blast_debuff", hCaster)
    if debuff ~= nil then
        local damage_pool = debuff.damage_pool
        for _, enemy in pairs(enemies) do
            if enemy ~= nil and enemy:IsAlive() and enemy ~= hCaster then
                enemy:AddNewModifier(hCaster, self, "modifier_mage_hellfire_blast_debuff", {duration = duration, damage_pool = damage_pool})
            end
        end
    end

    local particleID = ParticleManager:CreateParticle("particles/units/heroes/hero_jakiro/jakiro_liquid_fire_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, hTarget)
    ParticleManager:SetParticleControl(particleID, 1, Vector(radius, 0, 0))
    ParticleManager:ReleaseParticleIndex(particleID)

    EmitSoundOn("Hero_SkeletonKing.Hellfire_BlastImpact", hCaster)
end
--液态火监控modifiers
if modifier_mage_hellfire_blast == nil then
	modifier_mage_hellfire_blast = class({})
end
function modifier_mage_hellfire_blast:IsHidden()
    return false
end
function modifier_mage_hellfire_blast:IsDebuff()
    return false
end 
function modifier_mage_hellfire_blast:IsPurgable()
    return false
end
function modifier_mage_hellfire_blast:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_TOOLTIP,
    }
end
function modifier_mage_hellfire_blast:CDeclareFunctions()
    return {
        CMODIFIER_PROPERTY_BONUS_MAGICAL_CRIT_CHANCE_CONSTANT
    }
end
function modifier_mage_hellfire_blast:C_GetModifierBonusMagicalCritChance_Constant( params )
    if params.inflictor ~= nil and params.inflictor == self:GetAbility() then
        if bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_DIRECT) == DOTA_DAMAGE_FLAG_DIRECT then
            return 100
        end
    end
    return 0
end
function modifier_mage_hellfire_blast:OnCreated(params)
    self.duration = self:GetAbility():GetSpecialValueFor("duration")
    self.int_factor = self:GetAbility():GetSpecialValueFor("int_factor")
    self.combo_multiple = self:GetAbility():GetSpecialValueFor("combo_multiple")
    if IsServer() then
        self.dot_pct = self:GetCaster():GetIntellect() * (self.int_factor * 0.01)
        self:SetHasCustomTransmitterData(true)
        self:StartIntervalThink(0)
    end
end
function modifier_mage_hellfire_blast:OnRefresh(params)
    self.duration = self:GetAbility():GetSpecialValueFor("duration")
    self.int_factor = self:GetAbility():GetSpecialValueFor("int_factor")
end
function modifier_mage_hellfire_blast:OnIntervalThink()
    if IsServer() then
        self.dot_pct = self:GetCaster():GetIntellect() * (self.int_factor * 0.01)
        self:SendBuffRefreshToClients()
    end
end
function modifier_mage_hellfire_blast:AddCustomTransmitterData()
    return {
    dot_pct = self.dot_pct
    }
end
function modifier_mage_hellfire_blast:HandleCustomTransmitterData( data )
    self.dot_pct = data.dot_pct
end
function modifier_mage_hellfire_blast:OnTooltip()
    return self.dot_pct
end
function modifier_mage_hellfire_blast:OnTakeDamage(params)
    if IsServer() then
        if params.attacker == self:GetParent() then
            local hCaster = params.attacker
            local hTarget = params.unit
            local hAbility = self:GetAbility()
            local damage_pool = 0
            if params.damage_category == DOTA_DAMAGE_CATEGORY_SPELL and (bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_DIRECT) == DOTA_DAMAGE_FLAG_DIRECT) then
                damage_pool = params.damage * self.dot_pct * 0.01
                if bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_DIRECT) == DOTA_DAMAGE_FLAG_FIERY_SOUL_COMBO then
                    damage_pool = damage_pool * self.combo_multiple * 0.01
                end
                hTarget:AddNewModifier(hCaster, hAbility, "modifier_mage_hellfire_blast_debuff", {duration = self.duration, damage_pool = damage_pool})
            end
        end
    end
end
--液态火modifiers
if modifier_mage_hellfire_blast_debuff == nil then
	modifier_mage_hellfire_blast_debuff = class({})
end
function modifier_mage_hellfire_blast_debuff:IsHidden()
    return false
end
function modifier_mage_hellfire_blast_debuff:IsDebuff()
    return true
end 
function modifier_mage_hellfire_blast_debuff:IsPurgable()
    return false
end
function modifier_mage_hellfire_blast_debuff:OnCreated(params)
    self.dot_interval= self:GetAbility():GetSpecialValueFor("dot_interval")
    if IsServer() then
        self.damage_pool = params.damage_pool
        self:SetHasCustomTransmitterData(true)
        self:StartIntervalThink(self.dot_interval)
        self:OnIntervalThink()
        EmitSoundOnEntityForPlayer("Hero_Jakiro.LiquidFire", self:GetParent(), self:GetCaster():GetPlayerOwnerID())
    end
    local particleID = ParticleManager:CreateParticle("particles/units/heroes/hero_jakiro/jakiro_liquid_fire_debuff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    self:AddParticle(particleID, false, false, -1, false, false)
end
function modifier_mage_hellfire_blast_debuff:OnRefresh(params)
    self.dot_interval= self:GetAbility():GetSpecialValueFor("dot_interval")
    if IsServer() then
        self.damage_pool = params.damage_pool + self.damage_pool
        self:OnIntervalThink()
    end
end
function modifier_mage_hellfire_blast_debuff:OnIntervalThink()
    if IsServer() then
        local hCaster = self:GetCaster()
        local blast_Target = self:GetParent()
        local fDamage = math.max(self.damage_pool / (self:GetRemainingTime() / self.dot_interval + 1), 1)

        ApplyDamage({
            victim = blast_Target,
            attacker = hCaster,
            damage = fDamage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self:GetAbility(),
            damage_flags = DOTA_DAMAGE_FLAG_INDIRECT,
        })

        self.damage_pool = self.damage_pool - fDamage
    end
end
function modifier_mage_hellfire_blast_debuff:AddCustomTransmitterData()
    return {
        damage_pool = self.damage_pool
    }
end
function modifier_mage_hellfire_blast_debuff:HandleCustomTransmitterData( data )
    self.damage_pool = data.damage_pool
end
function modifier_mage_hellfire_blast_debuff:OnTooltip()
    return math.max(self.damage_pool / (self:GetRemainingTime() / self.dot_interval + 1), 1)
end