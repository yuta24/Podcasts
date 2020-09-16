//
//  Networking.swift
//  Podcasts
//
//  Created by Yu Tawata on 2020/08/17.
//

import Foundation
import Combine
import os.log
import Alamofire
import FeedKit

struct Networking {
    struct Failure: Error, Equatable {}

    var searchPodcasts: (String) -> AnyPublisher<SearchPodcastResult, Failure>
    var fetchPodcast: (URL) -> AnyPublisher<FetchPodcastResult, Failure>
    var downloadEpisode: (URL) -> AnyPublisher<URL, Failure>
}

private let decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return decoder
}()

private let logger = Logger(subsystem: "com.bivre.podcasts", category: "Networking")

extension Networking {
    static let live = Networking(
        searchPodcasts: { searchText in
            let escaped = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

            let mediaQueryItem: URLQueryItem? = URLQueryItem(name: "media", value: "podcast")
            let limitQueryItem: URLQueryItem? = URLQueryItem(name: "limit", value: "50")
            let countryQueryItem: URLQueryItem? = Locale.current.regionCode.flatMap { URLQueryItem(name: "country", value: $0) }
            let termQueryItem: URLQueryItem? = escaped.flatMap { URLQueryItem(name: "term", value: $0) }

            var component = URLComponents(string: "https://itunes.apple.com/search")!
            component.queryItems = [mediaQueryItem, countryQueryItem, termQueryItem, limitQueryItem]
                .compactMap { $0 }

            logger.debug("\(component.url!)")

            return AF.request(component.url!).publishDecodable(type: SearchPodcastResult.self, decoder: decoder)
                .value()
                .mapError { _ in Failure() }
                .eraseToAnyPublisher()
        },
        fetchPodcast: { feedUrl in
            let parser = FeedParser(URL: feedUrl)

            return Deferred {
                Future<FetchPodcastResult, Failure> { callback in
                    parser.parseAsync { result in
                        switch result {
                        case let .success(feed):
                            callback(.success(FetchPodcastResult(feed.rssFeed!)))
                        case let .failure(parserError):
                            callback(.failure(Failure()))
                        }
                    }
                }
            }
            .eraseToAnyPublisher()
        },
        downloadEpisode: { url in
            Deferred {
                Future<URL, Failure> { callback in
                    AF.download(url).response { response in
                        if let error = response.error {
                            callback(.failure(Failure()))
                        } else if let url = response.fileURL {
                            logger.debug("\(url)")
                            callback(.success(url))
                        }
                    }
                }
            }
            .eraseToAnyPublisher()
            .eraseToAnyPublisher()
        }
    )
}

extension Networking {
    static let mock = Networking(
        searchPodcasts: { _ in
            Fail<SearchPodcastResult, Failure>(error: Failure())
                .eraseToAnyPublisher()
        },
        fetchPodcast: { _ in
            Fail<FetchPodcastResult, Failure>(error: Failure())
                .eraseToAnyPublisher()
        },
        downloadEpisode: { _ in
            Fail<URL, Failure>(error: Failure())
                .eraseToAnyPublisher()
        }
    )
}
