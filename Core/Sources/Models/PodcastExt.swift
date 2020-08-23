//
//  PodcastExt.swift
//  Podcasts
//
//  Created by Yu Tawata on 2020/08/21.
//

import Foundation

public struct PodcastExt: Equatable, Codable {
    public var title: String?
    public var desc: String?
    public var link: URL?
    public var author: String?
    public var imageUrl: URL?
    public var summary: String?
    public var episodes: [Episode]

    public var isFavorited: Bool

    public init(
        title: String?,
        desc: String?,
        link: URL?,
        author: String?,
        imageUrl: URL?,
        summary: String?,
        episodes: [Episode],
        isFavorited: Bool
    ) {
        self.title = title
        self.desc = desc
        self.link = link
        self.author = author
        self.imageUrl = imageUrl
        self.summary = summary
        self.episodes = episodes
        self.isFavorited = isFavorited
    }
}
