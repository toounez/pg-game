///============================================================================
/// PSYCHIC GROUND ENGINE
///
/// SCRIPT:
///     scr_character_api
///
/// VERSION:
///     2.0.0
///
/// PURPOSE:
///     Public interface for Character data.
///
/// DESIGN RULES:
///     • Character structs are private.
///     • External systems NEVER access Character structs directly.
///     • Menus, Battles, AI, Events and Dialogue all use this API.
///
/// DEPENDENCIES:
///     scr_combat_vectors
///
/// USED BY:
///     scr_menu_api
///     obj_menu_controller
///     obj_battle_controller
///     Dialogue System
///
///============================================================================



//=============================================================================
// VALIDATION
//=============================================================================

function scr_character_exists(_char)
{
    return is_struct(_char);
}



//=============================================================================
// CHARACTER INFORMATION
//=============================================================================

function scr_character_get_name(_char)
{
    if (!scr_character_exists(_char))
        return "";

    return _char.name;
}


function scr_character_get_level(_char)
{
    if (!scr_character_exists(_char))
        return 1;

    if (!variable_struct_exists(_char, "level"))
        return 1;

    return _char.level;
}



//=============================================================================
// GENERAL STAT ACCESS
//=============================================================================

function scr_character_get_stat(_char, _stat, _vector = "")
{
    if (!scr_character_exists(_char))
        return 0;

    switch (_stat)
    {
        //---------------------------------------------------------------------
        // Combat Vectors
        //---------------------------------------------------------------------

        case "off":
            return scr_get_attack_vector(_char, _vector);

        case "def":
            return scr_get_defense_vector(_char, _vector);

        //---------------------------------------------------------------------
        // Scalar Attributes
        //---------------------------------------------------------------------

        case "spd":
        case "guts":
        case "vit":
        case "iq":
        case "luk":

            if (variable_struct_exists(_char.current_stats, _stat))
                return variable_struct_get(_char.current_stats, _stat);

            return 0;

        //---------------------------------------------------------------------
        // Resources
        //---------------------------------------------------------------------

        case "willpower":
            return _char.willpower;

        case "max_willpower":
            return _char.max_willpower;

        case "pp":
        case "pp_current":
            return _char.pp_current;

        case "max_pp":
            return _char.max_pp;

        //---------------------------------------------------------------------
        // Foundation
        //---------------------------------------------------------------------

        case "foundation_cracks":
            return _char.foundation_cracks;
    }

    return 0;
}



//=============================================================================
// EQUIPMENT
//=============================================================================

function scr_character_get_equipped_item(_char, _slot)
{
    if (!scr_character_exists(_char))
        return EMPTY_SLOT;

    if (!variable_struct_exists(_char.equipment, _slot))
        return EMPTY_SLOT;

    return variable_struct_get(_char.equipment, _slot);
}


function scr_character_has_equipment(_char, _slot)
{
    return (scr_character_get_equipped_item(_char, _slot) != EMPTY_SLOT);
}



//=============================================================================
// INVENTORY
//=============================================================================

function scr_character_get_inventory(_char, _inventory_name)
{
    if (!scr_character_exists(_char))
        return undefined;

    if (!variable_struct_exists(_char, _inventory_name))
        return undefined;

    return variable_struct_get(_char, _inventory_name);
}


function scr_character_get_inventory_item(_char, _inventory_name, _slot)
{
    var inv = scr_character_get_inventory(_char, _inventory_name);

    if (is_undefined(inv))
        return EMPTY_SLOT;

    if (_slot < 0)
        return EMPTY_SLOT;

    if (_slot >= array_length(inv))
        return EMPTY_SLOT;

    return inv[_slot];
}



//=============================================================================
// RESOURCE HELPERS
//=============================================================================

function scr_character_get_wp_percent(_char)
{
    if (!scr_character_exists(_char))
        return 0;

    if (_char.max_willpower <= 0)
        return 0;

    return (_char.willpower / _char.max_willpower);
}


function scr_character_get_pp_percent(_char)
{
    if (!scr_character_exists(_char))
        return 0;

    if (_char.max_pp <= 0)
        return 0;

    return (_char.pp_current / _char.max_pp);
}



//=============================================================================
// STATE QUERIES
//=============================================================================

function scr_character_is_alive(_char)
{
    if (!scr_character_exists(_char))
        return false;

    return (_char.willpower > 0);
}


function scr_character_is_exhausted(_char)
{
    if (!scr_character_exists(_char))
        return true;

    return (_char.pp_current <= 0);
}


function scr_character_has_pp(_char)
{
    return (scr_character_get_stat(_char, "pp") > 0);
}


function scr_character_has_wp(_char)
{
    return (scr_character_get_stat(_char, "willpower") > 0);
}



//=============================================================================
// PARTY HELPERS
//=============================================================================

function scr_character_get_party_size()
{
    if (!variable_global_exists("party"))
        return 0;

    return array_length(global.party);
}


function scr_character_get_party_member(_index)
{
    if (!variable_global_exists("party"))
        return undefined;

    if (_index < 0)
        return undefined;

    if (_index >= array_length(global.party))
        return undefined;

    return global.party[_index];
}



//=============================================================================
// RESERVED - GAMEPLAY ACTIONS
//
// These will eventually become the ONLY legal methods for modifying Characters.
//
// Reserved:
//
// scr_character_equip()
// scr_character_unequip()
// scr_character_add_item()
// scr_character_remove_item()
// scr_character_use_item()
// scr_character_can_equip()
// scr_character_can_use_item()
//
//=============================================================================



//=============================================================================
// BACKWARDS COMPATIBILITY
//=============================================================================

function scr_get_battle_stat(_char, _stat, _vector = "")
{
    return scr_character_get_stat(_char, _stat, _vector);
}