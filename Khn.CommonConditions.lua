---@diagnostic disable: lowercase-global
local __util = require 'larian.util'

function GetModifier(value)
    return math.floor((value - 10) / 2)
end

function SourceSpellDC(fallbackDC, entity, ability)
    local entity = entity or context.Source
	local spellDC = fallbackDC or 10 -- Global default so that we don't return 0
    local ability = ability or context.PreferredCastingAbility
	--if entity.IsValid then
    --    try
	--	    spellDC = CalculateSpellDC(ability, entity) --Commented out because base lua linter doesn't like trycatch --Ellie
    --    catch e then
    --    end
	--end
	return spellDC
end

function Self(entity, entity2)
    local entity = entity or context.Source
    local entity2 = entity2 or context.Target
	return ConditionResult(entity.IsValid and entity == entity2, {ConditionError("IsNotSelf")}, {ConditionError("IsSelf")})
end

function IsEquipmentSlot(expectedEquipmentSlot)
	local actualEquipmentSlot = GetEquipmentSlot()
	return ConditionResult(actualEquipmentSlot == expectedEquipmentSlot)
end

function TargetSizeEqualOrSmaller(size)
    return ConditionResult(context.Target.Size ~= Size.None and context.Target.Size.value <= size.value)
end

function SizeEqualOrGreater(size, entity)
    entity = entity or context.Target
    return ConditionResult(entity.Size ~= Size.None and entity.Size.value >= size.value)
end

function SizeGreater(size, entity)
    entity = entity or context.Target
    return ConditionResult(entity.Size ~= Size.None and entity.Size.value > size.value)
end

function ManeuverSaveDC()
    return 8 + context.Source.ProficiencyBonus + math.max(GetModifier(context.Source.Strength), GetModifier(context.Source.Dexterity))
end

function HybridCasterWeaponActionDC()
    return math.max(SourceSpellDC(-10), ManeuverSaveDC()+2) -- Passing a negative fallback to the SourceSpellDC because we don't want the default 10 to max over ManeuverSaveDC
end

function GenericSaveDC(baseDC)
    return baseDC + context.Source.ProficiencyBonus
end

function Unarmed(entity)
	-- Default to Target, like cpp functions
	entity = entity or context.Target
    return ~WieldingWeapon('Ammunition', false, true, entity) & ~WieldingWeapon('Melee', false, true, entity)
end

function LethalHP(entity)
	-- Default to Target, like cpp functions
	entity = entity or context.Target
    return ConditionResult(entity.HP == 1)
end

function FightingStyle_GreatWeapon(entity)
	-- Default to Target, like cpp functions
    entity = entity or context.Target
    local hasTwohandedWeapon = WieldingWeapon('Twohanded', false, false, entity) & WieldingWeapon('Melee', false, false, entity)
    local hasVersatileWeapon = WieldingWeapon('Versatile', false, false, entity) & ~WieldingWeapon('Melee', true, false, entity) & ~WieldingWeapon('Ammunition', true, false, entity) & ~HasShieldEquipped(entity)
    return hasTwohandedWeapon | hasVersatileWeapon
end

function FightingStyle_Dueling(entity)
	-- Default to Target, like cpp functions
    entity = entity or context.Target
    local hasNonVersatileWeapon = WieldingWeapon('Melee', false, false, entity) & ~WieldingWeapon('Versatile', false, false, entity) & ~WieldingWeapon('Twohanded', false, false, entity) & ~WieldingWeapon('Melee', true, false, entity) & ~WieldingWeapon('Ammunition', true, false, entity)
    local hasVersatileWeapon = WieldingWeapon('Versatile', false, false, entity) & WieldingWeapon('Melee', false, false, entity) & HasShieldEquipped(entity)
    return hasNonVersatileWeapon | hasVersatileWeapon
end

function FightingStyle_TwoWeapons(entity)
	-- Default to Target, like cpp functions
    entity = entity or context.Target
    return WieldingWeapon('Melee', false, false, entity) & ~WieldingWeapon('Twohanded', false, false, entity) & WieldingWeapon('Melee', true, false, entity)
end

function DualWielder(entity)
	-- Default to Target, like cpp functions
    entity = entity or context.Target
    return WieldingWeapon('Melee', false, true, entity) & WieldingWeapon('Melee', true, true, entity)
end

function GreatWeaponMaster(entity)
    local entity = entity or context.Source
    local weapon = context.AttackWeapon

    local isHeavy = HasWeaponProperty(WeaponProperties.Heavy, weapon)
    local isTwoHanded = HasWeaponProperty(WeaponProperties.Twohanded, weapon)
    local isMelee = HasWeaponProperty(WeaponProperties.Melee, weapon)
    local isVersatile = HasWeaponProperty(WeaponProperties.Versatile, weapon)
    local isOffhandMelee = WieldingWeapon('Melee', true, false, entity)
    local isOffhandAmmunition = WieldingWeapon('Ammunition', true, false, entity)
    local hasShield = HasShieldEquipped(entity)

    return IsProficientWith(entity, weapon) & ((isTwoHanded & isMelee) | (isVersatile & ~isOffhandMelee & ~isOffhandAmmunition & ~hasShield))
end

function Sharpshooter(entity)
    entity = entity or context.Source
    return WieldingWeapon('Ammunition', false, false, entity) & IsRangedWeaponAttack() & IsProficientWith(entity, GetAttackWeapon(entity))
end
function WieldingFinesseWeapon(entity)
	-- Default to Target, like cpp functions
    entity = entity or context.Target
    return WieldingWeapon('Finesse', false, false, entity) | WieldingWeapon('Finesse', true, false, entity)
end

function WieldingFinesseWeaponInSpecificHand(entity, offHand)
	-- Default to Target, like cpp functions
    local entity = entity or context.Target
    local offHand = offHand or false
    local result = WieldingWeapon('Finesse', offHand, true, entity)
    return ConditionResult(result.Result,{ConditionError("FinesseMainHand_False")},{},result.Chance)
end

function DistanceToTarget()
    return Distance(context.SourcePosition, context.TargetPosition)
end

function DistanceToSource()
    return Distance( context.TargetPosition, context.SourcePosition)
end

function DistanceToTargetGreaterThan(value)
    local errorTrue = {ConditionError("DistanceGreaterThan_True", {ConditionErrorData.MakeFromNumber(value, EErrorDataType.Distance)})}
    local errorFalse = {ConditionError("DistanceGreaterThan_False", {ConditionErrorData.MakeFromNumber(value, EErrorDataType.Distance)})}
    return ConditionResult(DistanceToTarget() > value, errorFalse, errorTrue)
end

function DistanceToTargetGreaterOrEqual(value)
    local errorTrue = {ConditionError("DistanceGreaterOrEqualThan_True", {ConditionErrorData.MakeFromNumber(value, EErrorDataType.Distance)})}
    local errorFalse = {ConditionError("DistanceGreaterOrEqualThan_False", {ConditionErrorData.MakeFromNumber(value, EErrorDataType.Distance)})}
    return ConditionResult(DistanceToTarget() >= value, errorFalse, errorTrue)
end

function DistanceToGreaterThan(pos1, pos2, value)
    return ConditionResult(Distance(pos1, pos2) > value)
end

function DistanceToTargetLessThan(value)
    return ConditionResult(DistanceToTarget() < value)
end

function InMeleeRange(entity)
    entity = entity or context.Target
    if entity == context.Source then
        return ConditionResult(DistanceToSource() <= 1.5)
    end
    return ConditionResult(DistanceToTarget() <= 1.5)
end

function InReachWeaponRange(entity)
    entity = entity or context.Target
    if entity == context.Source then
        return ConditionResult(DistanceToSource() <= 3.0)
    end
    return ConditionResult(DistanceToTarget() <= 3.0)
end

function IsMeleeAttack()
    result = context.HitDescription.AttackType == AttackType.MeleeWeaponAttack or context.HitDescription.AttackType == AttackType.MeleeSpellAttack or context.HitDescription.AttackType == AttackType.MeleeUnarmedAttack or context.HitDescription.AttackType == AttackType.MeleeOffHandWeaponAttack
	return ConditionResult(result)
end

function IsRangedAttack()
    result = context.HitDescription.AttackType == AttackType.RangedWeaponAttack or context.HitDescription.AttackType == AttackType.RangedSpellAttack or context.HitDescription.AttackType == AttackType.RangedUnarmedAttack or context.HitDescription.AttackType == AttackType.RangedOffHandWeaponAttack
	return ConditionResult(result)
end

function IsUnarmedAttack()
    result = context.HitDescription.AttackType == AttackType.MeleeUnarmedAttack
    or context.HitDescription.AttackType == AttackType.RangedUnarmedAttack
	return ConditionResult(result)
end

function IsMeleeUnarmedAttack()
    result = context.HitDescription.AttackType == AttackType.MeleeUnarmedAttack
    return ConditionResult(result)
end

function IsAttack()
    return IsMeleeAttack() | IsRangedAttack()
end

function IsHit()
    return HasDamageEffectFlag(DamageFlags.Hit)
end

function IsMiss()
    return HasDamageEffectFlag(DamageFlags.Miss) | HasDamageEffectFlag(DamageFlags.Dodge)
end

function IsKillingBlow()
    return HasDamageEffectFlag(DamageFlags.KillingBlow)
end

function IsWeaponAttack()
    result = context.HitDescription.AttackType == AttackType.RangedWeaponAttack
    or context.HitDescription.AttackType == AttackType.MeleeWeaponAttack
    or context.HitDescription.AttackType == AttackType.RangedOffHandWeaponAttack
    or context.HitDescription.AttackType == AttackType.MeleeOffHandWeaponAttack
	return ConditionResult(result)
end

function IsWeaponAttackAttackDescription()
    result = context.AttackDescription.AttackType == AttackType.RangedWeaponAttack
    or context.AttackDescription.AttackType == AttackType.MeleeWeaponAttack
    or context.AttackDescription.AttackType == AttackType.RangedOffHandWeaponAttack
    or context.AttackDescription.AttackType == AttackType.MeleeOffHandWeaponAttack
	return ConditionResult(result)
end

function IsMeleeWeaponAttack()
    result = context.HitDescription.AttackType == AttackType.MeleeWeaponAttack
    or context.HitDescription.AttackType == AttackType.MeleeOffHandWeaponAttack
    return ConditionResult(result)
end

function IsRangedWeaponAttack()
    result = context.HitDescription.AttackType == AttackType.RangedWeaponAttack
    or context.HitDescription.AttackType == AttackType.RangedOffHandWeaponAttack
    return ConditionResult(result)
end

function IsMeleeSpellAttack()
    result = context.HitDescription.AttackType == AttackType.MeleeSpellAttack
    return ConditionResult(result)
end

function IsRangedSpellAttack()
    result = context.HitDescription.AttackType == AttackType.RangedSpellAttack
    return ConditionResult(result)
end

function IsSpellAttack()
    return IsMeleeSpellAttack() | IsRangedSpellAttack()
end

function IsMainHandAttack()
    result = context.HitDescription.AttackType == AttackType.RangedWeaponAttack or context.HitDescription.AttackType == AttackType.MeleeWeaponAttack or context.HitDescription.AttackType == AttackType.MeleeUnarmedAttack or context.HitDescription.AttackType == AttackType.RangedUnarmedAttack
	return ConditionResult(result)
end

function IsOffHandAttack()
    result = context.HitDescription.AttackType == AttackType.MeleeOffHandWeaponAttack or context.HitDescription.AttackType == AttackType.RangedOffHandWeaponAttack
	return ConditionResult(result)
end

function HasAdvantage(attackType)
    attackType = attackType or AttackType.None
    result = GetAttackAdvantage(context.Source, context.Target, attackType)
    if result == AdvantageState.Both then
        return ConditionResult(false, {ConditionError("Disadvantage")})
    end
    return ConditionResult(result == AdvantageState.Advantage, {ConditionError("NotAdvantage")}, {ConditionError("Advantage")})
end

function HasDisadvantage(attackType)
    attackType = attackType or AttackType.None
    result = GetAttackAdvantage(context.Source, context.Target, attackType)
    if result == AdvantageState.Both then
        return ConditionResult(false, {ConditionError("Advantage")})
    end
    return ConditionResult(result == AdvantageState.Disadvantage, {ConditionError("NotDisadvantage")}, {ConditionError("Disadvantage")})
end

function TargetHasAdvantage(attackType)
    attackType = attackType or AttackType.None
    result = GetAttackAdvantage(context.Target, context.Source, attackType)
    if result == AdvantageState.Both then
        return ConditionResult(false, {ConditionError("Disadvantage")})
    end
    return ConditionResult(result == AdvantageState.Advantage, {ConditionError("NotAdvantage")}, {ConditionError("Advantage")})
end

function TargetHasDisadvantage(attackType)
    attackType = attackType or AttackType.None
    result = GetAttackAdvantage(context.Target, context.Source, attackType)
    if result == AdvantageState.Both then
        return ConditionResult(false, {ConditionError("Advantage")})
    end
    return ConditionResult(result == AdvantageState.Disadvantage, {ConditionError("NotDisadvantage")}, {ConditionError("Disadvantage")})
end

function HasLosToStatusSource()
    return CanSee(context.Source, context.Target, true)
end

function CanSeeStatusSource()
    return CanSee(context.Source, context.Target, false)
end

function FeatRequirementProficiency(proficiencyName)
	return HasProficiency(proficiencyName, context.Source)
end

function FeatRequirementAbilityGreaterEqual(ability, value)
	if ability == "Strength" then
		return ConditionResult(context.Source.Strength >= value)
	elseif ability == "Dexterity" then
		return ConditionResult(context.Source.Dexterity >= value)
	elseif ability == "Constitution" then
		return ConditionResult(context.Source.Constitution >= value)
	elseif ability == "Intelligence" then
		return ConditionResult(context.Source.Intelligence >= value)
	elseif ability == "Wisdom" then
		return ConditionResult(context.Source.Wisdom >= value)
	elseif ability == "Charisma" then
		return ConditionResult(context.Source.Charisma >= value)
	else
		return ConditionResult(false)
	end
end

function AbilityGreaterThan(ability, value, entity)
    local entity = entity or context.Target
    if ability == "Strength" then
		return ConditionResult(entity.Strength > value)
	elseif ability == "Dexterity" then
		return ConditionResult(entity.Dexterity > value)
	elseif ability == "Constitution" then
		return ConditionResult(entity.Constitution > value)
	elseif ability == "Intelligence" then
		return ConditionResult(entity.Intelligence > value)
	elseif ability == "Wisdom" then
		return ConditionResult(entity.Wisdom > value)
	elseif ability == "Charisma" then
		return ConditionResult(entity.Charisma > value)
	else
		return ConditionResult(false)
	end
end

function FeatRequirementHasAnySpell()
	return ConditionResult(true)
end

function HasHexStatus()
    return HasAnyStatus({'HEX_STRENGTH','HEX_DEXTERITY','HEX_CONSTITUTION','HEX_INTELLIGENCE','HEX_WISDOM','HEX_CHARISMA'}, {}, {},context.Target,context.Source)
end

function IsMetalItem(entity)
    entity = entity or context.Target
    result = Item(entity) & Tagged('METAL', entity)
    return ConditionResult(result.Result, {ConditionError("IsNotMetalItem")}, {ConditionError("IsMetalItem")})
end

function IsMetalCharacter(entity)
    entity = entity or context.Target
    result = Character(entity) & Tagged('METAL', entity)
    return ConditionResult(result.Result)
end

function HasMetalWeaponInAnyHand(entity)
    entity = entity or context.Target
    result = Character(entity) & (HasMetalWeapon(entity, true) | HasMetalWeapon(entity, false))
    return ConditionResult(result.Result, {ConditionError("HasNotMetalWeapon")}, {ConditionError("HasMetalWeapon")})
end

function HasMetalWeapon(entity, mainHand)
    entity = entity or context.Target
    weaponEntity = GetActiveWeapon(entity, mainHand)
    if weaponEntity.IsValid then
        result = Character(entity) & Tagged('METAL', weaponEntity)
        return ConditionResult(result.Result, {ConditionError("HasNotMetalWeapon")}, {ConditionError("HasMetalWeapon")})
    end
    return ConditionResult(false, {ConditionError("HasNotMetalWeapon")}, {ConditionError("HasMetalWeapon")})
end

function HasMetalArmor(entity)
    entity = entity or context.Target
    armorEntity = GetActiveArmor(entity)
    if armorEntity.IsValid then
        result = Character(entity) & Tagged('METAL', armorEntity)
        return ConditionResult(result.Result, {ConditionError("HasNotMetalArmor")}, {ConditionError("HasMetalArmor")})
    end
    return ConditionResult(false, {ConditionError("HasNotMetalArmor")}, {ConditionError("HasMetalArmor")})
end

function IsInorganic(entity)
    entity = entity or context.Target
    return Tagged('METAL', entity) | Tagged('CONSTRUCT', entity) | Tagged('STONE_CREATURE', entity)
end

function AdvantageOnCharmPerson(source, target)
    source = source or context.Source
    target = target or context.Target

    return AdvantageOnCharmed(target) | Enemy(target,source)
end

function AdvantageOnCharmed(target)
    target = target or context.Target

    return Tagged('CHARMED_ADV', target)
end

function AdvantageOnParalyzed(source, target)
    source = source or context.Source
    target = target or context.Target

    return Tagged('PARALYZED_ADV', target)
end

function AdvantageOnFrightened(source, target)
    source = source or context.Source
    target = target or context.Target

    return Tagged('FRIGHTENED_ADV', target)
end

function DisadvantageOnFrightened(source, target)
    source = source or context.Source
    target = target or context.Target

    return Tagged('FRIGHTENED_DISADV', target) | HasPassive('MAG_FrightenedDisadvantage_Passive', source)
end

function AdvantageOnRestrained(source, target)
    source = source or context.Source
    target = target or context.Target

    return Tagged('RESTRAINED_ADV', target)
end

function AdvantageOnPoisoned(source, target)
    source = source or context.Source
    target = target or context.Target

    return Tagged('POISONED_ADV', target)
end

function DisadvantageOnRestrained(source, target)
    source = source or context.Source
    target = target or context.Target

    return Tagged('RESTRAINED_DISADV', target) | HasPassive('FavoredEnemy_BountyHunter',source) | HasPassive('MAG_RestrainingAdvantage_Passive',source)
end

function AdvantageOnSlipping(source, target)
    source = source or context.Source
    target = target or context.Target

    return Tagged('SLIPPING_ADV', target)
end

function AdvantageOnTurned(source, target)
    source = source or context.Source
    target = target or context.Target

    return Tagged('TURNED_ADV')
end

function IsCrowdControlled(entity)
    local entity = entity or context.Target
	return HasAnyStatus({'SG_Fleeing','SG_Incapacitated','SG_Stunned','SG_Unconscious','SG_Restrained'}, {}, {}, entity)
end

function HasEvasion()
    return (HasStatus('SHIELD_MASTER') & HasActionResource('ReactionActionPoint', 1, 0, false)) | HasPassive('Evasion')
end

function HasTemporaryHP(value, entity)
    entity = entity or context.Target
    value = value or 0
    return ConditionResult(entity.TemporaryHP > value)
end

function IsStatusEvent(event)
    return ConditionResult(context.StatusEvent == event)
end

function TotalDamageDoneGreaterThan(value)
    return ConditionResult(context.HitDescription.TotalDamageDone > value)
end

function TotalAttackDamageDoneGreaterThan(value)
    return ConditionResult(context.AttackDescription.TotalDamageDone > value)
end

function HealDoneGreaterThan(value)
    return ConditionResult(context.HitDescription.TotalHealDone > value)
end

function IsAttackType(attackType)
    return ConditionResult(context.HitDescription.AttackType==attackType)
end

function HasMaxHP()
    return ConditionResult(context.AttackDescription.InitialHPPercentage == 100)
end

function HasMaxHPWithoutTemporaryHP(entity)
    entity = entity or context.Target
    return ConditionResult(entity.HPPercentageWithoutTemporaryHP == 100)
end

function HasHPPercentageLessThan(value, entity)
    entity = entity or context.Target
    return ConditionResult(entity.HPPercentage < value)
end

function HasHPPercentageEqualOrLessThan(value, entity)
    entity = entity or context.Target
    return ConditionResult(entity.HPPercentage <= value)
end

function HasHPPercentageWithoutTemporaryHPLessThan(value, entity)
    entity = entity or context.Target
    return ConditionResult(entity.HPPercentageWithoutTemporaryHP < value)
end

function HasHPPercentageWithoutTemporaryHPEqualOrLessThan(value, entity)
    entity = entity or context.Target
    return ConditionResult(entity.HPPercentageWithoutTemporaryHP <= value)
end

function HasHPPercentageMoreThan(value, entity)
    entity = entity or context.Target
    return ConditionResult(entity.HPPercentage > value)
end

function HasHPPercentageEqualOrMoreThan(value, entity)
    entity = entity or context.Target
    return ConditionResult(entity.HPPercentage >= value)
end

function HasHPPercentageWithoutTemporaryHPMoreThan(value, entity)
    entity = entity or context.Target
    return ConditionResult(entity.HPPercentageWithoutTemporaryHP > value)
end

function HasHPPercentageWithoutTemporaryHPEqualOrMoreThan(value, entity)
    entity = entity or context.Target
    return ConditionResult(entity.HPPercentageWithoutTemporaryHP >= value)
end

function HasCantripSpellLevel()
    return IsSpellLevel(0)
end

function HasSpellSpellLevel()
    return ConditionResult(context.HitDescription.SpellLevel >= 0)
end

function IsCantrip()
    return HasCantripSpellLevel() & 
    HasSpellFlag(SpellFlags.Spell) & 
    ~HasUseCosts('SpellSlot') & 
    ~HasUseCosts('KiPoint') & 
    ~HasUseCosts('WarlockSpellSlot') & 
    ~HasUseCosts('ArcaneRecoveryPoint') & 
    ~HasUseCosts('NaturalRecoveryPoint') & 
    ~HasUseCosts('WildShape')
end

function IsSpell()
    return HasSpellSpellLevel() & HasSpellFlag(SpellFlags.Spell)
end

function SpellPowerLevelEqualTo(value)
    return ConditionResult(context.HitDescription.SpellPowerLevel == value)
end

function SpellPowerLevelEqualOrLessThan(value)
    return ConditionResult(context.HitDescription.SpellPowerLevel <= value)
end

function SpellLevelEqualTo(value)
    return ConditionResult(context.HitDescription.SpellLevel == value)
end

function SpellLevelEqualOrLessThan(value)
    return ConditionResult(context.HitDescription.SpellLevel <= value)
end

function IsSpellSchool(spellSchool)
    return ConditionResult(context.HitDescription.SpellSchool == spellSchool)
end

function HasHPLessThan(value, entity)
    entity = entity or context.Target
    if (entity.IsValid) then
        return ConditionResult(entity.HP < value)
    end
    return ConditionResult(false)
end

function HasHPMoreThan(value, entity)
    entity = entity or context.Target
    return ConditionResult(entity.HP > value)
end

function MissingHPGreaterThan(value, entity)
    entity = entity or context.Target
    return ConditionResult((entity.MaxHP - entity.HP) > value)
end

function SpellAutoResolveOnAlly(ability, dc, result)
    result = result or false
    ally = Ally()
    if not ally.Result then
        st = ~SavingThrow(ability, dc)
        return ConditionResult(st.Result,{},{},st.Chance)
    end
    return ConditionResult(result)
end

function SpellAutoResolveOnSelf(ability, dc, result)
    result = result or false
    self = Self()
    if not self.Result then
        st = ~SavingThrow(ability, dc)
        return ConditionResult(st.Result,{},{},st.Chance)
    end
    return ConditionResult(result)
end

function AutoStabilizeCondition()
    return Ally() & HasStatus('DOWNED')
end

function IntelligenceGreaterThan(value, entity)
    entity = entity or context.Target
    local errorTrue = {ConditionError("IntelligenceGreaterThan_True", {ConditionErrorData.MakeFromNumber(value, EErrorDataType.SimpleNumber)})}
    local errorFalse = {ConditionError("IntelligenceGreaterThan_False", {ConditionErrorData.MakeFromNumber(1+value, EErrorDataType.SimpleNumber)})}
    return ConditionResult(entity.Intelligence > value, errorFalse, errorTrue)
end

function HeatMetalInitialCheck(ability, dc)
    weapon = HasMetalWeapon(context.Target, true) | HasMetalWeapon(context.Target, false)
    if weapon.Result then
        st = ~SavingThrow(ability, dc)
        return ConditionResult(st.Result,{},{},st.Chance)
    end
    return ConditionResult(weapon.Result,{},{},1.0)
end

function HeatMetalReapplyCheck(ability, dc)
    mainWeaponEntity = GetActiveWeapon(context.Target, true)
    mainWeapon = false
    if mainWeaponEntity.IsValid then
        mainWeapon = HasStatus('HEAT_METAL', weaponEntity,context.Source).Result
    end
    offWeaponEntity = GetActiveWeapon(context.Target, false)
    offWeapon = false
    if offWeaponEntity.IsValid then
        offWeapon = HasStatus('HEAT_METAL', weaponEntity,context.Source).Result
    end
    weapon = mainWeapon or offWeapon
    if weapon then
        st = ~SavingThrow(ability, dc)
        return ConditionResult(st.Result,{},{},st.Chance)
    end
    return ConditionResult(weapon,{},{},1.0)
end


function IsInInventory(target, source)
    local source = source or context.Source
    local items = GetItemsInInventory(source)
    if items ~= nil then
        for _, entity in ipairs(items.Items) do
            if entity == target then
                return true
            end
        end
    end

    return false
end

function CanThrowWeight()
    return ConditionResult(context.Source.Strength * context.Source.Strength * 0.2 >= (GetLiftingWeight(context.Target, not IsInInventory(context.Target)) / 1000),{ConditionError("CanThrowWeight_False")})
end

function HasLiftingWeightGreaterThan(value, entity, checkStacks)
    entity = entity or context.Target
    return ConditionResult(GetLiftingWeight(entity, checkStacks) > value)
end

function HasWeightGreaterThan(value, entity)
    entity = entity or context.Target
    return ConditionResult(entity.Weight > value)
end

function IsLightThrownObject(entity, checkStacks)
    entity = entity or context.Target
    return ~HasWeaponProperty(WeaponProperties.Thrown,entity) & HasLiftingWeightGreaterThan(500,entity,checkStacks) & ~HasLiftingWeightGreaterThan(10000,entity,checkStacks)
end

function IsMediumThrownObject(entity, checkStacks)
    entity = entity or context.Target
    return ~HasWeaponProperty(WeaponProperties.Thrown,entity) & HasLiftingWeightGreaterThan(10000,entity,checkStacks) & ~HasLiftingWeightGreaterThan(50000,entity,checkStacks)
end

function IsHeavyThrownObject(entity, checkStacks)
    entity = entity or context.Target
    return ~HasWeaponProperty(WeaponProperties.Thrown,entity) & HasLiftingWeightGreaterThan(50000,entity,checkStacks)
end

function CanShoveWeight()
    strengthMultiplier = 12
    if HasStatus('ENLARGE', context.Source).Result then
        strengthMultiplier = 28.2
    end
    if HasStatus('REDUCE', context.Source).Result then
        strengthMultiplier = 5.1
    end
   return ConditionResult(context.Source.Strength * strengthMultiplier >= (GetLiftingWeight(context.Target) / 1000),{ConditionError("CanShoveWeight_False")})
end

function CharismaGreaterThan(value, entity)
    entity = entity or context.Target
    return ConditionResult(entity.Charisma > value)
end

function HasSavingThrowWithAbility(ability)
    return ConditionResult(context.HitDescription.SaveAbility == ability)
end

function HasDeathType(deathType)
	return ConditionResult(context.HitDescription.DeathType == deathType)
end

function HasHelpableCondition()
    result = HasAnyStatus({'SG_Helpable_Condition','DOWNED','HAG_DOWNED','SCL_DOWNED','SG_Prone','SG_Restrained','PRONE','SLEEPING','SLEEP','ENSNARING_STRIKE','WEB','BURNING','HYPNOTIC_PATTERN','COL_NIGHTSONG_SOULCAGE'}, {}, {})
    return ConditionResult(result.Result, {ConditionError("HasNotHelpableCondition")})
end

function IsWaterBasedSurface()
    result = Surface('SurfaceWater') | Surface('SurfaceWaterElectrified') | Surface('SurfaceWaterFrozen') | Surface('SurfaceBlood') | Surface('SurfaceBloodElectrified') | Surface('SurfaceBloodFrozen') | Surface('SurfacePoison') | Surface('SurfaceAlcohol') | Surface('SurfaceBloodSilver') | Surface('SurfaceWaterCloud') | Surface('SurfaceWaterCloudElectrified') | Surface('SurfacePoisonCloud') | Surface('SurfaceFogCloud')
    return ConditionResult(result.Result, {ConditionError("IsNotWaterBasedSurface")})
end

function HasWeaponInMainHand()
    result = WieldingWeapon('Melee') | WieldingWeapon('Ammunition')
    return ConditionResult(result.Result, {ConditionError("HasNotWeaponInMainHand")}, {ConditionError("HasWeaponInMainHand")})
end

function HasVersatileOneHanded()
	local hasVersatileWeapon = WieldingWeapon('Versatile', false, false, context.Source) & (WieldingWeapon('Melee', true, false, context.Source) | WieldingWeapon('Ammunition', true, false, context.Source) | HasShieldEquipped(context.Source))
	return hasVersatileWeapon
end

function HasVersatileTwoHanded()
	local hasVersatileWeapon = WieldingWeapon('Versatile', false, false, context.Source) & ~(WieldingWeapon('Melee', true, false, context.Source) | WieldingWeapon('Ammunition', true, false, context.Source) | HasShieldEquipped(context.Source))
	return hasVersatileWeapon
end

function IsOnFire()
    result = HasStatus('BURNING') | HasStatus('FLAMING_SPHERE_AURA')
    return ConditionResult(result.Result, {ConditionError("IsNotOnFire")})
end

function IsDippableSurface()
    result = Surface('SurfaceFire') | Surface('SurfaceHellfire') | Surface('SurfacePoison') | Surface('SurfaceWater') | Surface('SurfaceSerpentVenom') | Surface('SurfaceWyvernPoison') | Surface('SurfacePurpleWormPoison')
    return ConditionResult(result.Result, {ConditionError("IsNotDippableSurface")})
end

function HasCoatableWeapon() -- Coating weapons with poison or oils
    result = (WieldingWeapon('Dippable',false,false,context.Source) & ~WieldingWeapon('Torch',false,false,context.Source)) | (WieldingWeapon('Dippable',true,false,context.Source) & ~WieldingWeapon('Torch',true,false,context.Source))
    return ConditionResult(result.Result, {ConditionError("HasNotCoatableWeapon")})
end

function HasDippableWeapon()
    result = WieldingWeapon('Dippable',false,false,context.Source) | WieldingWeapon('Dippable',true,false,context.Source)
    return ConditionResult(result.Result, {ConditionError("HasNotDippableWeapon")})
end

function HasHeatMetalActive()
    result = HasStatus('HEAT_METAL',GetActiveWeapon(context.Target, true),context.Source) | HasStatus('HEAT_METAL',GetActiveWeapon(context.Target, false),context.Source) | HasStatus('HEAT_METAL',GetActiveArmor(context.Target),context.Source) | HasStatus('HEAT_METAL',context.Target,context.Source)
    return ConditionResult(result.Result, {ConditionError("HasNotHeatMetalActive")})
end

function HasHeatMetalActiveHigherLevels()
    result3 = HasStatus('HEAT_METAL_3',GetActiveWeapon(context.Target, true),context.Source) | HasStatus('HEAT_METAL_3',GetActiveWeapon(context.Target, false),context.Source) | HasStatus('HEAT_METAL_3',GetActiveArmor(context.Target),context.Source) | HasStatus('HEAT_METAL_3',context.Target,context.Source)
    result4 = HasStatus('HEAT_METAL_4',GetActiveWeapon(context.Target, true),context.Source) | HasStatus('HEAT_METAL_4',GetActiveWeapon(context.Target, false),context.Source) | HasStatus('HEAT_METAL_4',GetActiveArmor(context.Target),context.Source) | HasStatus('HEAT_METAL_4',context.Target,context.Source)
    result = result3 | result4
    return ConditionResult(result.Result, {ConditionError("HasNotHeatMetalActive")})
end

function IsInflicterEqualToSource()
    return ConditionResult(context.HitDescription.InflicterObject == context.Source)
end

function AttackedWithPassiveSourceWeapon()
    result = IsPassiveSource(context.Passive, GetAttackWeapon(), context.Source) | IsPassiveSource(context.Passive, GetAttackWeapon(), GetAttackWeapon()) | IsPassiveOwner(context.Passive, GetAttackWeapon(), context.Source) | IsPassiveOwner(context.Passive, GetAttackWeapon(), GetAttackWeapon())
    return result
end

function IsLivingBeing(entity)
    entity = entity or context.Target
    result = Character(entity) & ~(IsInorganic(entity) | Tagged('UNDEAD', entity) | Tagged('GHOST', entity))
    return result
end

function WyvernPoison(entity)
    hasPoison = HasStatus('POISON_WYVERN', entity)
    if (hasPoison.Result) then
        st = ~SavingThrow(Ability.Constitution,15)
        return ConditionResult(st.Result,{},{},st.Chance)
    end
    return ConditionResult(false)
end

function HasDamageDoneForType(value)
    return ConditionResult(context.HitDescription.GetDamageDoneForType(value) > 0)
end

function HasAttackDamageDoneForType(value)
    return ConditionResult(context.AttackDescription.GetDamageDoneForType(value) > 0)
end

function IsDamageTypeAcid()
    return ConditionResult(context.HitDescription.GetDamageDoneForType(DamageType.Acid) > 0)
end

function IsDamageTypeCold()
    return ConditionResult(context.HitDescription.GetDamageDoneForType(DamageType.Cold) > 0)
end

function IsDamageTypeFire()
    return ConditionResult(context.HitDescription.GetDamageDoneForType(DamageType.Fire) > 0)
end

function IsDamageTypeLightning()
    return ConditionResult(context.HitDescription.GetDamageDoneForType(DamageType.Lightning) > 0)
end

function IsDamageTypeThunder()
    return ConditionResult(context.HitDescription.GetDamageDoneForType(DamageType.Thunder) > 0)
end

function IsDamageTypeRadiant()
    return ConditionResult(context.HitDescription.GetDamageDoneForType(DamageType.Radiant) > 0)
end

function IsDamageTypePoison()
    return ConditionResult(context.HitDescription.GetDamageDoneForType(DamageType.Poison) > 0)
end

function IsDamageTypePsychic()
    return ConditionResult(context.HitDescription.GetDamageDoneForType(DamageType.Psychic) > 0)
end

function IsDamageTypeNecrotic()
    return ConditionResult(context.HitDescription.GetDamageDoneForType(DamageType.Necrotic) > 0)
end

function IsDamageTypeForce()
    return ConditionResult(context.HitDescription.GetDamageDoneForType(DamageType.Force) > 0)
end

function IsDamageTypeSlashing()
    return ConditionResult(context.HitDescription.GetDamageDoneForType(DamageType.Slashing) > 0)
end

function IsDamageTypePiercing()
    return ConditionResult(context.HitDescription.GetDamageDoneForType(DamageType.Piercing) > 0)
end

function IsDamageTypeBludgeoning()
    return ConditionResult(context.HitDescription.GetDamageDoneForType(DamageType.Bludgeoning) > 0)
end

function IsEnergyDamage()
    local result = context.HitDescription.GetDamageDoneForType(DamageType.Acid) > 0
    or context.HitDescription.GetDamageDoneForType(DamageType.Cold) > 0
    or context.HitDescription.GetDamageDoneForType(DamageType.Fire) > 0
    or context.HitDescription.GetDamageDoneForType(DamageType.Lightning) > 0
    or context.HitDescription.GetDamageDoneForType(DamageType.Thunder) > 0
    return ConditionResult(result)
end

function IsPhysicalDamage()
    local result = context.HitDescription.GetDamageDoneForType(DamageType.Slashing) > 0
    or context.HitDescription.GetDamageDoneForType(DamageType.Piercing) > 0
    or context.HitDescription.GetDamageDoneForType(DamageType.Bludgeoning) > 0
    return ConditionResult(result)
end

function FrozenStatusRemovalDamage()
    return ConditionResult(context.HitDescription.GetDamageDoneForType(DamageType.Bludgeoning) > 0
    or context.HitDescription.GetDamageDoneForType(DamageType.Thunder) > 0
    or context.HitDescription.GetDamageDoneForType(DamageType.Force) > 0)
end

function FrostHatRequirement()
    return (HasStringInSpellRoll('SavingThrow') | HasStringInFunctorConditions('SavingThrow')) & HasSpellFlag(SpellFlags.Spell)
end

function NetRemovalCondition(entity)
    entity = entity or context.HitDescription
    result = (entity.GetDamageDoneForType(DamageType.Fire) > 0) or (entity.GetDamageDoneForType(DamageType.Slashing) > 0)
    return ConditionResult(result)
end

function IsAbilityChecked(value)
    result = context.CheckedAbility == value
    return ConditionResult(result)
end

function IsSkillChecked(value)
    result = context.CheckedSkill == value
    return ConditionResult(result)
end

function HasAllyWithinRange(exclusionStatus, distance, tag, hasShield, target, source)
    distance = distance or 1.5
    target = target or context.Target
    source = source or context.Source

    local errorTrue = {ConditionError("HasAllyWithinRange", {ConditionErrorData.MakeFromNumber(distance, EErrorDataType.Distance)})}
    local errorFalse = {ConditionError("HasNotAllyWithinRange", {ConditionErrorData.MakeFromNumber(distance, EErrorDataType.Distance)})}

    local allies = GetAlliesWithinRange(distance, target, source)
    if allies ~= nil then
        for _, entity in ipairs(allies.Allies) do
            -- ensure entity does not have the excluded status
            local noExcludedStatus = ConditionResult(exclusionStatus == nil)
            if exclusionStatus then
                noExcludedStatus = ~HasStatus(exclusionStatus, entity)
            end

            -- filter by tag if provided
            local hasTag = ConditionResult(tag == nil)
            if tag then
                hasTag = Tagged(tag, entity)
            end

            -- filter by having a shield if requested
            local shieldEquipped = ConditionResult(not hasShield)
            if hasShield then
                shieldEquipped = HasShieldEquipped(entity)
            end

            if noExcludedStatus.Result and hasTag.Result and shieldEquipped.Result then
                return ConditionResult(true, errorFalse, errorTrue)
            end
        end
    end

    return ConditionResult(false, errorFalse, errorTrue)
end

function HasEnemyWithinRange(exclusionStatus, distance, tag, NumberOfEnemy, target, source)
    distance = distance or 1.5
    NumberOfEnemy = NumberOfEnemy or 1
    target = target or context.Target
    source = source or context.Source

    local errorTrue = {ConditionError("HasAllyWithinRange", {ConditionErrorData.MakeFromNumber(distance, EErrorDataType.Distance)})}
    local errorFalse = {ConditionError("HasNotAllyWithinRange", {ConditionErrorData.MakeFromNumber(distance, EErrorDataType.Distance)})}

    local enemies = GetEnemiesWithinRange(distance, target, source)
    if enemies ~= nil then
        -- Only do the check when we are surounded by more than or equal the NumberOfEnemy
        if #enemies.Enemies >= NumberOfEnemy then
            for _, entity in ipairs(enemies.Enemies) do
                -- ensure entity does not have the excluded status
                local noExcludedStatus = ConditionResult(exclusionStatus == nil)
                if exclusionStatus then
                    noExcludedStatus = ~HasStatus(exclusionStatus, entity)
                end

                -- filter by tag if provided
                local hasTag = ConditionResult(tag == nil)
                if tag then
                    hasTag = Tagged(tag, entity)
                end

                if noExcludedStatus.Result and hasTag.Result then
                    return ConditionResult(true, errorFalse, errorTrue)
                end
            end
        end
    end
    return ConditionResult(false, errorFalse, errorTrue)
end

function RushWeaponActionTargetCondition()
    return (DistanceToTargetGreaterOrEqual(3.0) and not Ally() and Character()) | Item()
end

function MobileShootingCasterCondition(entity)
    entity = entity or context.Source
    result = HasStatus('DASH', entity, context.Source) | HasStatus('DISENGAGE', entity, context.Source)
    return ConditionResult(result.Result, {ConditionError("HasNotDashedOrDisengaged")})
end

function IsCriticalMiss()
    return ConditionResult(context.HitDescription.IsCriticalMiss)
end

function IsCritical()
    return ConditionResult(context.HitDescription.IsCriticalHit)
end

function IsHitpointsDamaged()
    return ConditionResult(context.HitDescription.IsHitpointsDamaged)
end

function IsFloating(entity)
    entity = entity or context.Target
    result = HasAttribute('Floating', entity) or HasAttribute('FloatingWhileMoving' , entity)
    return ConditionResult(result.Result, {ConditionError("IsNotFloating")}, {ConditionError("IsFloating")})
end

function TargetRadiusGreaterThan(threshold)
	local result = context.SpellModificationDescription.TargetRadius > threshold
	return ConditionResult(result)
end

function AreaRadiusGreaterThan(threshold)
	local result = GetSpellAreaRadius() > threshold
	return ConditionResult(result)
end

function NumberOfTargetsGreaterThan(threshold)
	local result = context.SpellModificationDescription.NumberOfTargets > threshold
	return ConditionResult(result)
end

function CarefulSpellCheck()
    return HasStringInSpellRoll('SavingThrow') & (HasSpellFlag(SpellFlags.Spell) | NonSpellMetamagicAbilities()) & (~HasStringInSpellConditions('Ally()') | HasStringInSpellConditions('SculptSpells'))
end

function DistantSpellCheck()
    return TargetRadiusGreaterThan(1.5) & (HasSpellFlag(SpellFlags.Spell) | NonSpellMetamagicAbilities()) & ~SpellTypeIs(SpellType.Zone) & ~SpellTypeIs(SpellType.Shout)
end

function DistantTouchSpellCheck()
    return TargetRadiusGreaterThan(0) & ~TargetRadiusGreaterThan(1.5) & (HasSpellFlag(SpellFlags.Spell) | NonSpellMetamagicAbilities()) & ~SpellTypeIs(SpellType.Zone) & ~SpellTypeIs(SpellType.Shout)
end

function ExtendedSpellCheck()
	return ~(SpellId('Zone_BurningHands') | SpellId('Zone_BurningHands_2')) & ((HasExtendableStatus() & HasDuration(StatsFunctorType.Status, 0)) | HasDuration(StatsFunctorType.Summon, 0) | HasDuration(StatsFunctorType.SummonInInventory, 0) | HasDuration(StatsFunctorType.CreateSurface, 0)) & (HasSpellFlag(SpellFlags.Spell) | NonSpellMetamagicAbilities())
end

function HeightenedSpellCheck()
    return (HasStringInSpellRoll('SavingThrow') | HasStringInFunctorConditions('SavingThrow') | HasStringInSpellRoll('SpellAutoResolveOnAlly') | HasStringInSpellRoll('HeatMetalInitialCheck') | HasStringInSpellRoll('HeatMetalReapplyCheck')) & (HasSpellFlag(SpellFlags.Spell) | NonSpellMetamagicAbilities())
end

function QuickenedSpellCheck()
    return HasUseCosts('ActionPoint') & (HasSpellFlag(SpellFlags.Spell) | NonSpellMetamagicAbilities())
end

function QuickenedCantripCheck()
    return IsCantrip() & QuickenedSpellCheck()
end

function SubtleSpellCheck()
    return HasSpellFlag(SpellFlags.Verbal) & (HasSpellFlag(SpellFlags.Spell) | NonSpellMetamagicAbilities())
end

function TwinnedProjectileSpellCheck()
    return ~NumberOfTargetsGreaterThan(1) & ~AreaRadiusGreaterThan(0) & (HasSpellFlag(SpellFlags.Spell) | NonSpellMetamagicAbilities()) & SpellTypeIs(SpellType.Projectile) & ~MetamagicExclusionSpells() & ~IsSpellChildOrVariantFromContext('Projectile_WitchBolt')
end

function TwinnedTargetSpellCheck()
    return ~NumberOfTargetsGreaterThan(1) & TargetRadiusGreaterThan(1.5) & ~AreaRadiusGreaterThan(0) & (HasSpellFlag(SpellFlags.Spell) | NonSpellMetamagicAbilities()) & SpellTypeIs(SpellType.Target) & ~HasFunctor(StatsFunctorType.Summon) & ~MetamagicExclusionSpells()
end

function TwinnedTargetTouchSpellCheck()
    return ~NumberOfTargetsGreaterThan(1) & TargetRadiusGreaterThan(0) & ~TargetRadiusGreaterThan(1.5) & ~AreaRadiusGreaterThan(0) & (HasSpellFlag(SpellFlags.Spell) | NonSpellMetamagicAbilities()) & SpellTypeIs(SpellType.Target) & ~HasFunctor(StatsFunctorType.Summon) & ~MetamagicExclusionSpells()
end

function WildMagicSpell()
    return SpellId('Shout_WildMagic_TurnMagic') | SpellId('Shout_WildMagic_Burning') | SpellId('Shout_WildMagic_Teleport') | SpellId('Shout_WildMagic_Enchant') | SpellId('Shout_WildMagic_SorceryPoints') | SpellId('Shout_WildMagic_Fog') | SpellId('Shout_WildMagic_Blur') | SpellId('Shout_WildMagic_Heal') | SpellId('Shout_WildMagic_Mephit') | SpellId('Shout_WildMagic_Swap')
end

function CharacterLevelGreaterThan(value, entity)
    entity = entity or context.Source
    return ConditionResult(entity.Level > value, {ConditionError("IsNotCharacterLevelGreaterThan")})
end

function MetamagicExclusionSpells()
    return SpellId('Target_MistyStep') | SpellId('Target_WildMagic_Teleport') | SpellId('Target_SpeakWithDead') | SpellId('Target_SpeakWithDead_FreeRecast') | SpellId('Target_SpeakWithDead_Amulet_CHA') | SpellId('Target_Light') | SpellId('Projectile_ChainLightning')
end

function SpellActivations()
    return SpellId('Target_WitchBolt_Activate') | SpellId('Target_Hex_Reapply_Strength') | SpellId('Target_Hex_Reapply_Dexterity') | SpellId('Target_Hex_Reapply_Constitution') | SpellId('Target_Hex_Reapply_Intelligence') | SpellId('Target_Hex_Reapply_Wisdom') | SpellId('Target_Hex_Reapply_Charisma')
end

function NonSpellMetamagicAbilities()
	return SpellId ('Target_HorrificVisage')
end

function BardSpellCheck()
    return (~HasStringInSpellRoll('WeaponAttack') & ~HasStringInSpellRoll('UnarmedAttack') & ~SpellId('Projectile_Jump') & ~SpellId('Target_CuttingWords') & ~SpellId('Target_StageFright')) |  HasSpellFlag(SpellFlags.Spell)
end

function CanPickUpWeight()
    return ConditionResult(context.Source.Strength * context.Source.Strength * 0.2 >= (GetLiftingWeight(context.Target, false) / 1000),{ConditionError("CanPickUpWeight_False")})
end

function WeaponAttackRollAbility(ability)
    return IsWeaponAttack() & ConditionResult(context.HitDescription.AttackAbility == ability)
end

function HasHeavyArmor(entity)
    entity = entity or context.Target
    local armor = GetActiveArmor(entity)
    local hasHeavyArmor = armor.ArmorType == ArmorType.RingMail or armor.ArmorType == ArmorType.ChainMail or armor.ArmorType == ArmorType.Splint or armor.ArmorType == ArmorType.Plate
    return ConditionResult(hasHeavyArmor)
end

function YDistanceToTarget()
    local sourcePos = context.SourcePosition
    local targetPos = context.TargetPosition
    return sourcePos.Y - targetPos.Y
end

function YDistanceToTargetGreaterOrEqual(value)
    local errorTrue = {ConditionError("YDistanceGreaterOrEqualThan_True", {ConditionErrorData.MakeFromNumber(value, EErrorDataType.Distance)})}
    local errorFalse = {ConditionError("YDistanceGreaterOrEqualThan_False", {ConditionErrorData.MakeFromNumber(value, EErrorDataType.Distance)})}
    return ConditionResult(YDistanceToTarget() >= value, errorFalse, errorTrue)
end

function IsInElectrifiedSurface(entity)
    local entity = entity or context.Target
    return InSurface('SurfaceBloodElectrified', entity)
    | InSurface('SurfaceDaggersCloudElectrified', entity)
    | InSurface('SurfaceWaterCloudElectrified', entity)
    | InSurface('SurfaceWaterElectrified', entity)
end

function IsReactionAttack()
    result = context.HitDescription.IsReaction == true
    return ConditionResult(result)
end

function AttackingWithMeleeWeapon(entity)
    entity = entity or context.Target
    return HasWeaponProperty(WeaponProperties.Melee, GetAttackWeapon(entity))
end

function AttackingWithRangedWeapon(entity)
    entity = entity or context.Target
    return HasWeaponProperty(WeaponProperties.Ammunition, GetAttackWeapon(entity))
end

function StatusDurationLessThan(entity, stringStatusName, number)
    local entity = entity or context.Target
    local number = number or 0
    return ConditionResult(GetStatusDuration(stringStatusName, entity) < number)
end

function StatusDurationMoreThan(entity, stringStatusName, number)
    local entity = entity or context.Target
    local number = number or 0
    return ConditionResult(GetStatusDuration(stringStatusName, entity) > number)
end

function StatusDurationEqualOrLessThan(entity, stringStatusName, number)
    local entity = entity or context.Target
    local number = number or 0
    return ConditionResult(GetStatusDuration(stringStatusName, entity) <= number)
end

function StatusDurationEqualOrMoreThan(entity, stringStatusName, number)
    local entity = entity or context.Target
    local number = number or 0
    return ConditionResult(GetStatusDuration(stringStatusName, entity) >= number)
end

function StatusGroupDurationLessThan(entity, stringStatusGroupName, number)
    local entity = entity or context.Target
    local number = number or 0
    return ConditionResult(GetStatusDuration(stringStatusGroupName, entity) < number)
end

function StatusGroupDurationMoreThan(entity, stringStatusGroupName, number)
    local entity = entity or context.Target
    local number = number or 0
    return ConditionResult(GetStatusDuration(stringStatusGroupName, entity) > number)
end

function StatusGroupDurationEqualOrLessThan(entity, stringStatusGroupName, number)
    local entity = entity or context.Target
    local number = number or 0
    return ConditionResult(GetStatusDuration(stringStatusGroupName, entity) <= number)
end

function StatusGroupDurationEqualOrMoreThan(entity, stringStatusGroupName, number)
    local entity = entity or context.Target
    local number = number or 0
    return ConditionResult(GetStatusDuration(stringStatusGroupName, entity) >= number)
end

function MaximumHigherStackableStatus(entity, stringStatusGroupName)
    local entity = entity or context.Target
    return ConditionResult(GetStatusDuration(stringStatusGroupName, entity) > 10)
end

function MaximumHighStackableStatus(entity, stringStatusGroupName)
    local entity = entity or context.Target
    return ConditionResult(GetStatusDuration(stringStatusGroupName, entity) > 7)
end

function MaximumLowStackableStatus(entity, stringStatusGroupName)
    local entity = entity or context.Target
    return ConditionResult(GetStatusDuration(stringStatusGroupName, entity) > 5)
end

function HasMaximumLightningCharge(entity)
    local entity = entity or context.Target
    return ConditionResult(GetStatusDuration('MAG_CHARGED_LIGHTNING', entity) > 7)
end

function IsDischargingLightning(entity)
    local entity = entity or context.Target
    return ConditionResult(GetStatusDuration('MAG_CHARGED_LIGHTNING', entity) >= 5)
end

function ChargedLightningAuraRequirement(entity)
    local entity = entity or context.Target
    return ConditionResult(GetStatusDuration('MAG_CHARGED_LIGHTNING', entity) >= 3)
end    

function ForceConduitBlastRequirement(entity)
    local entity = entity or context.Target
    return ConditionResult(GetStatusDuration('MAG_ZOC_FORCE_CONDUIT', entity) >= 5)
end

function FrostCounterRequirement(entity)
    local entity = entity or context.Target
    return ConditionResult(GetStatusDuration('MAG_FROST', entity) >= 7)
end

function RadiatingOrbBlindDuration(entity)
    local entity = entity or context.Target
    return ConditionResult(GetStatusDuration('MAG_RADIANT_RADIATING_ORB', entity) >= 5)
end

function ReverberationBlastRequirement(entity)
    local entity = entity or context.Target
    return ConditionResult(GetStatusDuration('MAG_THUNDER_REVERBERATION', entity) >= 5)
end

function MentalFatigueDischargeRequirement(entity)
    local entity = entity or context.Target
    return ConditionResult(GetStatusDuration('MAG_PSYCHIC_MENTAL_FATIGUE', entity) >= 5)
end

function CanAttack(entity)
    local entity = entity or context.Target
    local result = HasActionResource('ActionPoint', 1, 0, false, false, entity)
    return ConditionResult(result.Result,{ConditionError("IsCanNotAttack")})
end

function HasThrownWeaponInInventory(target)
    ---@diagnostic disable-next-line: undefined-global
    local entity = entity or context.Target
    local items = GetItemsInInventory(target)
    if items ~= nil then
        for _, entity in ipairs(items.Items) do
            if HasWeaponProperty(WeaponProperties.Thrown, entity).Result then
                return ConditionResult(true)
            end
        end
    end

    return ConditionResult(false)
end

function HasInstrumentEquipped(entity)
    local entity = entity or context.Target
    local items = GetItemsInInventory(entity)
    if items ~= nil then
        for _, entity in ipairs(items.Items) do
            if IsOfProficiencyGroup('MusicalInstrument', entity).Result and IsEquipped(entity).Result then
                return ConditionResult(true)
            end
        end
    end

    return ConditionResult(false)
end

function ExtraAttackSpellCheck()
    return HasStringInSpellRoll('WeaponAttack') | HasStringInSpellRoll('UnarmedAttack') | HasStringInSpellRoll('ThrowAttack') | SpellId('Target_CommandersStrike') | SpellId('Target_Bufotoxin_Frog_Summon') | SpellId('Projectile_ArrowOfSmokepowder')
end

function ExtraAttackCheck()
    return ExtraAttackSpellCheck() & HasUseCosts('ActionPoint',false)
end

function HasSpellRangeEqualOrLessThan(value, entity)
    local entity = entity or context.Target
    return ConditionResult(GetSpellTargetRadius(entity) <= value)
end

function CanImprovisedWeaponWeight()
    return ConditionResult(context.Source.Strength * context.Source.Strength * 0.2 >= (GetLiftingWeight(context.Target, not IsInInventory(context.Target)) / 1000),{ConditionError("CanImprovisedWeaponWeight_False")})
end

function RollDieAgainstDC(diceType, DC)
    local roll = Roll(1, diceType, 0)

	if type(roll) == "number" then
        if roll >= DC then
		    return ConditionResult(true)
        end

    	return ConditionResult(false)
	end
    return ConditionResult(true,{},{},1)
end

function IsSmiteStatusCondition()
    return (StatusId('BLINDING_SMITE_BLINDED') | StatusId('BRANDING_SMITE') | StatusId('SEARING_SMITE') | StatusId('FRIGHTENED') | StatusId('BANISHING_SMITE'))
end

function IsSmiteSpells()
    return
    SpellId('Target_Smite_Branding_ZarielTiefling') | SpellId('Projectile_Smite_Branding') | SpellId('Projectile_Smite_Branding_3') | SpellId('Target_Smite_Branding') | SpellId('Target_Smite_Branding_3') | SpellId('Target_Smite_Branding_4') | SpellId('Target_Smite_Branding_5') | SpellId('Target_Smite_Branding_6')
    | SpellId('Target_Smite_Searing_ZarielTiefling') | SpellId('Target_FOR_Smite_Searing_DeathOfATrueSoul') | SpellId('Target_UND_Smite_Searing_DuergarBlacksmithHammer') | SpellId('Target_Smite_Searing') | SpellId('Target_Smite_Searing_2') | SpellId('Target_Smite_Searing_3') | SpellId('Target_Smite_Searing_4') | SpellId('Target_Smite_Searing_5') | SpellId('Target_Smite_Searing_6')
    | SpellId('Projectile_Smite_Banishing') | SpellId('Projectile_Smite_Banishing_4') | SpellId('Projectile_Smite_Banishing_5') | SpellId('Projectile_Smite_Banishing_6') | SpellId('Target_Smite_Banishing')
    | SpellId('Target_Smite_Blinding')
    | SpellId('Target_Smite_Divine') | SpellId('Target_Smite_Divine_2') | SpellId('Target_Smite_Divine_3') | SpellId('Target_Smite_Divine_4') | SpellId('Target_Smite_Divine_5') | SpellId('Target_Smite_Divine_6')
    | SpellId('Target_Smite_Thunderous') | SpellId('Target_Smite_Thunderous_2') | SpellId('Target_Smite_Thunderous_3') | SpellId('Target_Smite_Thunderous_4') | SpellId('Target_Smite_Thunderous_5') | SpellId('Target_Smite_Thunderous_6') | SpellId('Target_MAG_ThunderousSmite')
    | SpellId('Target_Smite_Wrathful') | SpellId('Target_Smite_Wrathful_2') | SpellId('Target_Smite_Wrathful_3') | SpellId('Target_Smite_Wrathful_4') | SpellId('Target_Smite_Wrathful_5') | SpellId('Target_Smite_Wrathful_6') | SpellId('Target_MAG_Smite_Wrathful')
    | SpellId('Target_StaggeringSmite')
end

function IsLastConditionRollSuccess(conditionRollType)
    --try
        conditionRoll = context.HitDescription.GetLastConditionRoll(conditionRollType)
    --catch e then
    --    if ls.CheckType(e, ls.error.UnsupportedAttributeType) or ls.CheckType(e, ls.error.NotFound) then
    --        return ConditionResult(false)
    --    else
    --        return ConditionResult(false) --No TryCatch
    --    end
    --end
    return ConditionResult(conditionRoll.Total >= conditionRoll.Difficulty)
end

function IsSavingThrow()
    return (HasStringInSpellRoll('SavingThrow') | HasStringInFunctorConditions('SavingThrow') | HasDamageEffectFlag(DamageFlags.SavingThrow))
end

function IsLastSavingThrowRollSuccess()
    local isSavingThrow = IsSavingThrow()
    if isSavingThrow then
        return IsLastConditionRollSuccess(ConditionRollType.ConditionSavingThrow)
    end
    return ConditionResult(false)
end

function HasActionType(actionType, entity)
    local entity = entity or context.Target
    local actionTypes = entity.ActionTypes
    if actionTypes ~= nil then
        for _, type in ipairs(actionTypes.ActionTypes) do
            if type == actionType then
                return ConditionResult(true)
            end
        end
    end
    return ConditionResult(false)
end

function IsSneakingOrInvisible()
    return HasStatus('SNEAKING',context.Source) | HasStatus('SG_Invisible',context.Source)
end

function TwinnedCantripProjectileSpellCheck()
    return IsCantrip() & ~AreaRadiusGreaterThan(0) & SpellTypeIs(SpellType.Projectile) & ~MetamagicExclusionSpells()
end

function TwinnedCantripTargetSpellCheck()
    return IsCantrip() & TargetRadiusGreaterThan(1.5) & ~AreaRadiusGreaterThan(0) & SpellTypeIs(SpellType.Target) & ~HasFunctor(StatsFunctorType.Summon) & ~MetamagicExclusionSpells()
end

function TwinnedCantripTargetTouchSpellCheck()
    return IsCantrip() & TargetRadiusGreaterThan(0) & ~TargetRadiusGreaterThan(1.5) & ~AreaRadiusGreaterThan(0) & SpellTypeIs(SpellType.Target) & ~HasFunctor(StatsFunctorType.Summon) & ~MetamagicExclusionSpells()
end

function HeatConvergenceFireSpellCheck()
    return SpellDamageTypeIs(DamageType.Fire)
end

function RangedSpellAttackCheck()
    return TargetRadiusGreaterThan(1.5) & HasStringInSpellRoll('AttackType.RangedSpellAttack') & (HasSpellFlag(SpellFlags.Spell) | NonSpellMetamagicAbilities())
end

function IsSummon(entity)
    entity = entity or context.Source
    result = Tagged('SUMMON',entity)
    return ConditionResult(result.Result,{ConditionError("IsNotSummon")})
end

function IsSummonWithoutMouth(entity)
    entity = entity or context.Source
    result = Tagged('SUMMONWITHOUTMOUTH',entity)
    return ConditionResult(result.Result,{ConditionError("IsNotSummonWithMouth")})
end

function IsTargetableCorpse(entity)
    entity = entity or context.Target
    result = (Dead(entity) & FreshCorpse(entity) & ~Tagged('UNDEAD',entity)) & ~Party() & ~Tagged('PLAYABLE') & ~Tagged('AVATAR') & ~Tagged('CONSTRUCT')  & ~Tagged('ELEMENTAL') & ~Tagged('PLANT') & ~Tagged('OOZE')
    return ConditionResult(result.Result, {ConditionError("IsNotTargetableCorpse")})
end

function MagicalAmbushCheck()
    return ((HasStringInSpellRoll('SavingThrow') | HasStringInFunctorConditions('SavingThrow')) & HasSpellFlag(SpellFlags.Spell))
end

function IsClericCantrip()
	return SpellId ('Target_SacredFlame')
end

function MagicMissileSpellCheck()
    return SpellId('Projectile_MAG_MagicMissile_Shot')
    | SpellId('Projectile_UND_MagicMissile_SocietyOfBrilliance_Amulet') 
    | SpellId('Projectile_MagicMissile')
    | IsSpellChildOrVariantFromContext('Projectile_MagicMissile')
end

function TryCounterspellHigherLevel(level)
    local spellPowerLevel = SpellPowerLevelEqualOrLessThan(level)
    if not spellPowerLevel.Result then
        local counterspellDC = 10 + context.HitDescription.SpellPowerLevel
        local st = AbilityCheck(Ability.Intelligence, counterspellDC, false, false, 0, context.Observer, context.Observer)
        return ConditionResult(st.Result,{},{},st.Chance)
    end
    return ConditionResult(true,{},{},1.0)
end

function MageHandCheck()
    return SpellId('Target_MageHand') | SpellId('Target_MageHand_GithyankiPsionics')
end

function HasInterruptedAttack()
	return ConditionResult(context.InterruptedRoll.RollType == ConditionRollType.ConditionAttack)
end

function HasInterruptedSavingThrow()
	return ConditionResult(context.InterruptedRoll.RollType == ConditionRollType.ConditionSavingThrow)
end

function IsRerollInterruptInteresting(entity)
    local entity = entity or context.Target
    local rollSuccess = false
    if context.InterruptedRoll.RollCritical == RollCritical.None then
        rollSuccess = context.InterruptedRoll.Total >= context.InterruptedRoll.Difficulty
    else
        rollSuccess = context.InterruptedRoll.RollCritical == RollCritical.Success
    end

    if Enemy(context.Observer, entity).Result then
        return ConditionResult(rollSuccess)
    end

    return ConditionResult(not rollSuccess)
end

function IsFlatValueInterruptInteresting(max, entity)
    local entity = entity or context.Target
    local max = max or 0
    if context.InterruptedRoll.RollCritical ~= RollCritical.None then
        return ConditionResult(false, {ConditionError("IsCriticalFailSuccess")})
    end

    local rollSuccess = context.InterruptedRoll.Total >= context.InterruptedRoll.Difficulty

    if Enemy(context.Observer, entity).Result then
        local result = rollSuccess and ((context.InterruptedRoll.Total - context.InterruptedRoll.Difficulty) < max)
        return ConditionResult(result)
    end

    local result = not rollSuccess and ((context.InterruptedRoll.Difficulty - context.InterruptedRoll.Total) <= max)
    return ConditionResult(result)
end

function IsSetInterruptInteresting(value, entity)
    local entity = entity or context.Target
    local value = value or 0
    local rollSuccess = context.InterruptedRoll.Total >= context.InterruptedRoll.Difficulty

    if Enemy(context.Observer, entity).Result then
        local result = rollSuccess and ((value == 1) or (context.InterruptedRoll.Difficulty > value))
        return ConditionResult(result)
    end

    local result = not rollSuccess and ((value == 20) or (context.InterruptedRoll.Difficulty <= value))
    return ConditionResult(result)
end

function IsPortentInterruptInteresting(value, entity)
    local entity = entity or context.Target
    local value = value or 0
    local rollSuccess = context.InterruptedRoll.Total >= context.InterruptedRoll.Difficulty
    local bonus = context.InterruptedRoll.Total - context.InterruptedRoll.NaturalRoll

    if Enemy(context.Observer, entity).Result then
        local result = rollSuccess and ((value == 1) or ((context.InterruptedRoll.NaturalRoll > value) and (context.InterruptedRoll.Difficulty > (value + bonus))))
        return ConditionResult(result)
    end

    local result = not rollSuccess and ((value == 20) or ((context.InterruptedRoll.NaturalRoll < value) and (context.InterruptedRoll.Difficulty <= (value + bonus))))
    return ConditionResult(result)
end

function InterruptHasAdvantage()
    return ConditionResult(context.InterruptedRoll.AdvantageState == AdvantageState.Advantage)
end

function InterruptHasDisadvantage()
    return ConditionResult(context.InterruptedRoll.AdvantageState == AdvantageState.Disadvantage)
end

function IsDivineSmite()
    return SpellId('Target_Smite_Divine') | SpellId('Target_Smite_Divine_2') | SpellId('Target_Smite_Divine_3') | SpellId('Target_Smite_Divine_4') | SpellId('Target_Smite_Divine_5') | SpellId('Target_Smite_Divine_6')
end

function Uninterruptible()
    return SpellId('Target_Counterspell_Success') | SpellId('Target_Counterspell_Failure') | SpellId('Target_TAD_PsionicDominance')
end

function UndeadOrFiend(target)
    target = target or context.Target

    return Tagged('UNDEAD', target) | Tagged('FIEND', target)
end

function IsBreathWeapon()
    return SpellId('Zone_BreathWeapon_Acid')
    | SpellId('Zone_BreathWeapon_Cold')
    | SpellId('Zone_BreathWeapon_Fire_Cone')
    | SpellId('Zone_BreathWeapon_Fire_Line')
    | SpellId('Zone_BreathWeapon_Lightning')
    | SpellId('Zone_BreathWeapon_Poison')
end

function IsAbleToReact(entity)
    local entity = entity or context.Target

    return ~IsCrowdControlled(entity) & ~Dead(entity) & ~(Self(context.Target, entity) & IsKillingBlow())
end

function HasAttackRoll()
    return (HasStringInSpellRoll('Attack'))
end

function IsObserverTargeted()
    return context.Target == context.Observer
end

function IsEntityThrownObject(entity)
    local entity = entity or context.Target
    return context.HitDescription.ThrownObject == entity
end

function IsOffHandSlotEmpty(entity, rangedSlot)
    local entity = entity or context.Source
    local checkRangedSlot = rangedSlot or false
    local result = false

    if checkRangedSlot then
        result = not (GetItemInEquipmentSlot(EquipmentSlot.RangedOffHand, entity).IsValid)
    else
        result = not (GetItemInEquipmentSlot(EquipmentSlot.MeleeOffHand, entity).IsValid)
    end
    return ConditionResult(result)
end

function MagicItemPoweredSpellCheck()
    return IsSpell() & (HasUseCosts('SpellSlot') | HasUseCosts('WarlockSpellSlot'))
end

function HeightenedNecromancySpellCheck()
    return (HasStringInSpellRoll('SavingThrow') | HasStringInFunctorConditions('SavingThrow') | HasStringInSpellRoll('SpellAutoResolveOnAlly')) &
    (HasSpellFlag(SpellFlags.Spell) & IsSpellOfSchool(SpellSchool.Necromancy))
end

function SpellSchoolFilter(spellSchool)
    return IsSpell() & IsSpellOfSchool(spellSchool)
end

function GreaterNecromancySpellFilter()
    return (HasUseCosts('SpellSlot') | HasUseCosts('WarlockSpellSlot')) & SpellSchoolFilter(SpellSchool.Necromancy) & ~HasCantripSpellLevel() & SpellLevelEqualOrLessThan(GetStatusDuration('MAG_GREATER_NECROMANCY_LIFE_ESSENCE'))
end

function ArcaneTricksterQuickenedSpellFilter()
    return IsSpellOfSchool(SpellSchool.Illusion) | IsSpellOfSchool(SpellSchool.Enchantment)
end

function IsResistantToDamageType(damageType, entity)
    local entity = entity or context.Target
    return ConditionResult(entity.HasAllResistances({damageType}, ResistanceType.Resistant))
end

function IsImmuneToDamageType(damageType, entity)
    local entity = entity or context.Target
    return ConditionResult(entity.HasAllResistances({damageType}, ResistanceType.Immune))
end

function IsResistantToFireAndCold(entity)
    local entity = entity or context.Target
    return ConditionResult(entity.HasAllResistances({DamageType.Fire, DamageType.Cold}, ResistanceType.Resistant))
end

function IsResistantToFireOrCold(entity)
    local entity = entity or context.Target
    return ConditionResult(entity.HasAnyResistances({DamageType.Fire, DamageType.Cold}, ResistanceType.Resistant))
end

function AreSpellScrollsClassRestricted()
    local scrollClassRestrictionID = "33bd456b-e716-4ff7-aca7-04b61aaf5d9a"
    return CheckRulesetModifier(scrollClassRestrictionID, true)
end

function CanUseSpellScroll(spell, entity)
    local entity = entity or context.Source
    return ~AreSpellScrollsClassRestricted() | IsSpellAvailableFromClass(spell, entity)
end

function FreeCastSpellLevel3OrLower()
    return ((IsSpellLevel(1) | IsSpellLevel(2) | IsSpellLevel(3)) & HasUseCosts('SpellSlot') & HasSpellFlag(SpellFlags.Spell) & ~MetamagicExclusionSpells())
end

function FreeCastSpellLevel1()
    return (IsSpellLevel(1) & HasUseCosts('SpellSlot') & HasSpellFlag(SpellFlags.Spell) & ~MetamagicExclusionSpells())
end

function HasMarkingStatusCondition()
    return (HasHexStatus() | HasAnyStatus({'HUNTERS_MARK','TRUE_STRIKE','FAERIE_FIRE','GUIDING_BOLT'}, {}, {},context.Target,context.Source))
end

function SpellAttackCheck()
    return (HasStringInSpellRoll('Attack') & HasSpellFlag(SpellFlags.Spell))
end

function ManeuverAndWeaponActionCheck()
    return (HasStringInSpellRoll('ManeuverSaveDC') | HasStringInFunctorConditions('ManeuverSaveDC'))
end

function ThrowOrFirstAttack()
    return ConditionResult(context.HitDescription.FirstAttack) | SpellTypeIs(SpellType.Throw) | SpellTypeIs(SpellType.Rush)
end

function HasLastAttackTriggered()
	return ConditionResult(context.HitDescription.LastAttack)
end

function IsMovementSpell()
    return SpellCategoryIs(SpellCategory.Jump) | SpellTypeIs(SpellType.Rush)
end

function HasAnyExtraAttack(entity)
    local entity = entity or context.Target
	local result = HasAnyStatus({'EXTRA_ATTACK','EXTRA_ATTACK_2','EXTRA_ATTACK_WAR_MAGIC','EXTRA_ATTACK_WAR_PRIEST','MAG_MARTIAL_EXERTION','WILDSTRIKE_EXTRA_ATTACK','WILDSTRIKE_2_EXTRA_ATTACK','STALKERS_FLURRY','EXTRA_ATTACK_THIRSTING_BLADE','COMMANDERS_STRIKE_D10','COMMANDERS_STRIKE_D8'},{},{}, entity, context.Source, false).Result
    return ConditionResult(result)
end

function HasAnyExtraAttackQueued(entity)
    local entity = entity or context.Target
	local result = HasAnyStatus({'EXTRA_ATTACK_Q','EXTRA_ATTACK_2_Q','EXTRA_ATTACK_WAR_MAGIC_Q','EXTRA_ATTACK_WAR_PRIEST_Q','MAG_MARTIAL_EXERTION_Q','WILDSTRIKE_EXTRA_ATTACK_Q','WILDSTRIKE_2_EXTRA_ATTACK_Q','STALKERS_FLURRY_Q','EXTRA_ATTACK_THIRSTING_BLADE_Q','COMMANDERS_STRIKE_D10_Q','COMMANDERS_STRIKE_D8_Q'},{},{}, entity, context.Source, false).Result
    return ConditionResult(result)
end

function HasHigherPriorityExtraAttackQueued(status, entity)
    local entity = entity or context.Target
    local eaQueuedStatuses = {'EXTRA_ATTACK_2_Q'
        , 'EXTRA_ATTACK_Q'
        , 'EXTRA_ATTACK_WAR_MAGIC_Q'
        , 'MAG_MARTIAL_EXERTION_Q'
        , 'WILDSTRIKE_EXTRA_ATTACK_Q'
        , 'STALKERS_FLURRY_Q'
        , 'EXTRA_ATTACK_THIRSTING_BLADE_Q'
        , 'COMMANDERS_STRIKE_Q_D10'
        , 'COMMANDERS_STRIKE_Q_D8'
        , 'WILDSTRIKE_2_EXTRA_ATTACK_Q'
        , 'EXTRA_ATTACK_WAR_PRIEST_Q'
    }
    for i,v in ipairs(eaQueuedStatuses) do
        if (v == status) then
            return ConditionResult(false)
        end
        if HasStatus(v, entity, context.Source, false).Result then
            return ConditionResult(true)
        end
    end
    return ConditionResult(false)
end

function IsHideSpell()
    return SpellId('Shout_Hide') | SpellId('Shout_Hide_BonusAction') | SpellId('Shout_Hide_ShadowArts') | SpellId('Shout_Hide_DreadAmbusher') | SpellId('Shout_MAG_Harpers_RingOfTwilight_Hide')
end

function ShoveCheck()
    local result = Dead() | Item() | Ally()
    if not result.Result then
        ---@diagnostic disable-next-line: param-type-mismatch
        local skillCheck = SkillCheck(Skill.Athletics,math.max(context.Target.GetPassiveSkill(Skill.Athletics),context.Target.GetPassiveSkill(Skill.Acrobatics)), IsSneakingOrInvisible())
        return ConditionResult(skillCheck.Result,{},{},skillCheck.Chance)
    end
    return result
end

function InitialHideCheck()
    local isInCombat = Combat(context.Source)
    local isSneaking = HasStatus('SNEAKING', context.Source)
    if isInCombat.Result and not isSneaking.Result then
        local skillCheck = SkillCheck(Skill.Stealth,10)
        return ConditionResult(skillCheck.Result,{},{},skillCheck.Chance)
    end
    return ConditionResult(true)
end

function ThrowableCheck()
    local result = Dead() | Item() | Ally()
    if not result.Result then
        local skillCheck = SkillCheck(Skill.Athletics,math.max(context.Target.GetPassiveSkill(Skill.Athletics),context.Target.GetPassiveSkill(Skill.Acrobatics)))
        return ConditionResult(skillCheck.Result, {}, {}, skillCheck.Chance)
    end

    return result
end

function TelekinesisCheck()
    local result = Dead() | Item() | Ally()
    if not result.Result then
        local st = ~SavingThrow(Ability.Strength, SourceSpellDC())
        return ConditionResult(st.Result, {}, {}, st.Chance)
    end

    return result
end

function IsThrowAttackRoll()
    local res = IsUnarmedAttack() & SpellTypeIs(SpellType.Throw) & HasWeaponProperty(WeaponProperties.Finesse, context.HitDescription.ThrownObject)
    return ConditionResult(res.Result)
end

-- Used to check for items as interruptors (context.Observer), but is no longer necessary due to code changes.
function AnyEntityIsItem()
    return Item(context.Source) | Item(context.Target) | CrowdCharacter(context.Source) | CrowdCharacter(context.Target) | CrowdCharacter(context.Observer)
end

function IsPerformSpell()
    return SpellId('Shout_Bard_Perform_Drum') | SpellId('Shout_Bard_Perform_Flute') | SpellId('Shout_Bard_Perform_Lute') | SpellId('Shout_Bard_Perform_Lyre') | SpellId('Shout_Bard_Perform_Violin') | SpellId('Shout_Bard_Perform_Whistle')
end

function StatusDoesNotInterruptPerform()
    return StatusId('HEROISM_TEMP_HP') | StatusId('DOS2_JOIN_1') | StatusId('DOS2_JOIN_2') | StatusId('DOS2_JOIN_3')
end

function ClassLevelHigherOrEqualThan(level, class, entity)
    local entity = entity or context.Source
    return ConditionResult(entity.GetClassLevel(class) >= level)
end

function IsRevivifySpell()
    return SpellId('Teleportation_Revivify')
    | SpellId('Teleportation_Revivify_4')
    | SpellId('Teleportation_Revivify_5')
    | SpellId('Teleportation_Revivify_6')
    | SpellId('Teleportation_Revivify_Scroll')
    | SpellId('Teleportation_TrueResurection_Scroll')
    | SpellId('Teleportation_Revivify_Deva')
    | SpellId('Teleportation_MAG_Revivify') 
end

function RollDieEqualsTo(diceType, number)
	if Roll(1, diceType, 0) == number then
		return ConditionResult(true)
	end
	return ConditionResult(false)
end

function PlayableRace(entity)
    return Tagged('HUMAN',entity) | Tagged('ELF',entity) | Tagged('DROWELF',entity) | Tagged('DWARF',entity) | Tagged('HALFELF',entity) | Tagged('GNOME',entity) | Tagged('HALFLING',entity) | Tagged('TIEFLING',entity) | Tagged('GITHYANKI',entity) | Tagged('DRAGONBORN',entity) | Tagged('HALFORC',entity)
end

function IsNotHumanoid(entity)
    entity = entity or context.Source
    result = ~Tagged('HUMANOID',entity)
    return ConditionResult(result.Result,{ConditionError("IsHumanoid")})
end

function IsRedirectedDamage()
    return ConditionResult(context.HitDescription.HitWith == HitWith.Redirection)
end

function IsCharismaModifierPositive()
	return GetModifier(context.Source.Charisma) > 0
end

function CharismaModifierEqualsTo(value, entity)
    entity = entity or context.Source
    return GetModifier(entity.Charisma) == value
end

function CharismaModifierEqualsOrLessThan(value, entity)
    entity = entity or context.Source
    return GetModifier(entity.Charisma) <= value
end

function StatusDoesNotInvokeOnStatusApply()
    return StatusId('PERFORM_POSITIVE_DOS2_1')
    | StatusId('PERFORM_POSITIVE_DOS2_2')
    | StatusId('PERFORM_POSITIVE_DOS2_3')
    | StatusId('DOS2_JOIN_1')
    | StatusId('DOS2_JOIN_2')
    | StatusId('DOS2_JOIN_3')
    | StatusId('PERFORM_POSITIVE')
    | StatusId('PERFORM_POSITIVE_THEPOWER')
    | StatusId('PERFORM_POSITIVE_STARGAZING')
    | StatusId('PERFORM_POSITIVE_BARDDANCE')
    | StatusId('PERFORM_NEGATIVE')
    | StatusId('DASH')
    | StatusId('DASH_STACKED')
    | StatusId('DASH_STACKED_2')
    | StatusId('SNEAKING') 
    | StatusId('SNEAKING_CLEAR')
    | StatusId('SNEAKING_LIGHTLY_OBSCURED')
    | StatusId('SNEAKING_HEAVILY_OBSCURED')
    | StatusId('DISENGAGE') 
    | StatusId('NON_LETHAL')
    | StatusId('MONK_SOUND_SWITCH')
    | StatusId('FLANKED')
    | StatusId('MAG_FROST_DURATION_TECHNICAL')
    | StatusId('MAG_FROST_FROZEN_CHECK_TECHNICAL') 
    | StatusId('MAG_RADIANT_RADIATING_ORB_DURATION_TECHNICAL')
    | StatusId('MAG_ZOC_FORCE_CONDUIT_DURATION_TECHNICAL')
    | StatusId('MAG_FIRE_HEAT_DURATION_TECHNICAL')
    | StatusId('MAG_THUNDER_REVERBERATION_DURATION_TECHNICAL')
    | StatusId('MAG_PSYCHIC_MENTAL_FATIGUE_DURATION_TECHNICAL')
end

function IsExtraAttackStatuses()
    return StatusId('EXTRA_ATTACK')
    | StatusId('EXTRA_ATTACK_2')
    | StatusId('EXTRA_ATTACK_WAR_MAGIC')
    | StatusId('EXTRA_ATTACK_WAR_PRIEST')
    | StatusId('MAG_MARTIAL_EXERTION')
    | StatusId('WILDSTRIKE_EXTRA_ATTACK')
    | StatusId('WILDSTRIKE_2_EXTRA_ATTACK')
    | StatusId('STALKERS_FLURRY')
    | StatusId('EXTRA_ATTACK_THIRSTING_BLADE')
    | StatusId('COMMANDERS_STRIKE_D10')
    | StatusId('COMMANDERS_STRIKE_D8')
end

function HasAnyHaste(entity)
    local entity = entity or context.Source
    return HasAnyStatus({'HASTE','ALCH_ELIXIR_BLOODLUST_TEMPAP','POTION_OF_SPEED','MAG_CELESTIAL_HASTE','HASTE_SURFACE', 'CONS_DRUG_STIMULANT','TAD_MIND_SANCTUARY_HASTE'}, {}, {}, entity)
end

function HasExtraAttackPassive(entity)
    ---@diagnostic disable-next-line: undefined-field
    local entity = entity or context.target --Seems this method is unused. If you rely on this method, "context.target" will likely be incorrect because of lowercase. Avoid not sending an entity parameter.
    return HasPassive('ExtraAttack', entity) | HasPassive('ExtraAttack_2', entity)
end

function IsTrap()
    return HasSpellFlag(SpellFlags.Trap)
end

function CanUseWeaponActions()
    return not Tagged('AI_BLOCKWEAPONACTIONS') | Player()
end

function SlayerFormExtraAttackSpellCheck()
    return SpellId('Target_BloodBath_Slayer')
    | SpellId('Target_BloodBath_Slayer_10')
    | SpellId('Target_Slam_Slayer')
    | SpellId('Target_Slam_Slayer_10')
    | SpellId('Target_Multiattack_Slayer')
    | SpellId('Projectile_SlicingLunge_Slayer')
    | SpellId('Projectile_TerrifyingLunge_Slayer')
    | SpellId('Projectile_TerrifyingLunge_Slayer_10')
    | SpellId('Shout_Sacrifice_Slayer')
    | SpellId('Shout_LOW_LivingSacrifice_Slayer')
    | SpellId('Shout_LOW_Sacrifice_Slayer_Orin')
end

function SpellSavantAmuletAdditionalSpellCheck()
    return SpellId('Shout_CreateSorceryPoints_2')
end

function Level2HitCostSpellCheck()
    return SpellId('Target_Smite_Divine_2')
    | SpellId('Target_Smite_Divine_Unlock_2')
    | SpellId('Target_EnsnaringStrike_2')    
    | SpellId('Target_Smite_Searing_2')
    | SpellId('Target_Smite_Thunderous_2')
    | SpellId('Target_Smite_Wrathful_2')
    | SpellId('Target_Smite_Branding')
end