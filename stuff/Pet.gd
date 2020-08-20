extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var rng : RandomNumberGenerator = RandomNumberGenerator.new()
# Called when the node enters the scene tree for the first time.
func _ready():
    Manager.unique_randomize_rng(rng)
    pass # Replace with function body.

var turn_buildup = 0.0
var turns = 1.0

var directions = [Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1)]

func take_turn():
    if rng.randi_range(0, 2) == 0:
        var old_position = position
        var new_position = position + directions[rng.randi_range(0, len(directions)-1)]*16
        if new_position != position:
            var c = move_and_collide(new_position-position)
            var other = null
            if c:
                other = c.collider
            for object in get_tree().get_nodes_in_group("Mover"):
                if object != self and object.global_position == self.global_position:
                    other = object
            if other:
                position = old_position
            # TODO: test for enemy/player overlap

func grant_turn():
    turn_buildup += turns
    while turn_buildup >= 1.0:
        turn_buildup -= 1.0
        take_turn()
