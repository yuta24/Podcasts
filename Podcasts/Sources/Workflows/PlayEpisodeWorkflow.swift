//
//  PlayEpisodeWorkflow.swift
//  Podcasts
//
//  Created by Yu Tawata on 2020/09/15.
//

import Foundation
import Combine
import Core

struct PlayEpisodeWorkflow {
    let manager: AudioManager

    init(manager: AudioManager) {
        self.manager = manager
    }

    func execute(_ episode: PlayingEpisode) -> AnyPublisher<Void, Never> {
        manager.play(episode.enclosure)
    }
}
