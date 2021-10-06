%builtins output range_check

from starkware.cairo.common.math_cmp import is_le
from starkware.cairo.common.math import assert_nn
from starkware.cairo.common.serialize import serialize_word

struct Character:
    member health: felt
    member damage: felt
    member attackRecoverTime: felt
    member healthPerTurn: felt
end

func simulateCombat{ range_check_ptr }(
        player1: Character,
        player2: Character,
        currentHealths: (felt, felt),
        lastAttacks: (felt, felt),
        currentRound: felt,
        nCombatRounds: felt
    ) -> (
        simNextHealths: (felt, felt),
        simNextLastAttacks: (felt, felt)
    ):
    
    alloc_locals
    local nextHealths: (felt, felt)
    local nextLastAttacks: (felt, felt)
    local ZERO_HP_POINT = 1000
    
    if lastAttacks[1] == player2.attackRecoverTime:
        tempvar afterDamage = currentHealths[0] - player2.damage
        nextHealths[0] = afterDamage + player1.healthPerTurn
        nextLastAttacks[1] = 0
    else:
        nextHealths[0] = currentHealths[0] + player1.healthPerTurn
        nextLastAttacks[1] = lastAttacks[1] + 1
    end
    
    if lastAttacks[0] == player1.attackRecoverTime:
        tempvar afterDamage = currentHealths[1] - player1.damage
        nextHealths[1] = afterDamage + player2.healthPerTurn
        nextLastAttacks[0] = 0
    else:
        nextHealths[1] = currentHealths[1] + player2.healthPerTurn
        nextLastAttacks[0] = lastAttacks[0] + 1
    end
    
    if currentRound == nCombatRounds:
        return(nextHealths, nextLastAttacks)
    else:
        # if the combat has not ended, nobody can be dead
        assert_nn(nextHealths[0] - ZERO_HP_POINT)
        assert_nn(nextHealths[1] - ZERO_HP_POINT)
    end
    let (simulatedEndHealths, simulatedLastAttacks) = simulateCombat(
        player1 = player1,
        player2 = player2,
        currentHealths = nextHealths,
        lastAttacks = nextLastAttacks,
        currentRound = currentRound + 1,
        nCombatRounds = nCombatRounds
    )
    
    return(
        simNextHealths = simulatedEndHealths, 
        simNextLastAttacks = simulatedLastAttacks
    )
end

func main{ output_ptr: felt*, range_check_ptr }() -> ():
    alloc_locals

    local range_check_ptr = range_check_ptr
    local pl1: Character*
    local pl2: Character*
    local endHealths: felt*
    local nCombatRounds: felt
    %{
        log = program_input['log']
        dat_endHealths = log['endHealths']
        dat_nCombatRounds = log['nCombatRounds']
        
        ids.pl1 = pl1 = segments.add()
        for i, val in enumerate(program_input['player1']['stats']):
            memory[pl1 + i] = val
            
        ids.pl2 = pl2 = segments.add()
        for i, val in enumerate(program_input['player2']['stats']):
            memory[pl2 + i] = val

        ids.endHealths = endHealths = segments.add()
        for i, val in enumerate(dat_endHealths):
            memory[endHealths + i] = val

        ids.nCombatRounds = dat_nCombatRounds

        assert len(program_input['player1']['stats']) == 4
        assert len(program_input['player2']['stats']) == 4
        assert len(dat_endHealths) == 2
    %}
    
    local player1: Character = pl1[0]
    local player2: Character = pl2[0]
    
    local currentHealths: (felt, felt) = (player1.health, player2.health)
    local lastAttacks: (felt, felt) = (0, 0)
    
    let (simulatedEndHealths, lastSimulatedAttacks) = simulateCombat(
        player1 = player1,
        player2 = player2,
        currentHealths = currentHealths,
        lastAttacks = lastAttacks,
        currentRound = 0,
        nCombatRounds = nCombatRounds
    )
    
    # Check that the healths will match what was claimed
    assert simulatedEndHealths[0] = endHealths[0]
    assert simulatedEndHealths[1] = endHealths[1]

    # Return the program input and output
    serialize_word(player1.health)
    serialize_word(player1.damage)
    serialize_word(player1.attackRecoverTime)
    serialize_word(player1.healthPerTurn)
    
    serialize_word(player2.health)
    serialize_word(player2.damage)
    serialize_word(player2.attackRecoverTime)
    serialize_word(player2.healthPerTurn)
    
    serialize_word(simulatedEndHealths[0])
    serialize_word(simulatedEndHealths[1])
    
    return ()
end
