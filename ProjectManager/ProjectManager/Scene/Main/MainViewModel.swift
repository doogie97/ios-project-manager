//
//  MainViewModel.swift
//  ProjectManager
//
//  Created by 두기 on 2022/07/06.
//

import RxSwift
import RxRelay
import RxCocoa
import Network

protocol MainViewModelInOut: MainViewModelInput, MainViewModelOutput {}

protocol MainViewModelOutput {
    var todoList: Driver<[ListItem]> { get }
    var doingList: Driver<[ListItem]> { get }
    var doneList: Driver<[ListItem]> { get }
    func isOverDeadline(listItem: ListItem) -> Bool
    func listCount(_ type: ListType) -> Driver<String>
    
    var showAddView: PublishRelay<Void> { get }
    var showEditView: PublishRelay<ListItem> { get }
    var isConnectedInternet: PublishRelay<Bool> { get }
}

protocol MainViewModelInput {
    func touchAddButton()
    func touchCell(index: Int, type: ListType)
    func deleteCell(index: Int, type: ListType)
    func changeItemType(index: Int, type: ListType, to: ListType)
}

final class MainViewModel: MainViewModelInOut {
    private var storage: Storegeable
    let networkMonitor = NWPathMonitor()
    
    func checkNetwork() {
        networkMonitor.start(queue: DispatchQueue.global())
        networkMonitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                DispatchQueue.main.async {
                    self.isConnectedInternet.accept(true)
                }
            } else {
                DispatchQueue.main.async {
                    self.isConnectedInternet.accept(false)
                }
            }
        }
    }

//MARK: - output
    let todoList: Driver<[ListItem]>
    let doingList: Driver<[ListItem]>
    let doneList: Driver<[ListItem]>
    
    init(storage: Storegeable) {
        self.storage = storage
        
        todoList = storage.todoList.asDriver(onErrorJustReturn: [])
        doingList = storage.doingList.asDriver(onErrorJustReturn: [])
        doneList = storage.doneList.asDriver(onErrorJustReturn: [])
        checkNetwork()
    }
    
    func listCount(_ type: ListType) -> Driver<String> {
        switch type {
        case .todo:
            return todoList.map{ "\($0.count)"}
        case .doing:
            return doingList.map{ "\($0.count)"}
        case .done:
            return doneList.map{ "\($0.count)"}
        }
    }
    
    var showAddView = PublishRelay<Void>()
    var showEditView = PublishRelay<ListItem>()
    var isConnectedInternet = PublishRelay<Bool>()
}

//MARK: - input
extension MainViewModel {
    func isOverDeadline(listItem: ListItem) -> Bool {
        return listItem.type != .done && listItem.deadline < Date()
    }
    
    func touchAddButton() {
        showAddView.accept(())
    }
    
    func touchCell(index: Int, type: ListType) {
        let item = storage.selectItem(index: index, type: type)
        showEditView.accept(item)
    }
    
    func deleteCell(index: Int, type: ListType) {
        storage.deleteItem(index: index, type: type)
    }
    
    func changeItemType(index: Int, type: ListType, to destination: ListType) {
        storage.changeItemType(index: index, type: type, destination: destination)
    }
}
