//
//  PlayingEpisodeView.swift
//  Podcasts
//
//  Created by Yu Tawata on 2020/08/26.
//

import AVFoundation
import Combine
import SwiftUI
import ComposableArchitecture
import FetchImage
import Core

private extension CMTime {
    var secondes: Int64 {
        value / Int64(timescale)
    }
}

struct PlayingEpisodeState: Equatable {
    var episode: PlayingEpisode
    var playing: Bool
}

enum PlayingEpisodeAction: Equatable {
    case play
    case playing(AudioClient.Action)
    case pause
}

struct PlayingEpisodeEnvironment {
    var playEpisodeWorkflow: PlayEpisodeWorkflow
    var pauseEpisodeWorkflow: PauseEpisodeWorkflow
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

let playingEpisodeReducer = Reducer<PlayingEpisodeState, PlayingEpisodeAction, PlayingEpisodeEnvironment>.combine(
    .init { state, action, environment in

        struct AudioClientId: Hashable {}

        switch action {

        case .play:
            state.playing = true
            return environment.playEpisodeWorkflow.execute(id: AudioClientId(), episode: state.episode)
                .map(PlayingEpisodeAction.playing)

        case .playing(.updatePeriodicTime(let time)):
            state.episode.position = TimeInterval(time.seconds)

            return .none

        case .pause:
            state.playing = false
            return environment.pauseEpisodeWorkflow.execute(id: AudioClientId())
                .fireAndForget()

        }

    }
)

private let formatter: DateComponentsFormatter = {
    let formatter = DateComponentsFormatter()
    formatter.unitsStyle = .positional
    formatter.allowedUnits = [.hour, .minute, .second]
    formatter.zeroFormattingBehavior = .pad
    return formatter
}()

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
                        Text("\(formatter.string(from: viewStore.episode.position)!) ~ \(formatter.string(from: viewStore.episode.duration)!)")
                    }

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
