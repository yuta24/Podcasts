//
//  UnfavoritePodcastWorkflowTests.swift
//  PodcastsTests
//
//  Created by Yu Tawata on 2020/08/21.
//

import Combine
import XCTest
@testable import Podcasts

class UnfavoritePodcastWorkflowTests: XCTestCase {
    private var workflow: UnfavoritePodcastWorkflow!
    private let userDefaults = UserDefaults(suiteName: "\(#file)")!

    private var cancellables = Set<AnyCancellable>()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        userDefaults.removeObject(forKey: "favorites")
    }

    func test_Unfavoriting() throws {
        let spy = FavoritedPodcastDataStoreSpy(
            fetchs: { Just([]).eraseToAnyPublisher() },
            fetch: { Just(.none).eraseToAnyPublisher() },
            changed: { Just([]).eraseToAnyPublisher() })

        // Given
        workflow = UnfavoritePodcastWorkflow(dataStore: spy.dataStore)

        let exp = expectation(description: "\(#function):\(#line)")

        let podcast: PodcastExt = .init(
            title: "Title",
            desc: "Description",
            link: URL(string: "https://www.google.com/")!,
            author: "yuta24",
            imageUrl: .none,
            summary: "Summary",
            episodes: [],
            isFavorited: true
        )

        // When
        workflow.execute(podcast)
            .sink(
                receiveCompletion: { completion in
                    exp.fulfill()
                },
                receiveValue: { _ in
                    // Then
                    XCTAssertEqual(spy.fetchsCallCount, 0)
                    XCTAssertEqual(spy.fetchCallCount, 0)
                    XCTAssertEqual(spy.appendCallCount, 0)
                    XCTAssertEqual(spy.removeCallCount, 1)
                    XCTAssertEqual(spy.changedCallCount, 0)
                }
            )
            .store(in: &cancellables)

        wait(for: [exp], timeout: 0.1)
    }
}
