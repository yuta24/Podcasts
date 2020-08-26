//
//  Podcast.swift
//  Podcasts
//
//  Created by Yu Tawata on 2020/08/17.
//

import Foundation
import SwiftSQL
import SwiftSQLExt

public struct Podcast: Equatable, Codable {
    public var trackName: String?
    public var artistName: String?
    public var artworkUrl600: URL?
    public var trackCount: Int?
    public var feedUrl: URL?
    public var releaseDate: Date?

    public init(
        trackName: String?,
        artistName: String?,
        artworkUrl600: URL?,
        trackCount: Int?,
        feedUrl: URL?,
        releaseDate: Date?
    ) {
        self.trackName = trackName
        self.artistName = artistName
        self.artworkUrl600 = artworkUrl600
        self.trackCount = trackCount
        self.feedUrl = feedUrl
        self.releaseDate = releaseDate
    }
}

extension Podcast: SQLRowDecodable {
    public init(row: SQLRow) throws {
        self.trackName = row[0]
        self.artistName = row[1]
        self.artworkUrl600 = row[2]
        self.trackCount = row[3]
        self.feedUrl = row[4]
        self.releaseDate = row[5]
    }
}
