
/* Autogenerated file, do not edit! */

/* eslint-disable */
import {
  AztecAddress,
  AztecAddressLike,
  CompleteAddress,
  Contract,
  ContractArtifact,
  ContractBase,
  ContractFunctionInteraction,
  ContractInstanceWithAddress,
  ContractMethod,
  DeployMethod,
  EthAddress,
  EthAddressLike,
  FieldLike,
  Fr,
  FunctionSelectorLike,
  loadContractArtifact,
  NoirCompiledContract,
  Point,
  PublicKey,
  Wallet,
  WrappedFieldLike,
} from '@aztec/aztec.js';
import GuessingGameContractArtifactJson from '../target/guessing_game-GuessingGame.json' assert { type: 'json' };
export const GuessingGameContractArtifact = loadContractArtifact(GuessingGameContractArtifactJson as NoirCompiledContract);

/**
 * Type-safe interface for contract GuessingGame;
 */
export class GuessingGameContract extends ContractBase {
  
  private constructor(
    instance: ContractInstanceWithAddress,
    wallet: Wallet,
  ) {
    super(instance, GuessingGameContractArtifact, wallet);
  }
  

  
  /**
   * Creates a contract instance.
   * @param address - The deployed contract's address.
   * @param wallet - The wallet to use when interacting with the contract.
   * @returns A promise that resolves to a new Contract instance.
   */
  public static async at(
    address: AztecAddress,
    wallet: Wallet,
  ) {
    return Contract.at(address, GuessingGameContract.artifact, wallet) as Promise<GuessingGameContract>;
  }

  
  /**
   * Creates a tx to deploy a new instance of this contract.
   */
  public static deploy(wallet: Wallet, gm: AztecAddressLike) {
    return new DeployMethod<GuessingGameContract>(Point.ZERO, wallet, GuessingGameContractArtifact, GuessingGameContract.at, Array.from(arguments).slice(1));
  }

  /**
   * Creates a tx to deploy a new instance of this contract using the specified public key to derive the address.
   */
  public static deployWithPublicKey(publicKey: PublicKey, wallet: Wallet, gm: AztecAddressLike) {
    return new DeployMethod<GuessingGameContract>(publicKey, wallet, GuessingGameContractArtifact, GuessingGameContract.at, Array.from(arguments).slice(2));
  }

  /**
   * Creates a tx to deploy a new instance of this contract using the specified constructor method.
   */
  public static deployWithOpts<M extends keyof GuessingGameContract['methods']>(
    opts: { publicKey?: PublicKey; method?: M; wallet: Wallet },
    ...args: Parameters<GuessingGameContract['methods'][M]>
  ) {
    return new DeployMethod<GuessingGameContract>(
      opts.publicKey ?? Point.ZERO,
      opts.wallet,
      GuessingGameContractArtifact,
      GuessingGameContract.at,
      Array.from(arguments).slice(1),
      opts.method ?? 'constructor',
    );
  }
  

  
  /**
   * Returns this contract's artifact.
   */
  public static get artifact(): ContractArtifact {
    return GuessingGameContractArtifact;
  }
  

  /** Type-safe wrappers for the public methods exposed by the contract. */
  public methods!: {
    
    /** pair() */
    pair: (() => ContractFunctionInteraction) & Pick<ContractMethod, 'selector'>;

    /** constructor(gm: struct) */
    constructor: ((gm: AztecAddressLike) => ContractFunctionInteraction) & Pick<ContractMethod, 'selector'>;

    /** turn(game_id: field, guess: field) */
    turn: ((game_id: FieldLike, guess: FieldLike) => ContractFunctionInteraction) & Pick<ContractMethod, 'selector'>;

    /** compute_note_hash_and_nullifier(contract_address: struct, nonce: field, storage_slot: field, note_type_id: field, serialized_note: array) */
    compute_note_hash_and_nullifier: ((contract_address: AztecAddressLike, nonce: FieldLike, storage_slot: FieldLike, note_type_id: FieldLike, serialized_note: FieldLike[]) => ContractFunctionInteraction) & Pick<ContractMethod, 'selector'>;

    /** register(player: struct, secret: field) */
    register: ((player: AztecAddressLike, secret: FieldLike) => ContractFunctionInteraction) & Pick<ContractMethod, 'selector'>;
  };
}
