import SwiftUI
import LLCollectionView

struct ContentView: View {
    @ObservedObject var viewModel = LLCollectionView.ViewModel()
    
    @State var isShowing = true
    
    var body: some View {
        VStack {
            if isShowing {
                LLCollectionView(viewModel: viewModel)
                    .frame(height: 200)
                
            }
            
            Button(action: {
                self.isShowing.toggle()
            }) {
                Text("Tap")
            }
        }.onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.viewModel.sections = [
                    .init(items: [
                        .init(reuseIdentifier: "Test 1", view: Text("Test with bigger text!").background(Color.orange)),
                        .init(reuseIdentifier: "Test 2", view: Text("Test! asd asd as sadasdassda asdasdasd dasdas 123 123 123 4321")),
                        .init(reuseIdentifier: "Test", view: Text("Test!")),
                        .init(reuseIdentifier: "Test", view: Text("Test!")),
                        .init(reuseIdentifier: "Test", view: Text("Test!")),
                        .init(reuseIdentifier: "Test", view: Text("Test!")),
                        .init(reuseIdentifier: "Test", view: Text("Test!")),
                        .init(reuseIdentifier: "Test", view: Text("Test!")),
                        .init(reuseIdentifier: "Test", view: Text("Test!")),
                        .init(reuseIdentifier: "Test", view: Text("Test!")),
                    ])
                ]
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
