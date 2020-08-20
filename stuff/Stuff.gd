extends Node2D

func actually_interactable():
    true

var possibilities = [
"Stabby Stabber",
"Element of Life",
"Pizza",
"Piece of Lint",
"Stabby Stabber",
"Boxxy",
"American Emo",
"Broken Candy Heart",
"Keyboard",
"Juicebox",
"Pen Fifteen",
"Broken CPU",
"Christmas Cake",
"Swirly Straw",
"Broken Charger",
"Xylohammer",
"Lost Key",
"Biscuit",
"Ultima",
]

var text : String = ""

func _ready():
    text = possibilities[Manager.rng.randi_range(0, len(possibilities)-1)]

func get_name():
    return text

func interact():
    Manager.add_to_deck(text)
    if Manager.hand == [null, null, null, null, null]:
        Manager.add_to_log("Press Q to move it to your hand.")
    queue_free()
