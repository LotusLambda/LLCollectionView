import SwiftUI
import Combine

extension LLCollectionView {
    public class LLCollectionViewModel: NSObject, ObservableObject, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
        weak var view: UICollectionView?
        let viewBlock: ((LLSection, LLItem, IndexPath) -> AnyView)?
        var insetsBlock: ((Int) -> UIEdgeInsets)?
        
        private var _scrollViewDidScrollSubject = PassthroughSubject<UICollectionView, Never>()
        private var _didSelectItemSubject = PassthroughSubject<(UICollectionView, IndexPath), Never>()
        
        @Published public var initialIndexPath: IndexPath?
        private var initialIndexPathWasSet = false
        
        public var bounces: Bool {
            get {
                self.view?.bounces ?? true
            }
            set {
                self.view?.bounces = newValue
            }
        }
        
        public var showsVerticalScrollIndicator: Bool {
            get {
                self.view?.showsVerticalScrollIndicator ?? true
            }
            set {
                self.view?.showsVerticalScrollIndicator = newValue
            }
        }
        
        public var showsHorizontalScrollIndicator: Bool {
            get {
                self.view?.showsHorizontalScrollIndicator ?? true
            }
            set {
                self.view?.showsHorizontalScrollIndicator = newValue
            }
        }
        
//        public var initialIndexPath: IndexPath? {
//            didSet {
//                if let indexPath = initialIndexPath {
//                    DispatchQueue.main.async {
//                        self.view.scrollToItem(at: indexPath, at: .left, animated: false)
//                    }
//                }
//            }
//        }
        
        public init(viewBlock: @escaping (LLSection, LLItem, IndexPath) -> AnyView) {
            self.viewBlock = viewBlock
        }
        
        public func scrollToItem(at indexPath: IndexPath, at scrollPosition: UICollectionView.ScrollPosition, animated: Bool) {
            DispatchQueue.main.async {
                self.view?.scrollToItem(at: indexPath, at: scrollPosition, animated: animated)
            }
        }
        
        public func scrollViewDidScroll() -> AnyPublisher<UICollectionView, Never> {
            _scrollViewDidScrollSubject.eraseToAnyPublisher()
        }
        
        public func visibleIndexPath() -> AnyPublisher<IndexPath?, Never> {
            self.scrollViewDidScroll().map { [weak self] (collectionView) in
                guard let self = self else { return nil }
                var point = collectionView.contentOffset
                point.x += collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right + 1
                point.y += collectionView.bounds.height / 2
                 
                if
                    collectionView.contentOffset.x + collectionView.bounds.width >= collectionView.contentSize.width - 1,
                    collectionView.contentSize != .zero
                {
                    let lastSectionIndex = self.sections.count - 1
                    
                    if lastSectionIndex < 0 {
                        return nil
                    }
                    
                    let lastItemIndex = self.sections[lastSectionIndex].items.count - 1
                    
                    if lastItemIndex < 0 {
                        return nil
                    }
                    
                    return IndexPath(item: lastItemIndex, section: lastSectionIndex)
                }
                return collectionView.indexPathForItem(at: point)
            }.removeDuplicates().eraseToAnyPublisher()
        }
        
        public func didSelectItem() -> AnyPublisher<(UICollectionView, IndexPath), Never> {
            _didSelectItemSubject.eraseToAnyPublisher()
        }
        
        lazy var dataSource: UICollectionViewDiffableDataSource<String, String> = {
            print("Init datasource")
            
            return UICollectionViewDiffableDataSource<String, String>(collectionView: view!) { [weak self] (collectionView, indexPath, reuseIdentifier) -> UICollectionViewCell? in
                    guard let self = self else { return nil }
                    
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! LLCollectionViewCell
                    
                    let section = self.sections[indexPath.section]
                    let item = section.items[indexPath.item]
                    cell.host.rootView = self.viewBlock?(section, item, indexPath) ?? AnyView(EmptyView())
    //                if item.reuseIdentifier != cell.viewModel.loadedId {
    //                    let view = self.viewBlock?(section, item, indexPath) ?? AnyView(EmptyView())
    //                    let frame = cell.bounds
    //
    //                    cell.view = AnyView(view.frame(width: frame.size.width, height: frame.size.height)
    //                        .edgesIgnoringSafeArea(.all))
    //                    cell.viewModel.loadedId = item.reuseIdentifier
    //
    //                }
                    
                    return cell
                }
        }()
        
        @Published public var sections: [LLSection] = [] {
            didSet {
                print("Updated sections!", sections.count)
            }
        }
        
        public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            if
                let section = sections[safe: indexPath.section],
                let item = section.items[safe: indexPath.item]
            {
                return item.size(collectionView)
            }
            
            return .zero
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
        
        public func reloadData() {
            guard
                view != nil
            else { return }
                        
            print("Reloading data", self.sections.count, self.view!)

            let sections = self.sections

            DispatchQueue.global(qos: .background).async { [weak self] in
                guard let self = self else { return }
                
                var snapshot = NSDiffableDataSourceSnapshot<String, String>()
                
                snapshot.appendSections(sections.map { $0.reuseIdentifier })
                
                sections.forEach { (section) in
                    snapshot.appendItems(section.items.map { item in
                        let reuseIdentifier = section.reuseIdentifier + item.reuseIdentifier
                        
                        return reuseIdentifier
                    }, toSection: section.reuseIdentifier)
                }
                
                func scroll() {
                    if
                        !self.initialIndexPathWasSet,
                        let indexPath = self.initialIndexPath {
                        DispatchQueue.main.async { [weak self] in
                            self?.view?.scrollToItem(at: indexPath, at: .left, animated: false)
                            self?.initialIndexPathWasSet = true
                        }
                    }
                }
                
                self.dataSource.apply(snapshot, animatingDifferences: true, completion: {
                    scroll()
                })
                
                scroll()
            }
        }

    }
}

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
