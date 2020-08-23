//
//  FavoritedPodcastDataStore.swift
//  Podcasts
//
//  Created by Yu Tawata on 2020/08/22.
//

import Foundation
import Combine
import OSLog

public struct FavoritedPodcastDataStore {
    public var fetchs: () -> AnyPublisher<[PodcastExt], Never>
    public var fetch: (URL) -> AnyPublisher<PodcastExt?, Never>
    public var append: (PodcastExt) -> Void
    public var remove: (PodcastExt) -> Void

    public var changed: () -> AnyPublisher<[PodcastExt], Never>

    public init(
        fetchs: @escaping () -> AnyPublisher<[PodcastExt], Never>,
        fetch: @escaping (URL) -> AnyPublisher<PodcastExt?, Never>,
        append: @escaping (PodcastExt) -> Void,
        remove: @escaping (PodcastExt) -> Void,
        changed: @escaping () -> AnyPublisher<[PodcastExt], Never>
    ) {
        self.fetchs = fetchs
        self.fetch = fetch
        self.append = append
        self.remove = remove
        self.changed = changed
    }
}

private let logger = Logger(subsystem: "com.bivre.podcasts", category: "FavoritedPodcastDataStore")
private let encoder = JSONEncoder()
private let decoder = JSONDecoder()
private let userDefaults = UserDefaults(suiteName: "group.com.bivre.podcast")!

private extension UserDefaults {
    @objc dynamic var favorites: Data {
        data(forKey: "favorites") ?? Data()
    }
}

extension FavoritedPodcastDataStore {
    public static let live = FavoritedPodcastDataStore(
        fetchs: {
            Just(userDefaults.favorites)
                .map {
                    try? decoder.decode([PodcastExt].self, from: $0)
                }
                .map { $0 ?? [] }
                .eraseToAnyPublisher()
        },
        fetch: { link in
            Just(())
                .map { _ -> PodcastExt? in
                    let array = try? decoder.decode([PodcastExt].self, from: userDefaults.favorites)
                    return array?.first(where: { $0.link == link })
                }
                .eraseToAnyPublisher()
        },
        append: { ext in
            let array = try? decoder.decode([PodcastExt].self, from: userDefaults.favorites)
            let new = mutate(array ?? []) {
                $0.append(ext)
            }
            let data = try! encoder.encode(new)
            userDefaults.setValue(data, forKey: "favorites")
        },
        remove: { ext in
            let array = try? decoder.decode([PodcastExt].self, from: userDefaults.favorites)
            let new = mutate(array ?? []) {
                $0.removeAll(where: { $0.link == ext.link })
            }
            let data = try! encoder.encode(new)
            userDefaults.setValue(data, forKey: "favorites")
        },
        changed: {
            userDefaults.publisher(for: \.favorites)
                .setFailureType(to: Never.self)
                .eraseToAnyPublisher()
                .eraseToAnyPublisher()
                .map {
                    try? decoder.decode([PodcastExt].self, from: $0)
                }
                .map { $0 ?? [] }
                .eraseToAnyPublisher()
                .eraseToAnyPublisher()
        }
    )
}
