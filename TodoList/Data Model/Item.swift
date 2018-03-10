//
//  Item.swift
//  TodoList
//
//  Created by Fiona Miao on 3/9/18.
//  Copyright © 2018 Fiona Miao. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    
    //use linkingObjects to define a inverse relationship, ie parent object
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
    
}
