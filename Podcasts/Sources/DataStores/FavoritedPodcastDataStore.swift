//
//  FavoritedPodcastDataStore.swift
//  Podcasts
//
//  Created by Yu Tawata on 2020/08/22.
//

import Foundation
import Combine
import OSLog

struct FavoritedPodcastDataStore {
    var fetch: () -> AnyPublisher<[PodcastExt], Never>
    var append: (PodcastExt) -> Void
    var remove: (PodcastExt) -> Void

    var changed: () -> Publishers.Decode<NSObject.KeyValueObservingPublisher<UserDefaults, JSONDecoder.Input>, [PodcastExt], JSONDecoder>
}

private let logger = Logger(subsystem: "com.bivre.podcasts", category: "FavoritedPodcastDataStore")
private let encoder = JSONEncoder()
private let decoder = JSONDecoder()

private extension UserDefaults {
    @objc dynamic var favorites: Data {
        data(forKey: "favorites") ?? Data()
    }
}

extension FavoritedPodcastDataStore {
    static let live = FavoritedPodcastDataStore(
        fetch: {
            Just(UserDefaults.standard.favorites)
                .map {
                    try? decoder.decode([PodcastExt].self, from: $0)
                }
                .map { $0 ?? [] }
                .eraseToAnyPublisher()
        },
        append: { ext in
            let array = try? decoder.decode([PodcastExt].self, from: UserDefaults.standard.favorites)
            let new = mutate(array ?? []) {
                $0.append(ext)
            }
            let data = try! encoder.encode(new)
            UserDefaults.standard.setValue(data, forKey: "favorites")
        },
        remove: { ext in
            let array = try? decoder.decode([PodcastExt].self, from: UserDefaults.standard.favorites)
            let new = mutate(array ?? []) {
                $0.removeAll(where: { $0 == ext })
            }
            let data = try! encoder.encode(new)
            UserDefaults.standard.setValue(data, forKey: "favorites")
        },
        changed: {
            UserDefaults.standard.publisher(for: \.favorites)
                .decode(type: [PodcastExt].self, decoder: decoder)
        }
    )
}
