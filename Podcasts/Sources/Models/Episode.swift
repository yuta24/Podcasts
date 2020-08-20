//
//  Episode.swift
//  Podcasts
//
//  Created by Yu Tawata on 2020/08/18.
//

import Foundation

struct Episode: Equatable {
    var title: String?
    var desc: String?
    var pubDate: Date?
    var link: URL?
    var subtitle: String?
    var duration: TimeInterval?
    var enclosure: URL?
}
