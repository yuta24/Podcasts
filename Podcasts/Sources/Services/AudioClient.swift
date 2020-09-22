//
//  AudioClient.swift
//  Podcasts
//
//  Created by Yu Tawata on 2020/09/14.
//

import Foundation
import Combine
import AVFoundation
import ComposableArchitecture

struct AudioClient {
    struct Properties: Equatable {
        var rate: Float?

        var isMuted: Bool?
        var volume: Float?
    }

    enum Action: Equatable {
        case updatePeriodicTime(CMTime)
    }

    var play: (AnyHashable, URL) -> Effect<Action, Never>
    var resume: (AnyHashable) -> Effect<Never, Never>
    var pause: (AnyHashable) -> Effect<Never, Never>
    var stop: (AnyHashable) -> Effect<Never, Never>
    var rate: (AnyHashable) -> Float?
    var currentTime: (AnyHashable) -> CMTime?
    var seek: (AnyHashable, CMTime) -> Effect<Never, Never>
    var isMuted: (AnyHashable) -> Bool?
    var volume: (AnyHashable) -> Float?

    var set: (AnyHashable, Properties) -> Void
}

private struct Dependencies {
    let player: AVPlayer
    let subscriber: Effect<AudioClient.Action, Never>.Subscriber
}

private var dependencies: [AnyHashable: Dependencies] = [:]

extension AudioClient {
    static let live: AudioClient = {
        return .init(
            play: { id, url in
                Effect.run { subscriber in
                    let player = AVPlayer()

                    dependencies[id] = Dependencies(player: player, subscriber: subscriber)

                    player.replaceCurrentItem(with: .init(url: url))
                    player.addPeriodicTimeObserver(forInterval: .init(value: 10, timescale: 10), queue: .none) { time in
                        subscriber.send(.updatePeriodicTime(time))
                    }
                    player.play()

                    return AnyCancellable {
                        dependencies[id]?.player.pause()
                        dependencies[id] = .none
                    }
                }
                .cancellable(id: id)
            },
            resume: { id in
                Effect.fireAndForget {
                    dependencies[id]?.player.play()
                }
            },
            pause: { id in
                Effect.fireAndForget {
                    dependencies[id]?.player.pause()
                }
            },
            stop: { id in
                Effect.fireAndForget {
                    dependencies[id]?.player.pause()
                    dependencies[id] = .none
                }
            },
            rate: { dependencies[$0]?.player.rate },
            currentTime: { dependencies[$0]?.player.currentTime() },
            seek: { id, time in
                Effect.fireAndForget {
                    dependencies[id]?.player.seek(to: time)
                }
            },
            isMuted: { dependencies[$0]?.player.isMuted },
            volume: { dependencies[$0]?.player.volume },
            set: { id, properties in
                if let rate = properties.rate {
                    dependencies[id]?.player.rate = rate
                }
            }
        )
    }()
}

extension AudioClient {
    static let mock = AudioClient(
        play: { _, _ in
            Effect.fireAndForget {
            }
        },
        resume: { _ in
            Effect.fireAndForget {
            }
        },
        pause: { _ in
            Effect.fireAndForget {
            }
        },
        stop: { _ in
            Effect.fireAndForget {
            }
        },
        rate: { _ in
            return .none
        },
        currentTime: { _ in
            return .none
        },
        seek: { _, _ in
            Effect.fireAndForget {
            }
        },
        isMuted: { _ in
            return .none
        },
        volume: { _ in
            return .none
        },
        set: { _, _ in
        }
    )
}
