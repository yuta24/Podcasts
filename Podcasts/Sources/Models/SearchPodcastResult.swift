//
//  SearchPodcastResult.swift
//  Podcasts
//
//  Created by Yu Tawata on 2020/08/17.
//

import Foundation

struct SearchPodcastResult: Decodable {
    var resultCount: Int
    var results: [Podcast]
}
