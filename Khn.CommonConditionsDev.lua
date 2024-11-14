function EmpoweredSpellCheck()
    return HasFunctor(StatsFunctorType.DealDamage) & HasSpellFlag(SpellFlags.Spell)
end

function HasHeatMetalActiveAnyLevel()
	local resultWeaponMain = HasAnyStatus({'HEAT_METAL','HEAT_METAL_3','HEAT_METAL_4','HEAT_METAL_5','HEAT_METAL_5','HEAT_METAL_6'}, {}, {},GetActiveWeapon(context.Target, true),context.Source)
	local resultWeaponOff = HasAnyStatus({'HEAT_METAL','HEAT_METAL_3','HEAT_METAL_4','HEAT_METAL_5','HEAT_METAL_5','HEAT_METAL_6'}, {}, {},GetActiveWeapon(context.Target, false),context.Source)
	local resultArmor = HasAnyStatus({'HEAT_METAL','HEAT_METAL_3','HEAT_METAL_4','HEAT_METAL_5','HEAT_METAL_5','HEAT_METAL_6'}, {}, {},GetActiveArmor(context.Target),context.Source)
	local resultCharacter = HasAnyStatus({'HEAT_METAL','HEAT_METAL_3','HEAT_METAL_4','HEAT_METAL_5','HEAT_METAL_5','HEAT_METAL_6'}, {}, {},context.Target,context.Source)
	local result = resultWeaponMain | resultWeaponOff | resultArmor | resultCharacter
    return ConditionResult(result.Result, {ConditionError("HasNotHeatMetalActive")})
end

function HasAuraOfVitality()
    local result = HasStatus('AURA_OF_VITALITY',context.Target,context.Source) | HasStatus('AURA_OF_VITALITY_AURA',context.Target,context.Source)
    return ConditionResult(result.Result, {ConditionError("HasNotAuraOfVitality")})
end

function SpellLevelEquals(value)
    local result = context.HitDescription.SpellPowerLevel == value
    return ConditionResult(result)
end

function HasWeapon(entity, mainHand)
    local entity = entity or context.Target
    local weaponEntity = GetActiveWeapon(entity, mainHand)
    if weaponEntity.IsValid then
        ---@diagnostic disable-next-line: lowercase-global
        result = Character(entity)
        return ConditionResult(result.Result, {ConditionError("HasNotWeapon")}, {ConditionError("HasWeapon")})
    end
    return ConditionResult(false, {ConditionError("HasNotWeapon")}, {ConditionError("HasWeapon")})
end

function GithyankiPheromonesCheck(entity)
    local entity = entity or context.Target
    local res = ~((Tagged('GITHYANKI', entity) & ~Player()) | Tagged('REALLY_GITHYANKI', entity))
    if res.Result then
        ---@diagnostic disable-next-line: lowercase-global
        st = ~SavingThrow(Ability.Constitution, 15)
        return ConditionResult(st.Result,{},{},st.Chance)
    end
    return ConditionResult(true)
end

function IsFallDamage()
    return ConditionResult(context.HitDescription.HitWith == HitWith.FallDamage)
end

function IsMonkWeaponAttack()
    local attackWeapon = GetAttackWeapon(context.Source)
    if attackWeapon.IsValid then
        return ~(HasWeaponProperty(WeaponProperties.Heavy, attackWeapon) | HasWeaponProperty(WeaponProperties.Twohanded, attackWeapon)) & IsProficientWith(context.Source, attackWeapon)
    else
        return IsUnarmedAttack()
    end
end

function HasNotPrecisionAttack()
    local result = ~HasStatus('PRECISION_ATTACK')
    return ConditionResult(result.Result, {ConditionError("HasPrecisionAttack")})
end

function FreecastCheck()
    return HasUseCosts('SpellSlot') | HasUseCosts('Rage') | HasUseCosts('BardicInspiration') | HasUseCosts('ChannelDivinity') | HasUseCosts('SuperiorityDie') | HasUseCosts('KiPoint') | HasUseCosts('SorceryPoint') | HasUseCosts('WarlockSpellSlot') | HasUseCosts('ArcaneRecoveryPoint') | HasUseCosts('NaturalRecoveryPoint') | HasUseCosts('WildShape') | HasUseCosts('ChannelOath')| HasUseCosts('LayOnHandsCharge')
end

function IsTadpolePower()
    return SpellId('Shout_TAD_DisplacerBeast')
      | SpellId('Target_TAD_BlackHole')
      | SpellId('Target_TAD_BlackHole_Recast')
      | SpellId('Target_TAD_Charm')
      | SpellId('Target_TAD_ConcentratedBlast')
      | SpellId('Target_TAD_ShieldOfThralls')
      | SpellId('Target_TAD_TransfuseHealth')
      | SpellId('Zone_TAD_MindBlast')
      | SpellId('Shout_EndlessRage')
      | SpellId('Target_StageFright')
      | SpellId('Target_SurvivalInstinct')
      | SpellId('Shout_AberrantShape')
      | SpellId('Target_PsionicPull')
      | SpellId('Rush_ForceTunnel')
      | SpellId('Shout_Inkblot')
      | SpellId('Target_HorrificVisage')
      | SpellId('Target_SupernaturalAttraction')
      | SpellId('Shout_ReflectiveShell')
      | SpellId('Shout_Repulsor')
      | SpellId('Target_TAD_PerilousStakes')
      | SpellId('Target_TAD_Imperil')
      | SpellId('Target_TAD_Imperil_Recast')
      | SpellId('Target_TAD_MindSanctuary')
      | SpellId('Target_TAD_AbsorbIntellect')
      | SpellId('Shout_TAD_PsionicOverload')
end

function StatusGroupDurationEqual(entity, stringStatusGroupName, number)
    local entity = entity or context.Target
    local number = number or 0
    return ConditionResult(math.floor(GetStatusDuration(stringStatusGroupName, entity)) == number)
end

function UndeadThrallAnimateDeadSpellVariation()
    return SpellId('Target_AnimateDead_Skeleton') | SpellId('Target_AnimateDead_Zombie') | SpellId('Target_AnimateDead_Ghoul') | SpellId('Target_AnimateDead_FlyingGhoul') | SpellId('Target_AnimateDead_Skeleton_4') | SpellId('Target_AnimateDead_Zombie_4') | SpellId('Target_AnimateDead_Ghoul_6') | SpellId('Target_AnimateDead_FlyingGhoul_6') 
end

function MindSanctuaryCheck()
    return HasUseCosts('BonusActionPoint',true) | HasUseCosts('ActionPoint',true) | (~HasActionResource('ActionPoint', 1, 0, false, true, context.Source) & ~HasActionResource('BonusActionPoint', 1, 0, false, true, context.Source))
end

function IsKarlach(entity)
    local entity = entity or context.Source
    local result = Tagged('REALLY_KARLACH', entity)
    return ConditionResult(result.Result, {ConditionError("IsNotKarlach")})
end

function ShadowCurseUndead()
    return ~HasSpellFlag(SpellFlags.Attack) & ~HasSpellFlag(SpellFlags.IsSwarmAttack) & ~SpellId('Projectile_Jump') & ~SpellId('Shout_Dash') & ~SpellId('Shout_Dash_NPC') & ~SpellId('Shout_Dash_CunningAction') & ~SpellId('Shout_Dash_HookHorror') & ~SpellId('Shout_Dash_StepOfTheWind') & ~SpellId('Shout_Dash_BonusAction_NPC')
end

function JumpSpell()
    return SpellId('Projectile_Jump')
end

function HasActiveAstralKnowledge(entity)
    local entity = entity or context.Source
    local result = HasStatus('ASTRAL_KNOWLEDGE_STRENGTH', entity) | HasStatus('ASTRAL_KNOWLEDGE_DEXTERITY', entity) | HasStatus('ASTRAL_KNOWLEDGE_INTELLIGENCE', entity) | HasStatus('ASTRAL_KNOWLEDGE_WISDOM', entity) | HasStatus('ASTRAL_KNOWLEDGE_CHARISMA', entity)
    return ConditionResult(result.Result, {ConditionError("UnavailableUntilRest")}, {ConditionError("UnavailableUntilRest")})
end

function AttackRollAbility(ability)
    return ConditionResult(context.HitDescription.AttackAbility == ability)
end

function HasLessHPThanTadpolePowers(target, source)
    local target = target or context.Target
    local source = source or context.Source
    local value = GetTadpolePowersNumber(source)
    if value < 2 then
        value = 2
    end

    return ConditionResult(target.HP < value)
end

function SavingThrowWithHigherAbility(ability1, ability2, dc, entity)
    ---@diagnostic disable-next-line: undefined-global
    local target = target or context.Target

    if target.GetSavingThrow(ability1) >= target.GetSavingThrow(ability2) then
        return SavingThrow(ability1, dc)
    end
    return SavingThrow(ability2, dc)
end

function CheckedPhysicalAbility(entity)
    local entity = entity or context.Source
    local isStr = context.CheckedAbility == Ability.Strength
    local isDex = context.CheckedAbility == Ability.Dexterity
    local isCon = context.CheckedAbility == Ability.Constitution
    return ConditionResult(isStr or isDex or isCon)
end

function AdvantageOnPlantImpedeAttacks(source, target)
    local source = source or context.Source
    local target = target or context.Target

    return Tagged('PLANT_IMPEDE_ADV')
end

function SplitEnchantmentProjectileSpellCheck()
    return ~NumberOfTargetsGreaterThan(1) & ~AreaRadiusGreaterThan(0) & HasSpellFlag(SpellFlags.Spell) & SpellTypeIs(SpellType.Projectile) & IsSpellOfSchool(SpellSchool.Enchantment)
end

function SplitEnchantmentTargetSpellCheck()
    return TargetRadiusGreaterThan(1.5) & ~AreaRadiusGreaterThan(0) & HasSpellFlag(SpellFlags.Spell) & SpellTypeIs(SpellType.Target) & ~HasFunctor(StatsFunctorType.Summon) & IsSpellOfSchool(SpellSchool.Enchantment) & ~NumberOfTargetsGreaterThan(1)
end

function SplitEnchantmentTargetTouchSpellCheck()
    return TargetRadiusGreaterThan(0) & ~TargetRadiusGreaterThan(1.5) & ~AreaRadiusGreaterThan(0) & HasSpellFlag(SpellFlags.Spell) & SpellTypeIs(SpellType.Target) & ~HasFunctor(StatsFunctorType.Summon) & IsSpellOfSchool(SpellSchool.Enchantment) & ~NumberOfTargetsGreaterThan(1)
end

function HasPactWeapon(entity, mainHand)
    local entity = entity or context.Source
    local weaponEntity = GetActiveWeapon(entity, true)
    if weaponEntity.IsValid then
        ---@diagnostic disable-next-line: lowercase-global
        result = Character(entity) & HasStatus('PACT_BLADE', weaponEntity)
        return ConditionResult(result.Result, {ConditionError("HasNotPactWeapon")}, {ConditionError("HasPactWeapon")})
    end
    return ConditionResult(false, {ConditionError("HasNotPactWeapon")}, {ConditionError("HasPactWeapon")})
end

function MainDamageTypeIs(damageType)
    return ConditionResult(context.HitDescription.MainDamageType == damageType)
end

function SpellSniperCheck()
    return TargetRadiusGreaterThan(1.5) & ~AreaRadiusGreaterThan(0) & HasSpellFlag(SpellFlags.Spell) & ~HasFunctor(StatsFunctorType.Summon) & (SpellTypeIs(SpellType.Target) | SpellTypeIs(SpellType.Projectile))
end

function NoInstrumentEquipped(entity)
    local entity = entity or context.Source
    if (GetItemInEquipmentSlot(EquipmentSlot.MusicalInstrument, entity).IsValid) then
        return ConditionResult(false)
    end

    return ConditionResult(true)
end

function BlackTentaclesCheck(entity)
    local entity = entity or context.Target
    local res = ~HasStatus('BLACK_TENTACLES')
    if res.Result then
        ---@diagnostic disable-next-line: lowercase-global
        st = ~SavingThrow(Ability.Strength,SourceSpellDC(12))
        return ConditionResult(st.Result,{},{},st.Chance)
    end
    return ConditionResult(true)
end

function ResilientSphereCheck()
    local res1 = HasStatus('RESILIENT_SPHERE',context.Source)
    if res1.Result then
        return ConditionResult(Self().Result, {ConditionError("ResilientSphere")})
    end

    local res2 = HasStatus('RESILIENT_SPHERE')
    if res2.Result then
        return ConditionResult(Self().Result, {ConditionError("ResilientSphere")})
    end

    return ConditionResult(true)
end


function BlinkCheck()
    local res2 = HasStatus('GASEOUSFORM_BLINK')
    if res2.Result then
        return ConditionResult(Self().Result, {ConditionError("Blink")})
    end

    return ConditionResult(true)
end

function ElementalAffinityCheck(entity)
    local entity = entity or context.Observer

    local noStatus = (~HasStatus('ELEMENTALAFFINITY_ACID',entity) & ~HasStatus('ELEMENTALAFFINITY_COLD',entity) & ~HasStatus('ELEMENTALAFFINITY_FIRE',entity) & ~HasStatus('ELEMENTALAFFINITY_LIGHTNING',entity) & ~HasStatus('ELEMENTALAFFINITY_POISON',entity)).Result
    local acid = (SpellDamageTypeIs(DamageType.Acid) & (HasPassive('DraconicAncestry_Black',entity) | HasPassive('DraconicAncestry_Copper',entity))).Result
    local cold = (SpellDamageTypeIs(DamageType.Cold) & (HasPassive('DraconicAncestry_Silver',entity) | HasPassive('DraconicAncestry_White',entity))).Result
    local fire = (SpellDamageTypeIs(DamageType.Fire) & (HasPassive('DraconicAncestry_Red',entity) | HasPassive('DraconicAncestry_Gold',entity) | HasPassive('DraconicAncestry_Brass',entity))).Result
    local lightning = (SpellDamageTypeIs(DamageType.Lightning) & (HasPassive('DraconicAncestry_Blue',entity) | HasPassive('DraconicAncestry_Bronze',entity))).Result
    local poison = (SpellDamageTypeIs(DamageType.Poison) & HasPassive('DraconicAncestry_Green',entity)).Result

    if (acid or cold or fire or lightning or poison) and noStatus then
        return ConditionResult(true)
    end

    return ConditionResult(false)
end

function IsImprovedPactOfTheChain()
    return HasPassive('ThirstingBlade_Check',context.Source) & HasPassive('PactOfTheChain',context.Source)
end

function DistanceToEntityGreaterThan(value, from, to)
    local from = from or context.SourcePosition
    local to = to or context.Target
    return ConditionResult(DistanceToEntityHitBounds(from, to) > value)
end

function ArcaneWardOverflow(spellCast, entity)
    local entity = entity or context.Target
    local AWDuration = GetStatusDuration('ARCANE_WARD', entity)
    if spellCast then
        return ConditionResult(AWDuration + context.HitDescription.SpellPowerLevel >= (2 * entity.GetClassLevel('Wizard')))
    end

    return ConditionResult(AWDuration + entity.GetClassLevel('Wizard') >= (2 * entity.GetClassLevel('Wizard')))
end

function IsRangedUnarmedAttack()
    ---@diagnostic disable-next-line: lowercase-global
    result = context.HitDescription.AttackType == AttackType.RangedUnarmedAttack
    return ConditionResult(result)
end

function IsDexterityGreaterThanStrength()
    return ConditionResult(context.Source.Dexterity >= context.Source.Strength)
end

function HasFleshToSToneCheck()
    ---@diagnostic disable-next-line: lowercase-global
    result = HasStatus('FLESH_TO_STONE_1',context.Target) | HasStatus('FLESH_TO_STONE_2',context.Target) | HasStatus('FLESH_TO_STONE_3',context.Target) 
    return ConditionResult(result.Result, {ConditionError("CE_Status_FLESH_TO_STONE_1_True")}, {ConditionError("CE_Status_FLESH_TO_STONE_1_True")})
end

function MeleeUnarmedAttackCheck()
    return HasStringInSpellRoll('MeleeUnarmedAttack') & ~SpellTypeIs(SpellType.Throw)
end

function DampenElementsCheck(damageType, entity)
    local entity = entity or context.Target
    if (damageType == DamageType.Acid
        or damageType == DamageType.Cold
        or damageType == DamageType.Fire
        or damageType == DamageType.Lightning
        or damageType == DamageType.Thunder
    ) then
        return ~IsResistantToDamageType(damageType, entity)
    end
    return ConditionResult(false)
end

function LuckOfTheFarRealmCheck()
    local notCrit = context.InterruptedRoll.NaturalRoll < 20 and context.InterruptedRoll.NaturalRoll > 1
    local isHit = context.InterruptedRoll.Total >= context.InterruptedRoll.Difficulty

    return ConditionResult(notCrit and isHit)
end

function GreaterInvisibilityCheck_InvisSpellOrRoll()
    local invisSpell = IsStatusEvent(StatusEvent.OnSpellCast) and HasSpellFlag(SpellFlags.Invisible)
	if (invisSpell.Result) then
		return ConditionResult(false)
	end

	local numberOfSuccesses = GetStatusDuration('GREATER_INVISIBILITY_SUCCESS')

	local DC = 15 + numberOfSuccesses

	local skillCheck = SkillCheck(Skill.Stealth, DC, false, false, context.Target, context.Target)

    return ConditionResult(not skillCheck.Result)
end

function IsDivineStrike()
    return SpellId('Target_DivineStrike_Melee_Life') | SpellId('Target_DivineStrike_Melee_Nature_Cold') | SpellId('Target_DivineStrike_Melee_Nature_Fire') | SpellId('Target_DivineStrike_Melee_Nature_Lightning') | SpellId('Target_DivineStrike_Melee_Tempest') | SpellId('Target_DivineStrike_Melee_Trickery') | SpellId('Target_DivineStrike_Melee_War') | SpellId('Projectile_DivineStrike_Ranged_Life') | SpellId('Projectile_DivineStrike_Ranged_Nature_Cold') | SpellId('Projectile_DivineStrike_Ranged_Nature_Fire') | SpellId('Projectile_DivineStrike_Ranged_Nature_Lightning') | SpellId('Projectile_DivineStrike_Ranged_Tempest') | SpellId('Projectile_DivineStrike_Ranged_Trickery') | SpellId('Projectile_DivineStrike_Ranged_War')
end

function AppliesCrowdControlStatus(entity)
    local entity = entity or context.Target
    local ccStatuses = {
        'SG_Fleeing',
        'SG_Incapacitated',
        'SG_Stunned',
        'SG_Unconscious',
        'SG_Restrained',
        'SG_Prone',
        'SG_Polymorph',
        'SG_Dominated',
        'DISARM'
    }

    for i,v in ipairs(ccStatuses) do
        if PassiveHasStatus(v).Result then
            if (not IsImmuneToStatus(v, entity).Result) then
                return ConditionResult(true)
            end
        end
        if SpellHasStatus(v).Result then
            if (not IsImmuneToStatus(v, entity).Result) then
                return ConditionResult(true)
            end
        end
    end

    return ConditionResult(false)
end

function WallOfFireCheck(ability, dc, result)
    result = result or false
    ---@diagnostic disable-next-line: lowercase-global
    hasStatus =  HasStatus('WALLOFFIRE_DAMAGE_RECEIVED') | HasStatus('WALLOFFIRE_DAMAGE_RECEIVED_5') | HasStatus('WALLOFFIRE_DAMAGE_RECEIVED_6')
    if not hasStatus.Result then
        ---@diagnostic disable-next-line: lowercase-global
        st = ~SavingThrow(ability, dc)
        return ConditionResult(st.Result,{},{},st.Chance)
    end
    return ConditionResult(result)
end

function HasOrphicHammer(entity)
  local entity = entity or context.Target
  local weaponInHand = GetItemInEquipmentSlot(EquipmentSlot.MeleeMainHand, entity)
  if (weaponInHand.IsValid) then
    return Tagged('ORPHIC_HAMMER', weaponInHand)
  end

  local items = GetItemsInInventory(entity)
  if items ~= nil then
    for _, item in ipairs(items.Items) do
      if Tagged('ORPHIC_HAMMER', item).Result then
        return ConditionResult(true)
      end
    end
  end

  return ConditionResult(false)
end

function AdvantageOnOrinFear()
    return HasPassive('LOW_VoloFate_SlayerKnowledge')
end

function TutorialSummonBlockCheck()
	return ConditionResult(not HasStatus('TUT_SUMMON_BLOCK').Result, {ConditionError("SummonBlockCheck")}, {ConditionError("SummonBlockCheck")} )
end

function FearStatusSavingCheck()
    local result = CanSee(context.Target,context.Source)
    if result.Result == false then
        local st = SavingThrow(Ability.Wisdom, SourceSpellDC())
        return ConditionResult(st.Result, {}, {}, st.Chance)
    end
    return ConditionResult(false)
end

function BecomeHagControlled()
    ---@diagnostic disable-next-line: undefined-global
	local entity = entity or context.Source
	local qualifies = (Tagged('PALADIN', entity) | HasAnyStatus({'HAG_MASK_CONTROLLED','HAG_MASK_CONTROLLED_PALADIN','DOWNED'}, {}, {}, entity))
    if qualifies.Result then
	   return ConditionResult(false)
    end
	local result = ~SavingThrow(Ability.Wisdom, 13)
    return ConditionResult(result.Result)
end

function BecomePaladinHagControlled()
    ---@diagnostic disable-next-line: undefined-global
	local entity = entity or context.Source
	local qualifies = (~Tagged('PALADIN', entity) | HasAnyStatus({'HAG_MASK_CONTROLLED','HAG_MASK_CONTROLLED_PALADIN','DOWNED'}, {}, {}, entity))
    if qualifies.Result then
	   return ConditionResult(false)
    end
	local result = ~SavingThrow(Ability.Wisdom, 13)
    return ConditionResult(result.Result)
end

function AspectOfChimpanzeeSavingCheck()
    local result = IsSupply(context.HitDescription.ThrownObject)
    if result.Result == true then
        local st = ~SavingThrow(Ability.Dexterity, (8 + context.Source.ProficiencyBonus +GetModifier(context.Source.Dexterity)))
        return ConditionResult(st.Result, {}, {}, st.Chance)
    end
    return ConditionResult(false)
end

function CounterspellCheck(caster, target)
	local isPlayer = Player(caster)
	if isPlayer.Result then
		return ConditionResult(true)
	end
	return AreInSameCombat(caster, target)
end

function SpellDoesntApplyToElvesOrUndead(ability, dc, result)
    result = result or false
    ---@diagnostic disable-next-line: lowercase-global
    raceElfOrUndead = (~Player() & Tagged('ELF')) | (Player() & Tagged('REALLY_ELF')) | Tagged('UNDEAD')
    if not raceElfOrUndead.Result then
        ---@diagnostic disable-next-line: lowercase-global
        st = ~SavingThrow(ability, dc)
        return ConditionResult(st.Result,{},{},st.Chance)
    end
    return ConditionResult(result)
end