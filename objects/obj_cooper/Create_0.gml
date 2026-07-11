show_debug_message("!!!!!!!!!!!!!!!! PLAYER OBJECT IS ALIVE !!!!!!!!!生!!!!!!!");

// =====================================================================
// MOVEMENT & ENGINE BASICS
// =====================================================================
xspd = 0;
yspd = 0;

// Sub-pixel accumulator storage tanks for diagonal movement
sub_x = 0;
sub_y = 0;
move_spd = 2;

// Toggles between true and false every frame to balance diagonal speeds
tick = false;

// Sprite Array directional mapping
sprite[RIGHT] = spr_player_rt;
sprite[UP]    = spr_player_up;
sprite[LEFT]  = spr_player_lt;
sprite[DOWN]  = spr_player_dn;

face = DOWN;

// =====================================================================
// UI, INVENTORY, & PARTY BRIDGE
// =====================================================================
if (!variable_global_exists("party")) {
    global.party = array_create(4, noone);
}

inventory_max_slots = 16;

// Create Cooper as a persistent Data Struct matching your dynamic UI
global.party[0] = {
    name: "Cooper",
    
    // 1. THE SEVEN BASE ATTRIBUTES (Raw TTRPG stats)
    stats: {
        off:  1, // Offense
        def:  1, // Defense
        spd:  1, // Speed
        guts: 1, // Guts
        vit:  1, // Vitality
        iq:   1, // IQ
        luk:  1  // Luck
    },

    // 2. ACTIVE COMBAT MODIFIERS (What the game actually reads)
    current_stats: {
        off:  1,
        def:  1,
        spd:  1,
        guts: 1,
        vit:  1,
        iq:   1,
        luk:  1
    },

    // 3. COMBAT STAT BUFFS & DEBUFFS (In-Battle Stage Modifiers)
    buffs: {
        off:  0,
        def:  0,
        spd:  0,
        guts: 0,
        vit:  0,
        iq:   0,
        luk:  0
    },

    // 4. THE DERIVED RESOURCE POOLS
    max_willpower: 10, 
    willpower:     10,
    max_pp:        0, 
    pp_current:    0, 

    // 5. INVENTORY & EQUIPMENT SYSTEMS (Fully expanded to 16 slots)
    inventory: array_create(inventory_max_slots, EMPTY_SLOT),
    backpack:  array_create(inventory_max_slots, EMPTY_SLOT),
    items:     array_create(inventory_max_slots, EMPTY_SLOT), // Added to perfectly match menu generation!
    
    equipment: {
        weapon:     EMPTY_SLOT,
        armor:      EMPTY_SLOT,
        accessory1: EMPTY_SLOT,
        accessory2: EMPTY_SLOT
    },
    
    foundation_cracks: 0
}; 

// Create a local shortcut pointer to Cooper for initialization
var _cooper = global.party[0];

// Calculate Cooper's initial derived resource pools dynamically
var _bpsi_max = (3 * _cooper.stats.iq) + 2;
var _hpsi_max = _cooper.stats.guts;

_cooper.max_willpower = (5 * _cooper.stats.vit) + 5;
_cooper.willpower     = _cooper.max_willpower;
_cooper.max_pp        = _bpsi_max + _hpsi_max;
_cooper.pp_current    = 0;

// =====================================================================
// STRUCT EQUIPMENT & STAT RECALCULATION SYSTEM
// =====================================================================
init_item_database();

// Handles equipping an item from a character's direct storage
equip_item_to_struct = function(_char_struct, _slot_index) {
    if (_slot_index < 0 || _slot_index >= array_length(_char_struct.inventory)) return;
    
    var _item = _char_struct.inventory[_slot_index];
    if (_item == EMPTY_SLOT || _item == undefined) return;
    
    var _target_slot = _item.type; 
    
    if (_target_slot == "accessory") {
        if (_char_struct.equipment.accessory1 == EMPTY_SLOT) _target_slot = "accessory1";
        else _target_slot = "accessory2";
    }
    
    if (!variable_struct_exists(_char_struct.equipment, _target_slot)) {
        show_debug_message("Error: Invalid equipment type: " + string(_target_slot));
        return;
    }
    
    var _old_gear = variable_struct_get(_char_struct.equipment, _target_slot);
    variable_struct_set(_char_struct.equipment, _target_slot, _item);
    _char_struct.inventory[_slot_index] = _old_gear; 
    
    recalculate_struct_stats(_char_struct);
    show_debug_message("Successfully equipped " + _item.name + " to " + _char_struct.name + "'s " + _target_slot + " slot.");
};

// Resets and loops gear modifiers dynamically
recalculate_struct_stats = function(_char_struct) {
    _char_struct.current_stats.off  = _char_struct.stats.off;
    _char_struct.current_stats.def  = _char_struct.stats.def;
    _char_struct.current_stats.spd  = _char_struct.stats.spd;
    _char_struct.current_stats.guts = _char_struct.stats.guts;
    _char_struct.current_stats.vit  = _char_struct.stats.vit;
    _char_struct.current_stats.iq   = _char_struct.stats.iq;
    _char_struct.current_stats.luk  = _char_struct.stats.luk;
    
    var _slots = ["weapon", "armor", "accessory1", "accessory2"];
    for (var i = 0; i < array_length(_slots); i++) {
        var _slot = _slots[i];
        var _equipped_item = _char_struct.equipment[$ _slot];
        
        if (_equipped_item != EMPTY_SLOT && _equipped_item != undefined && variable_struct_exists(_equipped_item, "stats")) {
            var _vectors = variable_struct_get_names(_equipped_item.stats);
            for (var j = 0; j < array_length(_vectors); j++) {
                var _v_name = _vectors[j];
                var _vector_data = _equipped_item.stats[$ _v_name];
                
                if (variable_struct_exists(_vector_data, "off")) {
                    _char_struct.current_stats.off += _vector_data.off;
                }
                if (variable_struct_exists(_vector_data, "def")) {
                    _char_struct.current_stats.def += _vector_data.def;
                }
            }
        }
    }
};

// =====================================================================
// INITIAL SPAWN GEAR & TEST RUN
// =====================================================================
var _my_first_weapon = item_create_instance("shock_baton");
_cooper.inventory[0] = _my_first_weapon;

// Fire equipment calculation method safely
equip_item_to_struct(_cooper, 0);

// Debugging Verifications
show_debug_message("=== COOPER'S STRUCT STAT CHECK ===");
show_debug_message("Base Offense: " + string(_cooper.stats.off));
show_debug_message("Current Offense (With Gear): " + string(_cooper.current_stats.off));
show_debug_message("-------------------------------");
show_debug_message("Equipped Weapon Slot holds: " + string(_cooper.equipment.weapon != EMPTY_SLOT ? _cooper.equipment.weapon.name : "Nothing"));
show_debug_message("==================================");