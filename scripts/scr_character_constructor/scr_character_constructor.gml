///============================================================================
/// scr_character_constructor
/// Generic Character Blueprint
/// Every playable party member begins life here.
///============================================================================

function Character(_name) constructor
{
    //=========================================================================
    // IDENTITY
    //=========================================================================

    name = _name;


    //=========================================================================
    // CORE ATTRIBUTES
    //=========================================================================

    // Offensive combat vectors
    off =
    {
        slice   : 1,
        pummel  : 1,
        shoot   : 1,
        grab    : 1,
        psychic : 1
    };

    // Defensive combat vectors
    def =
    {
        slice   : 1,
        pummel  : 1,
        shoot   : 1,
        grab    : 1,
        psychic : 1
    };

    // Primary Attributes
    spd  = 1;
    guts = 1;
    vit  = 1;
    iq   = 1;
    luk  = 1;


    //=========================================================================
    // DERIVED / LIVE STATS
    //=========================================================================

    current_off = variable_clone(off);
    current_def = variable_clone(def);

    current_spd  = spd;
    current_guts = guts;
    current_vit  = vit;
    current_iq   = iq;
    current_luk  = luk;


    //=========================================================================
    // RESOURCES
    //=========================================================================

    max_willpower = (5 * vit) + 5;
    willpower     = max_willpower;

    max_pp     = (3 * iq) + 2 + guts;
    pp_current = max_pp;


    //=========================================================================
    // STATUS
    //=========================================================================

    foundation_cracks = 0;


    //=========================================================================
    // EQUIPMENT
    //=========================================================================

    equipment =
    {
        weapon     : EMPTY_SLOT,
        armor      : EMPTY_SLOT,
        accessory1 : EMPTY_SLOT,
        accessory2 : EMPTY_SLOT
    };


    //=========================================================================
    // INVENTORIES
    //=========================================================================

    backpack = array_create(16, EMPTY_SLOT);
    items    = array_create(16, EMPTY_SLOT);


    //=========================================================================
    // BATTLE MODIFIERS
    //=========================================================================

    buffs =
    {
        slice   : 0,
        pummel  : 0,
        shoot   : 0,
        grab    : 0,
        psychic : 0,

        spd      : 0,
        guts     : 0,
        vit      : 0,
        iq       : 0,
        luk      : 0
    };


    //=========================================================================
    // PARTY FLAGS
    //=========================================================================

    is_alive   = true;
    is_active  = false;

}