extends Node2D

var spritesheet = preload("res://art/colored_packed.png")
var spritesheet_transparent = preload("res://art/colored_transparent_packed.png")
var index = 0
var index_x = 0
var index_y = 0
var index_cursor = Vector2(0, 0)
var select_cursor = null
var select_index = null

func _ready():
    update_cursor()
    redraw()
    update()

func swap_cards(index_a, index_b):
    if index_a == index_b:
        return
    var temp = null
    if index_a > index_b:
        temp = index_b
        index_b = index_a
        index_a = temp
    if index_a < 5 and index_b < 5:
        temp = Manager.hand[index_a]
        Manager.hand[index_a] = Manager.hand[index_b]
        Manager.hand[index_b] = temp
    elif index_a >= 5 and index_b >= 5:
        index_a -= 5
        index_b -= 5
        if index_b < len(Manager.deck):
            temp = Manager.deck[index_a]
            Manager.deck[index_a] = Manager.deck[index_b]
            Manager.deck[index_b] = temp
        else:
            temp = Manager.deck[index_a]
            Manager.deck.remove(index_a)
            Manager.deck += [temp]
    else:
        index_b -= 5
        if index_b < len(Manager.deck):
            if Manager.hand[index_a] != null:
                temp = Manager.hand[index_a]
                Manager.hand[index_a] = Manager.deck[index_b]
                Manager.deck[index_b] = temp
            else:
                Manager.hand[index_a] = Manager.deck[index_b]
                Manager.deck.remove(index_b)
        elif Manager.hand[index_a] != null:
            Manager.deck += [Manager.hand[index_a]]
            Manager.hand[index_a] = null

func update_cursor():
    index = (index%25 + 25)%25
    index_x = (index%5)*2
    index_y = floor(index/5)
    if index_y > 0:
        index_y += 1
    
    index_cursor = Vector2((index_x+2)*16, (index_y+2)*16)
            

func _process(delta):
    if Input.is_action_just_pressed("ui_pause"):
        queue_free()
    
    if Input.is_action_just_pressed("ui_left"):
        index -= 1
    if Input.is_action_just_pressed("ui_right"):
        index += 1
    if Input.is_action_just_pressed("ui_up"):
        index -= 5
    if Input.is_action_just_pressed("ui_down"):
        index += 5
    
    update_cursor()
    
    if Input.is_action_just_pressed("ui_accept"):
        if select_cursor == null:
            select_cursor = index_cursor
            select_index = index
        else:
            swap_cards(index, select_index)
            select_cursor = null
            select_index = null
    
    if Input.is_action_just_pressed("ui_delete"):
        if index < 5:
            Manager.hand[index] = null
        else:
            Manager.deck.remove(index - 5)
    
    update()

func redraw():
    var view_transform = get_canvas_transform()
    
    var start = view_transform.origin
    start /= -2
    
    var size = get_viewport_rect().size/2
    
    var center = start + get_viewport_rect().size/4
    
    var start2 = center - Vector2(7.5, 4)*16
    
    var s_x = 20*16
    var s_y = 16*16
    
    draw_texture_rect_region(spritesheet,
        Rect2(start, size),
        Rect2(16, 0, 16, 16),
        Color(1, 1, 1, 0.5))
    
    for i in range(5):
        var card = Manager.hand[i]
        if card == null:
            continue
        var card_x = (i%5)*2+3
        var local_s_x = s_x + card["value"]*16
        var local_s_y = s_y + card["suit"]*16
        draw_texture_rect_region(spritesheet_transparent,
            Rect2(start2 + Vector2(card_x, 2)*16, Vector2(16, 16)),
            Rect2(local_s_x, local_s_y, 16, 16))
    
    var i = 0
    for card in Manager.deck:
        var card_x = (i%5)*2+3
        var card_y = floor(i/5)+4
        var local_s_x = s_x + card["value"]*16
        var local_s_y = s_y + card["suit"]*16
        draw_texture_rect_region(spritesheet_transparent,
            Rect2(start2 + Vector2(card_x, card_y)*16, Vector2(16, 16)),
            Rect2(local_s_x, local_s_y, 16, 16))
        i += 1
    
    if select_cursor != null:
        draw_texture_rect_region(spritesheet_transparent,
            Rect2(start2 + select_cursor, Vector2(16, 16)),
            Rect2(24*16, 20*16, 16, 16))
    
    draw_texture_rect_region(spritesheet_transparent,
        Rect2(start2 + index_cursor, Vector2(16, 16)),
        Rect2(24*16, 21*16, 16, 16))
    
    $Labels/CardLabel.text = ""
    var card = null
    if index < 5:
        card = Manager.hand[index]
    elif index-5 < len(Manager.deck):
        card = Manager.deck[index-5]
    if card != null:
        var types = {"physical":"phy", "elemental":"ele", "conceptual":"con"}
        var text = "%s (Lv%s)" % [card["name"], card["level"]]
        #text += "Stats: "
        text += "\ndmg: %s-%s %s, " % [card["damage_base"], card["damage_base"]+card["damage_spread"], card["damage_type"]]
        if card["defense"] > 0:
            text += "def: %s %s" % [card["defense"], card["defense_type"]]
        else:
            text += "def: 0"
        text += "\ndurability: %s, exp: %s/%s" % [card["durability"], card["exp"], card["exp_next"]]
        $Labels/CardLabel.text = text
    
    var base_size := Vector2(960, 720)/2
    var base_coords_1 := Vector2(48, 80)
    var base_coords_2 := Vector2(48, 144)
    $Labels/StaticLabel.rect_position = base_coords_1 - base_size/2 + size
    $Labels/StaticLabel2.rect_position = base_coords_2 - base_size/2 + size
    
    
    

func _draw():
    redraw()
