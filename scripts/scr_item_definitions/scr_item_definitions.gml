/// ============================================================================
/// scr_item_definitions
/// Master Item System for Psychic Ground
/// ============================================================================

#macro EMPTY_SLOT undefined

//=============================================================================
// ITEM CONSTRUCTOR
//=============================================================================

function Item(_id, _name, _type, _stats, _description = "", _on_use = undefined) constructor
{
    id          = _id;
    name        = _name;
    type        = _type;
    description = _description;
    on_use      = _on_use;

    // Every item owns its own copy of its stats.
    stats = variable_clone(_stats);
}

//=============================================================================
// ITEM DATABASE
//=============================================================================

function init_item_database()
{
    global.item_db = {};

    //---------------------------------------------------------------------
    // CONSUMABLES
    //---------------------------------------------------------------------

    global.item_db.remedy_capsule = new Item(
        "remedy_capsule",
        "Remedy Capsule",
        "consumable",
        {},
        "Restores 15 PP.",
        function(_char)
        {
            _char.pp_current += 15;
            scr_update_character_stats(_char);
            return true;
        }
    );

    global.item_db.psi_soda = new Item(
        "psi_soda",
        "Psi-Soda",
        "consumable",
        {},
        "Restores 30 PP.",
        function(_char)
        {
            _char.pp_current += 30;
            scr_update_character_stats(_char);
            return true;
        }
    );

    global.item_db.med_patch = new Item(
        "med_patch",
        "Med-Patch",
        "consumable",
        {},
        "Restores HP.",
        function(_char)
        {
            if (variable_struct_exists(_char, "hp_current"))
            {
                _char.hp_current += 30;
            }

            return true;
        }
    );

    //---------------------------------------------------------------------
    // WEAPONS
    //---------------------------------------------------------------------

    global.item_db.rusty_crowbar = new Item(
        "rusty_crowbar",
        "Rusty Crowbar",
        "weapon",
        {
            pummel : { off : 1 }
        },
        "A rusted construction tool."
    );

    global.item_db.shock_baton = new Item(
        "shock_baton",
        "Shock Baton",
        "weapon",
        {
            pummel : { off : 2 }
        },
        "A compact electroshock baton."
    );

    global.item_db.mono_blade = new Item(
        "mono_blade",
        "Mono-Blade",
        "weapon",
        {
            slice : { off : 4 }
        },
        "A mono-molecular edge."
    );

    //---------------------------------------------------------------------
    // ARMOR
    //---------------------------------------------------------------------

    global.item_db.kevlar_vest = new Item(
        "kevlar_vest",
        "Kevlar Vest",
        "armor",
        {
            slice  : { def : 2 },
            pummel : { def : 3 },
            shoot  : { def : 4 },

            vit : 1
        },
        "Standard ballistic protection."
    );

    //---------------------------------------------------------------------
    // ACCESSORIES
    //---------------------------------------------------------------------

    global.item_db.psychic_amplifier = new Item(
        "psychic_amplifier",
        "Psychic Amplifier",
        "accessory",
        {
            psychic : { off : 3, def : 1 },

            iq : 2
        },
        "Amplifies psychic output."
    );

    //---------------------------------------------------------------------
    // KEY ITEMS
    //---------------------------------------------------------------------

    global.item_db.keycard_01 = new Item(
        "keycard_01",
        "Keycard-01",
        "key_item",
        {},
        "Tier-1 Rainbow Corp access."
    );
}

//=============================================================================
// ITEM FACTORY
//=============================================================================

function item_create_instance(_id)
{
    if (!variable_struct_exists(global.item_db, _id))
    {
        return EMPTY_SLOT;
    }

    var _template = global.item_db[$ _id];

    return new Item(
        _template.id,
        _template.name,
        _template.type,
        _template.stats,
        _template.description,
        _template.on_use
    );
}

//=============================================================================
// INVENTORY HELPERS
//=============================================================================

function inventory_add_item(_inventory, _item)
{
    for (var i = 0; i < array_length(_inventory); i++)
    {
        if (_inventory[i] == EMPTY_SLOT)
        {
            _inventory[i] = _item;
            return true;
        }
    }

    return false;
}

function scr_give_item_to_character(_char, _item_id, _field = "items")
{
    if (!is_struct(_char)) return false;

    if (!variable_struct_exists(_char, _field))
        return false;

    var _item = item_create_instance(_item_id);

    if (_item == EMPTY_SLOT)
        return false;

    return inventory_add_item(_char[$ _field], _item);
}

//=============================================================================
// EQUIPMENT
//=============================================================================

function scr_equip_item(_char, _slot)
{
    if (!is_struct(_char)) return false;

    if (_slot < 0) return false;
    if (_slot >= array_length(_char.backpack)) return false;

    var _item = _char.backpack[_slot];

    if (_item == EMPTY_SLOT)
        return false;

    var _equip_slot = _item.type;

    if (_equip_slot == "accessory")
    {
        if (_char.equipment.accessory1 == EMPTY_SLOT)
            _equip_slot = "accessory1";
        else
            _equip_slot = "accessory2";
    }

    if (!variable_struct_exists(_char.equipment, _equip_slot))
        return false;

    var _old = _char.equipment[$ _equip_slot];

    _char.equipment[$ _equip_slot] = _item;
    _char.backpack[_slot] = _old;

    scr_update_character_stats(_char);

    return true;
}

//=============================================================================
// ITEM USE
//=============================================================================

function scr_use_item(_char, _inventory_name, _slot)
{
    if (!is_struct(_char))
        return false;

    var _inventory = _char[$ _inventory_name];

    if (_slot < 0 || _slot >= array_length(_inventory))
        return false;

    var _item = _inventory[_slot];

    if (_item == EMPTY_SLOT)
        return false;

    if (!is_callable(_item.on_use))
        return false;

    if (_item.on_use(_char))
    {
        _inventory[_slot] = EMPTY_SLOT;
        return true;
    }

    return false;
}