--Most of the classes in these file are found within the global context object.
--These mappings always seem to exist. However, as different condition contexts exist, the contents of the 
--context object can vary. For example, every context object will have a context.Observer, however the object
--will only ever be populated within an interrupt context (that I've observed(heh)).
--Therefore, sometimes data will appear correct, but as a false positive. You will want to use some safeties
--such as making sure that an entity IsValid, a value varies from what might be its default, etc etc

--disambiguating numbers as they're presented from example data
--- @alias KhnInteger number
--- @alias KhnFloat number

--- @class Khn_InterruptedRoll
--- @field Difficulty KhnInteger
--- @field NaturalRoll KhnInteger
--- @field Total KhnInteger
--- @field RollType {name:KhnConditionRollType, value:KhnInteger} --can possibly be mapped but didn't see an example of its enum
--- @field Ability {name:KhnAbility, value:KhnInteger}
--- @field RollCritical {name:RollCritical, value:KhnInteger}
--- @field AdvantageState {name:AdvantageState, value:KhnInteger} 

--- @class Khn_SpellModificationDescription
--- @field SpellId string
--- @field TargetRadius KhnFloat
--- @field AreaRadius KhnFloat
--- @field NumberOfTargets KhnInteger

--- @class Khn_Vector
--- @field Length KhnFloat
--- @field X KhnFloat
--- @field Y KhnFloat
--- @field Z KhnFloat

--- @class Khn_AttackDescription
--- @field GetDamageDoneForType fun(a1:any?) Needs Mapping. Assumed: KhnDamageType input, integer output
--- @field InitialHPPercentage KhnInteger
--- @field TotalHealDone KhnInteger
--- @field TotalDamageDone KhnInteger
--- @field AttackType KhnAttackType

--- @class Khn_Entity
--- @field IsValid boolean
--- @field Level KhnInteger
--- @field ProficiencyBonus KhnInteger
--- @field IsInvulnerable boolean
--- @field HP KhnInteger
--- @field HPWithoutTemporaryHP KhnInteger
--- @field MaxHP KhnInteger
--- @field MaxHPWithoutTemporaryHP KhnInteger
--- @field TemporaryHP KhnInteger
--- @field HPPercentage KhnInteger
--- @field HPPercentageWithoutTemporaryHP KhnInteger
--- @field GetClassLevel fun(a1:any?) Needs mapping. Assumed: string input, integer output
--- @field GetPassiveSkill fun(a1:KhnSkill?) Needs confirming: Assumed to return 10 + skill bonus
--- @field GetSavingThrow fun(a1:any?) Needs mapping.
--- @field HasAnyResistances fun(a1:table, a2:ResistanceType):boolean
--- @field HasAllResistances fun(a1:table, a2:ResistanceType):boolean
--- @field Weight KhnInteger
--- @field Size {name:string, value:KhnInteger} probably mappable
--- @field ArmorType {name:string, value:KhnInteger} probably mappable
--- @field ActionTypes {ActionTypes:table} default appears to be an empty table
--- @field EquipmentSlot {name:KhnItemSlot, value:KhnInteger}
--- @field Strength KhnInteger
--- @field Dexterity KhnInteger
--- @field Constitution KhnInteger
--- @field Intelligence KhnInteger
--- @field Wisdom KhnInteger
--- @field Charisma KhnInteger
--- @field Athletics KhnInteger
--- @field Acrobatics KhnInteger
--- @field SleightOfHand KhnInteger
--- @field Stealth KhnInteger
--- @field Arcana KhnInteger
--- @field History KhnInteger
--- @field Investigation KhnInteger
--- @field Nature KhnInteger
--- @field Religion KhnInteger
--- @field AnimalHandling KhnInteger
--- @field Insight KhnInteger
--- @field Medicine KhnInteger
--- @field Perception KhnInteger
--- @field Survival KhnInteger
--- @field Deception KhnInteger
--- @field Intimidation KhnInteger
--- @field Performance KhnInteger
--- @field Persuasion KhnInteger

--- @class Khn_HitDescription
--- @field GetDamageDoneForType fun(a1:any?) Needs Mapping. Assumed: KhnDamageType input, integer output
--- @field GetLastConditionRoll fun(a1:any?) Needs Mapping.
--- @field IsDamageAfterMiss boolean
--- @field IsFromSneak boolean
--- @field IsHitpointsDamaged boolean
--- @field IsInstantKill boolean
--- @field IsKillingBlow boolean
--- @field IsReaction boolean
--- @field FirstAttack boolean
--- @field LastAttack boolean
--- @field IsHit boolean
--- @field IsMiss boolean
--- @field IsCritical boolean
--- @field IsCriticalHit boolean
--- @field IsCriticalMiss boolean
--- @field OriginalDamageValue KhnInteger
--- @field TotalHealDone KhnInteger
--- @field TotalDamageDone KhnInteger
--- @field SpellLevel KhnInteger
--- @field SpellPowerLevel KhnInteger
--- @field SpellSchool {name:KhnSchool, value:KhnInteger}
--- @field AttackAbility {name:KhnAbility, value:KhnInteger}
--- @field AttackType {name:KhnAttackType, value:KhnInteger}
--- @field CauseType {name:CauseType, value:KhnInteger}
--- @field DeathType {name:string, value:KhnInteger} Probably mappable
--- @field HitWith {name:KhnHitWith, value:KhnInteger}
--- @field MainDamageType {name:KhnDamageType, value:KhnInteger} 
--- @field SaveAbility {name:KhnAbility, value:KhnInteger}
--- @field InflicterObject Khn_Entity
--- @field ThrownObject Khn_Entity

--- @class Khn_Context
--- @field Event string possibly mappable
--- @field HasContextFlag fun(a1:any?) Needs Mapping
--- @field StatusId string
--- @field StatusEvent {name:StatusEvent, value:KhnInteger}
--- @field StatusRemoveCause {name:KhnStatusRemoveCause, value:KhnInteger}
--- @field PassiveId string
--- @field PassiveFunctorIndex KhnInteger -1 means none
--- @field InterruptId string
--- @field InterruptedRoll Khn_InterruptedRoll
--- @field CheckedAbility {name:KhnAbility, value:KhnInteger}
--- @field CheckedSkill {name:KhnSkill, value:KhnInteger} value seems to default at 19 for some reason
--- @field SpellModificationDescription Khn_SpellModificationDescription
--- @field Distance KhnFloat
--- @field SourcePosition Khn_Vector
--- @field TargetPosition Khn_Vector
--- @field ObserverPosition Khn_Vector
--- @field PreferredCastingAbility {name:KhnAbility, value:KhnInteger} name defaults to Charisma and value to 6, it seems
--- @field AttackDescription Khn_AttackDescription
--- @field HitDescription Khn_HitDescription
--- @field Source Khn_Entity
--- @field Target Khn_Entity
--- @field Observer Khn_Entity
--- @field Passive Khn_Entity
--- @field SourceProxy Khn_Entity
--- @field TargetProxy Khn_Entity
--- @field ObserverProxy Khn_Entity
--- @field AttackWeapon Khn_Entity
--- @field UsedItem Khn_Entity
local Khn_Context = {}
---@diagnostic disable-next-line: lowercase-global
context = Khn_Context

local function andCondition(first, second)
    return ConditionResult(first.Result and second.Result, {}, {}, first.Chance * second.Chance)
end

local function notCondition(input)
    return ConditionResult(not input.Result, {}, {}, 1 - input.Chance)
end

local function orCondition(first, second)
    return ConditionResult(first.Result or second.Result, {}, {}, 1 - ((1 - first.Chance) * (1 - second.Chance)))
end

---@class Khn_ConditionResult
---@field Result boolean
---@field errorWhenFalse table --Not fully sure how these two work
---@field errorWhenTrue table
---@field Chance KhnFloat
---@operator band(Khn_ConditionResult): Khn_ConditionResult
---@operator bnot(Khn_ConditionResult): Khn_ConditionResult
---@operator bor(Khn_ConditionResult): Khn_ConditionResult
ConditionResult = {}
local ConditionResult_mt = {
    __metatable = ConditionResult,
    __index = ConditionResult,
    __band = andCondition,
    __bnot = notCondition,
    __bor = orCondition
}
setmetatable(ConditionResult, ConditionResult_mt)
local function resultConstructor(_, init)
    return setmetatable(init or {}, ConditionResult_mt)
end
ConditionResult.new = resultConstructor

--These need more exploration
---@class Khn_ConditionError 
ConditionError = {}
local ConditionError_mt = {
    __metatable = ConditionError,
    __index = ConditionError
}
setmetatable(ConditionError, ConditionError_mt)
local function errorConstructor(_, init)
    return setmetatable(init or {}, ConditionError_mt)
end
ConditionError.new = errorConstructor

---@class Khn_ConditionErrorData
---@field MakeFromNumber fun(value:any, type:EErrorDataType):Khn_ConditionErrorData
ConditionErrorData = {}
local ConditionErrorData_mt = {
    __metatable = ConditionErrorData,
    __index = ConditionErrorData
}
setmetatable(ConditionErrorData, ConditionErrorData_mt)
local function errorDataConstructor(_, init)
    return setmetatable(init or {}, ConditionErrorData_mt)
end
ConditionErrorData.new = errorDataConstructor