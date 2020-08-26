//
//  FavoritedPodcastDataStoreTests.swift
//  PodcastsTests
//
//  Created by Yu Tawata on 2020/08/22.
//

import Combine
import XCTest
@testable import Core

class FavoritedPodcastDataStoreTests: XCTestCase {
    private var store: FavoritedPodcastDataStore!

    private var cancellables = Set<AnyCancellable>()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        FavoritedPodcastDataStore.reset()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        FavoritedPodcastDataStore.reset()
    }

    func test_Changed() throws {
        // Given
        store = FavoritedPodcastDataStore.live

        let exp = expectation(description: "\(#function):\(#line)")
        exp.isInverted = true

        let expects1: [Podcast] = [
            .init(
                trackName: "TrackName1",
                artistName: "ArtistName",
                artworkUrl600: URL(string: "https://www.google.com/")!,
                trackCount: 10,
                feedUrl: URL(string: "https://www.google.com/")!,
                releaseDate: Date(timeIntervalSince1970: 123)
            )
        ]

        let expects2: [Podcast] = [
            .init(
                trackName: "TrackName2",
                artistName: "ArtistName",
                artworkUrl600: URL(string: "https://www.google.com/")!,
                trackCount: 10,
                feedUrl: URL(string: "https://www.google.com/")!,
                releaseDate: Date(timeIntervalSince1970: 1234)
            ),
            .init(
                trackName: "TrackName1",
                artistName: "ArtistName",
                artworkUrl600: URL(string: "https://www.google.com/")!,
                trackCount: 10,
                feedUrl: URL(string: "https://www.google.com/")!,
                releaseDate: Date(timeIntervalSince1970: 123)
            )
        ]

        var counter = 0

        // When
        store.changed()
            .sink(receiveCompletion: { completion in
                exp.fulfill()
            }, receiveValue: { value in
                if counter == 1 {
                    XCTAssertEqual(expects1, value)
                } else if counter == 2 {
                    XCTAssertEqual(expects2, value)
                }

                counter += 1
            })
            .store(in: &cancellables)

        store.append(.init(
            trackName: "TrackName1",
            artistName: "ArtistName",
            artworkUrl600: URL(string: "https://www.google.com/")!,
            trackCount: 10,
            feedUrl: URL(string: "https://www.google.com/")!,
            releaseDate: Date(timeIntervalSince1970: 123)
        ))

        store.append(.init(
            trackName: "TrackName2",
            artistName: "ArtistName",
            artworkUrl600: URL(string: "https://www.google.com/")!,
            trackCount: 10,
            feedUrl: URL(string: "https://www.google.com/")!,
            releaseDate: Date(timeIntervalSince1970: 1234)
        ))

        // Then
        wait(for: [exp], timeout: 0.5)
    }
}
