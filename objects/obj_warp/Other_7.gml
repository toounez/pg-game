// PHASE 1: The diamond animation has finished filling the screen black
room_goto(targetRM); // Teleport the game window to the target room

// Update obj_player's coordinates and look direction using your exact asset names
obj_cooper.x = targetX;
obj_cooper.y = targetY;
obj_cooper.face = targetFace;

// Force the sprite frames to reverse playback speed automatically
image_speed = -1;