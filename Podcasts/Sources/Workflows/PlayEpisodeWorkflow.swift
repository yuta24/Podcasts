//
//  PlayEpisodeWorkflow.swift
//  Podcasts
//
//  Created by Yu Tawata on 2020/09/15.
//

import Foundation
import Combine
import ComposableArchitecture
import Core

struct PlayEpisodeWorkflow {
    let client: AudioClient

    init(client: AudioClient) {
        self.client = client
    }

    func execute(id: AnyHashable, episode: PlayingEpisode) -> Effect<AudioClient.Action, Never> {
        client.play(id, episode.enclosure)
    }
}
