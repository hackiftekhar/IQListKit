IQListKit MIGRATION GUIDE 6.X TO 7.X
==========================

### 1. Actors isolation feature

- The library added actor isolation like `@MainActor` to remove potential race conditions. Due to this, there are major code structure updates to adopt actor isolation.
- The `IQList` class is changed to an actor type.
- This version now configure all the reload configuration in a new `Background Queue` and it's isolated to the `@ReloadActor`. Now the `reloadData` block is only allowed to use `@ReloadActor` things and nonisolated things. This means, it's not allowed to use `UIView` or `@MainActor` related things inside it. This also prevent using `append(_:models:section:beforeItem:afterItem:)` etc functions outside.
- Model we create inside the cell should confirm `Sendable`.

#### Sendable
If all your properties in a `Model` is `Sendable` then it automatically confirms to `Sendable`, however sometimes you may have to add `@unchecked Sendable` if one of the internal variables does not confirm to `Sendable`

```swift
struct Model: Hashable, @unchecked Sendable {
}
```
#### Actor

Now `reloadData` provide a `builder`, and you should be configuring the UI with builder. To access outside variables inside the block, you may have add them to capture list.

Old approach
```swift
    list.reloadData({
        let section: IQSection = IQSection(identifier: "section")
        list.append([section])
        list.append(TableViewCell.self, models: models)
    })
```

New Approach
```swift
    list.reloadData({ [models] builder in
        let section: IQSection = IQSection(identifier: "section")
        builder.append([section])
        builder.append(TableViewCell.self, models: models)
    })
```
        

### 2. Register Supplementary View function changes

Old size return functions
```swift
    static func estimatedSize(for model: AnyHashable?, listView: IQListView) -> CGSize
    static func size(for model: AnyHashable?, listView: IQListView) -> CGSize
    static func indentationLevel(for model: AnyHashable?, listView: IQListView) -> Int
```
New size return functions. Please note that the new function now provide `Model` as parameter instead of providing `AnyHashable?`. Also please note that the return type is changed from `CGSize` to `CGSize?`. Please make sure to adopt this change in your existing codebase.
```swift
    static func estimatedSize(for model: Model, listView: IQListView) -> CGSize?
    static func size(for model: Model, listView: IQListView) -> CGSize?
    static func indentationLevel(for model: Model, listView: IQListView) -> Int
```

### 3. IQModelableCell changes

Old modelable variables
```swift
final class TableViewCell: UITableViewCell, IQModelableCell {
    // IQReorderableCell
    var canMove: Bool { false }
    var canEdit: Bool { false }
    var editingStyle: UITableViewCell.EditingStyle { .none }

    // IQSelectableCell
    var isHighlightable: Bool { true }
    var isDeselectable: Bool { true }
    var canPerformPrimaryAction: Bool { true }
}
```
New modelable variables. These should now be part of the `Model` and must confirm to `IQReorderableModel`, `IQSelectableModel` for same feature.
```swift
final class TableViewCell: UITableViewCell, IQModelableCell {
    //...
    struct Model: Hashable, IQReorderableModel, IQSelectableModel {

        // IQReorderableModel
        var canMove: Bool { false }
        var canEdit: Bool { false }
        var editingStyle: UITableViewCell.EditingStyle { .none }

        // IQSelectableModel
        var isHighlightable: Bool { true }
        var isDeselectable: Bool { true }
        var canPerformPrimaryAction: Bool { true }
    }
}
```

### 4. Delegate function changes

Old delegate functions
```swift
    func listView(_ listView: IQListView, modifyCell cell: IQListCell, at indexPath: IndexPath)
    func listView(_ listView: IQListView, willDisplay cell: IQListCell, at indexPath: IndexPath)
    func listView(_ listView: IQListView, didEndDisplaying cell: IQListCell, at indexPath: IndexPath)

    func listView(_ listView: IQListView, modifySupplementaryElement view: UIView, section: IQSection, kind: String, at indexPath: IndexPath)
    func listView(_ listView: IQListView, willDisplaySupplementaryElement view: UIView, section: IQSection, kind: String, at indexPath: IndexPath)
    func listView(_ listView: IQListView, didEndDisplayingSupplementaryElement view: UIView, section: IQSection, kind: String, at indexPath: IndexPath)

```
New delegate functions. This replaced `IQListCell` with `some IQModelableCell`, for the supplementry element functions it's `UIView` is now replaced by `some IQModelableSupplementaryView`
```swift
    func listView(_ listView: IQListView, modifyCell cell: some IQModelableCell, at indexPath: IndexPath)
    func listView(_ listView: IQListView, willDisplay cell: some IQModelableCell, at indexPath: IndexPath)
    func listView(_ listView: IQListView, didEndDisplaying cell: some IQModelableCell, at indexPath: IndexPath)

    func listView(_ listView: IQListView, modifySupplementaryElement view: some IQModelableSupplementaryView, section: IQSection, kind: String, at indexPath: IndexPath)
    func listView(_ listView: IQListView, willDisplaySupplementaryElement view: some IQModelableSupplementaryView, section: IQSection, kind: String, at indexPath: IndexPath)
    func listView(_ listView: IQListView, didEndDisplayingSupplementaryElement view: some IQModelableSupplementaryView, section: IQSection, kind: String, at indexPath: IndexPath)
```

### 5. Data source function changes

Old data source functions
```swift
    func listView(_ listView: IQListView, supplementaryElementFor section: IQSection, kind: String, at indexPath: IndexPath) -> UIView?

```
New data source functions. This replaced `UIView` by `(any IQModelableSupplementaryView)?`
```swift
    func listView(_ listView: IQListView, supplementaryElementFor section: IQSection, kind: String, at indexPath: IndexPath) -> (any IQModelableSupplementaryView)?
```

### 6. IQSection initialization

Old initialization functions
```swift
    public init(identifier: AnyHashable, header: String? = nil, headerView: UIView? = nil, headerSize: CGSize? = nil, footer: String? = nil, footerView: UIView? = nil, footerSize: CGSize? = nil)
    public init<H: IQModelableSupplementaryView>(identifier: AnyHashable, headerType: H.Type, headerModel: H.Model, footer: String? = nil, footerView: UIView? = nil, footerSize: CGSize? = nil)
    public init<F: IQModelableSupplementaryView>(identifier: AnyHashable, header: String? = nil, headerView: UIView? = nil, headerSize: CGSize? = nil, footerType: F.Type, footerModel: F.Model)
```
New initialization functions. The `headerView` and `footerView` is now removed as menioned in the last major release.
```swift
    public init(identifier: AnyHashable, header: String? = nil, headerSize: CGSize? = nil, footer: String? = nil, footerSize: CGSize? = nil)
    public init<H: IQModelableSupplementaryView>(identifier: AnyHashable, headerType: H.Type, headerModel: H.Model, footer: String? = nil, footerSize: CGSize? = nil)
    public init<F: IQModelableSupplementaryView>(identifier: AnyHashable, header: String? = nil, headerSize: CGSize? = nil, footerType: F.Type, footerModel: F.Model)
```

