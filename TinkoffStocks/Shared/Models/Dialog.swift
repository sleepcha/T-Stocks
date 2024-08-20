struct Dialog {
    struct Action {
        enum Kind {
            case primary, cancel, destructive
        }

        let title: String
        let kind: Kind
        let handler: () -> Void
    }

    let title: String
    let text: String
    let actions: [Action]
}
