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
    case play
    case played
    case pause
    case paused
}

struct PlayingEpisodeEnvironment {
    var playEpisodeWorkflow: PlayEpisodeWorkflow
    var pauseEpisodeWorkflow: PauseEpisodeWorkflow
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

//let audioPlayerReducer = Reducer<PlayingEpisodeState, AudioPlayer.Action, PlayingEpisodeEnvironment>

let playingEpisodeReducer = Reducer<PlayingEpisodeState, PlayingEpisodeAction, PlayingEpisodeEnvironment>.combine(
    .init { state, action, environment in

        switch action {

        case .play:
            return environment.playEpisodeWorkflow.execute(state.episode)
                .catchToEffect()
                .map { _ in PlayingEpisodeAction.played }

        case .played:
            state.playing = true

            return .none

        case .pause:
            return environment.pauseEpisodeWorkflow.execute()
                .catchToEffect()
                .map { _ in PlayingEpisodeAction.paused }

        case .paused:
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
                        .padding()

                    Text("\(viewStore.episode.title)")
                        .font(.title2)
                        .bold()

                    HStack {
                        Button(
                            action: {
                                if viewStore.playing {
                                    viewStore.send(.pause)
                                } else {
                                    viewStore.send(.play)
                                }
                            },
                            label: {
                                if viewStore.playing {
                                    Image(systemName: "pause.fill")
                                        .resizable()
                                        .frame(width: 36, height: 36)
                                } else {
                                    Image(systemName: "play.fill")
                                        .resizable()
                                        .frame(width: 36, height: 36)
                                }
                            }
                        )
                    }
                }
                .padding()
            }
            .onDisappear {
                viewStore.send(.pause)
            }
        }
    }
}
