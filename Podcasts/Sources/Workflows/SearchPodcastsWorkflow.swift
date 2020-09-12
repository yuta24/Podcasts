//
//  SearchPodcastsWorkflow.swift
//  Podcasts
//
//  Created by Yu Tawata on 2020/08/17.
//

import Foundation
import Combine

struct SearchPodcastsWorkflow {
    let networking: Networking

    init(networking: Networking) {
        self.networking = networking
    }

    func execute(_ searchText: String) -> AnyPublisher<SearchPodcastResult, Networking.Failure> {
        networking.searchPodcasts(searchText)
    }
}
