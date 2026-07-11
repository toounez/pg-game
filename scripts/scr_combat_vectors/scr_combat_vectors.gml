///============================================================================
/// scr_combat_vectors
///
/// Central combat vector API.
/// Every combat system should query this script instead of reading stats
/// directly.
///============================================================================

#macro VECTOR_NEUTRAL_DEFENSE 3


//=============================================================================
// Returns the current attack value for a combat vector.
//=============================================================================
function scr_get_attack_vector(_char, _vector)
{
    if (!is_struct(_char)) return 0;

    if (!variable_struct_exists(_char, "current_off"))
        return 0;

    if (!variable_struct_exists(_char.current_off, _vector))
        return 0;

    return _char.current_off[$ _vector];
}


//=============================================================================
// Returns the defense modifier relative to neutral.
//
// Defense 3 = 0 modifier
// Defense 5 = +2
// Defense 1 = -2
//=============================================================================
function scr_get_defense_modifier(_char, _vector)
{
    if (!is_struct(_char)) return 0;

    if (!variable_struct_exists(_char, "current_def"))
        return 0;

    if (!variable_struct_exists(_char.current_def, _vector))
        return 0;

    return _char.current_def[$ _vector] - VECTOR_NEUTRAL_DEFENSE;
}


//=============================================================================
// Returns the raw defense rating.
//
// Used by menus and debugging.
//=============================================================================
function scr_get_defense_vector(_char, _vector)
{
    if (!is_struct(_char)) return 0;

    if (!variable_struct_exists(_char, "current_def"))
        return 0;

    if (!variable_struct_exists(_char.current_def, _vector))
        return 0;

    return _char.current_def[$ _vector];
}


//=============================================================================
// Returns true if the vector exists.
//=============================================================================
function scr_has_vector(_char, _vector)
{
    if (!is_struct(_char))
        return false;

    if (!variable_struct_exists(_char, "current_off"))
        return false;

    return variable_struct_exists(_char.current_off, _vector);
}


//=============================================================================
// Generic stat getter.
//
// "off"
// "def"
//=============================================================================
function scr_get_vector(_char, _vector, _type)
{
    switch (_type)
    {
        case "off":
            return scr_get_attack_vector(_char, _vector);

        case "def":
            return scr_get_defense_vector(_char, _vector);
    }

    return 0;
}


//=============================================================================
// Calculates the final attack score before skills.
//
// Formula:
//
// Base Attack
// + Equipment
// + Buffs
//
// (Already baked into current_off by stat recalculation.)
//
// Therefore this simply returns the current value.
//=============================================================================
function scr_calculate_attack(_char, _vector)
{
    return scr_get_attack_vector(_char, _vector);
}


//=============================================================================
// Calculates the defense modifier.
//
// Example:
//
// Defense Rating = 5
//
// Neutral = 3
//
// Modifier = +2
//=============================================================================
function scr_calculate_defense(_char, _vector)
{
    return scr_get_defense_modifier(_char, _vector);
}


//=============================================================================
// Calculates attack advantage.
//
// Positive = attacker favored
// Negative = defender favored
//=============================================================================
function scr_vector_advantage(_attacker, _defender, _vector)
{
    var _atk = scr_calculate_attack(_attacker, _vector);
    var _def = scr_calculate_defense(_defender, _vector);

    return _atk - _def;
}