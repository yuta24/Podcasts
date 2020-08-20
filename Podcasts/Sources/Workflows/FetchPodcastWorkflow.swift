//
//  FetchPodcastWorkflow.swift
//  Podcasts
//
//  Created by Yu Tawata on 2020/08/18.
//

import Foundation
import Combine

class FetchPodcastWorkflow {
    let networkingClosure: () -> Networking

    init(networkingClosure: @escaping () -> Networking) {
        self.networkingClosure = networkingClosure
    }

    func execute(_ feedUrl: URL) -> AnyPublisher<FetchPodcastResult, Networking.Failure> {
        networkingClosure().fetchPodcast(feedUrl)
    }
}
