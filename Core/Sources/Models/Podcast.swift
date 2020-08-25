//
//  Podcast.swift
//  Podcasts
//
//  Created by Yu Tawata on 2020/08/17.
//

import Foundation

public struct Podcast: Equatable, Codable {
    public var trackName: String?
    public var artistName: String?
    public var artworkUrl600: String?
    public var trackCount: Int?
    public var feedUrl: URL?
    public var releaseDate: Date?

    public init(
        trackName: String?,
        artistName: String?,
        artworkUrl600: String?,
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
