//
//  SearchPodcastsWorkflow.swift
//  Podcasts
//
//  Created by Yu Tawata on 2020/08/17.
//

import Foundation
import Combine
import ComposableArchitecture

struct SearchPodcastsWorkflow {
    let networking: Networking

    init(networking: Networking) {
        self.networking = networking
    }

    func execute(_ searchText: String) -> Effect<SearchPodcastResult, Networking.Failure> {
        networking.searchPodcasts(searchText)
    }
}
