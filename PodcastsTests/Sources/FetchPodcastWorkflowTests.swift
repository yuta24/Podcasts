//
//  FetchPodcastWorkflowTests.swift
//  PodcastsTests
//
//  Created by Yu Tawata on 2020/08/18.
//

import Combine
import XCTest
@testable import Podcasts

class FetchPodcastWorkflowTests: XCTestCase {
    private var workflow: FetchPodcastWorkflow!

    private var cancellables = Set<AnyCancellable>()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_Fetching() throws {
        // Given
        workflow = FetchPodcastWorkflow(
            networking: Networking(
                search: { _ in
                    Fail<SearchPodcastResult, Networking.Failure>(error: Networking.Failure())
                        .eraseToAnyPublisher()
                },
                fetchPodcast: { _ in
                    Just(
                        FetchPodcastResult(
                            title: "Title",
                            desc: "Description",
                            link: URL(string: "https://www.google.com/")!,
                            author: "yuta24",
                            imageUrl: .none,
                            summary: "Summary",
                            episodes: []
                        )
                    )
                    .setFailureType(to: Networking.Failure.self)
                    .eraseToAnyPublisher()
                },
                downloadEpisode: { _ in
                    Fail<URL, Networking.Failure>(error: Networking.Failure())
                        .eraseToAnyPublisher()
                }
            )
        )

        let expects: FetchPodcastResult = .init(
            title: "Title",
            desc: "Description",
            link: URL(string: "https://www.google.com/")!,
            author: "yuta24",
            imageUrl: .none,
            summary: "Summary",
            episodes: []
        )

        let exp = expectation(description: "\(#function):\(#line)")

        // When
        workflow.execute(URL(string: "https://www.google.com/")!)
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
