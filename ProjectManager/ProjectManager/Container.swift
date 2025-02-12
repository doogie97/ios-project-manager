//
//  Container.swift
//  ProjectManager
//
//  Created by 두기 on 2022/07/13.
//
import Network
import UIKit

final class Container {
    private let storage: AppStoregeable
    
    func makeMainViewController() -> MainViewController {
        return MainViewController(viewModel: makeMainViewModel(), container: self)
    }
    
    private func makeMainViewModel() -> MainViewModelInOut {
        return MainViewModel(storage: storage, networkMonitor: NWPathMonitor())
    }
    
    func makeAddViewController() -> AddViewController {
        let addVC = AddViewController(viewModel: makeAddViewModel())
        addVC.modalPresentationStyle = .formSheet
        return addVC
    }
    
    private func makeAddViewModel() -> AddViewModelable {
        return AddViewModel(storage: storage)
    }
    
    func makeEditViewController(_ listItem: ListItem) -> EditViewController {
        let editVC = EditViewController(viewModel: makeEditViewModel(listItem))
        editVC.modalPresentationStyle = .formSheet
        return editVC
    }

    private func makeEditViewModel(_ listItem: ListItem) -> EditViewModelable {
        return EditViewModel(storage: storage, item: listItem)
    }
    
    func makeHistoryViewController(sourceView: UIView, bounds: CGRect, history: [History]) -> HistoryViewController {
        let historyVC = HistoryViewController(viewModel: makeHistoryViewModel(history))
        historyVC.modalPresentationStyle = .popover
        historyVC.preferredContentSize = CGSize(width: 500, height: 500)
        guard let popover = historyVC.popoverPresentationController else {
            return historyVC
        }
        popover.sourceView = sourceView
        popover.sourceRect = CGRect(x: bounds.minX, y: bounds.minY + 20, width: bounds.width, height: bounds.height)
        
        return historyVC
    }
    
    private func makeHistoryViewModel(_ history: [History]) -> HistoryViewModelable {
        return HistoryViewModel(history: history)
    }
    
    init(storage: AppStoregeable) {
        self.storage = storage
    }
}
