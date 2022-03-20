//
//  DetailedViewController.swift
//  vadmitrievaPW8
//
//  Created by Varvara on 20.03.2022.
//

import UIKit

class DetailedViewController: UIViewController {
    var detailedView: DetailedView!
    
    var movieTitle: String?
    var poster: UIImage? = nil
    var overview: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        detailedView = DetailedView(posterImg: poster, title: movieTitle ?? "", overview: overview)
        view.backgroundColor = .white
        view.addSubview(detailedView)
    }
    
    public func configure(title: String, posterImg: UIImage, overview: String?) {
        self.movieTitle = title
        self.poster = posterImg
        self.overview = overview
    }
}
