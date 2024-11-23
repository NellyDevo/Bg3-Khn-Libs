--These in particular require a lot more mapping. 
--I filled everything in from what I detected from the linter in CommonConditions and CommonConditionsDev, 
--but any conditions in stats and in general could be used to explore this
--Several of these are things that I conclude probably exist but that I haven't yet seen any values for in khn code.
--The values might also be wrong, however in all the places where these enums are used, 
--the code simply calls things like `EquipmentSlot.MeleeMainHand` to send to the relevant function.
--Therefore all that really seems important to get mappings working is having the correct keys

--- @enum KhnItemSlot
EquipmentSlot = {
    None = "None",
    Helmet = "Helmet",
    Breast = "Breast",
    Cloak = "Cloak",
    MeleeMainHand = "Melee Main Weapon",
    MeleeOffHand = "Melee Offhand Weapon",
    RangedMainHand = "Ranged Main Weapon",
    RangedOffHand = "Ranged Offhand Weapon",
    Ring = "Ring",
    Underwear = "Underwear",
    Boots = "Boots",
    Gloves = "Gloves" ,
    Amulet = "Amulet" ,
    Ring2 = "Ring2" ,
    Wings = "Wings" ,
    Horns = "Horns" ,
    Overhead = "Overhead" ,
    MusicalInstrument = "MusicalInstrument" ,
    VanityBody = "VanityBody" ,
    VanityBoots = "VanityBoots" 
}

--- @enum KhnAbility
Ability = {
    None = "None",
    Strength = "Strength",
    Dexterity = "Dexterity",
    Constitution = "Constitution",
    Intelligence = "Intelligence",
    Wisdom = "Wisdom",
    Charisma = "Charisma"
}

--- @enum KhnSkill 
Skill = {
    None = "None",
    Arcana = "Arcana",
    History = "History",
    Religion = "Religion",
    Investigation = "Investigation",
    Athletics = "Athletics",
    Nature = "Nature",
    Acrobatics = "Acrobatics",
    SleightOfHand = "SleightOfHand",
    Stealth = "Stealth",
    AnimalHandling = "AnimalHandling",
    Insight = "Insight",
    Medicine = "Medicine",
    Deception = "Deception",
    Perception = "Perception",
    Persuasion = "Persuasion",
    Survival = "Survival",
    Intimidation = "Intimidation",
    Performance = "Performance"
}

--- @enum KhnSchool
SpellSchool = {
    None = "None",
    Abjuration = "Abjuration",
    Conjuration = "Conjuration",
    Divination = "Divination",
    Enchantment = "Enchantment",
    Evocation = "Evocation",
    Illusion = "Illusion",
    Necromancy = "Necromancy",
    Transmutation = "Transmutation"
}

--- @enum KhnDamageType 
DamageType = {
    None = "None",
    Acid = "Acid",
    Bludgeoning = "Bludgeoning",
    Cold = "Cold",
    Fire = "Fire",
    Force = "Force",
    Lightning = "Lightning",
    Necrotic = "Necrotic",
    Piercing = "Piercing",
    Poison = "Poison",
    Psychic = "Psychic",
    Radiant = "Radiant",
    Slashing = "Slashing",
    Thunder = "Thunder"
}

--- @enum KhnArmorType
ArmorType = {
    None = "None",

    Cloth = "Cloth",
    Padded = "Padded",
    Leather = "Leather",
    StuddedLeather = "StuddedLeather",

    Hide = "Hide",
    ChainShirt = "ChaintShirt",
    ScaleMail = "ScaleMail",
    BreastPlate = "BreastPlate",
    HalfPlate = "HalfPlate",

    RingMail = "RingMail",
    ChainMail = "ChainMail",
    Splint = "Splint",
    Plate = "Plate"
}

--- @enum KhnWeaponProperties
WeaponProperties = {
    Heavy = "Heavy",
    Twohanded = "TwoHanded",
    Melee = "Melee",
    Versatile = "Versatile",
    Thrown = "Thrown",
    Ammunition = "Ammunition",
    Finesse = "Finesse"
}

--- @enum KhnStatusRemoveCause
StatusRemoveCause = {

}

--- @enum KhnInstrumentType
InstrumentType = {

}

--- @enum KhnHealingType
HealingType = {

}

--- @enum KhnSpellCategory
SpellCategory = {
    Jump = "Jump"
}

--- @enum StatsFunctorType
StatsFunctorType = {
    Summon = "Summon",
    DealDamage = "DealDamage",
    Status = "Status",
    SummonInInventory = "SummonInInventory",
    CreateSurface = "CreateSurface"
}

--- @enum KhnDiceType
DiceType = {
    d8 = "d8"
}

--- @enum KhnAttackType
AttackType = {
    RangedUnarmedAttack = "RangedUnarmedAttack",
    MeleeWeaponAttack = "MeleeWeaponAttack",
    RangedWeaponAttack = "RangedWeaponAttack",
    MeleeUnarmedAttack = "MeleeUnarmedAttack",
    MeleeSpellAttack = "MeleeSpellAttack",
    RangedSpellAttack = "RangedSpellAttack",
    MeleeOffHandWeaponAttack = "MeleeOffHandWeaponAttack",
    RangedOffHandWeaponAttack = "RangedOffHandWeaponAttack",
    None = "None"
}

--- @enum RollOptions
RollOptions = {

}

--- @enum EErrorDataType
EErrorDataType = {
    Distance = "Distance",
    SimpleNumber = "SimpleNumber"
}

--- @enum StatusEvent
StatusEvent = {
    OnSpellCast = "OnSpellCast"
}

--- @enum KhnSpellFlags
SpellFlags = {
    Invisible = "Invisible",
    Spell = "IsSpell",
    Attack = "Attack",
    IsSwarmAttack = "IsSwarmAttack",
    Verbal = "Verbal",
    Trap = "Trap"
}

--- @enum KhnSpellType
SpellType = {
    Throw = "Throw",
    Target = "Target",
    Projectile = "Projectile",
    Shout = "Shout",
    Zone = "Zone",
    Rush = "Rush"
}

--- @enum KhnHitWith
HitWith = {
    FallDamage = "FallDamage",
    Redirection = "Redirection"
}

--- @enum Size
Size = {
    None = "None"
}

--- @enum KhnDamageFlags
DamageFlags = {
    Hit = "Hit",
    Miss = "Miss",
    Dodge = "Dodge",
    KillingBlow = "KillingBlow",
    SavingThrow = "SavingThrow"
}

--- @enum AdvantageState
AdvantageState = {
    Both = "Both",
    Advantage = "Advantage",
    Disadvantage = "Disadvantage"
}

--- @enum KhnConditionRollType
ConditionRollType = {
    ConditionSavingThrow = "ConditionSavingThrow",
    ConditionAttack = "ConditionAttack"
}

--- @enum KhnRollCritical
RollCritical = {
    None = "None",
    Success = "Success"
}

--- @enum ResistanceType
ResistanceType = {
    Resistant = "Resistant",
    Immune = "Immune"
}