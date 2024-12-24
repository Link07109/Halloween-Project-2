/**
  * Modified version of Karl Zylinski's 
  * code from his game CAT & ONION
  */

package game

import core_hash "core:hash"

Hash :: distinct u64

hash :: proc(s: string) -> Hash {
    return Hash(core_hash.murmur64a(transmute([]byte)(s)))
}
