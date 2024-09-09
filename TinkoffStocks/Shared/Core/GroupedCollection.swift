import Foundation

struct GroupedCollection<Group: Hashable, Element> {
    var numberOfGroups: Int { result.count }

    private let groupingKey: (Element) -> Group
    private let groupsComparator: KeyPathComparator<Group>
    private let elementsComparator: KeyPathComparator<Element>

    private var result = [(group: Group, elements: [Element])]()

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

    subscript(groupIndex: Int) -> (group: Group, numberOfElements: Int) {
        (result[groupIndex].group, result[groupIndex].elements.count)
    }

    subscript(indexPath: IndexPath) -> Element {
        let groupIndex = indexPath.section
        let elementIndex = indexPath.row
        return result[groupIndex].elements[elementIndex]
    }

    mutating func set(with array: [Element]) {
        let collections = Dictionary(grouping: array, by: groupingKey)
        let groups = collections.keys.sorted(using: groupsComparator)

        // array of tuples sorted by tuple's first item (group)
        result = groups.map { group in
            (group, collections[group]!.sorted(using: elementsComparator))
        }
    }
}
