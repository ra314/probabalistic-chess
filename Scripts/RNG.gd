extends Node

var rng := RandomNumberGenerator.new()

func init():
	rng.randomize()

func select_random(array):
	return array[index_random(array)]

func index_random(array):
	return rng.randi() % len(array)
