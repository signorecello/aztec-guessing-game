import {
  createPXEClient,
  PXE,
  GrumpkinScalar,
  AccountManager,
  AccountWallet,
  AztecAddress,
  waitForPXE,
} from '@aztec/aztec.js';
import { SingleKeyAccountContract } from '@aztec/accounts/single_key';
import { derivePublicKey } from '@aztec/circuits.js';
import { GuessingGameContract } from '../artifacts/GuessingGame';

describe('Account Tests', () => {
  const pxeURL = process.env.PXE_URL || 'http://localhost:8080';
  let pxe: PXE;
  let account: AccountManager;
  let wallets: { [key: string]: AccountWallet | null } = {
    gameMaster: null,
    player1: null,
    player2: null,
  };

  const privateKeys = {
    gameMaster: GrumpkinScalar.random(),
    player1: GrumpkinScalar.random(),
    player2: GrumpkinScalar.random(),
  };
  let game: GuessingGameContract;

  beforeAll(async () => {
    pxe = createPXEClient(pxeURL);
    waitForPXE(pxe);
    const { chainId } = await pxe.getNodeInfo();
    expect(chainId).toBe(31337);

    const accountContract = new SingleKeyAccountContract(privateKeys.gameMaster);
    account = new AccountManager(pxe, privateKeys.gameMaster, accountContract);
    wallets.gameMaster = await account.register();
  });

  test('Can deploy the game', async () => {
    game = await GuessingGameContract.deploy(wallets.gameMaster, wallets.gameMaster.getCompleteAddress())
      .send()
      .deployed();
    expect(game.methods).toHaveProperty('register');
  }, 20000);

  test('Can register a player', async () => {
    const accountContract = new SingleKeyAccountContract(privateKeys.player1);
    const player = new AccountManager(pxe, privateKeys.player1, accountContract);
    wallets.player1 = await player.register();

    const registerReceipt = await game
      .withWallet(wallets.player1)
      .methods.register(wallets.player1.getCompleteAddress(), 1)
      .send()
      .wait();
    expect(registerReceipt.status).toBe('mined');
  }, 20000);

  test('Can register a second player', async () => {
    const accountContract = new SingleKeyAccountContract(privateKeys.player2);
    const player = new AccountManager(pxe, privateKeys.player2, accountContract);
    wallets.player2 = await player.register();

    const registerReceipt = await game
      .withWallet(wallets.player2)
      .methods.register(wallets.player2.getCompleteAddress(), 1)
      .send()
      .wait();
    expect(registerReceipt.status).toBe('mined');
  }, 20000);

  test('Game master can pair two players', async () => {
    const pairReceipt = await game.withWallet(wallets.gameMaster).methods.pair().send().wait();
    expect(pairReceipt.status).toBe('mined');
  }, 20000);
});
