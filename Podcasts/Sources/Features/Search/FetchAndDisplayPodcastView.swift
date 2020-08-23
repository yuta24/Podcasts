//
//  FetchAndDisplayPodcastView.swift
//  Podcasts
//
//  Created by Yu Tawata on 2020/08/20.
//

import Combine
import SwiftUI
import ComposableArchitecture

struct FetchAndDisplayPodcastState: Equatable {
    var podcast: Podcast
    var ext: PodcastExt?

    var alertState: AlertState<FetchAndDisplayPodcastAction>?
}

enum FetchAndDisplayPodcastAction: Equatable {
    case fetch
    case fetchResponse(Result<FetchPodcastResult, Networking.Failure>)
    case load(FetchPodcastResult)
    case loadResult(Result<Tuple2<FetchPodcastResult, PodcastExt?>, Never>)

    case favorite
    case favoriteResponse(Result<PodcastExt, Never>)
    case unfavorite
    case unfavoriteResponse(Result<PodcastExt, Never>)

    case alertDismissed
}

struct FetchAndDisplayPodcastEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var favoritedPodcastDataStore: FavoritedPodcastDataStore
    var fetchWorkflow: FetchPodcastWorkflow
    var favoriteWorkflow: FavoritePodcastWorkflow
    var unfavoriteWorkflow: UnfavoritePodcastWorkflow
}

let fetchAndDisplayPodcastReducer = Reducer<FetchAndDisplayPodcastState, FetchAndDisplayPodcastAction, FetchAndDisplayPodcastEnvironment>.combine(
    .init { state, action, environment in

        switch action {

        case .fetch:
            return environment.fetchWorkflow.execute(URL(string: state.podcast.feedUrl!)!)
                .eraseToEffect()
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(FetchAndDisplayPodcastAction.fetchResponse)

        case .fetchResponse(.success(let result)):
            return .init(value: .load(result))

        case .fetchResponse(.failure(let error)):
            state.alertState = .init(title: "Error", message: error.localizedDescription, dismissButton: .default("OK", send: .alertDismissed))

            return .none

        case .load(let result):

            return environment.favoritedPodcastDataStore.fetch(result.link!)
                .map { Tuple2(value0: result, value1: $0) }
                .eraseToEffect()
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(FetchAndDisplayPodcastAction.loadResult)

        case .loadResult(.success(let tuple)):
            state.ext = .init(tuple.value0, isFavorited: tuple.value1?.isFavorited ?? false)

            return .none

        case .favorite:
            guard let ext = state.ext else {
                return .none
            }

            return environment.favoriteWorkflow.execute(ext)
                .eraseToEffect()
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(FetchAndDisplayPodcastAction.favoriteResponse)

        case .favoriteResponse(.success(let ext)):
            state.ext = ext

            return .none

        case .favoriteResponse(.failure):

            return .none

        case .unfavorite:
            guard let ext = state.ext else {
                return .none
            }

            return environment.unfavoriteWorkflow.execute(ext)
                .eraseToEffect()
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(FetchAndDisplayPodcastAction.unfavoriteResponse)

        case .unfavoriteResponse(.success(let ext)):
            state.ext = ext

            return .none

        case .unfavoriteResponse(.failure):

            return .none

        case .alertDismissed:
            state.alertState = .none

            return .none

        }

    }
)

struct FetchAndDisplayPodcastView: View {
    let store: Store<FetchAndDisplayPodcastState, FetchAndDisplayPodcastAction>

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
