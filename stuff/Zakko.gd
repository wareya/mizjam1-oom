extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var rng : RandomNumberGenerator = RandomNumberGenerator.new()
# Called when the node enters the scene tree for the first time.

var possible_names = [
"Zakko",
"B-Holder",
"Slime Mold",
"Newspaper",
"Stale Toast",
"Rat's Tail",
"Demon Heart",
"Trumpet",
"Rejector",
"Tokimeki Replay",
"OwO",
":3c",
";_;7",
"Silent Alarm",
"Deathbed Moon",
"Toe Toe",
"Pinky Promise",
"Dream Yeeter",
"Hot Curry",
"Quaff",
"Rie Kino",
"Baha Mute",
"Hoarse",
"Night Mare"
]

var log_name = "Zakko"

var hp_max = 7
var hp = hp_max
var hp_growth = 3

var level = 1
var exp_grant = 3

var damage_type = "physical"
var damage_min = 3
var damage_max = 5
var damage_growth = 3

var defense = {
"physical": 2,
"elemental": 0,
"conceptual": 3
}
var defense_growth = {
"physical": 2,
"elemental": 0,
"conceptual": 3
}
var growth_type = 0


var follow_radius = 1

var types = ["physical", "elemental", "conceptual"]

var modulates = [
Color(1.0, 1.0, 1.0),

Color(1.0, 0.5, 0.5),
Color(0.5, 1.0, 0.5),
Color(0.5, 0.5, 1.0),

Color(1.0, 1.0, 0.5),
Color(0.5, 1.0, 1.0),
Color(1.0, 0.5, 1.0),

Color(1.0, .75, 0.5),
Color(0.5, .75, 1.0),
Color(0.75, 0.75, 0.75),
]

var turn_buildup = 0.0
var turns = 1.75 # number of turns it gets every time it's granted a turn
var turn_chance = 25

# card levelup formula:
#    card["exp_next"] = ceil(card["exp_next"] * 1.5)
#    card["level"] += 1
#    
#    var rng : RandomNumberGenerator = RandomNumberGenerator.new()
#    rng.randomize()
#    if card["damage_growth"] > 0:
#        card["damage_base"] += ceil(card["damage_growth"] * rng.randf_range(0.5, 1.5) * sqrt(card["level"]*2))
#    if card["defense_growth"] > 0:
#        card["defense"] += ceil(card["defense_growth"] * rng.randf_range(0.5, 1.5) * sqrt(card["level"]*2))
#    
#    if rng.randi_range(0, 100) < card["level"]:
#        card["quality"] += round(sqrt(card["level"]))
#    
#    card["durability"] += 10
#    if card["durability"] > 20:
#        card["durability"] = 20
        
func levelup():
    exp_grant = ceil(exp_grant*1.5)
    level += 1
    
    rng.set_seed(hash(log_name + str(level)))
    if growth_type != 1:
        var damage_up = ceil(damage_growth * rng.randf_range(0.5, 1.5) * sqrt(level*2))
        damage_min += damage_up
        damage_max += damage_up
    for f in defense:
        if defense[f] == 0 or growth_type == 0: continue
        defense[f] += ceil(defense_growth[f] * rng.randf_range(0.5, 1.5) * sqrt(level*2))
    
    if rng.randi_range(0, 5) != 0:
        hp_max += min(15, ceil(hp_growth * rng.randf_range(0.5, 1.5) * sqrt(level*2)))
    hp = hp_max
    
    Manager.unique_randomize_rng(rng)
    pass

func configure_stats():
    rng.set_seed(hash(log_name))
    hp_max = 5 + rng.randi_range(0, 10)
    hp = hp_max
    damage_type = Manager.random_choose(rng, types)
    damage_min = rng.randi_range(1, 5)
    damage_max = rng.randi_range(damage_min, damage_min+4)
    
    defense["physical"] = rng.randi_range(0, 5)
    defense["elemental"] = rng.randi_range(0, 5)
    defense["conceptual"] = rng.randi_range(0, 5)
    
    growth_type = rng.randi_range(0, 9)
    
    turns = rng.randf_range(0.25, 1.75)
    turn_chance = rng.randi_range(25, 200)
    if turn_chance > 90:
        turn_chance = 90
    $Sprite.frame = rng.randi_range(0, $Sprite.hframes*$Sprite.vframes - 1)
    $Sprite.flip_h = Manager.random_choose(rng, [true, false])
    $Sprite.modulate = Manager.random_choose(rng, modulates)
    follow_radius = Manager.random_choose(rng, [1, 1, 2, 2, 2, 3, 4, 6])
    
    damage_growth = rng.randi_range(1, 3)
    defense_growth["physical"] = rng.randi_range(1, 3)
    defense_growth["elemental"] = rng.randi_range(1, 3)
    defense_growth["conceptual"] = rng.randi_range(1, 3)
    exp_grant = rng.randi_range(2, 5) + rng.randi_range(0, 1)
    
    hp_growth = rng.randi_range(1, 4) + rng.randi_range(0, 2)
    
    Manager.unique_randomize_rng(rng)
    
    var level_bracket = ceil((Manager.position+1.0)/3.0)
    var target_level = round(level_bracket * rng.randf_range(0.75, 1.25) * rng.randf_range(0.75, 1.25))
    if level_bracket > 1 and target_level > floor(level_bracket * 1.5):
        target_level = floor(level_bracket * 1.5)
    if target_level < 1:
        target_level = 1
    
    while level < target_level:
        levelup()
    
    pass

func _ready():
    Manager.unique_randomize_rng(rng)
    log_name = Manager.random_choose(rng, possible_names)
    configure_stats()
    pass # Replace with function body.

var directions = [Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1)]

func damage_function():
    return rng.randi_range(damage_min, damage_max)

func take_turn():
    if rng.randi_range(0, 99) < turn_chance:
        var old_position = position
        var new_position = position + directions[rng.randi_range(0, len(directions)-1)]*16
        
        # attack player if adjacent, 75% chance
        if rng.randi_range(0, 3) < 4:
            var player = get_tree().get_nodes_in_group("Player")
            if len(player) > 0:
                player = player[0]
                var delta : Vector2 = (player.position - position)/16.0
                var dist = abs(delta.x) + abs(delta.y)
                if dist <= follow_radius:
                    if abs(delta.x) > abs(delta.y):
                        delta.y = 0
                    elif abs(delta.y) > abs(delta.x) or rng.randi_range(0, 1) == 0:
                        delta.x = 0
                    else:
                        delta.y = 0
                    delta = delta.normalized()
                    new_position = position + delta*16
        
        
        if new_position != position:
            var c = move_and_collide(new_position-position)
            var other : Node = null
            if c:
                other = c.collider
            for object in get_tree().get_nodes_in_group("Mover"):
                if object != self and object.global_position == self.global_position:
                    other = object
            if other:
                position = old_position
                if other.is_in_group("Player"):
                    Manager.attack(self, other)

func grant_turn():
    if hp <= 0:
        return
    turn_buildup += turns
    while turn_buildup >= 1.0:
        turn_buildup -= 1.0
        take_turn()
