//
//  Category.swift
//  TodoList
//
//  Created by Fiona Miao on 3/9/18.
//  Copyright © 2018 Fiona Miao. All rights reserved.
//

import Foundation
import RealmSwift


class Category: Object{
    
    @objc dynamic var name: String = ""
    //define a child object
    let items = List<Item>()
    
}
