//
//  Beer.swift
//  JGE-Beer
//
//  Created by GoEun Jeong on 2021/03/27.
//

import UIKit
import SnapKit
import RxSwift
import Kingfisher
import Reachability

class BeerView: UIView {
    private let stackSpacing: CGFloat = 10.0
    private let padding: CGFloat = 16.0
    private var disposeBag = DisposeBag()
    
    private lazy var beerImageView: UIImageView = {
        let beerImageView = UIImageView()
        beerImageView.contentMode = .scaleAspectFit
        beerImageView.snp.makeConstraints {
            $0.height.width.equalTo(UIScreen.main.bounds.height / 3.5)
        }
        return beerImageView
    }()
    
    private lazy var idLabel: UILabel = {
        let idLabel = UILabel()
        idLabel.textColor = UIColor.orange
        idLabel.text = "ID"
        idLabel.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        return idLabel
    }()
    
    private lazy var nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.text = "User Name"
        return nameLabel
    }()
    
    private lazy var descLabel: UILabel = {
        let descLabel = UILabel()
        descLabel.text = "Description"
        descLabel.textColor = UIColor.gray
        descLabel.numberOfLines = 0
        return descLabel
    }()
    
    private lazy var nameStackView: UIStackView = {
        let nameStackView = UIStackView(arrangedSubviews: [beerImageView, idLabel, nameLabel, descLabel])
        nameStackView.axis = .vertical
        nameStackView.alignment = .center
        nameStackView.spacing = stackSpacing
        return nameStackView
    }()
    
    // MARK: - Initialization
    
    override func draw(_ rect: CGRect) {
        setupSubview()
    }
    
    // MARK: - Public Methods
    
    public func configure(with beer: Beer) {
        if beer.imageURL != nil {
            if #available(iOS 12.0, *) {
                if CheckInternet.shared.isInternet() == true {
                    self.beerImageView.kf.setImage(with: URL(string: beer.imageURL!))
                } else {
                    self.beerImageView.kf.setImage(with: URL(string: beer.imageURL!), options: [.cacheMemoryOnly])
                }
            }
            else {
                let reachability = try? Reachability()
                
                reachability?.whenReachable = { _ in
                    self.beerImageView.kf.setImage(with: URL(string: beer.imageURL!))
                }
                
                reachability?.whenUnreachable = { _ in
                    self.beerImageView.kf.setImage(with: URL(string: beer.imageURL!), options: [.cacheMemoryOnly])
                }
            }
        }
        idLabel.text = beer.id != nil ? String(beer.id!) : ""
        nameLabel.text = beer.name
        descLabel.text = beer.description
    }
    
    // MARK: Private Methods
    
    private func setupSubview() {
        addSubview(nameStackView)
        nameStackView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(padding)
        }
    }
}
