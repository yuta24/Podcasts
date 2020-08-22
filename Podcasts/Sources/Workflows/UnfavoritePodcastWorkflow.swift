//
//  UnfavoritePodcastWorkflow.swift
//  Podcasts
//
//  Created by Yu Tawata on 2020/08/21.
//

import Foundation
import Combine

struct UnfavoritePodcastWorkflow {
    let dataStore: FavoritedPodcastDataStore

    init(dataStore: FavoritedPodcastDataStore) {
        self.dataStore = dataStore
    }

    func execute(_ podcast: PodcastExt) -> AnyPublisher<PodcastExt, Never> {
        Just(mutate(podcast) {
            $0.isFavorited = false
        })
        .handleEvents(receiveOutput: { value in
            dataStore.remove(value)
        })
        .eraseToAnyPublisher()
    }
}