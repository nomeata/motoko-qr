/**
 * Module     : block.mo
 * Copyright  : 2020 DFINITY Stiftung
 * License    : Apache 2.0 with LLVM Exception
 * Maintainer : Enzo Haussecker <enzo@dfinity.org>
 * Stability  : Experimental
 */

import Common "common";
import List "mo:stdlib/list";
import Nat "nat";
import Prelude "mo:stdlib/prelude";
import Version "version";

module {

  type ErrorCorrection = Common.ErrorCorrection;
  type List<T> = List.List<T>;
  type Version = Version.Version;

  public func interleave(
    version : Version,
    level : ErrorCorrection,
    data : List<Bool>
  ) : List<Bool> {
    let info = Common.info(version);
    // TODO: Implement this function!
    Prelude.unreachable()
  };

  // 
  public func toBlocks(
    version : Version,
    level : ErrorCorrection,
    data : List<Bool>
  ) : List<List.List<Bool>> {
    func go(
      accum : List<List<Bool>>,
      chunks : List<List<Bool>>,
      sizes : List<Nat>
    ) : List<List<Bool>> {
      switch sizes {
        case (null) List.rev<List<Bool>>(accum);
        case (?(h, t)) {
          let (a, b) = List.splitAt<List<Bool>>(h, chunks);
          go(List.push<List<Bool>>(List.concat<Bool>(a), accum), b, t)
        }
      }
    };
    go(
      List.nil<List<Bool>>(),
      List.chunksOf<Bool>(8, toTargetLen(version, level, data)),
      List.fromArray<Nat>(Common.qrDCWSizes(version, level))
    );
  };

  // Pad or truncate the input data to its target length.
  func toTargetLen(
    version : Version,
    level : ErrorCorrection,
    data : List<Bool>
  ) : List<Bool> {
    let targetLen = Common.targetLen(version, level);
    let baseBuf = List.take<Bool>(data, targetLen);
    let baseBufLen = List.len<Bool>(baseBuf);
    let zeroPadLen =
      if (baseBufLen + 7 > targetLen) {
        targetLen - baseBufLen
      } else {
        8 - baseBufLen % 8
      };
    let zeroPad = List.replicate<Bool>(zeroPadLen, false);
    var fillPadLen = targetLen - baseBufLen - zeroPadLen;
    var fillPad = List.nil<Bool>();
    while (fillPadLen > 0) {
      let chunk = List.take<Bool>(Nat.natToBits(60433), fillPadLen);
      fillPadLen -= List.len<Bool>(chunk);
      fillPad := List.append<Bool>(fillPad, chunk);
    };
    List.append<Bool>(baseBuf, List.append<Bool>(zeroPad, fillPad))
  };

}
