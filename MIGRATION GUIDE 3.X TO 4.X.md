IQListKit MIGRATION GUIDE 3.X TO 4.X
==========================

### 1. Removed Backward Compatibility
In 4.x, backward compatibility before iOS 13 was removed and the library only support iOS 13 and newer.

### 1. performUpdates function

Old performUpdates function 
```swift
func performUpdates(_ updates: () -> Void, animatingDifferences: Bool = true,
                        endLoadingOnUpdate: Bool = true,
                        completion: (() -> Void)? = nil)
```
The performUpdates function renamed to reloadData for better understanding what it's doing. Also added few more optional arguments to the function.
```swift
func reloadData(_ updates: () -> Void,
                    updateExistingSnapshot: Bool = false,
                    animatingDifferences: Bool = true, animation: UITableView.RowAnimation? = nil,
                    endLoadingOnCompletion: Bool = true,
                    completion: (() -> Void)? = nil)
```
