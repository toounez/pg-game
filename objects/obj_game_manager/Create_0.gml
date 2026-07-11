/// @desc Global Game Data Initialization

//-----------------------------------------------------------------------------
// Global Defaults
//-----------------------------------------------------------------------------

global.fnt_main = -1;

//-----------------------------------------------------------------------------
// Helper Functions
//-----------------------------------------------------------------------------

function struct_get_nested(_struct, _path, _default)
{
    var _keys = string_split(_path, ".");
    var _current = _struct;

    for (var i = 0; i < array_length(_keys); i++)
    {
        if (!is_struct(_current) || !variable_struct_exists(_current, _keys[i]))
        {
            return _default;
        }

        _current = _current[$ _keys[i]];
    }

    return _current;
}

//-----------------------------------------------------------------------------
// Initialize Databases
//-----------------------------------------------------------------------------

init_item_database();

//-----------------------------------------------------------------------------
// Initialize Party
//-----------------------------------------------------------------------------

scr_initialize_starting_party();
scr_update_character_stats(global.party[0]);

//-----------------------------------------------------------------------------
// Initialize UI
//-----------------------------------------------------------------------------
//
// Menu initialization is handled by obj_menu_controller.
// No global menu bootstrap is required.
//

