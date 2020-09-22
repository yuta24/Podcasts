//
//  PodcastsApp.swift
//  Podcasts
//
//  Created by Yu Tawata on 2020/08/16.
//

import SwiftUI
import ComposableArchitecture
import Core

struct AppState: Equatable {
    var selected: Int
    var searchPodcastsState: SearchPodcastsState
    var favoritePodcastsState: FavoritePodcastsState
    var playingEpisodeState: PlayingEpisodeState?

    var isSheetPresented: Bool { playingEpisodeState != nil }
}

enum AppAction: Equatable {
    case tabSelected(Int)

    case setSheet(isPresented: Bool)
    case setSheetIsPresentedDelayCompleted

    case searchPodcasts(SearchPodcastsAction)
    case favoritePodcasts(FavoritePodcastsAction)
    case playingEpisode(PlayingEpisodeAction)
}

struct AppEnvironment {
    var networking: Networking
    var audioClient: AudioClient
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var favoritedPodcastDataStore: FavoritedPodcastDataStore
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    searchPodcastsReducer.pullback(
        state: \.searchPodcastsState,
        action: /AppAction.searchPodcasts,
        environment: {
            SearchPodcastsEnvironment(
                networking: $0.networking,
                mainQueue: $0.mainQueue,
                searchWorkflow: SearchPodcastsWorkflow(networking: $0.networking),
                favoritedPodcastDataStore: $0.favoritedPodcastDataStore
            )
        }
    ),
    favoritePodcastsReducer.pullback(
        state: \.favoritePodcastsState,
        action: /AppAction.favoritePodcasts,
        environment: {
            FavoritePodcastsEnvironment(
                networking: $0.networking,
                mainQueue: $0.mainQueue,
                favoritedPodcastDataStore: $0.favoritedPodcastDataStore
            )
        }
    ),
    playingEpisodeReducer.optional()
        .pullback(
            state: \.playingEpisodeState,
            action: /AppAction.playingEpisode,
            environment: {
                PlayingEpisodeEnvironment(
                    playEpisodeWorkflow: PlayEpisodeWorkflow(client: $0.audioClient),
                    pauseEpisodeWorkflow: PauseEpisodeWorkflow(client: $0.audioClient),
                    resumeEpisodeWorkflow: ResumeEpisodeWorkflow(client: $0.audioClient),
                    stopEpisodeWorkflow: StopEpisodeWorkflow(client: $0.audioClient),
                    mainQueue: $0.mainQueue
                )
            }
        ),
    .init { state, action, environment in

        switch action {

        case .tabSelected(let index):
            state.selected = index

            return .none

        case .setSheet(true):
            return Effect(value: .setSheetIsPresentedDelayCompleted)
               .delay(for: 1, scheduler: environment.mainQueue)
               .eraseToEffect()

        case .setSheet(false):
            state.playingEpisodeState = .none

            return .none

        case .setSheetIsPresentedDelayCompleted:

            return .none

        case .searchPodcasts(.fetchAndDisplayPodcast(.select(let episode))):
            state.playingEpisodeState = .init(
                episode: .init(
                    title: episode.title!,
                    position: 0,
                    duration: episode.duration!,
                    imageUrl: episode.imageUrl!,
                    enclosure: episode.enclosure!,
                    fileUrl: .none
                )
            )

            return .none

        case .searchPodcasts:

            return .none

        case .favoritePodcasts(.displayPodcast(.select(let episode))):
            state.playingEpisodeState = .init(
                episode: .init(
                    title: episode.title!,
                    position: 0,
                    duration: episode.duration!,
                    imageUrl: episode.imageUrl!,
                    enclosure: episode.enclosure!,
                    fileUrl: .none
                )
            )

            return .none

        case .favoritePodcasts:

            return .none

        case .playingEpisode:

            return .none

        }

    }
)

@main
struct PodcastsApp: App {
    let store = Store<AppState, AppAction>(
        initialState: .init(
            selected: 0,
            searchPodcastsState: .init(searchText: "", podcasts: []),
            favoritePodcastsState: .init(podcasts: [])
        ),
        reducer: appReducer.debug(),
        environment: .init(
            networking: .live,
            audioClient: .live,
            mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
            favoritedPodcastDataStore: .live
        )
    )

    @UIApplicationDelegateAdaptor(ApplicationDelegateAdaptor.self) private var delegate

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
                    FavoritePodcastsView(store: store.scope(state: \.favoritePodcastsState, action: AppAction.favoritePodcasts))
                        .tabItem {
                            Image(systemName: "star.fill")
                            Text("Favorite")
                        }
                        .tag(1)
                }
                .sheet(isPresented: viewStore.binding(get: { $0.isSheetPresented }, send: AppAction.setSheet(isPresented:))) {
                    IfLetStore(
                        store.scope(
                            state: { $0.playingEpisodeState }, action: AppAction.playingEpisode),
                        then: PlayingEpisodeView.init(store:)
                    )
                }
                .onOpenURL { url in
                }
            }
        }
    }
}
