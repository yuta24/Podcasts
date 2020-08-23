//
//  Episode.swift
//  Podcasts
//
//  Created by Yu Tawata on 2020/08/18.
//

import Foundation

public struct Episode: Equatable, Codable {
    public var title: String?
    public var desc: String?
    public var pubDate: Date?
    public var link: URL?
    public var subtitle: String?
    public var duration: TimeInterval?
    public var enclosure: URL?

    public init(
        title: String?,
        desc: String?,
        pubDate: Date?,
        link: URL?,
        subtitle: String?,
        duration: TimeInterval?,
        enclosure: URL?
    ) {
        self.title = title
        self.desc = desc
        self.pubDate = pubDate
        self.link = link
        self.subtitle = subtitle
        self.duration = duration
        self.enclosure = enclosure
    }
}
