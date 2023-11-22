IQListKit MIGRATION GUIDE 5.X TO 6.X
==========================

### 1. Swipe Actions

Old Swipe Actions
```swift
    func leadingSwipeActions() -> [IQContextualAction]?
    func trailingSwipeActions() -> [IQContextualAction]?
```
We removed `IQContextualAction` since it was added for backward compatibility and not needed now, so we now changed it to native `UIContextualAction`.
```swift
    func leadingSwipeActions() -> [UIContextualAction]?
    func trailingSwipeActions() -> [UIContextualAction]?
```

### 2. Register Supplementary View function changes

Old register function
```swift
    func registerSupplementaryView<T: UIView>(type: T.Type, kind: String, registerType: RegisterType, bundle: Bundle = .main)
```
New register function now only accept the view confirming to `IQListSupplementaryView` which usually be `UITableViewHeaderFooterView` or `UICollectionReusableView`
```swift
    func registerSupplementaryView<T: IQListSupplementaryView>(type: T.Type, kind: String, registerType: RegisterType, bundle: Bundle = .main)
```

### 3. Delegate functions changes

Old delegate functions
```swift
    func listView(_ listView: IQListView, modifySupplementaryElement view: UIView, section: IQSection, kind: String, at indexPath: IndexPath)
    func listView(_ listView: IQListView, willDisplaySupplementaryElement view: UIView, section: IQSection, kind: String, at indexPath: IndexPath)
    func listView(_ listView: IQListView, didEndDisplayingSupplementaryElement view: UIView, section: IQSection, kind: String, at indexPath: IndexPath)
```
New delegate functions. This change the `UIView` to `IQListSupplementaryView`
```swift
    func listView(_ listView: IQListView, modifySupplementaryElement view: IQListSupplementaryView, section: IQSection, kind: String, at indexPath: IndexPath)
    func listView(_ listView: IQListView, willDisplaySupplementaryElement view: IQListSupplementaryView, section: IQSection, kind: String, at indexPath: IndexPath)
    func listView(_ listView: IQListView, didEndDisplayingSupplementaryElement view: IQListSupplementaryView, section: IQSection, kind: String, at indexPath: IndexPath)
```


### 2. Data Source function changes

Old data source functions
```swift
    func listView(_ listView: IQListView, supplementaryElementFor section: IQSection, kind: String, at indexPath: IndexPath) -> UIView?
    func listView(_ listView: IQListView, canMove item: IQItem, at indexPath: IndexPath) -> Bool
    func listView(_ listView: IQListView, canEdit item: IQItem, at indexPath: IndexPath) -> Bool
```
New data source functions. Notice that the `canMove` and `canEdit` returns an optional `Bool?` now, so make sure to adopt this change in your existing codebase.
```swift
    func listView(_ listView: IQListView, supplementaryElementFor section: IQSection, kind: String, at indexPath: IndexPath) -> IQListSupplementaryView?
    func listView(_ listView: IQListView, canMove item: IQItem, at indexPath: IndexPath) -> Bool?
    func listView(_ listView: IQListView, canEdit item: IQItem, at indexPath: IndexPath) -> Bool?
```

### 2. IQSection initialization

Old functions
```swift
    public init(identifier: AnyHashable, header: String? = nil, footer: String? = nil)    
    public init<H: IQModelableSupplementaryView>(identifier: AnyHashable, headerType: H.Type, headerModel: H.Model)
    public init<F: IQModelableSupplementaryView>(identifier: AnyHashable, footerType: F.Type, footerModel: F.Model)
```
New functions reintroduce the views and header footer size, because users were now not able to set custom size for headers. But supporting the views will be removed in next major release.

We now accepting different kind of header/footer in same function. For example header can be configured by model and footer can be configured by string or view and vice versa.
```swift
    public init(identifier: AnyHashable, header: String? = nil, headerView: UIView? = nil, headerSize: CGSize? = nil, footer: String? = nil, footerView: UIView? = nil, footerSize: CGSize? = nil)\
    public init<H: IQModelableSupplementaryView>(identifier: AnyHashable, headerType: H.Type, headerModel: H.Model, footer: String? = nil, footerView: UIView? = nil, footerSize: CGSize? = nil)
    public init<F: IQModelableSupplementaryView>(identifier: AnyHashable, header: String? = nil, headerView: UIView? = nil, headerSize: CGSize? = nil, footerType: F.Type, footerModel: F.Model)
```
