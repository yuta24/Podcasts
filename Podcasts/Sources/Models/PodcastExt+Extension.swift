//
//  PodcastExt+Extension.swift
//  Podcasts
//
//  Created by Yu Tawata on 2020/08/24.
//

import Foundation
import Core

extension PodcastExt {
    init(_ result: FetchPodcastResult, isFavorited: Bool) {
        self.init(
            title: result.title,
            desc: result.desc,
            link: result.link,
            author: result.author,
            imageUrl: result.imageUrl,
            summary: result.summary,
            episodes: result.episodes,
            isFavorited: isFavorited
        )
    }
}
