//
//  SearchPodcastsWorkflowTests.swift
//  PodcastsTests
//
//  Created by Yu Tawata on 2020/08/17.
//

import Combine
import XCTest
@testable import Podcasts

class SearchPodcastsWorkflowTests: XCTestCase {
    private var workflow: SearchPodcastsWorkflow!

    private var cancellables = Set<AnyCancellable>()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_Searching_Empty() throws {
        // Given
        workflow = SearchPodcastsWorkflow(
            networkingClosure: {
                Networking(
                    search: { _ in
                        Just(SearchPodcastResult(resultCount: 0, results: []))
                            .setFailureType(to: Networking.Failure.self)
                            .eraseToAnyPublisher()
                    },
                    fetchPodcast: { _ in
                        Fail<FetchPodcastResult, Networking.Failure>(error: Networking.Failure())
                            .eraseToAnyPublisher()
                    }
                )
            }
        )

        let expects: SearchPodcastResult = .init(
            resultCount: 0,
            results: []
        )

        let exp = expectation(description: "\(#function):\(#line)")

        // When
        workflow.execute("Swift")
            .sink(
                receiveCompletion: { completion in
                    exp.fulfill()
                },
                receiveValue: { podcasts in
                    // Then
                    XCTAssertEqual(expects, podcasts)
                }
            )
            .store(in: &cancellables)

        wait(for: [exp], timeout: 0.1)
    }

    func test_Searching_Podcasts() throws {
        // Given
        workflow = SearchPodcastsWorkflow(
            networkingClosure: {
                Networking(
                    search: { _ in
                        Just(
                            SearchPodcastResult(
                                resultCount: 1,
                                results: [
                                    Podcast(
                                        trackName: "Track01",
                                        artistName: "Swift0",
                                        artworkUrl600: .none,
                                        trackCount: 123,
                                        feedUrl: .none
                                        )
                                ]
                            )
                        )
                        .setFailureType(to: Networking.Failure.self)
                        .eraseToAnyPublisher()
                    },
                    fetchPodcast: { _ in
                        Fail<FetchPodcastResult, Networking.Failure>(error: Networking.Failure())
                            .eraseToAnyPublisher()
                    }
                )
            }
        )

        let expects: SearchPodcastResult = .init(
            resultCount: 1,
            results: [
                Podcast(
                    trackName: "Track01",
                    artistName: "Swift0",
                    artworkUrl600: .none,
                    trackCount: 123,
                    feedUrl: .none
                )
            ]
        )

        let exp = expectation(description: "\(#function):\(#line)")

        // When
        workflow.execute("Swift")
            .sink(
                receiveCompletion: { completion in
                    exp.fulfill()
                },
                receiveValue: { podcasts in
                    // Then
                    XCTAssertEqual(expects, podcasts)
                }
            )
            .store(in: &cancellables)

        wait(for: [exp], timeout: 0.1)
    }
}