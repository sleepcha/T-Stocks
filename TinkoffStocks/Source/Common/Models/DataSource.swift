//
//  DataSource.swift
//  T-Stocks
//
//  Created by sleepcha on 9/8/24.
//

import Foundation

struct DataSource<Item> {
    struct Section {
        let header: String?
        let items: [Item]
        var numberOfItems: Int {
            items.count
        }
    }

    let sections: [Section]
    var numberOfSections: Int {
        sections.count
    }

    subscript(indexPath: IndexPath) -> Item {
        sections[indexPath.section].items[indexPath.row]
    }
}
