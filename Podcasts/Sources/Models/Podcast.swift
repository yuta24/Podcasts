//
//  Podcast.swift
//  Podcasts
//
//  Created by Yu Tawata on 2020/08/17.
//

import Foundation

struct Podcast: Equatable, Decodable {
    var trackName: String?
    var artistName: String?
    var artworkUrl600: String?
    var trackCount: Int?
    var feedUrl: String?
}
