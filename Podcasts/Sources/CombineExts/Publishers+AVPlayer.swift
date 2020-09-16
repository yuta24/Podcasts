//
//  Publishers+AVPlayer.swift
//  Podcasts
//
//  Created by Yu Tawata on 2020/09/15.
//

import Foundation
import AVKit
import Combine

extension AVPlayer {
    struct PeriodicTimePublisher: Publisher {
        typealias Output = CMTime
        typealias Failure = Never

        class PeriodicTimeSubscription<S: Subscriber>: Subscription where S.Input == CMTime {
            private let lock = NSLock()
            private let recursiveLock = NSRecursiveLock()
            private var demand: Subscribers.Demand

            private var player: AVPlayer?
            private var token: Any?

            init(_ player: AVPlayer, _ interval: CMTime, _ queue: DispatchQueue?, _ subscriber: S) {
                self.demand = .max(0)
                self.player = player
                self.token = player.addPeriodicTimeObserver(forInterval: interval, queue: queue) { [weak self] time in
                    guard let self = self else {
                        return
                    }

                    self.lock.lock()
                    guard self.token != nil else {
                        self.lock.unlock()
                        return
                    }

                    let demand = self.demand
                     if demand > 0 {
                         self.demand -= 1
                     }
                     self.lock.unlock()

                     if demand > 0 {
                         self.recursiveLock.lock()
                         let additionalDemand = subscriber.receive(time)
                         self.recursiveLock.unlock()

                         if additionalDemand > 0 {
                             self.lock.lock()
                             self.demand += additionalDemand
                             self.lock.unlock()
                         }
                     }
                }
            }

            func request(_ d: Subscribers.Demand) {
                lock.lock()
                demand += d
                lock.unlock()
            }

            func cancel() {
                lock.lock()

                guard let player = player, let token = token else {
                    lock.unlock()
                    return
                }

                self.player = .none
                self.token = .none

                lock.unlock()
                player.removeTimeObserver(token)
            }
        }

        let player: AVPlayer
        let interval: CMTime
        let queue: DispatchQueue?

        init(player: AVPlayer, interval: CMTime, queue: DispatchQueue?) {
            self.player = player
            self.interval = interval
            self.queue = queue
        }

        func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
            subscriber.receive(subscription: PeriodicTimeSubscription(player, interval, queue, subscriber))
        }
    }

    func periodicTimePublisher(forInterval interval: CMTime, queue: DispatchQueue? = .none) -> PeriodicTimePublisher {
        PeriodicTimePublisher(player: self, interval: interval, queue: queue)
    }
}
