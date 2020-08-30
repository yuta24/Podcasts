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
    init(_ item: RSSFeedItem, on rss: RSSFeed) {
        let imageUrl = rss.iTunes?.iTunesImage?.attributes?.href.flatMap(URL.init(string:))
        self.init(
            title: item.title,
            desc: item.description,
            pubDate: item.pubDate,
            link: item.link.flatMap(URL.init(string:)),
            subtitle: item.iTunes?.iTunesSubtitle,
            duration: item.iTunes?.iTunesDuration,
            imageUrl: item.iTunes?.iTunesImage?.attributes?.href.flatMap(URL.init(string:)) ?? imageUrl,
            enclosure: item.enclosure?.attributes?.url.flatMap(URL.init(string:)
            )
        )
    }
}
