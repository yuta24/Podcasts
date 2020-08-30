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

    @State private var position: Int = 0

    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                VStack(spacing: 16) {
                    ImageView(image: .init(url: viewStore.episode.imageUrl))
                        .frame(width: 180, height: 180)

                    VStack {
                        GeometryReader { proxy in
                            ZStack {
                                Rectangle().frame(width: proxy.size.width, height: 2)

                                Circle().frame(width: 4, height: 4)
                            }
                        }

                        HStack {
                            Text("\(position)")
                                .font(.caption)

                            Spacer()

                            Text("\(Int(viewStore.episode.duration) - position)")
                                .font(.caption)
                        }
                    }

//                    Slider(
//                        value: $position,
//                        in: 0...Float(viewStore.episode.duration),
//                        minimumValueLabel: Text("0"),
//                        maximumValueLabel: Text("\(viewStore.episode.duration)"),
//                        label: { Text("Seeker") })

                    Text("\(viewStore.episode.title)")
                        .font(.title2)
                        .bold()
                }
                .padding()
            }
        }
    }
}
