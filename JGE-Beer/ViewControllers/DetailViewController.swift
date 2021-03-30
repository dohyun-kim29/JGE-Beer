//
//  DetailViewController.swift
//  JGE-Beer
//
//  Created by GoEun Jeong on 2021/03/30.
//

import UIKit
import Moya
import RxSwift
import RxCocoa
import SnapKit

class DetailViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let detailView = BeerView()
    private let beer: Beer
    
    private lazy var indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        return indicator
    }()
    
    // MARK: - Initialization

    init(beer: Beer) {
      self.beer = beer
      super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        setupNavigationTitle()
        setupSubview()
    }
    
    // MARK: - Private Methods
    
    private func setupNavigationTitle() {
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationItem.title = beer.name
        self.navigationItem.accessibilityLabel = beer.name
    }
    
    private func setupSubview() {
        view.backgroundColor = .white
        detailView.configure(with: beer)
        view.addSubview(detailView)
        detailView.addSubview(indicator)
        
        detailView.snp.makeConstraints {
            $0.top.equalTo(view.layoutMarginsGuide)
            $0.size.equalToSuperview()
        }
    }
}
