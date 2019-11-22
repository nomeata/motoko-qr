/**
 * Module      : common.mo
 * Copyright   : 2019 Enzo Haussecker
 * License     : Apache 2.0 with LLVM Exception
 * Maintainer  : Enzo Haussecker <enzo@dfinity.org>
 * Stability   : Experimental
 */

import List "mo:stdlib/list.mo";
import Prelude "mo:stdlib/prelude.mo";

type List<T> = List.List<T>;

module Common {

  public type ErrorCorrection = { #L; #M; #Q; #H };

  public type Matrix = { unbox : [[Bool]] };

  public type Mode = { #Alphanumeric; #EightBit; #Kanji; #Numeric };

  public type Version = { unbox : Nat };

  public func version(n : Nat) : Version {
    if (n > 40 or n == 0) {
      Prelude.printLn("Error: Invalid version!");
      Prelude.unreachable()
    };
    { unbox = n }
  };

  public func getECIBits(level : ErrorCorrection) : List<Bool> {
    let bits = switch (level) {
      case (#L) { [false, true] };
      case (#M) { [false, false] };
      case (#Q) { [true, true] };
      case (#H) { [true, false] }
    };
    List.fromArray<Bool>(bits)
  };

  public func cciLen(version : Version, mode : Mode) : Nat {
    let n = version.unbox;
    let i =
      if (09 >= n and n >= 01) 0 else
      if (26 >= n and n >= 10) 1 else
      if (40 >= n and n >= 27) 2 else {
      Prelude.printLn("Error: Invalid version!");
      Prelude.unreachable()
    };
    switch mode {
      case (#Numeric) [10,12,14][i];
      case (#Alphanumeric) [9,11,13][i];
      case (#EightBit) [8,16,16][i];
      case (#Kanji) [8,10,12][i]
    }
  };

}
