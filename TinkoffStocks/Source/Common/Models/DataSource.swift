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
    }

    var sections: [Section]

    var numberOfSections: Int {
        sections.count
    }

    func numberOfItems(in section: Int) -> Int {
        guard section < sections.count else { return 0 }
        return sections[section].items.count
    }

    subscript(indexPath: IndexPath) -> Item {
        sections[indexPath.section].items[indexPath.row]
    }
}
