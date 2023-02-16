IQListKit MIGRATION GUIDE 1.0 TO 1.3.0
==========================

### 1. Append function

Old append function 
```swift
func append<T: IQModelableCell>(_ type: T.Type, model: T.Model?, section: IQSection? = nil)
```
New append function accepts an array of models
```swift
func append<T: IQModelableCell>(_ type: T.Type, models: [T.Model?], section: IQSection? = nil)
```

### 2. Old IQSection initialization

Old initialization function 
```swift
public init(identifier: AnyHashable,
                header: String? = nil, footer: String? = nil,
                headerSize: CGSize? = nil, footerSize: CGSize? = nil)
```
New initialization function changed the order of arguments and also added an optionally accept UIView to show as header/footer
```swift
public init(identifier: AnyHashable,
                header: String? = nil, headerView: UIView? = nil, headerSize: CGSize? = nil,
                footer: String? = nil, footerView: UIView? = nil, footerSize: CGSize? = nil,
                model: Any? = nil)
```
