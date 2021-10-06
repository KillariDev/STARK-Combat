from dataclasses import dataclass
import json

@dataclass
class Character:
    health: int
    damage: int
    attackRecoverTime: int
    healthPerTurn: int

def simulateFight(character1, character2):
    currentTick = 0
    lastAttack = [0, 0]
    
    while 1:
        # Health regeneration
        character1.health += character1.healthPerTurn
        character2.health += character2.healthPerTurn
        
        # Player 1 hits player 2
        if (lastAttack[0] == character1.attackRecoverTime):
            character2.health -= character1.damage
            lastAttack[0] = 0
        else:
            lastAttack[0] = lastAttack[0] + 1
            
        # Player 2 hits player 1
        if (lastAttack[1] == character2.attackRecoverTime):
            character1.health -= character2.damage
            lastAttack[1] = 0
        else:
            lastAttack[1] = lastAttack[1] + 1
        
        if character1.health <= 0 or character2.health <= 0:
            # one of the characters have died
            break
        currentTick = currentTick + 1
        
    return {
        'endHealths': [character1.health, character2.health],
        'nCombatRounds': currentTick
    }
        
player1 = Character(1000, 48, 80, 3) # Ogre
player2 = Character(240, 20, 2, 0) # Hero

ZERO_HP_POINT = 1000

assert player1.damage < ZERO_HP_POINT
assert player2.damage < ZERO_HP_POINT

data = {
    'player1': {
        'stats': [ZERO_HP_POINT + player1.health, player1.damage, player1.attackRecoverTime, player1.healthPerTurn]
    },
    'player2': {
        'stats': [ZERO_HP_POINT + player2.health, player2.damage, player2.attackRecoverTime, player2.healthPerTurn]
    },
    'log': simulateFight(player1, player2)
}

data['log']['endHealths'] = [h + ZERO_HP_POINT for h in data['log']['endHealths']]

with open('combat-input.json', 'w') as outfile:
    json.dump(data, outfile)
