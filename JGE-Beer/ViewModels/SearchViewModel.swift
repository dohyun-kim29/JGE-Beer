//
//  SearchViewModel.swift
//  JGE-Beer
//
//  Created by GoEun Jeong on 2021/03/28.
//

import RxSwift
import RxCocoa
import Moya

class SearchViewModel: ViewModelType {
    private var disposeBag = DisposeBag()
    
    // MARK: - ViewModelType
    
    struct Input {
        let provider: MoyaProvider<BeerAPI>
        let searchTrigger: Driver<String>
    }
    
    struct Output {
        let beer: BehaviorRelay<[Beer]>
        let isLoading: Driver<Bool>
        let errorRelay: PublishRelay<Error>
    }
    
    func transform(input: Input) -> Output {
        let activityIndicator = ActivityIndicator()
        let beer = BehaviorRelay<[Beer]>(value: [])
        let errorRelay = PublishRelay<Error>()
        
        input.searchTrigger
            .asObservable()
            .flatMapLatest { id in
                input.provider.rx.request(.searchID(id: Int(id) ?? 0))
                    .filterSuccessfulStatusCodes()
                    .map([Beer].self)
                    .trackActivity(activityIndicator)
                    .do(onError: { errorRelay.accept($0) })
                    .catchErrorJustReturn([])
            }
            .bind(to: beer)
            .disposed(by: disposeBag)
        
        return Output(beer: beer, isLoading: activityIndicator.asDriver(), errorRelay: errorRelay)
    }
}
