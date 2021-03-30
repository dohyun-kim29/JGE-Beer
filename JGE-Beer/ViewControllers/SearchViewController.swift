//
//  SearchViewController.swift
//  JGE-Beer
//
//  Created by GoEun Jeong on 2021/03/27.
//

import UIKit
import Moya
import RxSwift
import RxCocoa
import SnapKit

class SearchViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let randomView = BeerView()
    private var viewModel: SearchViewModel?
    
    private lazy var indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        return indicator
    }()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBar()
        bindViewModel()
    }
    
    // MARK: - Private Methods
    
    private func setupNavigationBar() {
        self.navigationItem.searchController = searchController
        searchController.searchBar.keyboardType = .numbersAndPunctuation
        self.navigationItem.title = "ID 검색"
        self.navigationItem.accessibilityLabel = "맥주 ID 검색"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        searchController.searchBar.rx.searchButtonClicked
            .subscribe(onNext: {
                self.searchController.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupSubview() {
        view.backgroundColor = .white
        view.addSubview(randomView)
        randomView.addSubview(indicator)
        
        randomView.snp.makeConstraints {
            $0.top.equalTo(view.layoutMarginsGuide)
            $0.size.equalToSuperview()
        }
    }
    
    private func bindViewModel() {
        viewModel = SearchViewModel()
        
        let searchTrigger = searchController.searchBar.rx.text.orEmpty.debounce(RxTimeInterval.microseconds(5), scheduler: MainScheduler.instance).distinctUntilChanged().asSignal(onErrorJustReturn: "0")
        
        let input = SearchViewModel.Input(provider: MoyaProvider<BeerAPI>(),
                                          searchTrigger: searchTrigger)
        
        let output = viewModel?.transform(input: input)
        
        output?.beer
            .subscribe(onNext: { [weak self] beer in
                self?.randomView.configure(with: beer.first ?? Beer(id: nil, name: "", description: "", imageURL: nil))
                self?.setupSubview()
            })
            .disposed(by: disposeBag)
        
        output?.isLoading
            .filter { !$0 }
            .emit(to: indicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        output?.errorRelay
            .subscribe(onNext: { [weak self] error in
                self?.showErrorAlert(with: error.localizedDescription)
            }).disposed(by: disposeBag)
    }
}
