//
//  FavoritedPodcastDataStoreTests.swift
//  PodcastsTests
//
//  Created by Yu Tawata on 2020/08/22.
//

import Combine
import XCTest
@testable import Podcasts

class FavoritedPodcastDataStoreTests: XCTestCase {
    private var store: FavoritedPodcastDataStore!

    private var cancellables = Set<AnyCancellable>()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        UserDefaults.standard.removeObject(forKey: "favorites")
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        UserDefaults.standard.removeObject(forKey: "favorites")
    }

    func test_Changed() throws {
        // Given
        store = FavoritedPodcastDataStore.live

        let exp = expectation(description: "\(#function):\(#line)")

        let expects1: [PodcastExt] = [
            .init(
                title: "Title1",
                desc: "Description",
                link: URL(string: "https://www.google.com/")!,
                author: "yuta24",
                imageUrl: .none,
                summary: "Summary",
                episodes: [],
                isFavorited: true
            )
        ]

        let expects2: [PodcastExt] = [
            .init(
                title: "Title1",
                desc: "Description",
                link: URL(string: "https://www.google.com/")!,
                author: "yuta24",
                imageUrl: .none,
                summary: "Summary",
                episodes: [],
                isFavorited: true
            ),
            .init(
                title: "Title2",
                desc: "Description",
                link: URL(string: "https://www.google.com/")!,
                author: "yuta24",
                imageUrl: .none,
                summary: "Summary",
                episodes: [],
                isFavorited: true
            )
        ]

        var counter = 0

        // When
        store.changed()
            .sink(receiveCompletion: { completion in
                exp.fulfill()
            }, receiveValue: { value in
                counter += 1

                if counter == 1 {
                    XCTAssertEqual(expects1, value)
                } else if counter == 2 {
                    XCTAssertEqual(expects2, value)
                }
            })
            .store(in: &cancellables)

        store.append(.init(
            title: "Title1",
            desc: "Description",
            link: URL(string: "https://www.google.com/")!,
            author: "yuta24",
            imageUrl: .none,
            summary: "Summary",
            episodes: [],
            isFavorited: true
        ))

        store.append(.init(
            title: "Title2",
            desc: "Description",
            link: URL(string: "https://www.google.com/")!,
            author: "yuta24",
            imageUrl: .none,
            summary: "Summary",
            episodes: [],
            isFavorited: true
        ))

        // Then
        wait(for: [exp], timeout: 0.1)
    }
}
