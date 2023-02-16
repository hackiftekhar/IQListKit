IQListKit MIGRATION GUIDE 4.0.0 TO 4.1.2
==========================

### 1. Finding items

Old itemIdentifier function 
```swift
func itemIdentifier<T: IQModelableCell>(_ type: T.Type, of model: T.Model,
                                            comparator: (T.Model, T.Model) -> Bool) -> IQItem?
```
New itemIdentifier function makes it easy to find an item by removing some arguments from the function
```swift
func itemIdentifier<T: IQModelableCell>(of type: T.Type, where predicate: (T.Model) -> Bool) -> IQItem?
```
