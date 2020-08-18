//
//  PodcastsApp.swift
//  Podcasts
//
//  Created by Yu Tawata on 2020/08/16.
//

import SwiftUI
import ComposableArchitecture

struct AppState: Equatable {
    var selected: Int

    var searchPodcastsState: SearchPodcastsState
}

enum AppAction: Equatable {
    case tabSelected(Int)

    case searchPodcasts(SearchPodcastsAction)
}

struct AppEnvironment {
    var networking: Networking
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    searchPodcastsReducer.pullback(
        state: \.searchPodcastsState,
        action: /AppAction.searchPodcasts,
        environment: { SearchPodcastsEnvironment(networking: $0.networking, mainQueue: $0.mainQueue) }
    ),
    .init { state, action, environment in

        switch action {

        case .tabSelected(let index):
            state.selected = index

            return .none

        case .searchPodcasts:

            return .none

        }

    }
)

@main
struct PodcastsApp: App {
    let store = Store<AppState, AppAction>(
        initialState: .init(selected: 0, searchPodcastsState: .init(searchText: "", podcasts: [])),
        reducer: appReducer.debug(),
        environment: .init(networking: .live, mainQueue: DispatchQueue.main.eraseToAnyScheduler()))

    var body: some Scene {
        WindowGroup {
            WithViewStore(store) { viewStore in
                TabView(selection: viewStore.binding(get: { $0.selected }, send: AppAction.tabSelected) ) {
                    SearchPodcastsView(store: store.scope(state: \.searchPodcastsState, action: AppAction.searchPodcasts))
                        .edgesIgnoringSafeArea(.vertical)
                        .tabItem {
                            Image(systemName: "magnifyingglass")
                            Text("Search")
                        }
                        .tag(0)
                    FavoritePodcastsView()
                        .tabItem {
                            Image(systemName: "star.fill")
                            Text("Favorite")
                        }
                        .tag(1)
                }
            }
        }
    }
}
