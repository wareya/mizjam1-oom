extends Area2D

func actually_interactable():
    true

func get_name():
    return "Stairs Up"

func interact():
    Manager.travel_up()
