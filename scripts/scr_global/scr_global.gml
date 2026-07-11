/// @description obj_game Create Event

// 1. Initialize the databases first!
init_item_database(); 

// 2. Initialize systems, variables, and global states
// init_game_systems();

// 3. Now that databases exist, safe to build the party and hand out items
scr_initialize_starting_party();

// Cleaned up to accept explicit arguments, avoiding instance scope locks
function scr_initialize_menus(_x, _y) {
    instance_create_layer(_x, _y, "Instances", obj_menu_controller);
}