//
//  DownloadEpisodeWorkflow.swift
//  Podcasts
//
//  Created by Yu Tawata on 2020/09/03.
//

import Foundation
import Combine
import Core

struct DownloadEpisodeWorkflow {
    let networking: Networking

    init(networking: Networking) {
        self.networking = networking
    }

    func execute(_ episode: PlayingEpisode) -> AnyPublisher<URL, Networking.Failure> {
        networking.downloadEpisode(episode.enclosure)
    }
}
