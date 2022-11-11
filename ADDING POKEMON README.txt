If you read the adding moves document, you will be happy to know that pokemon are much easier to do.
 

the structure is this 

"Bulbasaur" : {
            "ID": "001",
            "Types": ["Grass", "Poison"],
            "Moves": {
                "1": ["tackle", "growl"],
                "3": ["vine_whip"],
                "6": ["growth"],
                "9": ["leech_seed"],
                "12": ["razor_leaf"],
                "15": ["poison_powder"]
            },
	    BaseStats": {
                "hp": 45,
                "atk": 49,
                "def": 49,
                "spAtk": 65,
                "spDef": 65,
                "speed": 45
                },
            "EvoLv": 16,
            "EvoPokemon": "Ivysaur"
        },
You start with the name, note that it should be capatalized, as this is the displayed name

next, inside the name, is ID, thats the ID of the pokemon for the dex as well as what should
be the name of the sprite sheet file

Type is a list, of the 1-2 types that pokemon has.

I'll skip over moves for now

Base stats is just the stats, without IV's or EV's, you need every stat filled in as "stat": value

EvoLv is the level they start to try to evolve

EvoPokemon is the name of the pokemon they evolve into


Ok, now to adress moves.

so inside moves, each key is the level they get those moves available. inside that key, you put a list
of all the new moves they get at that lv, not by displayName, but by the id name in the movedex

note I say new moves, as you don't need to also put previously learned moves or egg moves. just level up moves
