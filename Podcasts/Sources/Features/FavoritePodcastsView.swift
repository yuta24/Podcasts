//
//  FavoritePodcastsView.swift
//  Podcasts
//
//  Created by Yu Tawata on 2020/08/16.
//

import Combine
import SwiftUI
import ComposableArchitecture

struct FavoritePodcastsState: Equatable {
    var podcasts: [PodcastExt]
}

enum FavoritePodcastsAction: Equatable {
    case subscribe
    case favoritedUpdate(Result<[PodcastExt], Never>)
}

struct FavoritePodcastsEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var favoritedPodcastDataStore: FavoritedPodcastDataStore
}

let favoritePodcastsReducer = Reducer<FavoritePodcastsState, FavoritePodcastsAction, FavoritePodcastsEnvironment>.combine(
    .init { state, action, environment in

        switch action {

        case .subscribe:

            return environment.favoritedPodcastDataStore.changed()
                .eraseToEffect()
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(FavoritePodcastsAction.favoritedUpdate)

        case .favoritedUpdate(.success(let exts)):
            state.podcasts = exts

            return .none

        case .favoritedUpdate(.failure):

            return .none

        }

    }
)

struct FavoritePodcastsView: View {
    let store: Store<FavoritePodcastsState, FavoritePodcastsAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                ScrollView {
                    if !viewStore.podcasts.isEmpty {
                        ForEach(Array(viewStore.podcasts.enumerated()), id: \.offset) { offset, podcast in
                            podcast.title.flatMap(Text.init)
                        }
                    } else {
                        Text("Search podcast and favorite")
                            .onAppear {
                                viewStore.send(.subscribe)
                            }
                    }
                }
                .navigationTitle("Favorite Podcasts")
            }
        }
    }
}
