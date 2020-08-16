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
}

enum AppAction: Equatable {
    case tabSelected(Int)
}

class AppEnvironment {
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in

    switch action {

    case .tabSelected(let index):
        state.selected = index

        return .none

    }

}

@main
struct PodcastsApp: App {
    let store = Store<AppState, AppAction>(
        initialState: .init(selected: 0),
        reducer: appReducer.debug(),
        environment: AppEnvironment())

    var body: some Scene {
        WindowGroup {
            WithViewStore(store) { viewStore in
                TabView(selection: viewStore.binding(get: { $0.selected }, send: AppAction.tabSelected) ) {
                        SearchPodcastsView()
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
