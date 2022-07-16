//
//  DetailViewModel.swift
//  ProjectManager
//
//  Created by 두기 on 2022/07/13.
//

import Foundation

protocol DetailViewModelable: DetailViewModelOutput, DetailViewModelInput{}

protocol DetailViewModelOutput {
    var list: ListItem { get }
}

protocol DetailViewModelInput {
    func changeTitle(_ text: String?)
    func changeDaedLine(_ date: Date?)
    func changeBody(_ text: String?)
    func creatList()
    func updateList()
}

final class DetailViewModel: DetailViewModelable {
    private let storage: Storegeable
    var list: ListItem
    
    init(storage: Storegeable, list: ListItem?) {
        self.storage = storage
        self.list = list ?? ListItem(title: "", body: "", deadline: Date())
    }
    
    func changeTitle(_ text: String?) {
        list.title = text ?? ""
    }
    
    func changeDaedLine(_ date: Date?) {
        list.deadline = date ?? Date()
    }
    
    func changeBody(_ text: String?) {
        list.body = text ?? ""
    }
    
    func creatList() {
        storage.creatList(listItem: list)
    }
    
    func updateList() {
        storage.updateList(listItem: list)
    }
}
