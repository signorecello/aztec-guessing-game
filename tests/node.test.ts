import { createPXEClient, PXE, GrumpkinScalar, AccountManager, AccountWallet, AztecAddress } from '@aztec/aztec.js';
import { SingleKeyAccountContract } from '@aztec/accounts/single_key';
import { derivePublicKey } from '@aztec/circuits.js';
import { GuessingGameContract } from '../artifacts/GuessingGame';

describe('Account Tests', () => {
  const pxeURL = process.env.PXE_URL || 'http://localhost:8080';
  let pxe: PXE;
  let account: AccountManager;
  let wallet: AccountWallet;

  const privateKey = GrumpkinScalar.random();
  const expectedPublicKey = derivePublicKey(privateKey).toString();

  beforeAll(async () => {
    pxe = createPXEClient(pxeURL);
    const { chainId } = await pxe.getNodeInfo();
    expect(chainId).toBe(31337);

    const accountContract = new SingleKeyAccountContract(privateKey);
    account = new AccountManager(pxe, privateKey, accountContract);
    wallet = await account.register();
  });

  test('Can deploy the game', async () => {
    const game = await GuessingGameContract.deploy(wallet, wallet.getCompleteAddress()).send().deployed();
    console.log(game);
    const publicKey = wallet.getCompleteAddress().publicKey.toString();
    expect(publicKey).toEqual(expectedPublicKey);
  });
});
