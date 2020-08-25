//
//  FavoritePodcastsView.swift
//  Podcasts
//
//  Created by Yu Tawata on 2020/08/16.
//

import Combine
import SwiftUI
import ComposableArchitecture
import Core

struct FavoritePodcastsState: Equatable {
    var podcasts: [Podcast]

    var selection: Identified<Int, DisplayPodcastState?>?
}

enum FavoritePodcastsAction: Equatable {
    case displayPodcast(DisplayPodcastAction)

    case subscribe
    case favoritedUpdate(Result<[Podcast], Never>)

    case setNavigation(selection: Int?)
    case setNavigationSelectionDelayCompleted
}

struct FavoritePodcastsEnvironment {
    var networking: Networking
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var favoritedPodcastDataStore: FavoritedPodcastDataStore
}

let favoritePodcastsReducer = Reducer<FavoritePodcastsState, FavoritePodcastsAction, FavoritePodcastsEnvironment>.combine(
    displayPodcastReducer.optional()
        .pullback(state: \Identified.value, action: .self, environment: { $0 })
        .optional()
        .pullback(
        state: \.selection,
        action: /FavoritePodcastsAction.displayPodcast,
        environment: {
            DisplayPodcastEnvironment(
                mainQueue: $0.mainQueue,
                favoritedPodcastDataStore: $0.favoritedPodcastDataStore,
                fetchWorkflow: FetchPodcastWorkflow(networking: $0.networking),
                favoriteWorkflow: FavoritePodcastWorkflow(dataStore: $0.favoritedPodcastDataStore),
                unfavoriteWorkflow: UnfavoritePodcastWorkflow(dataStore: $0.favoritedPodcastDataStore)
            )
        }
    ),
    .init { state, action, environment in

        struct CancelId: Hashable {}

        switch action {

        case .displayPodcast:

            return .none

        case .subscribe:

            return environment.favoritedPodcastDataStore.changed()
                .eraseToEffect()
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(FavoritePodcastsAction.favoritedUpdate)

        case .favoritedUpdate(.success(let podcasts)):
            state.podcasts = podcasts

            return .none

        case .favoritedUpdate(.failure):

            return .none

        case .setNavigation(.some(let index)):
            state.selection = Identified(nil, id: index)

            return Effect(value: .setNavigationSelectionDelayCompleted)
                .delay(for: 1, scheduler: DispatchQueue.main)
                .eraseToEffect()
                .cancellable(id: CancelId())

        case .setNavigation(.none):
            state.selection = nil

            return .cancel(id: CancelId())

        case .setNavigationSelectionDelayCompleted:
            guard let index = state.selection?.id else {
                return .none
            }

            state.selection?.value = .init(podcast: state.podcasts[index])

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
                            NavigationLink(
                                destination: IfLetStore(
                                    store.scope(
                                        state: { $0.selection?.value },
                                        action: FavoritePodcastsAction.displayPodcast
                                    ),
                                    then: DisplayPodcastView.init(store:)
                                ),
                                tag: offset,
                                selection: viewStore.binding(
                                    get: { $0.selection?.id },
                                    send: FavoritePodcastsAction.setNavigation(selection:)
                                ),
                                label: {
                                    Component.PodcastItemView(item: .podcast(podcast))
                                        .padding()
                                }
                            )
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
