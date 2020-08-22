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

extension PodcastExt {
    init(_ result: FetchPodcastResult, isFavorited: Bool) {
        self.title = result.title
        self.desc = result.desc
        self.link = result.link
        self.author = result.author
        self.imageUrl = result.imageUrl
        self.summary = result.summary
        self.episodes = result.episodes

        self.isFavorited = isFavorited
    }
}
