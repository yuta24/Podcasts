//
//  FetchPodcastWorkflow.swift
//  Podcasts
//
//  Created by Yu Tawata on 2020/08/18.
//

import Foundation
import Combine
import ComposableArchitecture

struct FetchPodcastWorkflow {
    let networking: Networking

    init(networking: Networking) {
        self.networking = networking
    }

    func execute(_ feedUrl: URL) -> Effect<FetchPodcastResult, Networking.Failure> {
        networking.fetchPodcast(feedUrl)
    }
}
