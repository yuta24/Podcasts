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
                Networking(search: { _ in
                    Just([])
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                })
            }
        )

        let expects: [Podcast] = []

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
                Networking(search: { _ in
                    Just<[Podcast]>([
                        Podcast(
                            trackName: "Track01",
                            artistName: "Swift0",
                            artworkUrl600: .none,
                            trackCount: 123,
                            feedUrlSting: .none
                        )
                    ])
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
                })
            }
        )

        let expects: [Podcast] = [
            Podcast(
                trackName: "Track01",
                artistName: "Swift0",
                artworkUrl600: .none,
                trackCount: 123,
                feedUrlSting: .none
            )
        ]

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
