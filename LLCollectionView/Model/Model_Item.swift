import SwiftUI

extension Model {
    public struct Item {
        let reuseIdentifier: String
        let view: AnyView
        
        public init<T: View>(reuseIdentifier: String, view: T) {
            self.reuseIdentifier = reuseIdentifier
            self.view = AnyView(view)
        }
    }
}
