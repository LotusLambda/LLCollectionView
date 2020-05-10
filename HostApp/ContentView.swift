import SwiftUI
import LLCollectionView

struct ContentView: View {
    @ObservedObject var viewModel = LLCollectionView.LLCollectionViewModel()

    @State var isShowing = true
    
    var body: some View {
        VStack {
            if isShowing {
                LLCollectionView(viewModel: viewModel, view: { (section, item, indexPath) in
                    Text("My view")
                    Text("My view 2")
                    EmptyView()
                })
                .frame(height: 200)   
            }
            
            Button(action: {
//                self.isShowing.toggle()
                self.viewModel.sections.append(.init(reuseIdentifier: UUID().uuidString, items: [
                    .init(reuseIdentifier: UUID().uuidString, size: { _ in
                        .zero
                    })
                ]))
            }) {
                Text("Tap")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
