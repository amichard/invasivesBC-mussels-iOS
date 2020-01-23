//
//  DropdownHelper.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-26.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation

extension Array where Element : Equatable {
    var unique: [Element] {
        var uniqueValues: [Element] = []
        forEach { item in
            if !uniqueValues.contains(item) {
                uniqueValues += [item]
            }
        }
        return uniqueValues
    }
}

class DropdownHelper {
    
    static let shared = DropdownHelper()
    private init() {}
    
    public func getDropdown(for type: CodeTableType) -> [DropdownModel] {
        let items = Storage.shared.codeTable(type: type)
        return dropdown(from: items)
    }
    
    public func dropdown(from items: [String]) -> [DropdownModel] {
        var options: [DropdownModel] = []
        let set = Array(Set(items)).sorted()
        for item in set {
            options.append(DropdownModel(display: item))
        }
        return options
    }
    
    public func dropdownContains(key: String, dropdownItems: [DropdownModel]) -> Bool {
        for item in dropdownItems where item.key == key {
            return true
        }
        return false
    }
}
