//
//  SearchPodcastsView.swift
//  Podcasts
//
//  Created by Yu Tawata on 2020/08/16.
//

import Combine
import SwiftUI
import ComposableArchitecture
import FetchImage
import Core

struct SearchPodcastsState: Equatable {
    var searchText: String
    var podcasts: [Podcast]

    var selection: Identified<Int, DisplayPodcastState?>?
    var alertState: AlertState<SearchPodcastsAction>?
}

enum SearchPodcastsAction: Equatable {
    case fetchAndDisplayPodcast(DisplayPodcastAction)

    case search
    case searchTextChanged(String)
    case podcastsResponse(Result<[Podcast], Networking.Failure>)

    case alertDismissed
    case setNavigation(selection: Int?)
    case setNavigationSelectionDelayCompleted
}

struct SearchPodcastsEnvironment {
    var networking: Networking
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var searchPodcastsWorkflow: SearchPodcastsWorkflow
    var favoritedPodcastDataStore: FavoritedPodcastDataStore
}

let searchPodcastsReducer = Reducer<SearchPodcastsState, SearchPodcastsAction, SearchPodcastsEnvironment>.combine(
    displayPodcastReducer.optional()
        .pullback(state: \Identified.value, action: .self, environment: { $0 })
        .optional()
        .pullback(
        state: \.selection,
        action: /SearchPodcastsAction.fetchAndDisplayPodcast,
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

        case .fetchAndDisplayPodcast:

            return .none

        case .search:
            struct SearchId: Hashable {}

            guard !state.searchText.isEmpty else {
                state.podcasts = []
              return .cancel(id: SearchId())
            }

            return environment.searchPodcastsWorkflow.execute(state.searchText)
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .debounce(id: SearchId(), for: 0.3, scheduler: environment.mainQueue)
                .map { SearchPodcastsAction.podcastsResponse($0.map(\.results)) }

        case .searchTextChanged(let searchText):

            state.searchText = searchText

            return .init(value: .search)

        case .podcastsResponse(.success(let podcasts)):
            state.podcasts = podcasts

            return .none

        case .podcastsResponse(.failure(let error)):
            state.alertState = .init(title: "Error", message: .init(error.localizedDescription), dismissButton: .default("OK", send: .alertDismissed))

            return .none

        case .alertDismissed:
            state.alertState = .none

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

struct SearchPodcastsView: View {
    let store: Store<SearchPodcastsState, SearchPodcastsAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            SearchNavigation(text: viewStore.binding(get: \.searchText, send: SearchPodcastsAction.searchTextChanged)) {
                viewStore.send(.search)
            } cancel: {

            } content: { () in
                ScrollView {
                    ForEach(Array(viewStore.podcasts.enumerated()), id: \.offset) { offset, podcast in
                        NavigationLink(
                            destination: IfLetStore(
                                store.scope(
                                    state: { $0.selection?.value },
                                    action: SearchPodcastsAction.fetchAndDisplayPodcast
                                ),
                                then: DisplayPodcastView.init(store:)
                            ),
                            tag: offset,
                            selection: viewStore.binding(
                                get: { $0.selection?.id },
                                send: SearchPodcastsAction.setNavigation(selection:)
                            ),
                            label: {
                                Component.PodcastItemView(item: .podcast(podcast))
                                    .padding()
                            }
                        )
                    }
                }
                .navigationTitle("Search")
            }
        }
        .alert(store.scope(state: \.alertState), dismiss: .alertDismissed)
    }
}
