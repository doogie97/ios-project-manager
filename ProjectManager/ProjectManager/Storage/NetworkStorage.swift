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
        readItem(.todo) { result in
            switch result {
            case .success(let items):
                for item in items {
                    print(item.title)
                }
            case .failure(_):
                print("에러임")
            }
        }
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
    
    func updateItem(_ item: ListItemDTO) {
        let object: [String: Any] = [
            "title": item.title,
            "body": item.body,
            "deadline": item.deadline.timeIntervalSince1970,
            "type": item.type,
            "id": item.id
        ]
        database.reference().child(item.type).child(item.id).updateChildValues(object)
    }
    
    func readItem(_ type: ListType, _ completion: @escaping ((Result<[ListItemDTO], Error>) -> Void)) {
        database.reference().child(type.rawValue).getData { error, snapshot in
            guard error == nil else {
                completion(.failure(error!)) //여기에 스토어에러 보내면 됨
                return
            }
            
            guard let value = snapshot?.value as? [String: Any] else {
                return
            }
            
            let items: [ListItemDTO] = value.compactMap {
                guard let values = $0.value as? [String: Any] else {
                    return nil
                }
                
                let item = ListItemDTO()
                item.title = values["title"] as? String ?? ""
                item.deadline = Date(timeIntervalSince1970: values["deadline"] as? Double ?? 0)
                item.body = values["body"] as? String ?? ""
                item.type = values["type"] as? String ?? ""
                item.id = values["id"] as? String ?? ""
                
                return item
            }
            
            completion(.success(items))
        }
    }
}
