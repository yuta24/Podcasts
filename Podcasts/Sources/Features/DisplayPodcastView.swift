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
    var fetchResult: FetchPodcastResult?

    var alertState: AlertState<DisplayPodcastAction>?
}

enum DisplayPodcastAction: Equatable {
    case fetch
    case fetchResponse(Result<FetchPodcastResult, Networking.Failure>)

    case alertDismissed
}

struct DisplayPodcastEnvironment {
    var networking: Networking
    var mainQueue: AnySchedulerOf<DispatchQueue>
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
        state.fetchResult = result

        return .none

    case .fetchResponse(.failure(let error)):
        state.alertState = .init(title: "Error", message: error.localizedDescription, dismissButton: .default("OK", send: .alertDismissed))

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
            if let fetchResult = viewStore.fetchResult {
                DisplayPodcastResultView(result: fetchResult)
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
