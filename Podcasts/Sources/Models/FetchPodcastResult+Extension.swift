//
//  FetchPodcastResult+Extension.swift
//  Podcasts
//
//  Created by Yu Tawata on 2020/08/24.
//

import Foundation
import FeedKit
import Core

extension FetchPodcastResult {
    init(_ rss: RSSFeed) {
        self.title = rss.title
        self.desc = rss.description
        self.link = rss.link.flatMap(URL.init(string:))
        self.author = rss.iTunes?.iTunesAuthor
        self.imageUrl = rss.iTunes?.iTunesImage?.attributes?.href.flatMap(URL.init(string:))
        self.summary = rss.iTunes?.iTunesSummary
        self.episodes = rss.items?.compactMap(Episode.init) ?? []
    }
}
