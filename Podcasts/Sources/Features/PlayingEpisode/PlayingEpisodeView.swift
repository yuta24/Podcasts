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

    var alertState: AlertState<DisplayPodcastAction>?
}

enum PlayingEpisodeAction: Equatable {
    case download
    case downloadResponse(Result<URL, Networking.Failure>)

    case resume
    case pause

    case alertDismissed
}

struct PlayingEpisodeEnvironment {
    var downloadEpisodeWorkflow: DownloadEpisodeWorkflow
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

let playingEpisodeReducer = Reducer<PlayingEpisodeState, PlayingEpisodeAction, PlayingEpisodeEnvironment>.combine(
    .init { state, action, environment in

        switch action {

        case .download:
            return environment.downloadEpisodeWorkflow.execute(state.episode)
                .catchToEffect()
                .map(PlayingEpisodeAction.downloadResponse)

        case .downloadResponse(.success(let url)):
            state.episode.fileUrl = url

            return .none

        case .downloadResponse(.failure(let error)):
            state.alertState = .init(title: "Error", message: error.localizedDescription, dismissButton: .default("OK", send: .alertDismissed))

            return .none

        case .resume:
            state.playing = true

            return .none

        case .pause:
            state.playing = false

            return .none

        case .alertDismissed:
            state.alertState = .none

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
            .onAppear {
                viewStore.send(.download)
            }
        }
    }
}
