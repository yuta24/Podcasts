//
//  FavoritePodcastWorkflow.swift
//  Podcasts
//
//  Created by Yu Tawata on 2020/08/21.
//

import Foundation
import Combine

class FavoritePodcastWorkflow {
    let userDefaults: UserDefaults
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    func execute(_ podcast: PodcastExt) -> AnyPublisher<PodcastExt, Never> {
        Just(mutate(podcast) {
            $0.isFavorited = true
        })
        .handleEvents(receiveOutput: { [weak self] value in
            self?.saveFavoritePodcasts(value)
        })
        .eraseToAnyPublisher()
    }

    private func saveFavoritePodcasts(_ podcast: PodcastExt) {
        let array = userDefaults.data(forKey: "favorites").flatMap {
            try? decoder.decode([PodcastExt].self, from: $0)
        } ?? []
        let new = mutate(array) {
            $0.append(podcast)
        }
        let data = try! encoder.encode(new)
        userDefaults.setValue(data, forKey: "favorites")
    }
}
