import SwiftUI
import Combine

extension LLCollectionView {
    public class ViewModel: NSObject, ObservableObject, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
        public lazy var view: UICollectionView = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            layout.sectionInsetReference = .fromContentInset
//            layout.sectionInset = .zero
            
            let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
            view.delegate = self
            view.insetsLayoutMarginsFromSafeArea = false
            view.backgroundColor = .clear
//            view.insetsLayoutMarginsFromSafeArea = false
            return view
        }()
        
        var viewBlock: ((LLSection, LLItem, IndexPath) -> AnyView)?
        var insetsBlock: ((Int) -> UIEdgeInsets)?
        
        private var _scrollViewDidScrollSubject = PassthroughSubject<UICollectionView, Never>()
        private var _didSelectItemSubject = PassthroughSubject<(UICollectionView, IndexPath), Never>()
        
        public var initialIndexPath: IndexPath? {
            didSet {
                if let indexPath = initialIndexPath {
                    DispatchQueue.main.async {
                        self.view.scrollToItem(at: indexPath, at: .left, animated: false)
                    }
                }
            }
        }
        
        public func scrollToItem(at indexPath: IndexPath, at scrollPosition: UICollectionView.ScrollPosition, animated: Bool) {
            DispatchQueue.main.async {
                self.view.scrollToItem(at: indexPath, at: scrollPosition, animated: animated)
            }
        }
        
        public func scrollViewDidScroll() -> AnyPublisher<UICollectionView, Never> {
            _scrollViewDidScrollSubject.eraseToAnyPublisher()
        }
        
        public func visibleIndexPath() -> AnyPublisher<IndexPath?, Never> {
            self.scrollViewDidScroll().map { (collectionView) in
                var point = collectionView.contentOffset
                point.x += collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right + 1
                point.y += collectionView.bounds.height / 2
                 
                if
                    collectionView.contentOffset.x + collectionView.bounds.width >= collectionView.contentSize.width - 1,
                    collectionView.contentSize != .zero
                {
                    let lastSectionIndex = self.sections.count - 1
                    let lastItemIndex = self.sections[lastSectionIndex].items.count - 1
                    return IndexPath(item: lastItemIndex, section: lastSectionIndex)
                }
                return collectionView.indexPathForItem(at: point)
            }.removeDuplicates().eraseToAnyPublisher()
        }
        
        public func didSelectItem() -> AnyPublisher<(UICollectionView, IndexPath), Never> {
            _didSelectItemSubject.eraseToAnyPublisher()
        }
        
        lazy var dataSource: UICollectionViewDiffableDataSource<String, String> = {
            let dataSource = UICollectionViewDiffableDataSource<String, String>(collectionView: self.view) { (collectionView, indexPath, reuseIdentifier) -> UICollectionViewCell? in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! LLCollectionViewCell
                
                
//                if cell.view == nil {
                    let section = self.sections[indexPath.section]
                    let item = section.items[indexPath.item]
                    let view = self.viewBlock?(section, item, indexPath) ?? AnyView(EmptyView())
                    let frame = cell.bounds
                    cell.view = AnyView(view.frame(width: frame.size.width, height: frame.size.height)
                    .edgesIgnoringSafeArea(.all))
//                }
                
                return cell
            }
            
            return dataSource
        }()
        
        public var sections: [LLSection] {
            didSet {                
                reloadData()
            }
        }
        
        public init(sections: [LLSection] = []) {
            self.sections = sections
            
            super.init()
            
            self.view.dataSource = dataSource
        }
        
        public func reloadData() {
            DispatchQueue.global(qos: .background).async { [weak self] in
                guard let self = self else { return }
                
                var snapshot = NSDiffableDataSourceSnapshot<String, String>()
                
                snapshot.appendSections(self.sections.map { $0.reuseIdentifier })
                
                self.sections.forEach { (section) in
                    snapshot.appendItems(section.items.map { item in
                        let reuseIdentifier = section.reuseIdentifier + item.reuseIdentifier
                        
                        DispatchQueue.main.async {
                            self.view.register(LLCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
                        }
                        
                        return reuseIdentifier
                    }, toSection: section.reuseIdentifier)
                }
                
                self.dataSource.apply(snapshot, animatingDifferences: true, completion: {
                    if let indexPath = self.initialIndexPath {
                        DispatchQueue.main.async {
                            self.view.scrollToItem(at: indexPath, at: .left, animated: false)
                        }
                    }
                })
                
                if let indexPath = self.initialIndexPath {
                    DispatchQueue.main.async {
                        self.view.scrollToItem(at: indexPath, at: .left, animated: false)
                    }
                }
            }
        }
        
        public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            sections[indexPath.section].items[indexPath.item].size(collectionView)
        }
        
        public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            0
        }
        
        public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            self.insetsBlock?(section) ?? .zero
        }
        
        public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            0
        }
        
        public func scrollViewDidScroll(_ scrollView: UIScrollView) {
            _scrollViewDidScrollSubject.send(scrollView as! UICollectionView)
        }
        
        public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            _didSelectItemSubject.send((collectionView, indexPath))
        }
    }
}
