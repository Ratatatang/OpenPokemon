extends Node2D

var loadedPokemon
var moves

func loadPokemon():
	loadedPokemon = pokemon.new("Bulbasaur", 5)
	moves = loadedPokemon.moves.duplicate()
	
	for i in moves.keys():
		if(moves.get(i) == ""):
			moves.erase(i)

func getMoves():
	return moves
