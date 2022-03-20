//
//  Movie.swift
//  vadmitrievaPW8
//
//  Created by Varvara on 17.03.2022.
//

import UIKit

class Movie {
    let title: String
    let posterPath: String?
    var poster: UIImage? = nil
    let id: Int
    let overview: String?
    
    init(title: String, posterPath: String?, id: Int, overview: String?) {
        self.title = title
        self.posterPath = posterPath
        self.id = id
        self.overview = overview
    }
    
    func loadPoster(completion: @escaping (UIImage?) -> Void) {
        guard
            let posterPath = posterPath,
            let url = URL(string: "https://image.tmdb.org/t/p/original/\(posterPath)")
        else {
                return completion(nil)
            }
        let request = URLSession.shared.dataTask(with: URLRequest(url: url)) {
            [weak self] data, _, _ in
            guard
                let data = data,
                let image = UIImage(data: data) else {
                    return completion(nil)
                }
            self?.poster = image
            completion(image)
        }
        request.resume()
    }
}
