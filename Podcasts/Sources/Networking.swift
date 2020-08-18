//
//  Networking.swift
//  Podcasts
//
//  Created by Yu Tawata on 2020/08/17.
//

import Foundation
import Combine
import OSLog

struct Networking {
    struct Failure: Error, Equatable {}

    var search: (String) -> AnyPublisher<SearchPodcastResult, Failure>
}

private let decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    return decoder
}()

private let logger = Logger(subsystem: "com.bivre.podcasts", category: "Networking")

extension Networking {
    static let live = Networking(
        search: { searchText in
            let escaped = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

            let mediaQueryItem: URLQueryItem? = URLQueryItem(name: "media", value: "podcast")
            let limitQueryItem: URLQueryItem? = URLQueryItem(name: "limit", value: "50")
            let countryQueryItem: URLQueryItem? = Locale.current
                .regionCode
                .flatMap {
                    URLQueryItem(name: "country", value: $0)
                }
            let termQueryItem: URLQueryItem? = escaped.flatMap {
                URLQueryItem(name: "term", value: $0)
            }

            var component = URLComponents(string: "https://itunes.apple.com/search")!
            component.queryItems = [mediaQueryItem, countryQueryItem, termQueryItem, limitQueryItem]
                .compactMap { $0 }

            logger.debug("\(component.url!)")

            return URLSession.shared.dataTaskPublisher(for: component.url!)
                .map(\.data)
                .decode(type: SearchPodcastResult.self, decoder: decoder)
                .mapError { _ in Failure() }
                .eraseToAnyPublisher()
        }
    )
}
