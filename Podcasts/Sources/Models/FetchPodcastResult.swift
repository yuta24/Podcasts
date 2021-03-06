//
//  FetchPodcastResult.swift
//  Podcasts
//
//  Created by Yu Tawata on 2020/08/18.
//

import Foundation
import Core

struct FetchPodcastResult: Equatable {
    var title: String?
    var desc: String?
    var link: URL?
    var author: String?
    var imageUrl: URL?
    var summary: String?
    var episodes: [Episode]
}
