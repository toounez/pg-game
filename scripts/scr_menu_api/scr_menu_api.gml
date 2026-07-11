///============================================================================
/// scr_menu_api
///============================================================================
///
/// PRESENTATION LAYER
///
/// PURPOSE
/// --------
/// Supplies menu-ready data to every UI in Psychic Ground.
///
/// This script NEVER:
///
/// • Changes gameplay
/// • Equips items
/// • Uses items
/// • Drops items
/// • Recalculates stats
/// • Modifies character data
///
/// Everything here is READ-ONLY.
///
/// DATA FLOW
///
/// Character
///     ↓
/// Stat Recalculation
///     ↓
/// Menu API
///     ↓
/// obj_menu_controller
///
///============================================================================



//=============================================================================
// PARTY ACCESS
//=============================================================================

/// @function menu_get_character()
/// @desc Returns the currently selected party member.
///       (Currently always party slot 0.)





function menu_get_character()
{
    if (!variable_global_exists("party"))
        return undefined;

    if (!is_array(global.party))
        return undefined;

    if (array_length(global.party) == 0)
        return undefined;

    if (global.party[0] == noone)
        return undefined;

    return global.party[0];
}


/// @function menu_has_character()
/// @desc True if a valid character exists.

function menu_has_character()
{
    return !is_undefined(menu_get_character());
}


/// @function menu_get_party_size()
/// @desc Returns the number of party slots.

function menu_get_party_size()
{
    if (!variable_global_exists("party"))
        return 0;

    if (!is_array(global.party))
        return 0;

    return array_length(global.party);
}


/// @function menu_get_party_member(_index)
/// @desc Safe indexed access.

function menu_get_party_member(_index)
{
    if (!variable_global_exists("party"))
        return undefined;

    if (!is_array(global.party))
        return undefined;

    if (_index < 0)
        return undefined;

    if (_index >= array_length(global.party))
        return undefined;

    return global.party[_index];
}


///=============================================================================
/// @function menu_build(_level)
///
/// @desc
/// Returns the menu option array for the requested menu level.
///=============================================================================

//=============================================================================
// MENU DISPATCHER
//=============================================================================

/// @function menu_build(_level)
/// @desc Returns the menu option array for the requested menu level.

function menu_build(_level)
{
    switch (_level)
    {
        case MENU_LEVEL.MAIN:
            return menu_build_main_menu();

        case MENU_LEVEL.STATUS:
            return menu_build_status_menu();

        case MENU_LEVEL.EQUIPMENT:
            return menu_build_equipment_menu();

        case MENU_LEVEL.PARTY:
            return menu_build_vectors_menu();

        case MENU_LEVEL.BACKPACK:
            return menu_build_backpack_menu();

        case MENU_LEVEL.ITEMS:
            return menu_build_item_menu();

        case MENU_LEVEL.CONTEXT:
            return menu_build_context_menu();
    }

    return [];
}

//=============================================================================
// MENU TITLES
//=============================================================================

/// @function menu_get_title(_level)

function menu_get_title(_level)
{
    switch (_level)
{
    case MENU_LEVEL.MAIN:
        return "MAIN MENU";

    case MENU_LEVEL.STATUS:
        return "STATUS & STATS";

    case MENU_LEVEL.EQUIPMENT:
        return "EQUIPMENT";

    case MENU_LEVEL.PARTY:
        return "PARTY";

    case MENU_LEVEL.BACKPACK:
        return "BACKPACK";

    case MENU_LEVEL.ITEMS:
        return "ITEMS";

    case MENU_LEVEL.CONTEXT:
        return "ACTIONS";
}

    return "";
}



//=============================================================================
// COMMON HELPERS
//=============================================================================

/// @function menu_back_option(_menu_level,_cursor)
/// @desc Generates a standard Back button.

function menu_back_option()
{
    return
    {
        label : "Back",

        action : function()
        {
            menu_go_back();
        }
    };
}


/// @function menu_change_menu(_menu_level,_cursor)
/// @desc Simple helper for changing menus.

/// @function menu_safe_item_name(_item)
/// @desc Returns a printable item name.

function menu_safe_item_name(_item)
{
    if (_item == EMPTY_SLOT)
        return "Empty";

    if (!is_struct(_item))
        return "---";

    if (!variable_struct_exists(_item, "name"))
        return "???";

    return _item.name;
}

//PART 2

//=============================================================================
// STATUS MENU
//=============================================================================

/// @function menu_build_status_menu()
/// @desc Builds the Status & Stats page.

function menu_build_status_menu()
{
    return
    [
        { get_dynamic_label : menu_get_wp_label },

        { get_dynamic_label : menu_get_pp_label },

        { get_dynamic_label : function(){ return menu_get_stat_label("spd",  "SPEED"); } },

        { get_dynamic_label : function(){ return menu_get_stat_label("guts", "GUTS"); } },

        { get_dynamic_label : function(){ return menu_get_stat_label("vit",  "VITALITY"); } },

        { get_dynamic_label : function(){ return menu_get_stat_label("iq",   "IQ"); } },

        { get_dynamic_label : function(){ return menu_get_stat_label("luk",  "LUCK"); } },

        menu_back_option()
    ];
}



//=============================================================================
// RESOURCE LABELS
//=============================================================================

/// @function menu_get_wp_label()

function menu_get_wp_label()
{
    var _char = menu_get_character();

    if (is_undefined(_char))
        return "WP: ---";

    return
        "WP: "
        + string(_char.willpower)
        + " / "
        + string(_char.max_willpower);
}


/// @function menu_get_pp_label()

function menu_get_pp_label()
{
    var _char = menu_get_character();

    if (is_undefined(_char))
        return "PP: ---";

    return
        "PP: "
        + string(_char.pp_current)
        + " / "
        + string(_char.max_pp);
}



//=============================================================================
// STAT LABELS
//=============================================================================

/// @function menu_get_stat_label(_stat,_label)
/// @desc Returns a formatted scalar stat.

function menu_get_stat_label(_stat, _label)
{
    var _char = menu_get_character();

    if (is_undefined(_char))
        return _label + ": ---";

    var _value = 0;

    switch (_stat)
    {
        case "spd":
            _value = _char.current_spd;
        break;

        case "guts":
            _value = _char.current_guts;
        break;

        case "vit":
            _value = _char.current_vit;
        break;

        case "iq":
            _value = _char.current_iq;
        break;

        case "luk":
            _value = _char.current_luk;
        break;

        default:
            _value = 0;
    }

    return _label + ": " + string(_value);
}

//=============================================================================
// EQUIPMENT MENU
//=============================================================================

/// @function menu_build_equipment_menu()

function menu_build_equipment_menu()
{
    return
    [
        {
            get_dynamic_label : function()
            {
                return menu_get_equipment_label("weapon", "Weapon");
            },

            action : function()
            {
                global.menu_context.equipment_slot = "weapon";
                global.menu_context.inventory_filter = "weapon";

                menu_change_menu(MENU_LEVEL.BACKPACK, 0);
            }
        },

        {
            get_dynamic_label : function()
            {
                return menu_get_equipment_label("armor", "Armor");
            },

            action : function()
            {
                global.menu_context.equipment_slot = "armor";
                global.menu_context.inventory_filter = "armor";

                menu_change_menu(MENU_LEVEL.BACKPACK, 0);
            }
        },

        {
            get_dynamic_label : function()
            {
                return menu_get_equipment_label("accessory1", "Accessory 1");
            },

            action : function()
            {
                global.menu_context.equipment_slot = "accessory1";
                global.menu_context.inventory_filter = "accessory";

                menu_change_menu(MENU_LEVEL.BACKPACK, 0);
            }
        },

        {
            get_dynamic_label : function()
            {
                return menu_get_equipment_label("accessory2", "Accessory 2");
            },

            action : function()
            {
                global.menu_context.equipment_slot = "accessory2";
                global.menu_context.inventory_filter = "accessory";

                menu_change_menu(MENU_LEVEL.BACKPACK, 0);
            }
        },

        menu_back_option()
    ];
}

/// @function menu_get_equipment_label()

function menu_get_equipment_label(_slot, _label)
{
    var _char = menu_get_character();

    if (is_undefined(_char))
        return _label + ": ---";

    var _item = _char.equipment[$ _slot];

    return _label + ": " + menu_safe_item_name(_item);
}

//=============================================================================
// BACKPACK MENU
//=============================================================================

function menu_build_backpack_menu()
{
    var _menu = [];

    var _char = menu_get_character();

    if (is_undefined(_char))
        return [menu_back_option()];

    var _filter = global.menu_context.inventory_filter;

    for (var i = 0; i < array_length(_char.backpack); i++)
    {
        var _item = _char.backpack[i];

        if (_item == EMPTY_SLOT)
            continue;

        if (!is_struct(_item))
            continue;

        if (_filter != "")
        {
            if (_item.type != _filter)
                continue;
        }

        array_push(_menu,
        {
            label : _item.name,

            action : function()
            {
                global.menu_context.selected_item = i;

                menu_change_menu(MENU_LEVEL.CONTEXT,0);
            }
        });
    }

    array_push(_menu,
        menu_back_option()
    );

    return _menu;
}

//=============================================================================
// ITEM MENU
//=============================================================================

/// @function menu_build_item_menu()
/// @desc Builds the consumable inventory.

function menu_build_item_menu()
{
    var _menu = [];

    var _char = menu_get_character();

    if (is_undefined(_char))
        return [menu_back_option()];

    for (var i = 0; i < array_length(_char.items); i++)
    {
        var _item = _char.items[i];

        if (_item == EMPTY_SLOT)
            continue;

        if (!is_struct(_item))
            continue;

        var _slot = i;

        array_push(_menu,
        {
            label : menu_safe_item_name(_item),

            action : function()
            {
                global.menu_context.selected_item = _slot;
                global.menu_context.inventory_filter = "items";

                menu_change_menu(MENU_LEVEL.CONTEXT, 0);
            }
        });
    }

    array_push(_menu,
        menu_back_option()
    );

    return _menu;
}

//=============================================================================
// CONTEXT MENU
//=============================================================================

function menu_build_context_menu()
{
    var _menu = [];

    var _char = menu_get_character();

    if (is_undefined(_char))
        return [menu_back_option()];

    var _slot = global.menu_context.selected_item;

    var _array =
        (global.menu_context.inventory_filter == "items")
        ? _char.items
        : _char.backpack;

    if (_slot < 0 || _slot >= array_length(_array))
        return [menu_back_option()];

    var _item = _array[_slot];

    if (!is_struct(_item))
        return [menu_back_option()];

    //---------------------------------------------------------
    // EQUIP
    //---------------------------------------------------------

    if (_item.type == "weapon"
    ||  _item.type == "armor"
    ||  _item.type == "accessory")
    {
        array_push(_menu,
        {
            label : "Equip",

            action : function()
            {
               if (scr_equip_item(_char, _slot))
{
    menu_change_menu(MENU_LEVEL.EQUIPMENT, 0);
}
            }
        });
    }

    //---------------------------------------------------------
    // USE
    //---------------------------------------------------------

    if (variable_struct_exists(_item,"usable"))
    {
        if (_item.usable)
        {
            array_push(_menu,
            {
                label : "Use",

                action : function()
                {
                    if (scr_use_item(_char, "items", _slot))
{
    menu_change_menu(MENU_LEVEL.ITEMS, 0);
}
                }
            });
        }
    }

    //---------------------------------------------------------
    // INSPECT
    //---------------------------------------------------------

    array_push(_menu,
    {
        label : "Inspect",

        action : function()
        {
            show_debug_message("Inspect: " + _item.name);
        }
    });

    //---------------------------------------------------------
    // DISCARD
    //---------------------------------------------------------

    array_push(_menu,
    {
        label : "Discard",

        action : function()
        {
            show_debug_message("The hell are you doing?");
        }
    });

    //---------------------------------------------------------
    // CANCEL
    //---------------------------------------------------------

    array_push(_menu,
        menu_back_option()
            
        )
    

    return _menu;
}

//=============================================================================
// COMBAT VECTOR MENU
//=============================================================================

/// @function menu_build_vectors_menu()
/// @desc Displays both Offensive and Defensive combat vectors.

function menu_build_vectors_menu()
{
    return
    [
        //==============================
        // OFFENSE
        //==============================

        { label : "--- OFFENSE ---" },

        { get_dynamic_label : function(){ return menu_get_vector_label("off","slice","Slice"); }},

        { get_dynamic_label : function(){ return menu_get_vector_label("off","pummel","Pummel"); }},

        { get_dynamic_label : function(){ return menu_get_vector_label("off","shoot","Shoot"); }},

        { get_dynamic_label : function(){ return menu_get_vector_label("off","grab","Grab"); }},

        { get_dynamic_label : function(){ return menu_get_vector_label("off","psychic","Psychic"); }},

        //==============================
        // DEFENSE
        //==============================

        { label : "--- DEFENSE ---" },

        { get_dynamic_label : function(){ return menu_get_vector_label("def","slice","Slice"); }},

        { get_dynamic_label : function(){ return menu_get_vector_label("def","pummel","Pummel"); }},

        { get_dynamic_label : function(){ return menu_get_vector_label("def","shoot","Shoot"); }},

        { get_dynamic_label : function(){ return menu_get_vector_label("def","grab","Grab"); }},

        { get_dynamic_label : function(){ return menu_get_vector_label("def","psychic","Psychic"); }},

        menu_back_option()
    ];
}

/// @function menu_get_vector_label(_type,_vector,_label)

function menu_get_vector_label(_type,_vector,_label)
{
    var _char = menu_get_character();

    if (is_undefined(_char))
        return _label + ": ---";

    var _value = 0;

    switch (_type)
    {
        case "off":

            if (variable_struct_exists(_char.current_off,_vector))
                _value = _char.current_off[$ _vector];

        break;

        case "def":

            if (variable_struct_exists(_char.current_def,_vector))
                _value = _char.current_def[$ _vector];

        break;
    }

    return _label + ": " + string(_value);
}

///=============================================================================
/// @func menu_change_menu(_level, _cursor)
///
/// @desc
/// Changes the active menu while preserving the previous menu for
/// Back navigation.
///
/// PARAMETERS
/// _level  - Destination MENU_LEVEL.
/// _cursor - Cursor position to restore in the destination menu.
///=============================================================================

function menu_change_menu(_level, _cursor)
{
    var _mc = obj_menu_controller;

    //--------------------------------------------------------------------------
    // Save current navigation state.
    //--------------------------------------------------------------------------

   array_push(_mc.menu_history,
{
    level  : _mc.menu_level,
    pos    : _mc.pos,
    scroll : _mc.scroll_offset
});

    //--------------------------------------------------------------------------
    // Switch menus.
    //--------------------------------------------------------------------------

    _mc.menu_level = _level;
    _mc.pos = _cursor;
    _mc.scroll_offset = _previous.scroll;

    //--------------------------------------------------------------------------
    // Refresh presentation.
    //--------------------------------------------------------------------------

    _mc.menu_dirty = true;
}

///=============================================================================
/// @func menu_go_back()
///
/// @desc
/// Returns to the previously visited menu.
///
/// If no history exists, nothing happens.
///=============================================================================

function menu_go_back()
{
    var _mc = obj_menu_controller;

    //--------------------------------------------------------------------------

    if (array_length(_mc.menu_history) == 0)
        return;

    //--------------------------------------------------------------------------

    var _previous = array_pop(_mc.menu_history);

    _mc.menu_level = _previous.level;
    _mc.pos        = _previous.pos;

   _mc.scroll_offset = _previous.scroll;
    _mc.menu_dirty = true;
}

//=============================================================================
// MAIN MENU
//=============================================================================

/// @function menu_build_main_menu()
/// @desc Builds the root menu.

function menu_build_main_menu()
{
    return
    [
        {
            label : "Status & Stats",

            action : function()
            {
                menu_change_menu(MENU_LEVEL.STATUS, 0);
            }
        },

        {
            label : "Equipment",

            action : function()
            {
                menu_change_menu(MENU_LEVEL.EQUIPMENT, 0);
            }
        },

        {
            label : "Party",

            action : function()
            {
                menu_change_menu(MENU_LEVEL.PARTY, 0);
            }
        },

        {
            label : "Items",

            action : function()
            {
                global.menu_context.inventory_filter = "items";
                menu_change_menu(MENU_LEVEL.ITEMS, 0);
            }
        }
    ];
}