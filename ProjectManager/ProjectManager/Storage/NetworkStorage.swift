//
//  NetworkStorage.swift
//  ProjectManager
//
//  Created by 두기 on 2022/07/20.
//

import FirebaseDatabase

struct NetworkStorage {
    private let database = Database.database()
    
    init() {
        database.isPersistenceEnabled = true
    }
    
    func addTodo(_ item: ListItemDTO) {
        let object: [String: Any] = [
            "title": item.title,
            "body": item.body,
            "deadline": item.deadline.timeIntervalSince1970,
            "type": item.type,
            "id": item.id
        ]
        database.reference().child("TODO").child(item.id).setValue(object)
    }
}
