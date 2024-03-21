mod player;
mod game;
mod player_turn;

contract GuessingGame {
    use dep::aztec::prelude::{
        AztecAddress, FunctionSelector, NoteHeader, NoteInterface, NoteGetterOptions, PrivateContext,
        Map, PublicMutable, PrivateImmutable, PrivateMutable, PrivateSet, PublicImmutable
    };
    use dep::value_note::value_note::{ValueNote, VALUE_NOTE_LEN};
    use dep::address_note::address_note::{AddressNote, ADDRESS_NOTE_LEN};
    use dep::aztec::context::Context;
    use dep::aztec::oracle::debug_log::debug_log;
    use crate::player::Player;
    use crate::player_turn::PlayerTurn;
    use crate::game::Game;

    struct Storage {
        game_master: PublicImmutable<AztecAddress>,
        lobby: PrivateSet<AddressNote>,
        in_play: PrivateSet<Player>,
        games: Map<Field, PublicMutable<Game>>,
    }

    #[aztec(public)]
    #[aztec(initializer)]
    fn constructor(gm: AztecAddress) {
        debug_log("initializing contract");
        storage.game_master.initialize(gm)
    }

    #[aztec(private)]
    fn register(player: AztecAddress, secret: Field) {
        let gm = storage.game_master.read();
        let mut p = AddressNote::new(player, gm);
        debug_log("inserting player");
        storage.lobby.insert(&mut p, true);
        let mut player = Player::new(player, secret);
        storage.in_play.insert(&mut player, true);
    }

    #[aztec(private)]
    fn pair() {
        let options = NoteGetterOptions::new().set_limit(2);
        let mut pair = storage.lobby.get_notes(options);
        storage.lobby.remove(pair[0].unwrap_unchecked());
        storage.lobby.remove(pair[1].unwrap_unchecked());

        let mut player1 = pair[0].unwrap_unchecked().owner;
        let mut player2 = pair[1].unwrap_unchecked().owner;

        let turn = PlayerTurn::new(player1, 0);
        storage.games.at(0).write(Game::new([player1, player2], turn));
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
