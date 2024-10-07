import Foundation

// MARK: - GroupedCollection

struct GroupedCollection<Group: Hashable, Element> {
    typealias GroupOfElements = (group: Group, elements: [Element])

    private let groupingKey: (Element) -> Group
    private let groupsComparator: KeyPathComparator<Group>
    private let elementsComparator: KeyPathComparator<Element>

    private var groups = [GroupOfElements]()

    init(
        _ array: [Element]? = nil,
        groupedBy: @escaping (Element) -> Group,
        groupsSortedBy: KeyPath<Group, some Comparable>,
        groupsOrder: SortOrder = .forward,
        elementsSortedBy: KeyPath<Element, some Comparable>,
        elementsOrder: SortOrder = .forward
    ) {
        self.groupingKey = groupedBy
        self.groupsComparator = KeyPathComparator(groupsSortedBy, order: groupsOrder)
        self.elementsComparator = KeyPathComparator(elementsSortedBy, order: elementsOrder)
        if let array { set(with: array) }
    }

    subscript(index: Int) -> GroupOfElements {
        groups[index]
    }

    subscript(indexPath: IndexPath) -> Element {
        groups[indexPath.section].elements[indexPath.item]
    }

    mutating func set(with array: [Element]) {
        let collections = Dictionary(grouping: array, by: groupingKey)
        let groupKeys = collections.keys.sorted(using: groupsComparator)

        // array of tuples sorted by tuple's first item (group)
        groups = groupKeys.map { group in
            (group, collections[group]!.sorted(using: elementsComparator))
        }
    }
}

extension GroupedCollection {
    func asDataSource<Item>(groupName: KeyPath<Group, String>?, transform: (Element) -> Item) -> DataSource<Item> {
        DataSource(sections: groups.map {
            DataSource.Section(
                header: (groupName == nil) ? nil : $0.group[keyPath: groupName!],
                items: $0.elements.map(transform)
            )
        })
    }
}
