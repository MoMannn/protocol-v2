// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

/**
 * @title Sapphire
 * @notice This library provides a number of convenient wrappers for
 * cryptographic operations such as the x25519 key derivation, Deoxys-II-based
 * encryption and decryption, signing key generation, message digest signing and
 * verification, gas padding and hashing.
 *
 * Most of the mentioned functions are implemented as Sapphire's precompiles and
 * are cheap to call.
 *
 * #### Calling Precompiles Manually
 *
 * You can override the wrappers and call Sapphire precompiles by dispatching
 * calls to specific well-known contract addresses, as described below. The
 * __Precompile address__ section of each function will show you the address
 * of the corresponding precompile.
 *
 * Input parameters should be packed into a contiguous memory region with each
 * chunk of data padded to 32 bytes as usual. The recommended way to construct
 * parameter byte sequences in Solidity is with `abi.encode` and `abi.decode`,
 * which will transparently handle things like putting `bytes` lengths in the
 * correct position.
 */
library Sapphire {
    // Oasis-specific, confidential precompiles
    address internal constant RANDOM_BYTES =
        0x0100000000000000000000000000000000000001;
 
    /**
     * @notice Generate `num_bytes` pseudo-random bytes, with an optional
     * personalization string (`pers`) added into the hashing algorithm to
     * increase domain separation when needed.
     *
     * #### Precompile address
     *
     * `0x0100000000000000000000000000000000000001`
     *
     * #### Gas cost
     *
     * 10,000 minimum plus 240 per output word plus 60 per word of the
     * personalization string.
     *
     * #### Implementation details
     *
     * The mode (e.g. simulation or "view call" vs transaction execution) is fed
     * to TupleHash (among other block-dependent components) to derive the "key
     * id", which is then used to derive a per-block VRF key from
     * epoch-ephemeral entropy (using KMAC256 and cSHAKE) so a different key
     * id will result in a unique per-block VRF key. This per-block VRF key is
     * then used to create the per-block root RNG which is then used to derive
     * domain-separated (using Merlin transcripts) per-transaction random RNGs
     * which are then exposed via this precompile. The KMAC, cSHAKE and
     * TupleHash algorithms are SHA-3 derived functions defined in [NIST
     * Special Publication 800-185](https://nvlpubs.nist.gov/nistpubs/specialpublications/nist.sp.800-185.pdf).
     *
     * #### Example
     *
     * ```solidity
     * bytes memory randomPad = Sapphire.randomBytes(64, "");
     * ```
     *
     * @param numBytes The number of bytes to return.
     * @param pers An optional personalization string to increase domain
     *        separation.
     * @return The random bytes. If the number of bytes requested is too large
     *         (over 1024), a smaller amount (1024) will be returned.
     */
    function randomBytes(uint256 numBytes, bytes memory pers)
        internal
        view
        returns (bytes memory)
    {
        (bool success, bytes memory entropy) = RANDOM_BYTES.staticcall(
            abi.encode(numBytes, pers)
        );
        require(success, "randomBytes: failed");
        return entropy;
    }

}