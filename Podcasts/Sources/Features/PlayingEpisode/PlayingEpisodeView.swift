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
    var playing: Bool
}

enum PlayingEpisodeAction: Equatable {
    case resume
    case pause
}

struct PlayingEpisodeEnvironment {
}

let playingEpisodeReducer = Reducer<PlayingEpisodeState, PlayingEpisodeAction, PlayingEpisodeEnvironment>.combine(
    .init { state, action, environment in

        switch action {

        case .resume:
            state.playing = true

            return .none

        case .pause:
            state.playing = false

            return .none

        }

    }
)

struct PlayingEpisodeView: View {
    let store: Store<PlayingEpisodeState, PlayingEpisodeAction>

    @State private var position: Int = 0

    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                VStack(spacing: 32) {
                    ImageView(image: .init(url: viewStore.episode.imageUrl))
                        .frame(width: 240, height: 240)
                        .cornerRadius(8)

                    Text("\(viewStore.episode.title)")
                        .font(.title2)
                        .bold()

                    HStack {
                        Button(
                            action: {
                                if viewStore.playing {
                                    viewStore.send(.pause)
                                } else {
                                    viewStore.send(.resume)
                                }
                            },
                            label: {
                                if viewStore.playing {
                                    Image(systemName: "pause.fill")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                } else {
                                    Image(systemName: "play.fill")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                }
                            }
                        )
                    }
                }
                .padding()
            }
        }
    }
}
