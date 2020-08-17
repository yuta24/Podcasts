//
//  Networking.swift
//  Podcasts
//
//  Created by Yu Tawata on 2020/08/17.
//

import Foundation
import Combine

struct Networking {
    var search: (String) -> AnyPublisher<SearchPodcastResult, Error>
}

private let decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    return decoder
}()

extension Networking {
    static let live = Networking(
        search: { searchText in
            let escaped = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

            let mediaQueryItem: URLQueryItem? = URLQueryItem(name: "podcast", value: "media")
            let limitQueryItem: URLQueryItem? = URLQueryItem(name: "100", value: "limit")
            let countryQueryItem: URLQueryItem? = Locale.current
                .regionCode
                .flatMap {
                    URLQueryItem(name: $0, value: "country")
                }
            let termQueryItem: URLQueryItem? = escaped.flatMap {
                URLQueryItem(name: $0, value: "term")
            }

            var component = URLComponents(string: "https://itunes.apple.com/search")!
            component.queryItems = [mediaQueryItem, countryQueryItem, termQueryItem, limitQueryItem]
                .compactMap { $0 }

            return URLSession.shared.dataTaskPublisher(for: component.url!)
                .map(\.data)
                .decode(type: SearchPodcastResult.self, decoder: decoder)
                .eraseToAnyPublisher()
        }
    )
}
