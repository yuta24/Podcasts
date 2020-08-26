//
//  Utils.swift
//  PodcastsTests
//
//  Created by Yu Tawata on 2020/08/22.
//

import Foundation
import Combine
import Core
@testable import Podcasts

class FavoritedPodcastDataStoreSpy {
    private(set) var dataStore: FavoritedPodcastDataStore!

    private(set) var fetchsCallCount = 0
    private(set) var fetchCallCount = 0
    private(set) var appendCallCount = 0
    private(set) var removeCallCount = 0
    private(set) var changedCallCount = 0

    init(fetchs: @escaping () -> AnyPublisher<[Podcast], Never>, fetch: @escaping () -> AnyPublisher<Podcast?, Never>, changed: @escaping () -> AnyPublisher<[Podcast], Never>) {
        self.dataStore = FavoritedPodcastDataStore(
            fetchs: { [weak self] in
                self?.fetchsCallCount += 1
                return fetchs()
            },
            fetch: { [weak self] _ in
                self?.fetchCallCount += 1
                return fetch()
            },
            append: { [weak self] _ in
                self?.appendCallCount += 1
            },
            remove: { _ in
                self.removeCallCount += 1
            }, changed: {
                self.changedCallCount += 1
                return changed()
            }
        )
    }
}
