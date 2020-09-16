//
//  FavoritedPodcastDataStore.swift
//  Podcasts
//
//  Created by Yu Tawata on 2020/08/22.
//

import Foundation
import Combine
import os.log

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
private let subject = CurrentValueSubject<[Podcast], Never>([])

extension FavoritedPodcastDataStore {
    static let reset: () -> Void = {
        try! Database.connection.execute("""
            DELETE FROM \(Database.Table.favoritePodcast.name)
        """)
        try! Database.connection.execute("""
            VACUUM
        """)
    }

    static func published() {
        let podcasts = try! Database.connection.prepare("SELECT track_name, artist_name, artwork_url_600, track_count, feed_url, release_date FROM \(Database.Table.favoritePodcast.name) ORDER BY created DESC")
            .rows(Podcast.self)

        subject.send(podcasts)
    }

    public static let live: FavoritedPodcastDataStore = {
        try! Database.connection.execute("""
            CREATE TABLE IF NOT EXISTS \(Database.Table.favoritePodcast.name)
            (
                id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
                track_name VARCHAR,
                artist_name VARCHAR,
                artwork_url_600 VARCHAR,
                track_count INTEGER,
                feed_url VARCHAR,
                release_date REAL,
                created REAL NOT NULL
            )
        """)

        return FavoritedPodcastDataStore(
            fetchs: {
                Deferred {
                    Future<[Podcast], Never> { promise in
                        let podcasts = try! Database.connection.prepare("SELECT track_name, artist_name, artwork_url_600, track_count, feed_url, release_date FROM \(Database.Table.favoritePodcast.name) ORDER BY created DESC")
                            .rows(Podcast.self)
                        promise(.success(podcasts))
                    }
                }
                .eraseToAnyPublisher()
            },
            fetch: { feedUrl in
                Deferred {
                    Future<Podcast?, Never> { promise in
                        let podcast = try! Database.connection.prepare("SELECT track_name, artist_name, artwork_url_600, track_count, feed_url, release_date FROM \(Database.Table.favoritePodcast.name) WHERE feed_url = ?")
                            .bind(feedUrl.absoluteString)
                            .row(Podcast.self)
                        promise(.success(podcast))
                    }
                }
                .eraseToAnyPublisher()
            },
            append: { podcast in
                _ = try! Database.connection.prepare("INSERT INTO \(Database.Table.favoritePodcast.name) (track_name, artist_name, artwork_url_600, track_count, feed_url, release_date, created) VALUES (?, ?, ?, ?, ?, ?, ?)")
                    .bind(podcast.trackName!, podcast.artistName!, podcast.artworkUrl600!.absoluteString, podcast.trackCount!, podcast.feedUrl!.absoluteString, podcast.releaseDate!.timeIntervalSince1970, Date().timeIntervalSince1970)
                    .execute()

                published()
            },
            remove: { podcast in
                _ = try! Database.connection.prepare("DELETE FROM \(Database.Table.favoritePodcast.name) WHERE feed_url = ?")
                    .bind(podcast.feedUrl!.absoluteURL)
                    .execute()
            },
            changed: {
                // FIXME:
                defer { published() }
                return subject.eraseToAnyPublisher()
            }
        )
    }()
}
