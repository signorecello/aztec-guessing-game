use dep::aztec::prelude::{AztecAddress, NoteHeader, NoteInterface, PrivateContext, emit_encrypted_log, Map, PrivateImmutable};
use dep::value_note::value_note::{ValueNote, VALUE_NOTE_LEN};
use dep::aztec::protocol_types::{traits::{Serialize, Deserialize}};

use dep::aztec::{
    context::Context, hash::pedersen_hash, protocol_types::traits::Empty,
    oracle::{nullifier_key::get_nullifier_secret_key, get_public_key::get_public_key},
    note::{utils::compute_note_hash_for_consumption}
};

use crate::player::Player;
use crate::player_turn::{PlayerTurn, PLAYER_TURN_NOTE_LENGTH};

struct Game {
    players: [AztecAddress; 2],
    turn: PlayerTurn,
}

impl Game {
    pub fn new(players: [AztecAddress; 2], turn: PlayerTurn) -> Self {
        Game { players, turn }
    }

    pub fn get_opponent(self, player: AztecAddress) -> AztecAddress {
        if player == self.players[0] {
            self.players[1]
        } else {
            self.players[0]
        }
    }

    pub fn reveal(self, player: Player) -> bool {
        assert(self.turn.recipient == player.owner, "It is not your turn");
        self.turn.guess == player.secret
    }
}

global GAME_NOTE_LENGTH: Field = 2 + PLAYER_TURN_NOTE_LENGTH;

impl Serialize<GAME_NOTE_LENGTH> for Game {
    fn serialize(game: Game) -> [Field; GAME_NOTE_LENGTH] {
        let turn : [Field] = [];
        
        let mut turn = [].push_back(game.players[0].to_field());
        turn = turn.push_back(game.players[1].to_field());

        for i in 0..game.turn.serialize_content().len() as u32 {
            turn = turn.push_back(game.turn.serialize_content()[i]);
        };

        let mut turn_arr : [Field; GAME_NOTE_LENGTH] = [0; GAME_NOTE_LENGTH];

        for i in 0..GAME_NOTE_LENGTH as u32 {
            turn_arr[i] = turn[i];
        }
        turn_arr
    }
}

impl Deserialize<GAME_NOTE_LENGTH> for Game {
    fn deserialize(note: [Field; GAME_NOTE_LENGTH]) -> Game {
        Game {
            players: [
                AztecAddress::from_field(note[0]),
                AztecAddress::from_field(note[1]),
            ],
            turn: PlayerTurn::deserialize_content([note[2], note[3], note[4]]),
        }
    }
}
