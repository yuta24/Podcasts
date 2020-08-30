//
//  PlayingEpisode.swift
//  Core
//
//  Created by Yu Tawata on 2020/08/25.
//

import Foundation
import SwiftSQL
import SwiftSQLExt

public struct PlayingEpisode: Equatable {
    public let title: String
    public var position: TimeInterval
    public let duration: TimeInterval
    public let imageUrl: URL
    public let enclosure: URL
    public let created: Date

    public init(title: String, position: TimeInterval, duration: TimeInterval,  imageUrl: URL, enclosure: URL) {
        self.title = title
        self.position = position
        self.duration = duration
        self.imageUrl = imageUrl
        self.enclosure = enclosure
        self.created = Date()
    }
}

extension PlayingEpisode: SQLRowDecodable {
    public init(row: SQLRow) throws {
        self.title = row[1]
        self.position = row[2]
        self.duration = row[3]
        self.imageUrl = row[4]
        self.enclosure = row[5]
        self.created = row[6]
    }
}
