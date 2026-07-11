// Ensure the player is always moved to the "player" layer of the current room
if (layer_exists("player")) {
    layer = layer_get_id("player");
}