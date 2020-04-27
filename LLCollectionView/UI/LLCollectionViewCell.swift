import SwiftUI

struct LLCollectionViewCellContentView: View {
    class ViewModel: ObservableObject {
        @Published var view: AnyView?
    }
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        ZStack {
            viewModel.view
        }
    }
}

class LLCollectionViewCell: UICollectionViewCell {
    lazy var host = UIHostingController(rootView: LLCollectionViewCellContentView(viewModel: viewModel))
    private let viewModel = LLCollectionViewCellContentView.ViewModel()
    
    var view: AnyView? {
        get {
            viewModel.view
        }
        set {
            viewModel.view = newValue
        }
    }
    
    override init(frame: CGRect) {        
        super.init(frame: frame)
        
        let cellContent = self.host.view!
        
        cellContent.backgroundColor = .clear
        
        cellContent.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cellContent)
        
        cellContent.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        cellContent.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        cellContent.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        cellContent.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview != nil {
            host.view.sizeToFit()
        }
    }
    
}
