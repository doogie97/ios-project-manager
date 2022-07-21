//
//  NetworkStorage.swift
//  ProjectManager
//
//  Created by 두기 on 2022/07/21.
//

import FirebaseDatabase

struct NetworkStorage {
    private let database = Database.database()
    
    init() {
        database.isPersistenceEnabled = true
    }
    
    func createItem(_ item: ListItemDTO) {
        let object: [String: Any] = [
            "title": item.title,
            "body": item.body,
            "deadline": item.deadline.timeIntervalSince1970,
            "type": item.type,
            "id": item.id
        ]
        database.reference().child(item.type).child(item.id).setValue(object)
    }
    
    func deleteItem(_ item: ListItemDTO) {
        database.reference().child(item.type).child(item.id).removeValue()
    }
}
