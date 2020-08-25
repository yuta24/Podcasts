//
//  PlayingEpisodeDataStore.swift
//  Core
//
//  Created by Yu Tawata on 2020/08/25.
//

import Foundation
import Combine
import OSLog
import SwiftSQL

public struct PlayingEpisodeDataStore {
    public var fetchs: () -> AnyPublisher<[PlayingEpisode], Never>
    public var last: () -> AnyPublisher<PlayingEpisode?, Never>
    public var append: (PlayingEpisode) -> Void
    public var remove: (PlayingEpisode) -> Void
}

private let logger = Logger(subsystem: "com.bivre.podcasts", category: "PlayingEpisodeDataStore")
private let db = try! SQLConnection(location: .disk(url: FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.bivre.podcast")!.appendingPathComponent("playingepisode")))

extension PlayingEpisodeDataStore {
    enum Constant {
        static let tableName = "playing_episodes"
    }

    public static let live: PlayingEpisodeDataStore = {
        try! db.execute("""
        CREATE IF NOT EXISTS TABLE \(Constant.tableName)
        (
            id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            title VARCHAR NOT NULL,
            position REAL NOT NULL,
            duration REAL NOT NULL,
            enclosure VARCHAR NOT NULL,
            created REAL NOT NULL
        )
        """)

        return PlayingEpisodeDataStore(
            fetchs: {
                Deferred {
                    Future<[PlayingEpisode], Never> { promise in
                        let episodes = try! db.prepare("SELECT title, position, duration, enclosure, created FROM \(Constant.tableName) ORDER BY created DESC")
                            .rows(PlayingEpisode.self)
                        promise(.success(episodes))
                    }
                }
                .eraseToAnyPublisher()
            },
            last: {
                Deferred {
                    Future<PlayingEpisode?, Never> { promise in
                        let lastRowId = db.lastInsertRowID
                        let episode = try! db.prepare("SELECT title, position, duration, enclosure, created FROM \(Constant.tableName) WHERE id = ?")
                            .bind(lastRowId)
                            .row(PlayingEpisode.self)
                        promise(.success(episode))
                    }
                }
                .eraseToAnyPublisher()
            },
            append: { episode in
                _ = try! db.prepare("INSERT INTO \(Constant.tableName) (title, position, duration, enclosure, created) VALUES (?, ?, ?, ?, ?)")
                    .bind(episode.title, episode.position, episode.duration, episode.enclosure, episode.created)
                    .execute()
            },
            remove: { episode in
                _ = try! db.prepare("DELETE FROM \(Constant.tableName) WHERE title = ? AND enclosure = ?")
                    .bind(episode.title, episode.enclosure)
                    .execute()
            }
        )
    }()
}
