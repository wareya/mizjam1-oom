extends KinematicBody2D


var log_name = "Fire of OOM"

var damage_type = "elemental"
var damage = 50
var direction : Vector2 = Vector2(1, 0)
var level = -1
var turns_of_life = 6

func _ready():
    $BG.visible = false
    $Sprite.visible = false
    update_stuff()

func damage_function():
    return damage

func update_stuff():
    match direction:
        Vector2(1, 0), Vector2(1, -1):
            $Sprite.rotation_degrees = 0
        Vector2(0, 1), Vector2(1, 1):
            $Sprite.rotation_degrees = 90
        Vector2(-1, 0), Vector2(-1, 1):
            $Sprite.rotation_degrees = 180
        Vector2(0, -1), Vector2(-1, -1):
            $Sprite.rotation_degrees = 270
    if abs(direction.x) == 0 or abs(direction.y) == 0:
        $Sprite.frame = $Sprite.frame%3 + 6
    else:
        $Sprite.frame = $Sprite.frame%3
        
    $BG2.position = $BG.position + direction*16
    $Sprite2.position = $Sprite.position + direction*16
    $Sprite2.frame = $Sprite.frame%3 +3

func destroy():
    queue_free()
    $BG.visible = false
    $Sprite.visible = false
    $BG2.visible = false
    $Sprite2.visible = false

func take_turn():
    turns_of_life -= 1
    if turns_of_life == 0:
        destroy()
    if turns_of_life == 1:
        $BG2.visible = false
        $Sprite2.visible = false
    
    position += direction*16
    update_stuff()
    $BG.visible = true
    $Sprite.visible = true
    
    var player = get_tree().get_nodes_in_group("Player")
    if turns_of_life > 1 and len(player) > 0:
        player = player[0]
        if player.global_position == global_position:
            Manager.attack(self, player)
            destroy()
    pass

func grant_turn():
    take_turn()
