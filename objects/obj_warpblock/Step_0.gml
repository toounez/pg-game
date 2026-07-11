// Check if obj_player steps on this exact spot AND a transition isn't running
if (place_meeting(x, y, obj_cooper) && !instance_exists(obj_warp)) 
{
    // Create the visual transition object at a very high render depth
    var inst = instance_create_depth(0, 0, -9999, obj_warp);

    // Feed our specific room rules directly into the newly born visual object
    inst.targetX = targetX;
    inst.targetY = targetY;
    inst.targetRM = targetRM;
    inst.targetFace = targetFace;
}