//
//  PauseEpisodeWorkflow.swift
//  Podcasts
//
//  Created by Yu Tawata on 2020/09/15.
//

import Foundation
import Combine
import Core

struct PauseEpisodeWorkflow {
    let manager: AudioManager

    init(manager: AudioManager) {
        self.manager = manager
    }

    func execute() -> AnyPublisher<Void, Never> {
        manager.pause()
    }
}
