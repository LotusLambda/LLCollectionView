import SwiftUI

public struct LLItem {
    public let reuseIdentifier: String
    public let size: (UICollectionView) -> CGSize
    
    public init(reuseIdentifier: String, size: @escaping (UICollectionView) -> CGSize) {
        self.reuseIdentifier = reuseIdentifier
        self.size = size
    }
}
