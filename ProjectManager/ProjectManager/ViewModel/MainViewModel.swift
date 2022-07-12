//
//  MainViewModel.swift
//  ProjectManager
//
//  Created by 두기 on 2022/07/06.
//

import RxSwift
import RxRelay
import RxCocoa

protocol MainViewModelOutput {
    var todoList: Driver<[ListItem]> { get }
    var doingList: Driver<[ListItem]> { get }
    var doneList: Driver<[ListItem]> { get }
}

protocol MainViewModelInput {
    func isOverDeadline(listItem: ListItem) -> Bool
    func peekList(index: Int, type: ListType, completion: @escaping ((ListItem) -> Void))
    func creatList(listItem: ListItem)
    func updateList(listItem: ListItem)
    func deleteList(listItem: ListItem)
    func changeListType(listItem: ListItem, type: ListType)
}

final class MainViewModel: MainViewModelOutput {
    private var storage = MockStorage()

//MARK: - output
    let todoList: Driver<[ListItem]>
    let doingList: Driver<[ListItem]>
    let doneList: Driver<[ListItem]>
    
    init() {
        todoList = storage.list
            .map{ $0.filter { $0.type == .todo }}
            .asDriver(onErrorJustReturn: [])
        
        doingList = storage.list
            .map{ $0.filter { $0.type == .doing }}
            .asDriver(onErrorJustReturn: [])
        
        doneList = storage.list
            .map{ $0.filter { $0.type == .done }}
            .asDriver(onErrorJustReturn: [])
    }
}

//MARK: - input
extension MainViewModel: MainViewModelInput {
    func isOverDeadline(listItem: ListItem) -> Bool {
        return listItem.type != .done && listItem.deadline < Date()
    }
    
    func peekList(index: Int, type: ListType, completion: @escaping ((ListItem) -> Void)) {
        switch type {
        case .todo:
            _ = todoList.drive(onNext: {
                completion($0[index])
            })
        case .doing:
            _ = doingList.drive(onNext: {
                completion($0[index])
            })
        case .done:
            _ = doneList.drive(onNext: {
                completion($0[index])
            })
        }
    }
    
    func creatList(listItem: ListItem) {
        
    }
    
    func updateList(listItem: ListItem) {
        
    }
    
    func deleteList(listItem: ListItem) {
        
    }
    
    func changeListType(listItem: ListItem, type: ListType) {
        
    }
}
