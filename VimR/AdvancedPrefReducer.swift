/**
 * Tae Won Ha - http://taewon.de - @hataewon
 * See LICENSE
 */

import Foundation

class AdvancedPrefReducer {

  typealias Pair = StateActionPair<AppState, AdvancedPref.Action>

  func reduce(_ pair: Pair) -> Pair {
    var state = pair.state

    switch pair.action {

    case let .setUseInteractiveZsh(value):
      state.mainWindowTemplate.useInteractiveZsh = value

    case let .setUseSnapshotUpdate(value):
      state.useSnapshotUpdate = value
    }

    return StateActionPair(state: state, action: pair.action)
  }
}
