//
//  DetailedView.swift
//  vadmitrievaPW8
//
//  Created by Varvara on 20.03.2022.
//

import UIKit

class DetailedView: UIView {
    let poster = UIImageView()
    let title = UILabel()
    let overview = UITextView()
    
    init(posterImg: UIImage?, title: String, overview: String?) {
        super.init(frame: CGRect(x: 0, y: 0, width: 320, height: 1000))
        setupUI()
        self.poster.image = posterImg
        self.title.text = title
        self.overview.text = overview
    }
    
    func setupUI() {
        addSubview(poster)
        poster.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            poster.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            poster.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            poster.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            poster.heightAnchor.constraint(equalToConstant: 300),
            poster.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor)
        ])
        
        addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: poster.bottomAnchor, constant: 10),
            title.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            title.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            title.heightAnchor.constraint(equalToConstant: 20)
        ])
        title.textAlignment = .center
        title.font = UIFont.boldSystemFont(ofSize: 14.0)
        
        addSubview(overview)
        overview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            overview.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 10),
            overview.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            overview.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            overview.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
        overview.isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
