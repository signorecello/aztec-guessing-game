use dep::aztec::prelude::{AztecAddress, NoteHeader, NoteInterface, PrivateContext, emit_encrypted_log};
use dep::value_note::value_note::{ValueNote, VALUE_NOTE_LEN};

use dep::aztec::{
    context::Context, hash::pedersen_hash, protocol_types::traits::Empty,
    oracle::{rand::rand, nullifier_key::get_nullifier_secret_key, get_public_key::get_public_key},
    note::{utils::compute_note_hash_for_consumption}
};

global PLAYER_TURN_NOTE_LENGTH: Field = 3;

struct PlayerTurn {
    recipient: AztecAddress,
    guess: Field,
    randomness: Field,
    header: NoteHeader,
}

impl PlayerTurn {
    pub fn new(recipient: AztecAddress, guess: Field) -> Self {
        let randomness = rand();
        let header = NoteHeader::empty();
        PlayerTurn { recipient, guess, randomness, header }
    }

    pub fn serialize(self) -> [Field; PLAYER_TURN_NOTE_LENGTH] {
        [self.recipient.to_field(), self.guess, self.randomness]
    }
}

impl NoteInterface<PLAYER_TURN_NOTE_LENGTH> for PlayerTurn {
    fn serialize_content(self) -> [Field; PLAYER_TURN_NOTE_LENGTH] {
        [self.recipient.to_field(), self.guess, self.randomness]
    }

    fn deserialize_content(serialized_note: [Field; PLAYER_TURN_NOTE_LENGTH]) -> Self {
        PlayerTurn {
            recipient: AztecAddress::from_field(serialized_note[0]),
            guess: serialized_note[1],
            randomness: serialized_note[2],
            header: NoteHeader::empty(),
        }
    }

    fn compute_note_content_hash(self) -> Field {
        pedersen_hash(self.serialize_content(), 0)
    }

    fn compute_nullifier(self, context: &mut PrivateContext) -> Field {
        let note_hash_for_nullify = compute_note_hash_for_consumption(self);
        let secret = context.request_nullifier_secret_key(self.recipient);
        pedersen_hash([
            note_hash_for_nullify,
            secret.high,
            secret.low,
        ],0)
    }

    fn compute_nullifier_without_context(self) -> Field {
        let note_hash_for_nullify = compute_note_hash_for_consumption(self);
        let secret = get_nullifier_secret_key(self.recipient);
        pedersen_hash([
            note_hash_for_nullify,
            secret.high,
            secret.low,
        ],0)
    }

    fn set_header(&mut self, header: NoteHeader) {
        self.header = header;
    }

    fn get_header(note: PlayerTurn) -> NoteHeader {
        note.header
    }

    // Broadcasts the note to the opponent
    fn broadcast(self, context: &mut PrivateContext, slot: Field) {
        let encryption_pub_key = get_public_key(self.recipient);
        emit_encrypted_log(
            context,
            (*context).this_address(),
            slot,
            Self::get_note_type_id(),
            encryption_pub_key,
            self.serialize_content(),
        );
    }

    fn get_note_type_id() -> Field {
        // TODO(#4519): autogenerate
        // python -c "print(int(''.join(str(ord(c)) for c in 'CardNote')))"
        679711410078111116101
    }
}
