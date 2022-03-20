//
//  InfiniteScrollViewController.swift
//  vadmitrievaPW8
//
//  Created by Varvara on 20.03.2022.
//

import UIKit

class InfiniteScrollViewController: UIViewController {
    private let searchBar = UITextField(frame: CGRect(x: 0, y: 0, width: 300, height: 20))
    private let tableView = UITableView()
    private let apiKey = "554e7ac8416f0775b18600664214853d"
    private let searchButton = UIButton(type: .system)
    
    var movies: [Movie]!

    private var page = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        tableView.backgroundColor = .white
        page = 1
        movies = [Movie]()
        configureUI()
        DispatchQueue.global(qos: .background).async {
            [weak self] in
            self?.loadMovies()
        }
    }
    
    private func configureUI() {
        setupButtons()
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MovieView.self, forCellReuseIdentifier: MovieView.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        tableView.reloadData()
    }
    
    private func setupButtons() {
        view.addSubview(searchButton)
        searchButton.setImage(UIImage(named: "search"), for: .normal)
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            searchButton.heightAnchor.constraint(equalToConstant: 25),
            searchButton.widthAnchor.constraint(equalToConstant: 25)
        ])
        searchButton.addTarget(self, action: #selector(searchButtonPressed),
        for: .touchUpInside)
        
        
    }
    
    @objc
    private func searchButtonPressed() {
        navigationController?.pushViewController(SearchViewController(), animated: true)
    }
    
    private func loadImagesForMovies(_ movies: [Movie], completion: @escaping ([Movie]) -> Void) {
        let group = DispatchGroup()
        for movie in movies {
            group.enter()
            DispatchQueue.global(qos: .background).async {
                movie.loadPoster {_ in
                    group.leave()
                }
            }
        }
        group.notify(queue: .main) {
            completion(movies)
        }
    }
    
    private func loadMovies() {
        guard let url = URL(string: "https://api.themoviedb.org/3/discover/movie?api_key=\(apiKey)&language=ruRu&page=\(page)") else {
            return assertionFailure("some problems with url")
        }
        let session = URLSession.shared.dataTask(with: URLRequest(url: url), completionHandler: {[weak self] data, _, _ in
            guard
                let data = data,
                let dict = try? JSONSerialization.jsonObject(with: data, options: .json5Allowed) as? [String: Any],
                let result = dict["results"] as? [[String: Any]]
            else {
                    return
                }
            let movies: [Movie] = result.map { params in
                let title = params["title"] as! String
                let imagePath = params["poster_path"] as? String
                return Movie(title: title, posterPath: imagePath)
            }
            self?.loadImagesForMovies(movies) { movies in
                for movie in movies {
                    self?.movies.append(movie)
                }
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        })
        session.resume()
    }
}

extension InfiniteScrollViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if movies != nil {
            return movies.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MovieView.identifier, for: indexPath) as! MovieView
        cell.configure(movie: movies[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250.0;//Choose your custom row height
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == Int(0.8 * Double(movies.count)) {
            page += 1
            if page <= 1000 {
                loadMovies()
            }
        }
    }
}

