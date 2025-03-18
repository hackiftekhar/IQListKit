
# 📝 **IQListKit Delegate and Data Source Guide**  

IQListKit provides powerful delegate and data source methods to give you full control over the behavior and appearance of your lists.

---

## 🎯 **Delegate Methods**

### ✅ **Cell Modification**
Modify the cell with additional configurations:
```swift
func listView(_ listView: IQListView, modifyCell cell: some IQModelableCell, at indexPath: IndexPath) {
    if let cell = cell as? UserCell {
        cell.backgroundColor = .lightGray
        cell.delegate = self
    }
}
```

### ✅ **Cell Selection**
Handle cell selection directly with the model:
```swift
func listView(_ listView: IQListView, didSelect item: IQItem, at indexPath: IndexPath) {
    if let model = item.model as? UserCell.Model {
        print("Selected user: \(model.user.name)")
    }
}

func listView(_ listView: IQListView, didDeselect item: IQItem, at indexPath: IndexPath) {
}

func listView(_ listView: IQListView, didHighlight item: IQItem, at indexPath: IndexPath) {
}

func listView(_ listView: IQListView, didUnhighlight item: IQItem, at indexPath: IndexPath) {
}

```

### ✅ **Cell Display**
Perform additional configuration when the cell display:
```swift
func listView(_ listView: IQListView, willDisplay cell: some IQModelableCell, at indexPath: IndexPath) {
}

func listView(_ listView: IQListView, didEndDisplaying cell: some IQModelableCell, at indexPath: IndexPath) {
}
```

### ✅ **Header/Footer Modification**
```swift
func listView(_ listView: IQListView, modifySupplementaryElement view: some IQModelableSupplementaryView,
                  section: IQSection, kind: String, at indexPath: IndexPath) {
}

func listView(_ listView: IQListView, willDisplaySupplementaryElement view: some IQModelableSupplementaryView,
                  section: IQSection, kind: String, at indexPath: IndexPath) {
}

func listView(_ listView: IQListView, didEndDisplayingSupplementaryElement view: some IQModelableSupplementaryView,
                  section: IQSection, kind: String, at indexPath: IndexPath) {
}
```

 ### ✅ **Context menu Display**
```swift
func listView(_ listView: IQListView, willDisplayContextMenu configuration: UIContextMenuConfiguration,
                  animator: UIContextMenuInteractionAnimating?, item: IQItem, at indexPath: IndexPath) {
}

func listView(_ listView: IQListView, willEndContextMenuInteraction configuration: UIContextMenuConfiguration,
                  animator: UIContextMenuInteractionAnimating?, item: IQItem, at indexPath: IndexPath) {
}
```

 ### ✅ **Primary Actionsy**
```swift
func listView(_ listView: IQListView, performPrimaryAction item: IQItem, at indexPath: IndexPath) {
}
```
                
---

## 📌 **Data Source Methods**

### ✅ **Size for Item**
Specify size for cells:
```swift
func listView(_ listView: IQListView, size item: IQItem, at indexPath: IndexPath) -> CGSize? {
    return CGSize(width: listView.frame.width, height: 60)
}
```

### ✅ **Header/Footer Titles**
Provide section headers and footers:
```swift
func listView(_ listView: IQListView, supplementaryElementFor section: IQSection,
                  kind: String, at indexPath: IndexPath) -> (any IQModelableSupplementaryView)? {
    let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                       withReuseIdentifier: "TitleSupplementaryView",
                                                                       for: indexPath)
    return view
}

func sectionIndexTitles(_ listView: IQListView) -> [String]? {
    return nil
}
```

### ✅ **Reordering Items**
Enable reordering for cells:
```swift
func listView(_ listView: IQListView, canMove item: IQItem, at indexPath: IndexPath) -> Bool {
    return true
}

func listView(_ listView: IQListView, move sourceItem: IQItem, at sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    print("Moved item from \(sourceIndexPath.row) to \(destinationIndexPath.row)")
}
```

### ✅ **Prefetching**
Enable data prefetching for performance:
```swift
func listView(_ listView: IQListView, prefetch items: [IQItem], at indexPaths: [IndexPath]) {
    print("Prefetching items at index paths: \(indexPaths)")
}

func listView(_ listView: IQListView, cancelPrefetch items: [IQItem], at indexPaths: [IndexPath]) {
    print("Cancelled prefetching at index paths: \(indexPaths)")
}
```

 ### ✅ **Primary Actionsy**
```swift
func listView(_ listView: IQListView, canEdit item: IQItem, at indexPath: IndexPath) -> Bool? {
    return nil
}

func listView(_ listView: IQListView, commit item: IQItem,
                  style: UITableViewCell.EditingStyle, at indexPath: IndexPath) {
}
```

---

## 🎯 **Additional Cell configurations**
```swift
class UserCell: UITableViewCell, IQModelableCell {

    static func estimatedSize(for model: Model, listView: IQListView) -> CGSize? {
        return CGSize(width: listView.frame.width, height: 100)
    }

    static func size(for model: Model, listView: IQListView) -> CGSize? {...}

    func leadingSwipeActions() -> [UIContextualAction]? {...}

    func trailingSwipeActions() -> [UIContextualAction]? {...}

    func contextMenuConfiguration() -> UIContextMenuConfiguration? {...}

    func performPreviewAction(configuration: UIContextMenuConfiguration,
                              animator: UIContextMenuInteractionCommitAnimating) {...}
```

---
