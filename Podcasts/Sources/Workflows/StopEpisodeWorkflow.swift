//
//  StopEpisodeWorkflow.swift
//  Podcasts
//
//  Created by Yu Tawata on 2020/09/22.
//

import Foundation
import Combine
import ComposableArchitecture
import Core

struct StopEpisodeWorkflow {
    let client: AudioClient

    init(client: AudioClient) {
        self.client = client
    }

    func execute(id: AnyHashable) -> Effect<Never, Never> {
        client.stop(id)
    }
}
