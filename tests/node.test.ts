import { createPXEClient, PXE, GrumpkinScalar, AccountManager, AccountWallet, AztecAddress } from '@aztec/aztec.js';
import { SingleKeyAccountContract } from '@aztec/accounts/single_key';
import { derivePublicKey } from '@aztec/circuits.js';
import { GuessingGameContract } from '../artifacts/GuessingGame';

describe('Account Tests', () => {
  const pxeURL = process.env.PXE_URL || 'http://localhost:8080';
  let pxe: PXE;
  let account: AccountManager;
  let wallet: AccountWallet;

  const privateKey = GrumpkinScalar.fromString('0x1234');
  const expectedPublicKey = derivePublicKey(privateKey).toString();

  test('Can start the PXE server', async () => {
    pxe = createPXEClient(pxeURL);
    const { chainId } = await pxe.getNodeInfo();
    expect(chainId).toBe(31337);
  });

  beforeEach(() => {
    const accountContract = new SingleKeyAccountContract(privateKey);
    account = new AccountManager(pxe, privateKey, accountContract);
  });

  test('Can create an account contract with a known address', async () => {
    const publicKey = account.getCompleteAddress().publicKey.toString();
    expect(publicKey).toEqual(expectedPublicKey);
  });

  test('Can deploy a contract with a known address', async () => {
    wallet = await account.register();
    const publicKey = wallet.getCompleteAddress().publicKey.toString();
    expect(publicKey).toEqual(expectedPublicKey);
  });

  test('Can deploy the game', async () => {
    const game = await GuessingGameContract.deploy(
      wallet,
      AztecAddress.fromString('0x063f2ac22db40f44cced107ef8c55dd788831377d7b896d405929f909abdd0b1'),
    )
      .send()
      .deployed();
    console.log(game);
    const publicKey = wallet.getCompleteAddress().publicKey.toString();
    expect(publicKey).toEqual(expectedPublicKey);
  });
});
