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
}
