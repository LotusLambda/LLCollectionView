import SwiftUI

public struct LLCollectionView: UIViewRepresentable {
    @ObservedObject var viewModel: LLCollectionViewModel
    
    let layout = UICollectionViewFlowLayout()
    
    public init(
        viewModel: LLCollectionViewModel
    ) {
        print("Init Collection view")
       
        self.viewModel = viewModel
    }
    
    public func makeUIView(context: Context) -> UICollectionView {
        print("Make Collection view")
        
        layout.scrollDirection = .horizontal
        layout.sectionInsetReference = .fromSafeArea
        layout.sectionInset = .zero
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.delegate = context.coordinator
        view.insetsLayoutMarginsFromSafeArea = false
        view.backgroundColor = .clear
        view.bounces = viewModel.bounces
        view.showsVerticalScrollIndicator = viewModel.showsVerticalScrollIndicator
        view.showsHorizontalScrollIndicator = viewModel.showsHorizontalScrollIndicator
        view.register(LLCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        context.coordinator.view = view

        view.dataSource = context.coordinator.dataSource
        
        return view
    }
    
    public func updateUIView(_ uiView: UICollectionView, context: Context) {
        print("Update Collection view")
        context.coordinator.view = uiView
        
        context.coordinator.reloadData()
    }
    
    public static func dismantleUIView(_ uiView: Self.UIViewType, coordinator: Self.Coordinator) {
        print("Dismantle Collection view")
    }
    
    public func makeCoordinator() -> LLCollectionViewModel {
        print("Make Coordinator")
        
        return viewModel
    }
}

extension LLCollectionView {
    public func sectionInsetReference(_ sectionInsetReference: UICollectionViewFlowLayout.SectionInsetReference) -> Self {
        self.layout.sectionInsetReference = sectionInsetReference
        
        return self
    }
    
    public func bounces(_ bounces: Bool) -> Self {
        self.viewModel.bounces = bounces
        
        return self
    }
    
    public func showsVerticalScrollIndicator(_ showsVerticalScrollIndicator: Bool) -> Self {
        self.viewModel.showsVerticalScrollIndicator = showsVerticalScrollIndicator
        
        return self
    }
    
    public func showsHorizontalScrollIndicator(_ showsHorizontalScrollIndicator: Bool) -> Self {
        self.viewModel.showsHorizontalScrollIndicator = showsHorizontalScrollIndicator
        
        return self
    }
}
//
//extension LLCollectionView {
//    public func insetsForSection(_ insets: @escaping (Int) -> UIEdgeInsets) -> Self {
//        self.viewModel.insetsBlock = insets
//
//        return self
//    }
//}

