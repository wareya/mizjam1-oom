extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var beat_boss = false
var noinput = false

var rng_counter : int = 0
func unique_randomize_rng(rng : RandomNumberGenerator):
    rng_counter += 1
    rng.set_seed(hash(str(OS.get_ticks_msec()) + "_" + str(rng_counter)))

func random_choose(rng, array : Array):
    return array[rng.randi_range(0, len(array)-1)]

func level_up_card(card, _seed = null):
    card["exp"] = max(card["exp"], card["exp_next"])
    card["exp_next"] = ceil(card["exp_next"] * 1.5)
    card["level"] += 1
    
    var rng : RandomNumberGenerator = RandomNumberGenerator.new()
    if _seed == null:
        unique_randomize_rng(rng)
    else:
        rng.set_seed(hash(_seed))
    if card["damage_growth"] > 0:
        card["damage_base"] += ceil(card["damage_growth"] * rng.randf_range(0.5, 1.5) * sqrt(card["level"]*2))
    if card["defense_growth"] > 0:
        card["defense"] += ceil(card["defense_growth"] * rng.randf_range(0.5, 1.5) * sqrt(card["level"]*2))
    
    if rng.randi_range(0, 100) < card["level"]:
        card["quality"] += round(sqrt(card["level"]))
    
    card["durability"] += 10
    if card["durability"] > 20:
        card["durability"] = 20


func generate_card(name : String, base_level : int):
    var card = {}
    var rng : RandomNumberGenerator = RandomNumberGenerator.new()
    rng.set_seed(hash(name + "CARDSTATS"))
    card["name"] = name
    card["damage_type"] = random_choose(rng, ["physical", "elemental", "conceptual"])
    card["damage_base"] = rng.randi_range(1, 4) + rng.randi_range(0, 2)
    card["damage_spread"] = rng.randi_range(0, 5)
    card["defense_type"] = random_choose(rng, ["physical", "elemental", "conceptual"])
    card["defense"] = rng.randi_range(0, 5)
    card["level"] = 1
    card["exp"] = 0
    card["exp_next"] = rng.randi_range(20, 40)
    
    card["quality"] = rng.randi_range(0, 50)
    
    card["damage_growth"] = rng.randi_range(1, 3)
    card["defense_growth"] = rng.randi_range(1, 3)
    var nogrowth_type = rng.randi_range(0, 6)
    if nogrowth_type == 0:
        card["damage_growth"] = 0
    elif nogrowth_type == 1:
        card["defense_growth"] = 0
    
    card["suit"] = rng.randi_range(0, 3)
    card["value"] = rng.randi_range(0, 11)
    
    unique_randomize_rng(rng)
    card["quality"] += rng.randi_range(0, 25)
    if rng.randi_range(0, 1) == 0:
        card["quality"] += rng.randi_range(0, 25)
    if rng.randi_range(0, 1) == 0:
        card["exp"] += rng.randi_range(1, 5)
    if rng.randi_range(0, 2) == 0:
        card["exp"] += rng.randi_range(3, 7)
    
    if card["quality"] >= 75:
        card["level"] += random_choose(rng, [1, 1, 1, 2])
        card["damage_base"] += rng.randi_range(3, 6)
        card["damage_spread"] -= rng.randi_range(0, 3)
        if card["damage_spread"] < 0:
            card["damage_spread"] = 0
        card["damage_growth"] += 1
        card["defense_growth"] += 1
    
    card["durability"] = 20
    card["cooldown"] = 0
    
    while card["level"] < base_level:
        level_up_card(card)
    
    print("generated card:")
    print(card)
    
    return card



var seedDictA = [
"Bright", "Candid", "Honorable", "Dark", "Cursed", "Evil", "Haunted",
"Great", "Exiled", "Rotten", "Corrupt", "Ancient", "Forlorn", "Lost",
"Forgotten", "Spoiled", "Failed", "Late", "Untouched", "Uncharted",
"Very", "Hardly", "Extremely", "Kind of", "Plain", "Blurry", "Hidden",
"Vast", "Enchanted", "Dearest", "Historical", "Magnificent", "Destitute"
]

var seedDictB = [
"Oceanic", "Endless", "Pure", "Rural", "Rustic", "Utopian", "Heroic",
"Long", "Distant", "Frozen", "Sweltering", "Crested", "Bright", "Gone",
"Wandering", "Epic", "Silver", "Snowy", "Hilly", "Torched", "Flooded",
"Loud", "Anchored", "Virtual", "Tortured", "Imprisoned", "Trapped", "Crushed",
"Placid", "Cheeky", "Perky", "Happy", "Depressed", "Infatuated", "Infuriated"
]

var seedDictC = [
"Temple", "Field", "Forest", "Meadow", "Promised Land", "Hell",
"Purgatory", "Dungeon", "Haze", "Village", "Shipwreck", "Islands",
"Caves", "Vista", "Fjords", "Waters", "Crypt", "Wanderwood", "Paradise",
"Barrow", "Prison", "Volcano", "Planet", "Dungeon", "Expanse", "Desert",
"Bastion", "Graveyard", "Town Square", "Ruins", "Cathedral", "Jungle"
]

var gamelog = []
var complete_gamelog = []
var gamelog_text : String = ""
func add_to_log(text : String):
    complete_gamelog += [text]
    gamelog += [text]
    while len(gamelog) > 5:
        gamelog.remove(0)
    gamelog_text = ""
    for line in gamelog:
        gamelog_text += line + "\n"
    print(text)
    

func generate_level_name(rng):
    var my_seed = ""
    my_seed += random_choose(rng, seedDictA)
    my_seed += " "
    my_seed += random_choose(rng, seedDictB)
    my_seed += " "
    my_seed += random_choose(rng, seedDictC)
    return my_seed


var current_seed = "Exiled Lonely Village"
var rng = RandomNumberGenerator.new()

var direction = "down" 
var stack = [current_seed]
var position = 0

var hand = [null, null, null, null, null]
var deck = []
func add_to_deck(text):
    var card_level = ceil((position+1.0)/3.0)
    print(card_level)
    var min_card_level = 1
    if position == 17:
        min_card_level = 2
    if position == 18:
        min_card_level = 3
        card_level += 1
    if position == 19:
        min_card_level = 4
        card_level += 2
    if card_level > 1:
        card_level = rng.randi_range(min_card_level, card_level)
    var new_card = generate_card(text, card_level)
    while len(deck) >= 20:
        var r = rng.randi_range(0, len(deck)-1)
        var removed_card = deck[r]
        deck.remove(r)
        add_to_log("Removed " + removed_card["name"] + " (Lv" + str(removed_card["level"]) + ") from deck")
    deck += [new_card]
    add_to_log("Added " + new_card["name"] + " (Lv" + str(new_card["level"]) + ") to deck")



var player : AudioStreamPlayer = AudioStreamPlayer.new()
func _ready():
    player.stream = preload("res://audio/pathfinder.ogg")
    player.stream.loop_offset = 13.9636121115
    print(player.stream.loop_offset)
    player.volume_db = -12
    player.play()
    get_tree().get_root().call_deferred("add_child", player)
    pass # Replace with function body.


var player_hp_max = 25
var player_hp = player_hp_max
var stardust = 0

func attack(attacker : Node, defender : Node):
    if defender.log_name == "Player":
        if player_hp <= 0:
            return
        var dmg = attacker.damage_function()
        
        var defense = 0
        
        var best_card = null
        for card in hand:
            if card == null or card["durability"] <= 0 or card["defense_type"] != attacker.damage_type:
                continue
            if best_card == null or card["defense"] >= best_card["defense"]:
                best_card = card
        if best_card != null:
            defense = best_card["defense"]
            if rng.randi_range(0, 99) >= best_card["quality"]:
                best_card["durability"] -= 1
            if best_card["durability"] <= 0:
                add_to_log("%s(lv%s) broke" % [best_card["name"], best_card["level"]])
        
        dmg -= defense
        if dmg < 0:
            dmg = 0
        
        player_hp -= dmg
        if player_hp < 0:
            player_hp = 0
        #add_to_log(attacker.log_name + " attacks " + defender.log_name + " for " + str(dmg) + " damage")
        if attacker.level > 0:
            add_to_log("%s(lv%s) attacks %s for %sdmg" % [attacker.log_name, attacker.level, defender.log_name, dmg])
        else:
            add_to_log("%s attacks %s for %sdmg" % [attacker.log_name, defender.log_name, dmg])
        #add_to_log(str(player_hp) + "/" + str(player_hp_max) + "hp")
        add_to_log("%s/%shp" % [player_hp, player_hp_max])
        if player_hp <= 0:
            add_to_log(defender.log_name + " has died")
            add_to_log("Press R to respawn")
            add_to_log("You will lose your deck, but not your hand")
            defender.visible = false
    pass

func attack_as_player(attacker : Node, defender : Node):
    var used_card = null
    var usable_cards = 0
    for card in hand:
        if card != null and card["durability"] > 0:
            usable_cards += 1
    if usable_cards == 0:
        var dmg = 1
        if defender.log_name == "Keeper of OOM":
            dmg = 5
        defender.hp -= dmg
        if defender.hp < 0:
            defender.hp = 0
        add_to_log("%s attacks %s(lv%s) barehanded for %sdmg" % [attacker.log_name, defender.log_name, defender.level, dmg])
        if len(deck) > 0:
            if hand == [null, null, null, null, null]:
                add_to_log("Your hand is empty, but your deck is not.")
                add_to_log("Press Q to open the deck screen.")
            else:
                add_to_log("Your hand is full of unusable cards (0 durability).")
                add_to_log("Press Q to open the deck screen.")
    else:
        var card = random_choose(rng, hand)
        while card == null or card["durability"] <= 0:
            card = random_choose(rng, hand)
        
        var spread = card["damage_spread"]
        var dmg = card["damage_base"]
        if spread > 0:
            dmg += rng.randi_range(0, spread)
        
        dmg -= defender.defense[card["damage_type"]]
        if dmg < 1 and dmg > -10:
            dmg = 1
        elif dmg < 0:
            dmg = 0
        
        defender.hp -= dmg
        if defender.hp < 0:
            defender.hp = 0
        
        add_to_log("%s attacks %s(lv%s) with %s(lv%s) for %sdmg" % [attacker.log_name, defender.log_name, defender.level, card["name"], card["level"], dmg])
        
        if rng.randi_range(0, 99) >= card["quality"]:
            card["durability"] -= 1
            if card["durability"] <= 0:
                add_to_log("%s(lv%s) broke" % [card["name"], card["level"]])
        used_card = card
    if defender.hp <= 0:
        if defender.log_name == "Keeper of OOM":
            beat_boss = true
        if used_card != null:
            used_card["exp"] += defender.exp_grant
            while used_card["exp"] >= used_card["exp_next"]:
                level_up_card(used_card)
        add_to_log(defender.log_name + " has died")
        defender.queue_free()

func travel_up():
    for object in get_tree().get_nodes_in_group("TurnTaker"):
        object.queue_free()
    
    direction = "up"
    position -= 1
    while position >= len(stack):
        unique_randomize_rng(rng)
        current_seed = generate_level_name(rng)
        stack += [current_seed]
    current_seed = stack[position]
    if position < 1:
        add_to_log("Returned to Town")
        player_hp = player_hp_max
        get_tree().change_scene_to(preload("res://Town.tscn"))
    else:
        add_to_log("Entered Floor " + str(position) + ": " + current_seed)
        get_tree().change_scene_to(preload("res://Levelgen.tscn"))

func travel_down():
    for object in get_tree().get_nodes_in_group("TurnTaker"):
        object.queue_free()
    
    direction = "down"
    position += 1
    
    if position == 20:
        current_seed = "Evergreen Underground Meadow"
        add_to_log("Entered Floor " + str(position) + ": " + current_seed)
        get_tree().change_scene_to(preload("res://BossRoom.tscn"))
        return
    
    if position == 21:
        current_seed = "Neverending Empty Void"
        add_to_log("Entered Floor " + str(position) + ": " + current_seed)
        get_tree().change_scene_to(preload("res://OOM.tscn"))
        return
    
    while position >= len(stack):
        unique_randomize_rng(rng)
        current_seed = generate_level_name(rng)
        stack += [current_seed]
    current_seed = stack[position]
    
    add_to_log("Entered Floor " + str(position) + ": " + current_seed)
    
    get_tree().change_scene_to(preload("res://Levelgen.tscn"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
