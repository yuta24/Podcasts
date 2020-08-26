//
//  Database.swift
//  Core
//
//  Created by Yu Tawata on 2020/08/26.
//

import Foundation
import SwiftSQL

enum Database {
    struct Table {
        let id: Int
        let name: String

        static let favoritePodcast = Table(id: 0, name: "favorite_podcast")
        static let playingEpisode = Table(id: 0, name: "playing_episodes")
    }

    static let connection: SQLConnection = {
        let db = try! SQLConnection(location: .disk(url: FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.bivre.podcast")!.appendingPathComponent("database")))

        return db
    }()
}
