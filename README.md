
# 🏆 **IQListKit**  
Model-Driven `UITableView` and `UICollectionView` in Swift  

![Insertion Sort](https://raw.githubusercontent.com/hackiftekhar/IQListKit/master/Documents/insertion_sort.gif)
![Conference Video Feed](https://raw.githubusercontent.com/hackiftekhar/IQListKit/master/Documents/conference_video_feed.gif)
![Orthogonal Section](https://raw.githubusercontent.com/hackiftekhar/IQListKit/master/Documents/orthogonal_section.gif)
![Mountains](https://raw.githubusercontent.com/hackiftekhar/IQListKit/master/Documents/mountains.gif)
![User List](https://raw.githubusercontent.com/hackiftekhar/IQListKit/master/Documents/users_list.gif)

[![Build Status](https://travis-ci.org/hackiftekhar/IQListKit.svg)](https://travis-ci.org/hackiftekhar/IQListKit)
[![CocoaPods](https://img.shields.io/cocoapods/v/IQListKit.svg)](http://cocoadocs.org/docsets/IQListKit)  
[![Swift Version](https://img.shields.io/badge/Swift-5.7%2B-orange.svg)](https://www.swift.org/)
[![Platform](https://img.shields.io/badge/platform-iOS-blue)]()  

---

## 🚀 **Why IQListKit?**
IQListKit simplifies working with `UITableView` and `UICollectionView` by eliminating the need to implement `dataSource` methods manually. Just define your sections, models, and cell types — IQListKit takes care of the rest, including:  
✅ Automatic diffing and animations  
✅ Clean and reusable code  
✅ Single API for both `UITableView` and `UICollectionView`  

---

## 🎯 **Features**
- ✅ **Unified API** – Works with both `UITableView` and `UICollectionView`  
- ✅ **Diffable Data Source** – Smooth animations and state updates  
- ✅ **Declarative Syntax** – Cleaner and more concise code  
- ✅ **Custom Headers/Footers** – Easy to implement and manage  
- ✅ **Reusable Cells** – No more `dequeueReusableCell` hassles  

---

## 📋 **Requirements**
| Version | Swift | iOS Target | Xcode Version |
|---------|-------|------------|---------------|
| IQListKit 1.1.0 | Swift 5.7+ | iOS 9.0+ | Xcode 11+ |
| IQListKit 4.0.0+ | Swift 5.7+ | iOS 13.0+ | Xcode 14+ |
| IQListKit 5.0.0+ | Swift 5.7+ | iOS 13.0+ | Xcode 14+ |

---

## 📦 **Installation**

### ▶️ **Swift Package Manager**
1. Open Xcode → File → Add Package Dependency  
2. Enter URL:  
   ``` 
   https://github.com/hackiftekhar/IQListKit.git 
   ``` 
3. Select the version and install.  

### ▶️ **CocoaPods**
Add to your `Podfile`:  
```ruby
pod 'IQListKit'
```

### ▶️ **Manual Installation**
1. Clone the repository.  
2. Drag and drop the `IQListKit` folder into your project.  

---

## 🛠️ **How to Use IQListKit**
Let’s build a user list in **5 simple steps**!  

### **1️⃣ Create a Model**
Make sure your model conforms to `Hashable`:  
```swift
struct User: Hashable {
    let id: Int
    let name: String
}
```

### **2️⃣ Create a Cell**
Create a cell that conforms to `IQModelableCell`:  
```swift
class UserCell: UITableViewCell, IQModelableCell {
    @IBOutlet var nameLabel: UILabel!

    struct Model: Hashable {
        let user: User
    }

    var model: Model? {
        didSet {
            nameLabel.text = model?.user.name
        }
    }
}
```

### **3️⃣ Set Up the List**
Create a `list` in your `UIViewController`:  
```swift
class UsersViewController: UIViewController {
    
    private lazy var list = IQList(listView: tableView, delegateDataSource: self)
    private var users = [User(id: 1, name: "John"), User(id: 2, name: "Jane")]

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
}
```

### **4️⃣ Provide Data**
Provide data directly to `IQListKit`:  
```swift
func loadData() {
    list.reloadData { [users] builder in

        let section = IQSection(identifier: "Users")
        builder.append([section])

        let models: [UserCell.Model] = users.map { .init(user: $0) }
        builder.append(UserCell.self, models: models, section: section)
    }
}
```

### **5️⃣ Handle Selection**
Handle user selection easily:  
```swift
extension UsersViewController: IQListViewDelegateDataSource {
    func listView(_ listView: IQListView, didSelect item: IQItem, at indexPath: IndexPath) {
        if let model = item.model as? UserCell.Model {
            print("Selected user: \(model.user.name)")
        }
    }
}
```

---

## 🧰 **Using the Wrapper Class**  
If you would like to display a **single-section list** of similar objects in a `UITableView` or `UICollectionView`, IQListKit provides a convenient `IQListWrapper` class to handle all the boilerplate code for you.

### ▶️ **Setup with IQListWrapper**
You can set up `IQListWrapper` in just a few lines of code:

```swift
class UsersViewController: UIViewController {

    @IBOutlet var tableView: UITableView!

    private lazy var listWrapper = IQListWrapper(listView: tableView,
                                                 type: UserCell.self,
                                                 registerType: .nib,
                                                 delegateDataSource: self)
    private var users = [User(id: 1, name: "John"), User(id: 2, name: "Jane")]

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }

    func loadData() {
        listWrapper.setModels(users, animated: true, completion: nil)
    }
}
```

The `IQListWrapper` class reduces complexity by handling the setup and data binding automatically, making it ideal for quick implementations!  

---

## 📖 **Documentation**
- [Delegate, DataSource and Cell Configuration Guide](https://github.com/hackiftekhar/IQListKit/blob/master/Documents/Delegate_DataSource_Guide.md)
- [Workaround Guide](https://github.com/hackiftekhar/IQListKit/blob/master/Documents/Workarounds.md)
- [IQListKit Presentation](https://raw.githubusercontent.com/hackiftekhar/IQListKit/master/Documents/IQListKitPresentation.pdf)  
- [Modern Collection View](https://raw.githubusercontent.com/hackiftekhar/IQListKit/master/Documents/IQListKitWithModernCollectionView.pdf)  

---

## 🏆 **Best Practices**
- Always handle cell reuse correctly to avoid glitches.  
- Use lightweight models for better memory usage.  


## ❤️ **Contributions**
Contributions are welcome!  
- Report issues  
- Submit pull requests  
- Improve documentation  

---

## 📄 **License**
IQListKit is distributed under the MIT license.  

---

## 👨‍💻 **Author**
Iftekhar Qureshi  
- GitHub Sponsors: [Support my open-source work](https://github.com/sponsors/hackiftekhar)
- PayPal: [PayPal](https://www.paypal.me/hackiftekhar)
- Buy Me a Coffee: [Support here](https://www.buymeacoffee.com/hackiftekhar)
- Twitter: [@hackiftekhar](https://twitter.com/hackiftekhar)
- Website: [hackiftekhar.com](https://hackiftekhar.com)

---

### ⭐️ **Star the repo on GitHub if you like it!**  
