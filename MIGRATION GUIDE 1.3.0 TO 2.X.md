IQListKit MIGRATION GUIDE 1.3.0 TO 2.X
==========================

### 1. registerCell function

Old registerCell function 
```swift
func registerCell<T: IQModelableCell>(type: T.Type, bundle: Bundle? = .main, registerType: RegisterType = .default)
```
New registerCell function changes the order of argument and makes to send registerType as required parameter.
```swift
func registerCell<T: IQModelableCell>(type: T.Type, registerType: RegisterType, bundle: Bundle = .main)
```

### 2. registerHeaderFooter function

Old registerHeaderFooter function 
```swift
func registerHeaderFooter<T: UIView>(type: T.Type, bundle: Bundle? = .main)
```
New registerHeaderFooter function changed the order of arguments and also added to send registerType as required parameter
```swift
func registerHeaderFooter<T: UIView>(type: T.Type, registerType: RegisterType, bundle: Bundle = .main)
```
