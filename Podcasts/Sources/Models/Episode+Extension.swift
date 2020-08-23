//
//  Episode+Extension.swift
//  Podcasts
//
//  Created by Yu Tawata on 2020/08/24.
//

import Foundation
import FeedKit
import Core

extension Episode {
    init(_ feed: RSSFeedItem) {
        self.init(
            title: feed.title,
            desc: feed.description,
            pubDate: feed.pubDate,
            link: feed.link.flatMap(URL.init(string:)),
            subtitle: feed.iTunes?.iTunesSubtitle,
            duration: feed.iTunes?.iTunesDuration,
            enclosure: feed.enclosure?.attributes?.url.flatMap(URL.init(string:)
            )
        )
    }
}
