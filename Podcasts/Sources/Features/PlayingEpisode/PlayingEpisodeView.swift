//
//  PlayingEpisodeView.swift
//  Podcasts
//
//  Created by Yu Tawata on 2020/08/26.
//

import Combine
import SwiftUI
import ComposableArchitecture
import FetchImage
import Core

struct PlayingEpisodeState: Equatable {
    var episode: PlayingEpisode
}

enum PlayingEpisodeAction: Equatable {
    case resume
    case stop
}

struct PlayingEpisodeEnvironment {
}

let playingEpisodeReducer = Reducer<PlayingEpisodeState, PlayingEpisodeAction, PlayingEpisodeEnvironment>.combine(
    .init { state, action, environment in

        return .none

    }
)

struct PlayingEpisodeView: View {
    let store: Store<PlayingEpisodeState, PlayingEpisodeAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            Text("\(viewStore.episode.title)")
                .font(.title)
        }
    }
}
