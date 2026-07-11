// PHASE 2: We have arrived in the new destination room
if (room == targetRM) 
{
    // Once the backward animation shrinks completely out of view, clean up
    if (image_index < 1) 
    {
        instance_destroy(); // This completely destroys the transition and unfreezes the player!
    }
}