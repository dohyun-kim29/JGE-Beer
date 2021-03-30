//
//  JGE_BeerTests.swift
//  JGE-BeerTests
//
//  Created by GoEun Jeong on 2021/03/30.
//

import XCTest
import RxCocoa
import RxSwift
import RxTest
import Moya

@testable import JGE_Beer

class ListViewControllerTests: XCTestCase {
    
    var viewModel: ListViewModel!
    var disposeBag: DisposeBag!
    var scheduler: TestScheduler!
    var output: ListViewModel.Output!
    
    override func setUpWithError() throws {
        viewModel = ListViewModel()
        disposeBag = DisposeBag()
        scheduler = TestScheduler(initialClock: 0, resolution: 0.01)
        
        let refreshTrigger = scheduler.createHotObservable([.next(100, ())])
            .asSignal(onErrorJustReturn: ())
        
        let input = ListViewModel.Input(provider: MoyaProvider<BeerAPI>(stubClosure: { _ in .immediate }), refreshTrigger: refreshTrigger, nextPageSignal: .empty())
        output = viewModel.transform(input: input)
    }
    
    // MARK: - RxTest
    
    func testIndicatorEvents() throws {
        let observer = scheduler.createObserver(Bool.self)
        
        output.isLoading
            .emit(to: observer)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        let exceptEvents: [Recorded<Event<Bool>>] = [
            .next(0, false),
            .next(100, true),
            .next(100, false)
        ]
        
        XCTAssertEqual(observer.events, exceptEvents)
    }
    
    func testListCount() throws {
        let observer = scheduler.createObserver(Int.self)
        
        output.list
            .map { $0.count }
            .bind(to: observer)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        let exceptEvents: [Recorded<Event<Int>>] = [
            .next(0, 0),
            .next(100, 25)
        ]
        
        XCTAssertEqual(observer.events, exceptEvents)
    }
    
    func testUserData() throws {
        let observer = scheduler.createObserver(Beer?.self)
        
        output.list
            .map({ $0.last })
            .bind(to: observer)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        let exceptEvents: [Recorded<Event<Beer?>>] = [
            .next(0, nil),
            .next(100, Beer(id: 25, name: "Bad Pixie", description: "2008 Prototype beer, a 4.7% wheat ale with crushed juniper berries and citrus peel.", imageURL: "https://images.punkapi.com/v2/25.png"))
        ]
        
        XCTAssertEqual(observer.events, exceptEvents)
    }
}
