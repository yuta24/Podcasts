//
//  FavoritePodcastWorkflow.swift
//  Podcasts
//
//  Created by Yu Tawata on 2020/08/21.
//

import Foundation
import Combine
import Core

struct FavoritePodcastWorkflow {
    let dataStore: FavoritedPodcastDataStore

    init(dataStore: FavoritedPodcastDataStore) {
        self.dataStore = dataStore
    }

    func execute(_ podcast: PodcastExt) -> AnyPublisher<PodcastExt, Never> {
        Just(mutate(podcast) {
            $0.isFavorited = true
        })
        .handleEvents(receiveOutput: { value in
            dataStore.append(value)
        })
        .eraseToAnyPublisher()
    }
}
