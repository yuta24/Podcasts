//
//  DisplayPodcastView.swift
//  Podcasts
//
//  Created by Yu Tawata on 2020/08/20.
//

import Combine
import SwiftUI
import ComposableArchitecture
import Core

struct DisplayPodcastState: Equatable {
    var podcast: Podcast
    var ext: PodcastExt?

    var alertState: AlertState<DisplayPodcastAction>?
}

enum DisplayPodcastAction: Equatable {
    case fetch
    case fetchResponse(Result<FetchPodcastResult, Networking.Failure>)
    case load(FetchPodcastResult)
    case loadResult(Result<Tuple2<FetchPodcastResult, Podcast?>, Never>)

    case favorite
    case favoriteResponse(Result<Void, Never>)
    case unfavorite
    case unfavoriteResponse(Result<Void, Never>)

    case alertDismissed

    static func == (lhs: DisplayPodcastAction, rhs: DisplayPodcastAction) -> Bool {
        switch (lhs, rhs) {
        case (.favoriteResponse(.success), .favoriteResponse(.success)):
            return true
        case (.favoriteResponse(.failure), .favoriteResponse(.failure)):
            return true
        case (.unfavoriteResponse(.success), .unfavoriteResponse(.success)):
            return true
        case (.unfavoriteResponse(.failure), .unfavoriteResponse(.failure)):
            return true
        case (let l, let r):
            return l == r
        }
    }
}

struct DisplayPodcastEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var favoritedPodcastDataStore: FavoritedPodcastDataStore
    var fetchWorkflow: FetchPodcastWorkflow
    var favoriteWorkflow: FavoritePodcastWorkflow
    var unfavoriteWorkflow: UnfavoritePodcastWorkflow
}

let displayPodcastReducer = Reducer<DisplayPodcastState, DisplayPodcastAction, DisplayPodcastEnvironment>.combine(
    .init { state, action, environment in

        switch action {

        case .fetch:
            return environment.fetchWorkflow.execute(state.podcast.feedUrl!)
                .eraseToEffect()
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(DisplayPodcastAction.fetchResponse)

        case .fetchResponse(.success(let result)):
            return .init(value: .load(result))

        case .fetchResponse(.failure(let error)):
            state.alertState = .init(title: "Error", message: error.localizedDescription, dismissButton: .default("OK", send: .alertDismissed))

            return .none

        case .load(let result):
            return environment.favoritedPodcastDataStore.fetch(state.podcast.feedUrl!)
                .map { Tuple2(value0: result, value1: $0) }
                .eraseToEffect()
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(DisplayPodcastAction.loadResult)

        case .loadResult(.success(let tuple)):
            state.ext = .init(tuple.value0, isFavorited: tuple.value1 != .none)

            return .none

        case .favorite:
            return environment.favoriteWorkflow.execute(state.podcast)
                .eraseToEffect()
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(DisplayPodcastAction.favoriteResponse)

        case .favoriteResponse(.success):
            state.ext?.isFavorited = true

            return .none

        case .favoriteResponse(.failure):

            return .none

        case .unfavorite:
            return environment.unfavoriteWorkflow.execute(state.podcast)
                .eraseToEffect()
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(DisplayPodcastAction.unfavoriteResponse)

        case .unfavoriteResponse(.success):
            state.ext?.isFavorited = false

            return .none

        case .unfavoriteResponse(.failure):

            return .none

        case .alertDismissed:
            state.alertState = .none

            return .none

        }

    }
)

struct DisplayPodcastView: View {
    let store: Store<DisplayPodcastState, DisplayPodcastAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            if let ext = viewStore.ext {
                Component.PodcastExtView(
                    podcast: ext,
                    onFavorite: {
                        viewStore.send(.favorite)
                    },
                    onUnfavorite: {
                        viewStore.send(.unfavorite)
                    }
                )
            } else {
                Text("Loading ...")
                    .onAppear {
                        viewStore.send(.fetch)
                    }
            }
        }
        .alert(store.scope(state: \.alertState), dismiss: .alertDismissed)
    }
}
