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
    var showHistoryView: PublishRelay<[History]> { get }
    var showEditView: PublishRelay<ListItem> { get }
    var showErrorAlert: PublishRelay<String?> { get }
    var showNetworkErrorAlert: PublishRelay<StorageError> { get }
    var isConnectedInternet: PublishRelay<Bool> { get }
}

protocol MainViewModelInput {
    func touchAddButton()
    func touchHistoryButton()
    func touchCell(index: Int, type: ListType)
    func deleteCell(index: Int, type: ListType)
    func changeItemType(index: Int, type: ListType, to: ListType)
}

final class MainViewModel: MainViewModelInOut {
    private let storage: AppStoregeable
    private let networkMonitor: NWPathMonitor

//MARK: - output
    let todoList: Driver<[ListItem]>
    let doingList: Driver<[ListItem]>
    let doneList: Driver<[ListItem]>
    
    init(storage: AppStoregeable, networkMonitor: NWPathMonitor) {
        self.storage = storage
        self.networkMonitor = networkMonitor
        todoList = storage.todoList.asDriver(onErrorJustReturn: [])
        doingList = storage.doingList.asDriver(onErrorJustReturn: [])
        doneList = storage.doneList.asDriver(onErrorJustReturn: [])
        checkNetwork()
        if UserDefaults.standard.bool(forKey: "lunchedBefore") == false {
            setList()
        }
    }
    
    private func checkNetwork() {
        networkMonitor.start(queue: DispatchQueue.global())
        networkMonitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                DispatchQueue.main.async {
                    self.isConnectedInternet.accept(true)
                }
            }
            
            if path.status != .satisfied  {
                DispatchQueue.main.async {
                    if UserDefaults.standard.bool(forKey: "lunchedBefore") == false {
                        self.showNetworkErrorAlert.accept(StorageError.networkError)
                    }
                    self.isConnectedInternet.accept(false)
                }
            }
        }
    }
    
    private func setList() {
        storage.setList { result in
            switch result {
            case .success():
                UserDefaults.standard.set(true, forKey: "lunchedBefore")
            case .failure(_):
                self.showNetworkErrorAlert.accept(StorageError.networkError)
            }
        }
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
    
    let showAddView = PublishRelay<Void>()
    let showHistoryView = PublishRelay<[History]>()
    let showEditView = PublishRelay<ListItem>()
    let showErrorAlert = PublishRelay<String?>()
    let showNetworkErrorAlert = PublishRelay<StorageError>()
    let isConnectedInternet = PublishRelay<Bool>()
}

//MARK: - input
extension MainViewModel {
    func isOverDeadline(listItem: ListItem) -> Bool {
        return listItem.type != .done && listItem.deadline < Date()
    }
    
    func touchAddButton() {
        showAddView.accept(())
    }
    
    func touchHistoryButton() {
        showHistoryView.accept(storage.readHistory().reversed())
    }
    
    func touchCell(index: Int, type: ListType) {
        let item = storage.selectItem(index: index, type: type)
        showEditView.accept(item)
    }
    
    func deleteCell(index: Int, type: ListType) {
        do {
            let item = storage.selectItem(index: index, type: type)
            try storage.deleteItem(listItem: item)
            try storage.makeHistory(title: "Removed '\(item.title)'.")
        } catch {
            guard let error = error as? StorageError else {
                showErrorAlert.accept(nil)
                return
            }
            
            showErrorAlert.accept(error.errorDescription)
        }
    }
    
    func changeItemType(index: Int, type: ListType, to destination: ListType) {
        do {
            let item = storage.selectItem(index: index, type: type)
            try storage.changeItemType(listItem: item, destination: destination)
            try storage.makeHistory(title: "Moved '\(item.title)' from \(type.title) to \(destination.title).")
        } catch {
            guard let error = error as? StorageError else {
                showErrorAlert.accept(nil)
                return
            }
            
            showErrorAlert.accept(error.errorDescription)
        }
    }
}
