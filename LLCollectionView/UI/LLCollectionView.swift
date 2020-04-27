import SwiftUI

public struct LLCollectionView: UIViewRepresentable {
    @ObservedObject var viewModel: ViewModel
    
    public init<Content: View>(
        viewModel: ViewModel,
        @ViewBuilder view: @escaping (LLSection, LLItem, IndexPath) -> Content
    ) {
        viewModel.viewBlock = { (section, item, indexPath) in
            return AnyView(view(section, item, indexPath))
        }
        self.viewModel = viewModel
    }
    
    public func makeUIView(context: Context) -> UICollectionView {
        viewModel.view
    }
    
    public func updateUIView(_ uiView: UICollectionView, context: Context) {
        
    }
    
    public static func dismantleUIView(_ uiView: Self.UIViewType, coordinator: Self.Coordinator) {
//        coordinator.sections = []
    }
    
    public func makeCoordinator() -> ViewModel {
        viewModel
    }
}

extension LLCollectionView {
    public func insetsForSection(_ insets: @escaping (Int) -> UIEdgeInsets) -> Self {
        self.viewModel.insetsBlock = insets
        
        return self
    }
}
