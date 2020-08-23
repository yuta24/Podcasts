//
//  DisplayPodcastView.swift
//  Podcasts
//
//  Created by Yu Tawata on 2020/08/23.
//

import Combine
import SwiftUI
import ComposableArchitecture
import Core

struct DisplayPodcastState: Equatable {
    var podcast: PodcastExt
}

enum DisplayPodcastAction: Equatable {
    case favorite
    case favoriteResponse(Result<PodcastExt, Never>)
    case unfavorite
    case unfavoriteResponse(Result<PodcastExt, Never>)
}

struct DisplayPodcastEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var favoritedPodcastDataStore: FavoritedPodcastDataStore
    var favoriteWorkflow: FavoritePodcastWorkflow
    var unfavoriteWorkflow: UnfavoritePodcastWorkflow
}

let displayPodcastReducer = Reducer<DisplayPodcastState, DisplayPodcastAction, DisplayPodcastEnvironment>.combine(
    .init { state, action, environment in

        switch action {

        case .favorite:
            return environment.favoriteWorkflow.execute(state.podcast)
                .eraseToEffect()
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(DisplayPodcastAction.favoriteResponse)

        case .favoriteResponse(.success(let ext)):
            state.podcast = ext

            return .none

        case .favoriteResponse(.failure):

            return .none

        case .unfavorite:
            return environment.unfavoriteWorkflow.execute(state.podcast)
                .eraseToEffect()
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(DisplayPodcastAction.unfavoriteResponse)

        case .unfavoriteResponse(.success(let ext)):
            state.podcast = ext

            return .none

        case .unfavoriteResponse(.failure):

            return .none

        }

    }
)

struct DisplayPodcastView: View {
    let store: Store<DisplayPodcastState, DisplayPodcastAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            Component.PodcastExtView(
                podcast: viewStore.podcast,
                onFavorite: {
                    viewStore.send(.favorite)
                },
                onUnfavorite: {
                    viewStore.send(.unfavorite)
                }
            )
        }
    }
}
