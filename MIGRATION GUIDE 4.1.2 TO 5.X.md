IQListKit MIGRATION GUIDE 4.1.2 TO 5.X
==========================

### 1. Register header Footer

Old registerHeaderFooter function 
```swift
    func registerHeaderFooter<T: UIView>(type: T.Type, registerType: RegisterType, bundle: Bundle = .main)
```
New function renamed to registerSupplementaryView and now include a new paameter 'kind' to also povide the kind of supplementaryView. This change has been made to make library compatible for modern collection view.
```swift
    func registerSupplementaryView<T: IQListSupplementaryView>(type: T.Type, kind: String,
                                                               registerType: RegisterType,
                                                               bundle: Bundle = .main)
```

### 2. Delegate function changes

Old delegate functions
```swift
    func listView(_ listView: IQListView, modifyHeader headerView: UIView, section: IQSection, at sectionIndex: Int)
    func listView(_ listView: IQListView, modifyFooter footerView: UIView, section: IQSection, at sectionIndex: Int)
    func listView(_ listView: IQListView, willDisplayHeaderView view: UIView, section: IQSection, at sectionIndex: Int)
    func listView(_ listView: IQListView, didEndDisplayingHeaderView view: UIView, section: IQSection, at sectionIndex: Int)
    func listView(_ listView: IQListView, willDisplayFooterView view: UIView, section: IQSection, at sectionIndex: Int)
    func listView(_ listView: IQListView, didEndDisplayingFooterView view: UIView, section: IQSection, at sectionIndex: Int)
```
New delegate functions
```swift
    func listView(_ listView: IQListView, modifySupplementaryElement view: IQListSupplementaryView, section: IQSection, kind: String, at indexPath: IndexPath)
    func listView(_ listView: IQListView, willDisplaySupplementaryElement view: IQListSupplementaryView, section: IQSection, kind: String, at indexPath: IndexPath)
    func listView(_ listView: IQListView, didEndDisplayingSupplementaryElement view: IQListSupplementaryView, section: IQSection, kind: String, at indexPath: IndexPath)
```

### 2. Data Source function changes

Old data source functions
```swift
    func listView(_ listView: IQListView, headerFor section: IQSection, at sectionIndex: Int) -> UIView?
    func listView(_ listView: IQListView, footerFor section: IQSection, at sectionIndex: Int) -> UIView?
    
```
New data source functions
```swift
    func listView(_ listView: IQListView, supplementaryElementFor section: IQSection, kind: String, at indexPath: IndexPath) -> IQListSupplementaryView?
```

### 2. IQSection initialization

Old function
```swift
    public init(identifier: AnyHashable, header: String? = nil, headerView: UIView? = nil, headerSize: CGSize? = nil, footer: String? = nil, footerView: UIView? = nil, footerSize: CGSize? = nil, model: Any? = nil)    
```
New functions removed accepting header footer views, and instead they now accept class and model to be used as header or footer like cells mechanism.
```swift
    public init(identifier: AnyHashable, header: String? = nil, footer: String? = nil)
    public init<H: IQModelableSupplementaryView>(identifier: AnyHashable, headerType: H.Type, headerModel: H.Model)
    public init<F: IQModelableSupplementaryView>(identifier: AnyHashable, footerType: F.Type, footerModel: F.Model)
    public init<H: IQModelableSupplementaryView, F: IQModelableSupplementaryView>(identifier: AnyHashable, headerType: H.Type, headerModel: H.Model, footerType: F.Type, footerModel: F.Model)
```
