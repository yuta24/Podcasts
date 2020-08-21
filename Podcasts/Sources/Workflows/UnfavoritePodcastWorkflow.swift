//
//  UnfavoritePodcastWorkflow.swift
//  Podcasts
//
//  Created by Yu Tawata on 2020/08/21.
//

import Foundation
import Combine

class UnfavoritePodcastWorkflow {
    let userDefaults: UserDefaults
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    func execute(_ podcast: PodcastExt) -> AnyPublisher<PodcastExt, Never> {
        Just(mutate(podcast) {
            $0.isFavorited = false
        })
        .handleEvents(receiveOutput: { [weak self] value in
            self?.removeFavoritePodcasts(value)
        })
        .eraseToAnyPublisher()
    }

    private func removeFavoritePodcasts(_ podcast: PodcastExt) {
        let array = userDefaults.data(forKey: "favorites").flatMap {
            try? decoder.decode([PodcastExt].self, from: $0)
        } ?? []
        let new = mutate(array) {
            $0.removeAll(where: { $0 == podcast })
        }
        let data = try! encoder.encode(new)
        userDefaults.setValue(data, forKey: "favorites")
    }
}
