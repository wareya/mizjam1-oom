extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var rng : RandomNumberGenerator = RandomNumberGenerator.new()
# Called when the node enters the scene tree for the first time.

var log_name = "Keeper of OOM"

var hp_max = 10
var hp = hp_max
var hp_growth = 6.5

var level = 1
var exp_grant = 3

var types = ["physical", "elemental", "conceptual"]

var damage_type = "physical"
var damage_min = 3
var damage_max = 5
var damage_growth = 3

var defense = {
"physical": 2,
"elemental": 1,
"conceptual": 3
}
var defense_growth = {
"physical": 1.5,
"elemental": 1,
"conceptual": 2
}
var raw_defense = defense
var growth_type = 0
var follow_radius = 0

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

func levelup():
    exp_grant = ceil(exp_grant*1.5)
    level += 1
    
    rng.set_seed(hash(log_name + str(level)))
    if growth_type != 1:
        var damage_up = ceil(damage_growth * rng.randf_range(0.5, 1.5) * sqrt(level*2))
        damage_min += damage_up
        damage_max += damage_up
    for f in defense:
        defense[f] += ceil(defense_growth[f] * rng.randf_range(0.5, 1.5) * sqrt(level*2))
    
    if rng.randi_range(0, 5) != 0:
        hp_max += min(15, ceil(hp_growth * rng.randf_range(0.5, 1.5) * sqrt(level*2)))
    hp = hp_max
    
    Manager.unique_randomize_rng(rng)
    pass

func _ready():
    Manager.position = 20
    if Manager.beat_boss:
        $Sprite.visible = false
        queue_free()
    Manager.unique_randomize_rng(rng)
    while level < 10:
        levelup()
    raw_defense = defense.duplicate()
    print(hp_max)
    print(raw_defense)
    pass # Replace with function body.

var directions = [Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1), Vector2(-1, -1), Vector2(-1, 1), Vector2(1, -1), Vector2(1, 1)]

var projectile : PackedScene = preload("res://stuff/OOMProjectile.tscn")

func spawn_sword(dir, rel_pos = Vector2(0, 0)):
    var sword = projectile.instance()
    sword.get_node("Sprite").frame = 0
    sword.damage_type = "physical"
    sword.direction = dir
    sword.log_name = "Blade of OOM"
    get_tree().get_root().add_child(sword)
    sword.position = position + rel_pos*16
    return sword

func spawn_swords_corners():
    for i in range(4, 8):
        var sword = spawn_sword(directions[i])
        sword.turns_of_life = 4

func spawn_swords_edges():
    for i in range(0, 4):
        spawn_sword(directions[i])
    pass

func spawn_swords_both():
    for dir in directions:
        spawn_sword(dir)

func spawn_flame(dir, rel_pos = Vector2(0, 0)):
    var flame = spawn_sword(dir, rel_pos)
    flame.damage_type = "elemental"
    flame.get_node("Sprite").frame = 1
    flame.log_name = "Flame of OOM"
    flame.update_stuff()
    return flame

func spawn_flames_corners():
    for i in range(4, 8):
        var flame = spawn_flame(directions[i])
        flame.turns_of_life = 4

func spawn_flames_edges():
    for i in range(0, 4):
        spawn_flame(directions[i])
    pass

func spawn_flames_both():
    for dir in directions:
        spawn_flame(dir)

func do_nothing():
    pass

func spew_generator():
    yield()
    while true:
        spawn_flames_edges(); yield()
        if hp < hp_max*0.25: spawn_swords_edges(); yield()
        spawn_flames_corners(); spawn_flames_edges(); yield()
        yield()
        spawn_flames_corners(); yield()
        yield()
        spawn_swords_corners(); spawn_swords_edges();  yield()
        if hp < hp_max*0.25: spawn_flames_edges(); yield()
        spawn_flames_edges(); yield()
        yield()
        yield()
        yield()

func spawn_stuff(dir, rel_pos = Vector2(0, 0)):
    var stuff = spawn_sword(dir, rel_pos)
    stuff.damage_type = "conceptual"
    stuff.get_node("Sprite").frame = 2
    stuff.log_name = "Stuff of OOM"
    stuff.update_stuff()
    stuff.turns_of_life = 4
    return stuff

func rain_generator():
    yield()
    var sword
    var life = 7
    while generator_phase%2 == 0:
        yield()
    while true:
        sword = spawn_sword(Vector2(0, 1), Vector2(-5, -3)); sword.turns_of_life = life;
        if hp < hp_max*0.5:
            sword = spawn_sword(Vector2(0, 1), Vector2(-4, -3));
            sword.turns_of_life = life;
        sword = spawn_sword(Vector2(0, 1), Vector2(-3, -3)); sword.turns_of_life = life; yield()
        yield()
        sword = spawn_sword(Vector2(0, 1), Vector2(-1, -3)); sword.turns_of_life = life;
        if hp < hp_max*0.5:
            sword = spawn_sword(Vector2(0, 1), Vector2( 0, -3));
            sword.turns_of_life = life;
        sword = spawn_sword(Vector2(0, 1), Vector2( 1, -3)); sword.turns_of_life = life; yield()
        yield()
        sword = spawn_sword(Vector2(0, 1), Vector2( 3, -3)); sword.turns_of_life = life;
        if hp < hp_max*0.5:
            sword = spawn_sword(Vector2(0, 1), Vector2( 4, -3));
            sword.turns_of_life = life;
        sword = spawn_sword(Vector2(0, 1), Vector2( 5, -3)); sword.turns_of_life = life; yield()
        yield()

func plasma_generator():
    yield()
    while generator_phase%2 == 0:
        yield()
    while true:
        spawn_stuff(Vector2(0, 0), Vector2(-1, -1))
        spawn_stuff(Vector2(0, 0), Vector2( 1, -1))
        spawn_stuff(Vector2(0, 0), Vector2(-1,  1))
        spawn_stuff(Vector2(0, 0), Vector2( 1,  1))
        for _i in range(12):
            yield()
        spawn_stuff(Vector2(0, 0), Vector2(-1,  1))
        spawn_stuff(Vector2(0, 0), Vector2( 0,  2))
        spawn_stuff(Vector2(0, 0), Vector2( 1,  1))
        spawn_stuff(Vector2(0, 0), Vector2(-2,  0))
        spawn_stuff(Vector2(0, 0), Vector2( 2,  0))
        spawn_stuff(Vector2(0, 0), Vector2(-1, -1))
        spawn_stuff(Vector2(0, 0), Vector2( 0, -2))
        spawn_stuff(Vector2(0, 0), Vector2( 1, -1))
        for _i in range(12):
            yield()
    

var generators = [spew_generator()]

var generator_phase = 0
var generator_phase_max = 24

func tick_generators():
    if len(generators) < 2 and hp < hp_max*0.75:
        generators += [rain_generator()]
    if len(generators) < 3 and hp < hp_max*0.5:
        generators += [plasma_generator()]
    for i in len(generators):
        generators[i] = generators[i].resume()
    generator_phase = (generator_phase+1)%generator_phase_max

var active = false

func in_range(a, b, my_range):
    my_range *= 16
    return abs(a.x-b.x) <= my_range.x and abs(a.y-b.y) <= my_range.y

var defense_shuffle = -1
var defense_shuffle_min = 10
var defense_shuffle_max = 20

func take_turn():
    for player in get_tree().get_nodes_in_group("Player"):
        player.label_override = false
        if in_range(self.position, player.position, Vector2(5, 3)):
            if !active:
                defense_shuffle = rng.randi_range(7, 14)
            active = true
        elif !active and in_range(self.position, player.position, Vector2(1000, 8)):
            var label = player.get_node("HUD/InteractLabel")
            label.text = "YoU are not ready...\nMOrtALs cannot behold the BacKSIDe of the OOM...\nPrepare to dIE..."
            label.visible = true
            player.label_override = true
            
    if active:
        tick_generators()
        defense_shuffle -= 1
        if defense_shuffle == 0:
            defense_shuffle = rng.randi_range(defense_shuffle_min, defense_shuffle_max)
            var temp
            if rng.randi_range(0, 1) == 0:
                temp = defense["physical"]
                defense["physical"] = defense["elemental"]
                defense["elemental"] = temp
            var dir = rng.randi_range(-1, 1)
            if dir == -1:
                temp = defense["physical"]
                defense["physical"] = defense["elemental"]
                defense["elemental"] = defense["conceptual"]
                defense["conceptual"] = temp
            elif dir == 1:
                temp = defense["physical"]
                defense["physical"] = defense["conceptual"]
                defense["conceptual"] = defense["elemental"]
                defense["elemental"] = temp
            Manager.add_to_log("Keeper of OOM's defenses have shuffled!")
        

func grant_turn():
    if hp <= 0:
        return
    take_turn()
