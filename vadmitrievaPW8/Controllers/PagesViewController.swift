//
//  PagesViewController.swift
//  vadmitrievaPW8
//
//  Created by Varvara on 20.03.2022.
//

import UIKit

class PagesViewController: UIViewController {
    private let tableView = UITableView()
    private let apiKey = "554e7ac8416f0775b18600664214853d"
    private let searchButton = UIButton(type: .system)
    
    private var page = 1
    private let previousButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)
    private let currentPage = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
    
    var movies: [Movie]!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        tableView.backgroundColor = .white
        page = 1
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
            tableView.bottomAnchor.constraint(equalTo: previousButton.topAnchor, constant: -5),
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
        
        view.addSubview(previousButton)
        previousButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            previousButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            previousButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            previousButton.heightAnchor.constraint(equalToConstant: 20),
            previousButton.widthAnchor.constraint(equalToConstant: 60)
        ])
        previousButton.setTitle("previous", for: .normal)
        previousButton.setTitleColor(.black, for: .normal)
        previousButton.setTitle("previous", for: .disabled)
        previousButton.setTitleColor(.gray, for: .disabled)
        if page == 1 {
            previousButton.isEnabled = false
        } else {
            previousButton.isEnabled = true
        }
        previousButton.addTarget(self, action: #selector(loadPreviousPage),
            for: .touchUpInside)
        
        view.addSubview(nextButton)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nextButton.topAnchor.constraint(equalTo: previousButton.topAnchor),
            nextButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30),
            nextButton.heightAnchor.constraint(equalToConstant: 20),
            nextButton.widthAnchor.constraint(equalToConstant: 60)
        ])
        nextButton.setTitle("next", for: .normal)
        nextButton.setTitleColor(.black, for: .normal)
        nextButton.setTitle("next", for: .disabled)
        nextButton.setTitleColor(.gray, for: .disabled)
        if page == 1000 {
            nextButton.isEnabled = false
        } else {
            nextButton.isEnabled = true
        }
        nextButton.addTarget(self, action: #selector(loadNextPage),
            for: .touchUpInside)
        
        view.addSubview(currentPage)
        currentPage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            currentPage.topAnchor.constraint(equalTo: previousButton.topAnchor),
            currentPage.leadingAnchor.constraint(equalTo: previousButton.trailingAnchor, constant: 15),
            currentPage.trailingAnchor.constraint(equalTo: nextButton.leadingAnchor, constant: -15),
            currentPage.heightAnchor.constraint(equalToConstant: 20)
        ])
        currentPage.text = String(page)
        currentPage.textAlignment = .center
    }
    
    @objc
    private func loadPreviousPage() {
        page -= 1
        currentPage.text = String(page)
        if page == 1 {
            previousButton.isEnabled = false
        } else {
            previousButton.isEnabled = true
        }
        if page == 1000 {
            nextButton.isEnabled = false
        } else {
            nextButton.isEnabled = true
        }
        loadMovies()
    }
    
    @objc
    private func loadNextPage() {
        page += 1
        currentPage.text = String(page)
        if page == 1 {
            previousButton.isEnabled = false
        } else {
            previousButton.isEnabled = true
        }
        if page == 1000 {
            nextButton.isEnabled = false
        } else {
            nextButton.isEnabled = true
        }
        loadMovies()
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
                let id = params["id"] as! Int
                let overview = params["overview"] as? String
                return Movie(title: title, posterPath: imagePath, id: id, overview: overview)
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

extension PagesViewController: UITableViewDataSource, UITableViewDelegate {
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
