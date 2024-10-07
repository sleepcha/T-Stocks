final class LinkedList<T> {
    private final class Node {
        var value: T
        var next: Node?

        init(value: T, next: Node? = nil) {
            self.value = value
            self.next = next
        }
    }

    private var head: Node?
    private var tail: Node?

    func append(_ value: T) {
        let newNode = Node(value: value)
        if let tail {
            tail.next = newNode
        } else {
            head = newNode
        }
        tail = newNode
    }

    func removeAll() {
        head = nil
        tail = nil
    }

    @discardableResult
    func popFirst() -> T? {
        let headValue = head?.value
        head = head?.next
        return headValue
    }
}
