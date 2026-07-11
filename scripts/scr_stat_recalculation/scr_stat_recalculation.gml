/// @function scr_update_character_stats(_char)
/// @desc Rebuilds a character's live stats from base stats + equipment.

function scr_update_character_stats(_char)
{
    if (!is_struct(_char)) return;

    //==========================================================
    // RESET CURRENT STATS
    //==========================================================

    _char.current_off = variable_clone(_char.off);
    _char.current_def = variable_clone(_char.def);

    _char.current_spd  = _char.spd;
    _char.current_guts = _char.guts;
    _char.current_vit  = _char.vit;
    _char.current_iq   = _char.iq;
    _char.current_luk  = _char.luk;

    //==========================================================
    // APPLY EQUIPMENT BONUSES
    //==========================================================

    var _slots = variable_struct_get_names(_char.equipment);

    for (var i = 0; i < array_length(_slots); i++)
    {
        var _slot_name = _slots[i];
        var _item = _char.equipment[$ _slot_name];

        if (_item == EMPTY_SLOT) continue;
        if (!is_struct(_item)) continue;
        if (!variable_struct_exists(_item, "stats")) continue;

        var _fields = variable_struct_get_names(_item.stats);

        for (var j = 0; j < array_length(_fields); j++)
        {
            var _field = _fields[j];
            var _value = _item.stats[$ _field];

            // -----------------------------------------------------
            // Combat vectors (off / def)
            // -----------------------------------------------------

            if (is_struct(_value))
            {
                if (_field == "off")
                {
                    var _vectors = variable_struct_get_names(_value);

                    for (var k = 0; k < array_length(_vectors); k++)
                    {
                        var _vec = _vectors[k];
                        _char.current_off[$ _vec] += _value[$ _vec];
                    }
                }
                else if (_field == "def")
                {
                    var _vectors = variable_struct_get_names(_value);

                    for (var k = 0; k < array_length(_vectors); k++)
                    {
                        var _vec = _vectors[k];
                        _char.current_def[$ _vec] += _value[$ _vec];
                    }
                }

                continue;
            }

            // -----------------------------------------------------
            // Scalar bonuses
            // -----------------------------------------------------

            switch (_field)
            {
                case "spd":  _char.current_spd  += _value; break;
                case "guts": _char.current_guts += _value; break;
                case "vit":  _char.current_vit  += _value; break;
                case "iq":   _char.current_iq   += _value; break;
                case "luk":  _char.current_luk  += _value; break;
            }
        }
    }

    //==========================================================
    // DERIVED RESOURCES
    //==========================================================

    _char.max_willpower =
        (_char.current_vit * 5) + 5;

    var _bpsi_pool =
        (_char.current_iq * 3) + 2;

    var _hpsi_pool =
        _char.current_guts;

    _char.max_pp =
        _bpsi_pool + _hpsi_pool;

    //==========================================================
    // CLAMP CURRENT RESOURCES
    //==========================================================

    _char.willpower =
        clamp(_char.willpower, 0, _char.max_willpower);

    _char.pp_current =
        clamp(_char.pp_current, 0, _char.max_pp);
}