extends KinematicBody2D

var want_to_up = false
var want_to_down = false
var want_to_left = false
var want_to_right = false

var log_name = "Player"

func update_camera():
    $Camera2D.force_update_scroll()

var heal_turns = 20
var heal_turn = 0
var heal_turn_rate = 1
var heal_heal_rate = 2

var label_override = false

func update_labels():
    
    $HUD/MapLabel.text = Manager.current_seed
    $HUD/InteractLabel.margin_top = 0
    $HUD/InteractLabel.margin_bottom = 0
    $HUD/InteractLabel.anchor_top = 1
    $HUD/InteractLabel.anchor_bottom = 1
    if !label_override:
        $HUD/InteractLabel.visible = false
        $HUD/InteractLabel.text = ""
    
    for object in get_tree().get_nodes_in_group("Interact"):
        if object.position == position:
            var text = ""
            if object.actually_interactable():
                text += "Space to interact:\n"
            text += "\"" + object.get_name() + "\""
            $HUD/InteractLabel.text = text
            $HUD/InteractLabel.visible = object.get_name() != ""
    
    $HUD/GameLog.text = Manager.gamelog_text
    $HUD/GameLog.anchor_left = 0
    $HUD/GameLog.anchor_right = 1
    $HUD/GameLog.anchor_top = 0
    $HUD/GameLog.anchor_bottom = 1
    
    $Camera2D.force_update_scroll()

func _process(delta):
    if Manager.noinput:
        return
    
    if Manager.player_hp <= 0:
        if Input.is_action_just_pressed("ui_rest"):
            Manager.deck = []
            #Manager.hand = [null, null, null, null, null]
            Manager.player_hp = Manager.player_hp_max
            if Manager.direction == "down":
                Manager.position -= 1
                Manager.travel_down()
            else:
                Manager.position += 1
                Manager.travel_up()
        update_labels()
        return
    
    if len(get_tree().get_nodes_in_group("PlayerInputBlocker")) != 0:
        $HUD.scale = Vector2(0.0000001, 0.0000001)
        return
    $HUD.scale = Vector2(1, 1)
    
    if Input.is_action_just_pressed("ui_pause"):
        print("pausing")
        get_tree().get_root().add_child(preload("res://InventoryManager.tscn").instance())
    
    var actions = 0
    
    if Input.is_action_just_pressed("ui_down"):
        want_to_down = true
    elif !Input.is_action_pressed("ui_down"):
        want_to_down = false
    if Input.is_action_just_pressed("ui_up"):
        want_to_up = true
    elif !Input.is_action_pressed("ui_up"):
        want_to_up = false
    if Input.is_action_just_pressed("ui_right"):
        want_to_right = true
    elif !Input.is_action_pressed("ui_right"):
        want_to_right = false
    if Input.is_action_just_pressed("ui_left"):
        want_to_left = true
    elif !Input.is_action_pressed("ui_left"):
        want_to_left = false
    
    var old_position = position
    var new_position = position
    if want_to_down:
        new_position.y += 16
        want_to_down = false
        actions += 1
    elif want_to_up:
        new_position.y -= 16
        want_to_up = false
        actions += 1
    elif want_to_right:
        new_position.x += 16
        want_to_right = false
        actions += 1
    elif want_to_left:
        new_position.x -= 16
        want_to_left = false
        actions += 1
    
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
            if other.is_in_group("Enemy"):
                Manager.attack_as_player(self, other)
    
    # TODO: test for enemy/player overlap
    
    for object in get_tree().get_nodes_in_group("Interact"):
        if object.position == position and Input.is_action_just_pressed("ui_accept"):
            object.interact()
            actions += 1
    
    if actions == 0 and Input.is_action_just_pressed("ui_rest"):
        actions += 1
    
    for i in range(actions):
        if Manager.player_hp < Manager.player_hp_max:
            heal_turn += heal_turn_rate
        while heal_turn >= heal_turns:
            heal_turn -= heal_turns
            Manager.player_hp += heal_heal_rate
            if Manager.player_hp > Manager.player_hp_max:
                Manager.player_hp = Manager.player_hp_max
            Manager.add_to_log(str(Manager.player_hp) + "/" + str(Manager.player_hp_max) + "hp")
        
        for object in get_tree().get_nodes_in_group("TurnTaker"):
            if !object.is_queued_for_deletion():
                object.grant_turn()
        
    
    update_labels()
    
    
