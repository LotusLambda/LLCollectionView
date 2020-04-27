import SwiftUI

public struct LLCollectionView: UIViewRepresentable {
    @ObservedObject var viewModel: ViewModel
    
    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    public func makeUIView(context: Context) -> UICollectionView {
        viewModel.view
    }
    
    public func updateUIView(_ uiView: UICollectionView, context: Context) {
        
    }
    
    public func makeCoordinator() -> () {
        
    }
}
