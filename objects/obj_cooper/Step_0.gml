// =====================================================================
// INPUT
// =====================================================================
right_key = keyboard_check(ord("D")) || keyboard_check(vk_right);
left_key  = keyboard_check(ord("A")) || keyboard_check(vk_left);
up_key    = keyboard_check(ord("W")) || keyboard_check(vk_up);
down_key  = keyboard_check(ord("S")) || keyboard_check(vk_down);

// =====================================================================
// MENU INPUT LOCK
// =====================================================================
// While the menu exists, player movement is disabled.

if (instance_exists(obj_menu_controller))
{
    right_key = 0;
    left_key  = 0;
    up_key    = 0;
    down_key  = 0;
}

// =====================================================================
// OPTIONAL: Read movement speed from character
// =====================================================================

// Future-proof.
// Once Speed affects overworld movement:
//
// move_spd = player_character.current_move_speed;

// =====================================================================
// MOVEMENT
// =====================================================================
var _input_x = right_key - left_key;
var _input_y = down_key - up_key;

if (_input_x != 0 && _input_y != 0)
{
    tick = !tick;

    if (tick)
    {
        xspd = _input_x * 2;
        yspd = _input_y * 1;
    }
    else
    {
        xspd = _input_x * 1;
        yspd = _input_y * 2;
    }
}
else
{
    xspd = _input_x * move_spd;
    yspd = _input_y * move_spd;
}

// =====================================================================
// FACING
// =====================================================================
mask_index = sprite[DOWN];

if (_input_x != 0 || _input_y != 0)
{
    if (_input_x != 0)
        face = (_input_x > 0) ? RIGHT : LEFT;
    else
        face = (_input_y > 0) ? DOWN : UP;
}

sprite_index = sprite[face];

// =====================================================================
// COLLISION
// =====================================================================
if (place_meeting(x + xspd, y, obj_wall))
{
    while (!place_meeting(x + sign(xspd), y, obj_wall))
    {
        x += sign(xspd);
    }

    xspd = 0;
    sub_x = 0;
}

x += xspd;

if (place_meeting(x, y + yspd, obj_wall))
{
    while (!place_meeting(x, y + sign(yspd), obj_wall))
    {
        y += sign(yspd);
    }

    yspd = 0;
    sub_y = 0;
}

y += yspd;

// =====================================================================
// ANIMATION
// =====================================================================
if (xspd == 0 && yspd == 0)
{
    image_index = 0;
    image_speed = 0;
}
else
{
    image_speed = 1;
}

// =====================================================================
// INTERACTION
// =====================================================================
if (keyboard_check_pressed(ord("E")) || keyboard_check_pressed(vk_space))
{
    var _distance = 8;

    var _target_x = x + lengthdir_x(_distance, face * 90);
    var _target_y = y + lengthdir_y(_distance, face * 90);

    var _target = instance_place(
        _target_x,
        _target_y,
        obj_interactable_parent
    );

    if (_target != noone)
    {
        with (_target)
        {
            event_user(0);
        }
    }
}


//=============================================================================
// MENU TOGGLE
//=============================================================================

if (keyboard_check_pressed(vk_escape))
{
    if (!instance_exists(obj_menu_controller))
    {
        instance_create_depth(
            x,
            y,
            -9999,
            obj_menu_controller
        );
    }
    else
    {
        with (obj_menu_controller)
        {
            instance_destroy();
        }
    }
}