import SwiftUI

extension LLCollectionView {
    public class ViewModel: NSObject, ObservableObject {
        public lazy var view: UICollectionView = {
            let layout = UICollectionViewFlowLayout()
            
            layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            layout.scrollDirection = .horizontal
            let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = .white
            view.delegate = self
            view.dataSource = self
            return view
        }()
        
        public var sections: [Model.Section] {
            didSet {
                sections.forEach { $0.items.forEach { (item) in
                    view.register(LLCollectionViewCell.self, forCellWithReuseIdentifier: item.reuseIdentifier)
                } }
                view.reloadData()
            }
        }
        
        public init(sections: [Model.Section] = []) {
            self.sections = sections
        }
    }
}

extension LLCollectionView.ViewModel: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        sections.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        sections[section].items.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = sections[indexPath.section]
        let item = section.items[indexPath.item]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: item.reuseIdentifier, for: indexPath) as! LLCollectionViewCell
        let view = item.view//.fixedSize()
        
        // create & setup hosting controller only once
        if cell.host == nil {
            let controller = UIHostingController(rootView: AnyView(view))
            cell.host = controller

            let cellContent = controller.view!
            cellContent.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(cellContent)
            cellContent.topAnchor.constraint(equalTo: cell.contentView.topAnchor).isActive = true
            cellContent.leftAnchor.constraint(equalTo: cell.contentView.leftAnchor).isActive = true
            cellContent.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor).isActive = true
            cellContent.rightAnchor.constraint(equalTo: cell.contentView.rightAnchor).isActive = true
        } else {
            // reused cell, so just set other SwiftUI root view
            cell.host?.rootView = AnyView(view)
        }
        cell.setNeedsLayout()
        
        return cell
    }
}
