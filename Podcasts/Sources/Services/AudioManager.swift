//
//  AudioManager.swift
//  Podcasts
//
//  Created by Yu Tawata on 2020/09/14.
//

import Foundation
import Combine
import AVFoundation

struct AudioManager {
    struct Properties: Equatable {
        var rate: Float?
    }

    enum Action: Equatable {
        case didPeriodicTime(CMTime)
    }

    var play: (URL) -> AnyPublisher<Void, Never>
    var pause: () -> AnyPublisher<Void, Never>
    var rate: () -> Float
    var currentTime: () -> CMTime
    var observingTime: (CMTime) -> AnyPublisher<CMTime, Never>

    var set: (Properties) -> Void
}

private let player = AVPlayer()

extension AudioManager {
    static let live: AudioManager = {

        return .init(
            play: { url in
                Deferred {
                    Future<Void, Never> { callback in
                        player.replaceCurrentItem(with: .init(url: url))
                        player.play()
                        callback(.success(()))
                    }
                }
                .eraseToAnyPublisher()
            },
            pause: {
                Deferred {
                    Future<Void, Never> { callback in
                        player.pause()
                        callback(.success(()))
                    }
                }
                .eraseToAnyPublisher()
            },
            rate: { player.rate },
            currentTime: player.currentTime,
            observingTime: { time in
                player.periodicTimePublisher(forInterval: time)
                    .eraseToAnyPublisher()
            },
            set: { properties in
                if let rate = properties.rate {
                    player.rate = rate
                }
            }
        )
    }()
}
