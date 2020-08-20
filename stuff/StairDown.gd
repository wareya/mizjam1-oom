extends Area2D

func actually_interactable():
    true

func get_name():
    return "Stairs Down"

func interact():
    Manager.travel_down()
