mod player;
mod game;
mod player_turn;

contract GuessingGame {
    use dep::aztec::prelude::{
        AztecAddress, NoteGetterOptions,
        Map, PublicMutable, PrivateSet, SharedImmutable
    };
    use dep::address_note::address_note::{AddressNote, ADDRESS_NOTE_LEN};
    use dep::aztec::oracle::debug_log::{debug_log, debug_log_format};
    use crate::player::Player;
    use crate::player_turn::PlayerTurn;
    use crate::game::Game;

    struct Storage {
        game_master: SharedImmutable<AztecAddress>,
        lobby: PrivateSet<AddressNote>,
        in_play: PrivateSet<Player>,
        games: Map<Field, PublicMutable<Game>>,
    }

    #[aztec(public)]
    #[aztec(initializer)]
    fn constructor(gm: AztecAddress) {
        storage.game_master.initialize(gm)
    }

    #[aztec(private)]
    fn register(address: AztecAddress, secret: Field) {
        let gm = storage.game_master.read_private();
        debug_log("registering player");
        debug_log_format("encrypting to {0}", [gm.to_field()]);
        let mut address_note = AddressNote::new(address, gm);
        storage.lobby.insert(&mut address_note, true);
        let mut player = Player::new(address, secret);
        storage.in_play.insert(&mut player, true);
    }

    #[aztec(private)]
    fn pair() {
        let options = NoteGetterOptions::new();
        debug_log("getting players");
        let mut pair = storage.lobby.get_notes(options);
        debug_log("removing players from lobby");
        // storage.lobby.remove(pair[0].unwrap_unchecked());
        // storage.lobby.remove(pair[1].unwrap_unchecked());

        // let mut player1 = pair[0].unwrap_unchecked().owner;
        // let mut player2 = pair[1].unwrap_unchecked().owner;

        // debug_log("creating new turn");
        // let turn = PlayerTurn::new(player1, 0);
        // storage.games.at(0).write(Game::new([player1, player2], turn));
    }

    #[aztec(private)]
    fn turn(game_id: Field, guess: Field) {
        let game = storage.games.at(game_id).read();
        let options = NoteGetterOptions::new().set_limit(1);
        let me = storage.in_play.get_notes(options)[0].unwrap_unchecked();
        let didMatch = game.reveal(me);
        if (didMatch) {
            storage.in_play.remove(me);
        }

        let opponent = game.get_opponent(context.msg_sender());
        let turn = PlayerTurn::new(opponent, guess);

        storage.games.at(game_id).write(Game::new(game.players, turn));
    }
}
