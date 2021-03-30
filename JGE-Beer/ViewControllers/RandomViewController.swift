//
//  RandomViewController.swift
//  JGE-Beer
//
//  Created by GoEun Jeong on 2021/03/27.
//

import UIKit
import Moya
import RxSwift
import RxCocoa
import SnapKit

class RandomViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let randomView = BeerView()
    private var viewModel: RandomViewModel?
    
    private lazy var randomButton: UIButton = {
        let randomButton = UIButton()
        randomButton.isHighlighted = false
        randomButton.setImage(UIImage(named: "Dice"), for: .normal)
        randomButton.setImage(UIImage(named: "Dice"), for: .highlighted)
        randomButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 30)
        randomButton.setTitle("돌려돌려 돌림판", for: .normal)
        randomButton.titleEdgeInsets = UIEdgeInsets(top: 10, left: 30, bottom: 10, right: 30)
        randomButton.backgroundColor = UIColor.orange
        randomButton.clipsToBounds = true
        randomButton.layer.cornerRadius = 10
        return randomButton
    }()
    
    private lazy var indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        return indicator
    }()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationTitle()
        bindViewModel()
    }
    
    // MARK: - Private Methods
    
    private func setupNavigationTitle() {
        self.navigationItem.title = "아무거나"
        self.navigationItem.accessibilityLabel = "아무거나 검색"
    }
    
    private func setupSubview() {
        view.backgroundColor = .white
        view.addSubview(randomView)
        randomView.addSubview(indicator)
        randomView.addSubview(randomButton)
        
        randomView.snp.makeConstraints {
            $0.top.equalTo(view.layoutMarginsGuide)
            $0.size.equalToSuperview()
        }
        
        randomButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.layoutMarginsGuide).offset(-30)
            $0.width.equalTo(view.snp.width).offset(-30)
            $0.height.equalTo(40)
        }
    }
    
    private func bindViewModel() {
        viewModel = RandomViewModel()
        
        let buttonTrigger = Driver<Void>.merge(.of(()), randomButton.rx.tap.asDriver())
        
        let input = RandomViewModel.Input(provider: MoyaProvider<BeerAPI>(),
                                        buttonTrigger: buttonTrigger)
        
        let output = viewModel?.transform(input: input)
        
        output?.beer
            .subscribe(onNext: { [weak self] beer in
                self?.randomView.configure(with: beer.first ?? Beer(id: nil, name: "", description: "", imageURL: nil))
                self?.setupSubview()
            })
            .disposed(by: disposeBag)
        
        output?.isLoading
            .filter { !$0 }
            .drive(indicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        output?.errorRelay
            .subscribe(onNext: { [weak self] error in
                self?.showErrorAlert(with: error.localizedDescription)
            }).disposed(by: disposeBag)
    }
}
