//
//  SearchViewController.swift
//  vadmitrievaPW8
//
//  Created by Varvara on 18.03.2022.
//

import UIKit

class SearchViewController: UIViewController, UITextFieldDelegate {
    private let searchBar = UITextField(frame: CGRect(x: 0, y: 0, width: 300, height: 20))
    private let tableView = UITableView()
    private let apiKey = "554e7ac8416f0775b18600664214853d"
    
    var movies: [Movie]!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.backgroundColor = .white
        configureUI()
    }

    private func configureUI() {
        searchBar.isUserInteractionEnabled = true
        searchBar.delegate = self
        searchBar.backgroundColor = .lightGray
        view.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            searchBar.heightAnchor.constraint(equalToConstant: 30)
        ])
        searchBar.addTarget(self, action: #selector(SearchViewController.textFieldDidChange(_:)), for: .editingChanged)
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MovieView.self, forCellReuseIdentifier: MovieView.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        tableView.reloadData()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        let searchRequest = textField.text ?? ""
        DispatchQueue.global(qos: .background).async {
            [weak self] in
            self?.loadMovies(search: searchRequest)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            self.view.endEditing(true)
            return false
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
    
    private func loadMovies(search: String) {
        let request = search.replacingOccurrences(of: " ", with: "+")
        guard let url = URL(string: "https://api.themoviedb.org/3/search/movie?api_key=\(apiKey)&query=\(request)") else {
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
                self?.movies = movies
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        })
        session.resume()
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
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
}
