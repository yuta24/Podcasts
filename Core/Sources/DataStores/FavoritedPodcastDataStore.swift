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
    public var fetchs: () -> AnyPublisher<[Podcast], Never>
    public var fetch: (URL) -> AnyPublisher<Podcast?, Never>
    public var append: (Podcast) -> Void
    public var remove: (Podcast) -> Void

    public var changed: () -> AnyPublisher<[Podcast], Never>

    public init(
        fetchs: @escaping () -> AnyPublisher<[Podcast], Never>,
        fetch: @escaping (URL) -> AnyPublisher<Podcast?, Never>,
        append: @escaping (Podcast) -> Void,
        remove: @escaping (Podcast) -> Void,
        changed: @escaping () -> AnyPublisher<[Podcast], Never>
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
                    try? decoder.decode([Podcast].self, from: $0)
                }
                .map { $0 ?? [] }
                .eraseToAnyPublisher()
        },
        fetch: { feedUrl in
            Just(())
                .map { _ -> Podcast? in
                    let array = try? decoder.decode([Podcast].self, from: userDefaults.favorites)
                    return array?.first(where: { $0.feedUrl == feedUrl })
                }
                .eraseToAnyPublisher()
        },
        append: { podcast in
            let array = try? decoder.decode([Podcast].self, from: userDefaults.favorites)
            let new = mutate(array ?? []) {
                $0.append(podcast)
            }
            let data = try! encoder.encode(new)
            userDefaults.setValue(data, forKey: "favorites")
        },
        remove: { podcast in
            let array = try? decoder.decode([Podcast].self, from: userDefaults.favorites)
            let new = mutate(array ?? []) {
                $0.removeAll(where: { $0.feedUrl == podcast.feedUrl })
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
                    try? decoder.decode([Podcast].self, from: $0)
                }
                .map { $0 ?? [] }
                .eraseToAnyPublisher()
                .eraseToAnyPublisher()
        }
    )
}
