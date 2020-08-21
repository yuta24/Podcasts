//
//  PodcastExt.swift
//  Podcasts
//
//  Created by Yu Tawata on 2020/08/21.
//

import Foundation

struct PodcastExt: Equatable, Codable {
    var title: String?
    var desc: String?
    var link: URL?
    var author: String?
    var imageUrl: URL?
    var summary: String?
    var episodes: [Episode]

    var isFavorited: Bool
}
