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

struct SearchPodcastsState: Equatable {
    var searchText: String
    var podcasts: [Podcast]
    var alertState: AlertState<SearchPodcastsAction>?
}

enum SearchPodcastsAction: Equatable {
    case search
    case searchTextChanged(String)
    case alertDismissed

    case podcastsResponse(Result<[Podcast], Networking.Failure>)
}

struct SearchPodcastsEnvironment {
    var networking: Networking
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

let searchPodcastsReducer = Reducer<SearchPodcastsState, SearchPodcastsAction, SearchPodcastsEnvironment> { state, action, environment in

    switch action {

    case .search:
        struct SearchId: Hashable {}

        guard !state.searchText.isEmpty else {
            state.podcasts = []
          return .cancel(id: SearchId())
        }

        return environment.networking.search(state.searchText)
            .eraseToEffect()
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .debounce(id: SearchId(), for: 0.3, scheduler: environment.mainQueue)
            .map { SearchPodcastsAction.podcastsResponse($0.map(\.results)) }

    case .searchTextChanged(let searchText):

        state.searchText = searchText

        return .init(value: .search)

    case .alertDismissed:
        state.alertState = .none

        return .none

    case .podcastsResponse(.success(let podcasts)):
        state.podcasts = podcasts

        return .none

    case .podcastsResponse(.failure(let error)):
        state.alertState = .init(title: "Error", message: error.localizedDescription, dismissButton: .default("OK", send: .alertDismissed))

        return .none

    }

}

struct SearchPodcastsResultView: View {
    let podcast: Podcast

    var body: some View {
        HStack {
            podcast.artworkUrl600.flatMap {
                ImageView(image: .init(url: URL(string: $0)!))
            }
            .frame(width: 72, height: 72)
            .cornerRadius(8)

            VStack(alignment: .leading) {
                podcast.trackName.flatMap(Text.init)
                    .lineLimit(.none)
                    .font(.headline)
                    .foregroundColor(Color(.label))
                podcast.trackCount.map { "\($0) episodes" }
                    .flatMap(Text.init)
                    .font(.footnote)
                    .foregroundColor(Color(.secondaryLabel))

                Spacer()
            }

            Spacer()
        }
    }
}

struct SearchPodcastsView: View {
    let store: Store<SearchPodcastsState, SearchPodcastsAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            SearchNavigation(text: viewStore.binding(get: \.searchText, send: SearchPodcastsAction.searchTextChanged)) {
                viewStore.send(.search)
            } cancel: {

            } content: { () in
                ScrollView {
                    ForEach(Array(viewStore.podcasts.enumerated()), id: \.offset) { _, podcast in
                        SearchPodcastsResultView(podcast: podcast)
                            .padding()
                    }
                }
                .navigationTitle("Search")
            }
        }
    }
}
