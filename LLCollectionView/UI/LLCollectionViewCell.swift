import SwiftUI

class LLCollectionViewCell: UICollectionViewCell {
    var host: UIHostingController<AnyView>?
}
/*
class LLCollectionViewCell: UICollectionViewCell {
    class Model: ObservableObject {
        @Published var view: AnyView? = nil
    }
    
    struct ContentView: View {
        @ObservedObject var model: Model
        
        init(model: Model) {
            self.model = model
        }
        
        var body: some View {
            VStack {
                HStack {
                    self.model.view
                }
            }
        }
    }
    
    lazy var width: NSLayoutConstraint = {
        let width = contentView.widthAnchor.constraint(equalToConstant: bounds.size.width)
        width.isActive = true
        return width
    }()
    
    let model = Model()
    lazy var controller = UIHostingController(rootView: ContentView(model: self.model))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .red
        
        let uiView = controller.view!
        
        uiView.translatesAutoresizingMaskIntoConstraints = false
        uiView.backgroundColor = .clear
//        uiView.frame = contentView.bounds
        let size = uiView.sizeThatFits(UIScreen.main.bounds.size)
        
        print("Frame: ", uiView.frame, size)
        contentView.addSubview(uiView)
        
        uiView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        uiView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        uiView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: uiView.bottomAnchor).isActive = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

}
*/
