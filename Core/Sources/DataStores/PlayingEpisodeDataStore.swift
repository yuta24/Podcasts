//
//  PlayingEpisodeDataStore.swift
//  Core
//
//  Created by Yu Tawata on 2020/08/25.
//

import Foundation
import Combine
import os.log
import SwiftSQL

public struct PlayingEpisodeDataStore {
    public var fetchs: () -> AnyPublisher<[PlayingEpisode], Never>
    public var last: () -> AnyPublisher<PlayingEpisode?, Never>
    public var append: (PlayingEpisode) -> Void
    public var remove: (PlayingEpisode) -> Void
}

private let logger = Logger(subsystem: "com.bivre.podcasts", category: "PlayingEpisodeDataStore")

extension PlayingEpisodeDataStore {
    static let reset: () -> Void = {
        try! Database.connection.execute("""
            DELETE FROM \(Database.Table.playingEpisode.name)
        """)
        try! Database.connection.execute("""
            VACUUM
        """)
    }

    public static let live: PlayingEpisodeDataStore = {
        try! Database.connection.execute("""
            CREATE TABLE IF NOT EXISTS \(Database.Table.playingEpisode.name)
            (
                id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
                title VARCHAR NOT NULL,
                position REAL NOT NULL,
                duration REAL NOT NULL,
                imageUrl VARCHAR NOT NULL,
                enclosure VARCHAR NOT NULL,
                created REAL NOT NULL
            )
        """)

        return PlayingEpisodeDataStore(
            fetchs: {
                Deferred {
                    Future<[PlayingEpisode], Never> { promise in
                        let episodes = try! Database.connection.prepare("SELECT title, position, duration, enclosure, created FROM \(Database.Table.playingEpisode.name) ORDER BY created DESC")
                            .rows(PlayingEpisode.self)
                        promise(.success(episodes))
                    }
                }
                .eraseToAnyPublisher()
            },
            last: {
                Deferred {
                    Future<PlayingEpisode?, Never> { promise in
                        let lastRowId = Database.connection.lastInsertRowID
                        let episode = try! Database.connection.prepare("SELECT title, position, duration, enclosure, created FROM \(Database.Table.playingEpisode.name) WHERE id = ?")
                            .bind(lastRowId)
                            .row(PlayingEpisode.self)
                        promise(.success(episode))
                    }
                }
                .eraseToAnyPublisher()
            },
            append: { episode in
                _ = try! Database.connection.prepare("INSERT INTO \(Database.Table.playingEpisode.name) (title, position, duration, enclosure, created) VALUES (?, ?, ?, ?, ?)")
                    .bind(episode.title, episode.position, episode.duration, episode.enclosure, episode.created)
                    .execute()
            },
            remove: { episode in
                _ = try! Database.connection.prepare("DELETE FROM \(Database.Table.playingEpisode.name) WHERE title = ? AND enclosure = ?")
                    .bind(episode.title, episode.enclosure)
                    .execute()
            }
        )
    }()
}
