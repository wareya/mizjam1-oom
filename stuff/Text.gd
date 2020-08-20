extends Area2D

func actually_interactable():
    false

export(String, MULTILINE) var text : String = ""

func get_name():
    return text

func interact():
    pass
