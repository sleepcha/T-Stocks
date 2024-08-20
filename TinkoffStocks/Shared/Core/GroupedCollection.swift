import Foundation

// MARK: - GroupedCollection

struct GroupedCollection<Group: Hashable, Element> {
    var groupCount: Int { groups.count }
    
    private let groupingKey: (Element) -> Group
    private let groupsComparator: KeyPathComparator<Group>
    private let elementsComparator: KeyPathComparator<Element>

    private var collections = [Group: [Element]]()
    private var groups = [Group]()

    init(
        _ array: [Element]? = nil,
        groupedBy: @escaping (Element) -> Group,
        groupsSortedBy: KeyPathComparator<Group>,
        elementsSortedBy: KeyPathComparator<Element>
    ) {
        self.groupingKey = groupedBy
        self.groupsComparator = groupsSortedBy
        self.elementsComparator = elementsSortedBy
        if let array { set(with: array) }
    }

    mutating func set(with array: [Element]) {
        collections = Dictionary(grouping: array, by: groupingKey)
        groups = collections.keys.sorted(using: groupsComparator)

        for i in collections.values.indices {
            collections.values[i].sort(using: elementsComparator)
        }
    }

    subscript(index: Int) -> (group: Group, elements: [Element]) {
        let group = groups[index]
        return (group, collections[group]!)
    }

    subscript(indexPath: IndexPath) -> Element {
        let group = groups[indexPath.section]
        return collections[group]![indexPath.row]
    }
}
