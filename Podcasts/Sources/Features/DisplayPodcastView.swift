//
//  DisplayPodcastView.swift
//  Podcasts
//
//  Created by Yu Tawata on 2020/08/20.
//

import Combine
import SwiftUI
import ComposableArchitecture

struct DisplayPodcastState: Equatable {
    var podcast: Podcast
    var ext: PodcastExt?

    var alertState: AlertState<DisplayPodcastAction>?
}

enum DisplayPodcastAction: Equatable {
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

struct DisplayPodcastEnvironment {
    var favoritedPodcastDataStore: FavoritedPodcastDataStore
    var networking: Networking
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var favoriteWorkflow: FavoritePodcastWorkflow
    var unfavoriteWorkflow: UnfavoritePodcastWorkflow
}

let displayPodcastReducer = Reducer<DisplayPodcastState, DisplayPodcastAction, DisplayPodcastEnvironment> { state, action, environment in

    switch action {

    case .fetch:
        return environment.networking.fetchPodcast(URL(string: state.podcast.feedUrl!)!)
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

        return environment.favoritedPodcastDataStore.fetch(result.link!)
            .map { Tuple2(value0: result, value1: $0) }
            .eraseToEffect()
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map(DisplayPodcastAction.loadResult)

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
            .map(DisplayPodcastAction.favoriteResponse)

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
            .map(DisplayPodcastAction.unfavoriteResponse)

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

struct DisplayPodcastView: View {
    let store: Store<DisplayPodcastState, DisplayPodcastAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            if let ext = viewStore.ext {
                DisplayPodcastResultView(
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
