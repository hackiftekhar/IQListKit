IQListKit
==========================
Model driven UITableView/UICollectionView

[![Build Status](https://travis-ci.org/hackiftekhar/IQListKit.svg)](https://travis-ci.org/hackiftekhar/IQListKit)

IQListKit allows you to use UITableView/UICollectionView without implementing the dataSource. Just provide the section and their models with cell type and it will take of rest including the animations of all changes.

For iOS13: Thanks to Apple for [NSDiffableDataSourceSnapshot](https://developer.apple.com/documentation/uikit/nsdiffabledatasourcesnapshot)

For iOS12 and below: Thanks to Ryo Aoyama for [DiffableDataSources](https://github.com/ra1028/DiffableDataSources)

## Requirements
[![Platform iOS](https://img.shields.io/badge/Platform-iOS-blue.svg?style=fla)]()

| Library                | Language | Minimum iOS Target | Minimum Xcode Version |
|------------------------|----------|--------------------|-----------------------|
| IQListKit (1.0.0)      | Swift    | iOS 9.0            | Xcode 11              |

#### Swift versions support
5.0 and above

Installation
==========================

#### Installation with CocoaPods

[![CocoaPods](https://img.shields.io/cocoapods/v/IQListKit.svg)](http://cocoadocs.org/docsets/IQListKit)

IQListKit is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'IQListKit'
```

*Or you can choose the version you need based on the Swift support table from [Requirements](README.md#requirements)*

```ruby
pod 'IQListKit', '1.0.0'
```

#### Installation with Source Code

[![Github tag](https://img.shields.io/github/tag/hackiftekhar/IQListKit.svg)]()

***Drag and drop*** `IQListKit` directory from demo project to your project

#### Installation with Swift Package Manager

[Swift Package Manager(SPM)](https://swift.org/package-manager/) is Apple's dependency manager tool. It is now supported in Xcode 11. So it can be used in all appleOS types of projects. It can be used alongside other tools like CocoaPods and Carthage as well. 

To install IQListKit package into your packages, add a reference to IQListKit and a targeting release version in the dependencies section in `Package.swift` file:

```swift
import PackageDescription

let package = Package(
    name: "YOUR_PROJECT_NAME",
    products: [],
    dependencies: [
        .package(url: "https://github.com/hackiftekhar/IQListKit.git", from: "1.0.0")
    ]
)
```

To install IQListKit package via Xcode

 * Go to File -> Swift Packages -> Add Package Dependency...
 * Then search for https://github.com/hackiftekhar/IQListKit.git
 * And choose the version you would like

How to use IQListKit?
==========================

We'll be learning IQListKit using a simple example.

Let's say we have to show a list of users in a **UITableView** and for that, we have **User Model** like this:

```swift
struct User {

    let id: Int       //A unique id of each user
    let name: String  //Name of the user
}
```

Before going deep into the implementation, we have to learn about the [Hashable](https://developer.apple.com/documentation/swift/hashable) protocol.

#### Now what is [Hashable](https://developer.apple.com/documentation/swift/hashable)? I never used it before.
A Hashable protocol is used to determine the uniqueness of the object/variable. Technically a hashable is a type that has hashValue in the form of an integer that can be compared across different types.

Many types in the standard library conform to Hashable: **String, Int, Float, Double and Bool** values and even **Set** are hashable by default.
To confirm the Hashable protocol, we have to modify our model a little bit like below:

```swift
//We have Int and String variables in the struct
//That's why we do not have to manually confirm the hashable protocol
//It will work out of the box by just adding the hashable protocol to the User struct
struct User: Hashable {

    let id: Int
    let name: String
}
```
But if we would like to manually confirm, we have to implement **func hash(into hasher: inout Hasher)** and preferably we should also confirm the to Equatable protocol by implementing **static func == (lhs: User, rhs: User) -> Bool** like below:

```swift
struct User: Hashable {

    func hash(into hasher: inout Hasher) {  //Manually Confirming to the Hashable protocol
        hasher.combine(id)
    }

    static func == (lhs: User, rhs: User) -> Bool { //Manually confirming to the Equatable protocol
        lhs.id == rhs.id && lhs.name == rhs.name
    }

    let id: Int
    let name: String
}
```

Now let's come back to the implementation part. To use the IQListKit, we have to follow a couple of steps:

### Step 1) Confirm our "UserCell" to "IQModelableCell" protocol

#### What is IQModelableCell protocol? and how we should confirm it?
The **IQModelableCell** protocol says that, whoever adopts me, have to expose a variable named **model** and it can be any type conforming to the [Hashable](https://developer.apple.com/documentation/swift/hashable).

Let's say we have **UserCell** like this:
```swift
class UserCell: UITableViewCell {

    @IBOutlet var labelName: UILabel!
}
```

There are a couple of ways we could easily confirm it by exposing a **model** named variable.

#### Method 1: Directly using our User model
```swift
class UserCell: UITableViewCell, IQModelableCell {

    @IBOutlet var labelName: UILabel!
    
    var model: User?  //Our User model confirms the Hashable protocol
}
```

#### Method 2: typealias our User model to common name like 'Model'
```swift
class UserCell: UITableViewCell, IQModelableCell {

    @IBOutlet var labelName: UILabel!
    
    typealias Model = User  //typealiasing the User model to a common name

    var model: Model?  //Model is a typealias of User
}
```

#### Method 3: By creating a Hashable struct in each cell (Preferred)
This method is preferable because it will have the ability to use multiple parameters in the model

```swift
class UserCell: UITableViewCell, IQModelableCell {

    @IBOutlet var labelName: UILabel!
    
    struct Model: Hashable {
        let user: User
        let canShowMenu: Bool //custom parameter which can be controlled from ViewControllers
        let paramter2: Int  //Another customized parameter
        ... and so on (if needed)
    }

    var model: Model?  //Our new Model struct confirms the Hashable protocol
}
```

### Step 2) Connect the model with the cell
To do this, we could easily do it by implementing the didSet of our model variable
```swift
class UserCell: UITableViewCell, IQModelableCell {

    @IBOutlet var labelName: UILabel!
    
    var model: User? {  //For simplicity, we'll be using the 1st method
        didSet {
            guard let model = model else {
                return
            }
        
            labelName.text = model.name
        }
    }
}
```

### Step 3) Creating and configuring the IQList variable
Let's say we have a **UsersTableViewController** like this:-

```swift
class UsersTableViewController: UITableViewController {

    private var users = [User]() //assuming the users array is loaded from somewhere e.g. API call response

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
```
Now we'll be creating an instance of IQList and providing it the list of models and cells
The listView parameter accepts either a UITableView or UICollectionView object.
The delegateDataSource parameter is optional, but preferable when we would like
to do additional configuration in our cell before display
or to get callbacks when the cell is clicked.

```swift
class UsersTableViewController: UITableViewController {

    private var users = [User]() //assuming the users array is loaded from somewhere e.g. API call response

    private lazy var list = IQList(listView: tableView, delegateDataSource: self)
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        Optional configuration when there are no items to display
//        list.noItemImage = UIImage(named: "empty")
//        list.noItemTitle = "No Items"
//        list.noItemMessage = "Nothing to display here."
//        list.noItemAction(title: "Reload", target: self, action: #selector(refresh(_:)))
    }
}

extension UsersTableViewController: IQListViewDelegateDataSource {
}
```

### Step 4) Provide the models with cell types to the IQList in the performUpdates method
Let's do this in a separate function called refreshUI

```swift
    func refreshUI(animated: Bool = true) {

        //This is the actual method that reloads the data.
        //You could think it like a tableView.reloadData()
        //It does all the needed thing
        list.performUpdates({

            //If we use multiple sections, then each section should be unique.
            //This should also confirm to hashable, so we can also provide a Int
            //like this `let section = IQSection(identifier: 1)`
            let section = IQSection(identifier: "first")
            
            //We could also provide the header/footer title and it's size also, they are optional
            //let section = IQSection(identifier: "first",
            //                        header: "I'm header", headerSize: CGSize(width: UITableView.automaticDimension, height: 30),
            //                        footer: "I'm footer", footerSize: CGSize(width: UITableView.automaticDimension, height: 50))
            
            list.append(section)

            //Getting the list of users
            for user in users {
                //Telling to the list that the model should render in UserCell

                //If model created using Method 1 or Method 2
                list.append(UserCell.self, model: user, section: section) 
                
                //If model created using Method 3
                //  list.append(UserCell.self, model: UserCell.Model(user: user), section: section)
            }

        }, animatingDifferences: animated, completion: nil) //controls if the changes should animate or not while reloading
    }
    
    func loadDataFromAPI() {
    
        //Get users list from API or somewhere else
        APIClient.getUsersList({ [weak self] result in
        
            switch result {

                case .success(let users):
                    self?.users = users   //Updates the users array
                    self?.refreshUI()     //Refresh the data
            
                case .failure(let error):
                    //Handle error
            }
        }
    }
```

Now whenever our users array changes, we will be calling the refreshUI() method to reload tableView and that's it.

Additional configuration before cell display.
==========================

#### I would like to do additional configuration like setting some delegate of UserCell. Where is my old `func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell`?
The IQListKit is a model-driven framework, so we'll be dealing with the Cell and models instead of the indexPath.row or indexPath.section. The IQListKit provides a couple of delegates to modify the cell or do additional configuration before the cell display. To do this, we can implement a delegate method of IQList like below:-

```swift
extension TableViewController: IQListViewDelegateDataSource {

    func listView(_ listView: IQLisView, modifyCell cell: IQListCell, at indexPath: IndexPath) {
        if let cell = cell as? UserCell { //Casting our cell as UserCell
            cell.delegate = self
            //Or additional work with the UserCell
            
            //Top get the user object associated with the cell
            let user = cell.model

            //We discourage to use the indexPath variable to get the model object
            //let user = users[indexPath.row] //Don't do like this since we are model-driven list, not the index driven list.
        }
    }
}
```

Callback when Cell is selected
==========================
#### I would like to move to UserDetailViewController when user tapped on UserCell. Where is my old friend `func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)`?
Ahh, Don't worry about getting your user model by using the indexPath.row. We'll provide you the user model associated with the cell directly. It's interesting!

```swift
extension TableViewController: IQListViewDelegateDataSource {

    func listView(_ listView: IQLisView, didSelect item: IQItem, at indexPath: IndexPath) {
        if let model = item.model as? UserCell.Model {
            if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "UserDetailViewController") as? UserDetailViewController {
                controller.user = model //If used Method 1 or Method 2
                //  controller.user = model.user  //If used method 3
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
}
```

Other useful delegate methods
==========================

```swift
    //Cell will about to display
    func listView(_ listView: IQLisView, willDisplay cell: IQListCell, at indexPath: IndexPath)

    //Cell did end displaying
    func listView(_ listView: IQLisView, didEndDisplaying cell: IQListCell, at indexPath: IndexPath)
```

Other useful data source methods
==========================

```swift
    //Return the size of an Item, for tableView the size.height will only be effective
    func listView(_ listView: IQLisView, size item: IQItem, at indexPath: IndexPath) -> CGSize?

    //Return the headerView of section
    func listView(_ listView: IQLisView, headerFor section: IQSection, at sectionIndex: Int) -> UIView?

    //Return the footerView of section
    func listView(_ listView: IQLisView, footerFor section: IQSection, at sectionIndex: Int) -> UIView?
```

LICENSE
---
Distributed under the MIT License.

Contributions
---
Any contribution is more than welcome! You can contribute through pull requests and issues on GitHub.

Author
---
If you wish to contact me, email me: hack.iftekhar@gmail.com
