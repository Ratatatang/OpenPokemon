adding moves is relativly easy with the framework I built

here's a sample move:

"tackle":{
            "DisplayName" : "Tackle",
            "Type": "Normal",
            "Power": 40,
            "PP": 35,
            "Accuracy": 100,
            "Category": "Physical",
            "Flags": [],
            "Target": "AdjacentFoe",
            "Priority": 0,
            "SpecialEffect": null,
            "StatChanges": {},
},

So let me break it down

DisplayName is what is shown on buttons and in the text

Type is the base type for the move. for moves like flying press, you want fighting as
that is what is displayed and used for all intensive purposes

Power is the base power for the move

PP is the power points, the number of times you can use a move

Accuracy is a little strange. Its the percent value, but if a move cannot miss, even 
with accuracy debuffs, it needs to be 101

Category is the category, (Physical, Special, Status) the stats the move uses in the 
damage calculations

Flags is special flags that things like abilities use, (eg: "Powder" for powder moves) 
all of the valid flags are at the bottom of the file

Target is the valid targets for a move. AdjacentFoe is any foe, AllAdjacentFoe is for 
moves like snarl that hit all foes, All is for moves like earthquake that hit everyone 
minus the user, Any is for moves that can hit any one poekmon, and Self is for moves that
hit only the user.

Priority is for priority moves like quick attack, its the amount they will get pushed forward.
as a better explanation, all the highest priority moves calculate speed, then the lower moves, 
then lowest moves

SpecialEffect is for any extra special effects. you can pretty much ignore that


Now for secondary effects.

"StatChanges": {
                "100":  {
                    "Target": "Victim",
                    "Attack": -1
                },
                "50": {
                    "Target": "User",
                    "StatusEffect": "Confusion"
                },
		"25": {
                    "Target": "User",
                    "RecoilPercent": 0.25
                }
            }

the structure for stat changes is immediatly in statchanges you have the percent chance for that 
group of changes.

then in that, you have the target, so victim for the target of the move, and user for the user. 
note that if the target is self, the stat changes target is victim as you have targeted yourself

the victim is followed by the effect in the same dictionary, below the target. you can have multiple
effects in the same percentage, but they will all happen if the chance is met.

for status effects, you have "StatusEffect": Effect
for Recoil, you have the word "RecoilPercent": percent
for healing, you have "HealingPercent": percent
for stat changes, you need "Stat": stages (in this case Stat is the stat you're changing, not the word stat)
