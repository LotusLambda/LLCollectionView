public struct LLSection {
    public let reuseIdentifier: String
    public let items: [LLItem]
    
    public init(reuseIdentifier: String, items: [LLItem]) {
        self.reuseIdentifier = reuseIdentifier
        self.items = items
    }
}
