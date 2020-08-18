//
//  SearchPodcastsWorkflow.swift
//  Podcasts
//
//  Created by Yu Tawata on 2020/08/17.
//

import Foundation
import Combine

class SearchPodcastsWorkflow {
    let networkingClosure: () -> Networking

    init(networkingClosure: @escaping () -> Networking) {
        self.networkingClosure = networkingClosure
    }

    func execute(_ searchText: String) -> AnyPublisher<SearchPodcastResult, Networking.Failure> {
        networkingClosure().search(searchText)
    }
}
