IQListKit
==========================
Model driven UITableView/UICollectionView

[![Insertion Sort](https://raw.githubusercontent.com/hackiftekhar/IQListKit/master/Documents/insertion_sort.gif)]
[![Conference Video Feed](https://raw.githubusercontent.com/hackiftekhar/IQListKit/master/Documents/conference_video_feed.gif)]
[![Orthogonal Section](https://raw.githubusercontent.com/hackiftekhar/IQListKit/master/Documents/orthogonal_section.gif)]
[![Mountains](https://raw.githubusercontent.com/hackiftekhar/IQListKit/master/Documents/mountains.gif)]
[![User List](https://raw.githubusercontent.com/hackiftekhar/IQListKit/master/Documents/users_list.gif)]

[![Build Status](https://travis-ci.org/hackiftekhar/IQListKit.svg)](https://travis-ci.org/hackiftekhar/IQListKit)

IQListKit allows us to use UITableView/UICollectionView without implementing the dataSource. Just provide the section and their models with cell type and it will take care of rest including the animations of all changes.

For iOS13: Thanks to Apple for [NSDiffableDataSourceSnapshot](https://developer.apple.com/documentation/uikit/nsdiffabledatasourcesnapshot)

## Requirements
[![Platform iOS](https://img.shields.io/badge/Platform-iOS-blue.svg?style=fla)]()

| Library                | Language | Minimum iOS Target | Minimum Xcode Version |
|------------------------|----------|--------------------|-----------------------|
| IQListKit (1.1.0)      | Swift    | iOS 9.0            | Xcode 11              |
| IQListKit (4.0.0)      | Swift    | iOS 13.0           | Xcode 14              |
| IQListKit (5.0.0)      | Swift    | iOS 13.0           | Xcode 14              |

#### Swift versions support
5.7 and above

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

If you wish to learn using a presentation then download the presentation PDF here: [Presentation PDF](https://raw.githubusercontent.com/hackiftekhar/IQListKit/master/Documents/IQListKitPresentation.pdf)

If you wish to learn about how to use it with Modern Collection View layout then you can download the presentation PDF here: [IQListKit with Modern Collection View](https://raw.githubusercontent.com/hackiftekhar/IQListKit/master/Documents/IQListKitWithModernCollectionView.pdf)

We'll be learning IQListKit using a simple example.

Let's say we have to show a list of users in a **UITableView** and for that, we have **User Model** like this:

```swift
struct User {

    let id: Int       //A unique id of each user
    let name: String  //Name of the user
}
```

## 5 Easy Steps
1) Confirm ```Model``` (```User``` in our case) to ```Hashable``` protocol.
2) Confirm ```Cell``` (```UserCell``` in our case) to ```IQModelableCell``` protocol, which force to have a ```var model: Model?``` property.
3) Connect the ```Model``` with ```Cell``` UI like setting label texts, load images etc.
4) Create ```IQList``` variable in your ```ViewController``` and optionally configure with optional settings if necessary.
5) Provide ```Models``` (```User``` models in our case) with Cell type (```UserCell``` in our case) to the IQList and see the magic 🥳🎉🎉🎉.

### Step 1) Confirm ```Model``` (```User``` in our case) to ```Hashable``` protocol.

Before going deep into the implementation, we have to learn about the [Hashable](https://developer.apple.com/documentation/swift/hashable) protocol.

#### Now what is [Hashable](https://developer.apple.com/documentation/swift/hashable)? I never used it before.
A Hashable protocol is used to determine the uniqueness of the object/variable. Technically a hashable is a type that has hashValue in the form of an integer that can be compared across different types.

Many types in the standard library confirm to Hashable: **String, Int, Float, Double and Bool** values and even **Set** are hashable by default.
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
But if we would like to manually confirm, we have to implement **func hash(into hasher: inout Hasher)** and preferably we should also confirm to the Equatable protocol by implementing **static func == (lhs: User, rhs: User) -> Bool** like below:

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

### Step 2) Confirm ```Cell``` (```UserCell``` in our case) to ```IQModelableCell``` protocol, which force to have a ```var model: Model?``` property.

#### What is IQModelableCell protocol? and how we should confirm it?
The **IQModelableCell** protocol says that, whoever adopts me, have to expose a variable named **model** and it can be any type confirming to the [Hashable](https://developer.apple.com/documentation/swift/hashable).

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

### Step 3) Connect the ```Model``` with ```Cell``` UI like setting label texts, load images etc.
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

### Step 4) Create ```IQList``` variable in your ```ViewController``` and optionally configure with optional settings if necessary.
Let's say we have a **UsersTableViewController** like this:-

```swift
class UsersTableViewController: UITableViewController {

    private var users = [User]() //assuming the users array is loaded from somewhere e.g. API call response

    //...

    func loadDataFromAPI() {
    
        //Get users list from API
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
}
```
Now we'll be creating an instance of IQList and providing it the list of models and cell type.
The listView parameter accepts either a UITableView or UICollectionView.
The delegateDataSource parameter is optional, but preferable when we would like
to do additional configuration in our cell before display
or to get callbacks when the cell is clicked.

```swift
class UsersTableViewController: UITableViewController {

    //...

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

### Step 5) Provide ```Models``` (```User``` models in our case) with Cell type (```UserCell``` in our case) to the IQList and see the magic 🥳🎉🎉🎉.
Let's do this in a separate function called refreshUI

```swift
class UsersTableViewController: UITableViewController {

    //...

    func refreshUI(animated: Bool = true) {

        //This is the actual method that reloads the data.
        //We could think it like a tableView.reloadData()
        //It does all the needed thing
        list.reloadData({ [users] builder in

            //If we use multiple sections, then each section should be unique.
            //This should also confirm to hashable, so we can also provide a Int
            //like this `let section = IQSection(identifier: 1)`
            let section = IQSection(identifier: "first")
            
            //We can also provide the header/footer title, they are optional
            //let section = IQSection(identifier: "first",
            //                        header: "I'm header",
            //                        footer: "I'm footer")
            
            /*Or we an also provide custom header footer view and it's model, just like the cell,
              We have to adopt IQModelableSupplementaryView protocol to SampleCollectionReusableView 
              And it's also havie exactly same requirement as cell (have a model property)
              However, you also need to register this using
              list.registerSupplementaryView(type: SampleCollectionReusableView.self,
                                         kind: UICollectionView.elementKindSectionHeader, registerType: .nib)
              and use it like below
            */
            //let section = IQSection(identifier: "first",
            //                        headerType: SampleCollectionReusableView.self,
            //                        headerModel: "This is my header text for Sample Collection model")
            
            builder.append([section])

            //Telling to the builder that the models should render in UserCell

            //If model created using Method 1 or Method 2
            builder.append(UserCell.self, models: users, section: section) 
            
            /*
            If model created using Method 3
            var models = [UserCell.Model]()

            for user in users {
                models.append(.init(user: user))
            }
            builder.append(UserCell.self, models: models, section: section)
            */

        //controls if the changes should animate or not while reloading
        }, animatingDifferences: animated, completion: nil)
    }
}
```

Now whenever our users array changes, we will be calling the **refreshUI()** method to reload tableView and that's it.

🥳


Default Wrapper Class (IQListWrapper)
==========================
Most of the time, we have same requirements where we show single section list of models in table view or collection view. If this is your case then you can use IQListWrapper class to display single section list of objects very easily. This class handles all the boilerplate code of ViewController.

You just need to initialize the listWrapper and provide table view and cell type, and then you just need to pass models to it and it will refresh your list in your tableView and collectionView.

```swift
class MountainsViewController: UIViewController {

    //...

    private lazy var listWrapper = IQListWrapper(listView: userTableView,
                                                 type: UserCell.self,
                                                 registerType: .nib, delegateDataSource: self)
    
    //...
    
    func refreshUI(models: [User]) {
        listWrapper.setModels(models, animated: true)
    }
    //...
}
```

UITableView/UICollectionView delegate and datasource replacements
==========================

#### - `func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell`

The IQListKit is a model-driven framework, so we'll be dealing with the Cell and models instead of the IndexPath. The IQListKit provides a couple of delegates to modify the cell or do additional configuration based on their model before the cell display. To do this, we can implement a delegate method of IQList like below:-

```swift
extension UsersTableViewController: IQListViewDelegateDataSource {

    func listView(_ listView: IQListView, modifyCell cell: some IQModelableCell, at indexPath: IndexPath) {
        if let cell = cell as? UserCell { //Casting our cell as UserCell
            cell.delegate = self
            //Or additional work with the UserCell
            
            //🙂 Get the user object associated with the cell
            let user = cell.model

            //We discourage to use the indexPath variable to get the model object
            //😤 Don't do like this since we are model-driven list, not the indexPath driven list.
            //let user = users[indexPath.row]
        }
    }
}
```

#### - `func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)`
Ahh, Don't worry about that. We'll provide you the user model associated with the cell directly. It's interesting!

```swift
extension UsersTableViewController: IQListViewDelegateDataSource {

    func listView(_ listView: IQListView, didSelect item: IQItem, at indexPath: IndexPath) {
        if let model = item.model as? UserCell.Model { //😍 We get the user model associated with the cell
            if let controller = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(identifier: "UserDetailViewController") as? UserDetailViewController {
                controller.user = model //If used Method 1 or Method 2
                //  controller.user = model.user  //If used method 3
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
}
```

#### - `func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat`
#### - `func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat`
Because this method mostly return values based on cell and it's model, we have moved these configurations to cell. This is part of the **IQCellSizeProvider** protocol and we can override the default behaviour.

```swift
class UserCell: UITableViewCell, IQModelableCell {

    //...

    static func estimatedSize(for model: Model, listView: IQListView) -> CGSize? {
        return CGSize(width: listView.frame.width, height: 100)
    }

    static func size(for model: Model, listView: IQListView) -> CGSize? {

        if let model = model as? Model {
            var height: CGFloat = 100
            //...
            // return height based on the model
            return CGSize(width: listView.frame.width, height: height)
        }

        //Or return a constant height
        return CGSize(width: listView.frame.width, height: 100)

        //Or UITableView.automaticDimension for dynamic behaviour
//        return CGSize(width: listView.frame.width, height: UITableView.automaticDimension)
    }
}
```

#### - `func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?`
#### - `func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?`
Well, this method also mostly return values based on the cell and it's model, we have moved these configurations to cell. This is part of the **IQCellActionsProvider** protocol and we can override the default behaviour.
     
```swift
class UserCell: UITableViewCell, IQModelableCell {

    //...

    func leadingSwipeActions() -> [UIContextualAction]? {
        let action = UIContextualAction(style: .normal, title: "Hello Leading") { (_, _, completionHandler) in
            completionHandler(true)
            //Do your stuffs here
        }
        action.backgroundColor = UIColor.orange

        return [action]
    }

    func trailingSwipeActions() -> [UIContextualAction]? {

        let action1 = UIContextualAction(style: .normal, title: "Hello Trailing") { [weak self] (_, _, completionHandler) in
            completionHandler(true)
            guard let self = self, let user = self.model else {
                return
            }

            //Do your stuffs here
        }

        action.backgroundColor = UIColor.purple

        return [action]
    }
}
```

#### - `func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration?`
#### - `func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating)`
This method also mostly return values based on the cell and it's model, we have moved these configurations to cell.  This is also part of the **IQCellActionsProvider** protocol and we can override the default behaviour.
                   
```swift
class UserCell: UITableViewCell, IQModelableCell {

    //...

    func contextMenuConfiguration() -> UIContextMenuConfiguration? {

        let contextMenuConfiguration = UIContextMenuConfiguration(identifier: nil,
                                                                  previewProvider: { () -> UIViewController? in
            let controller = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(identifier: "UserViewController") as? UserViewController
            controller?.user = self.model
            return controller
        }, actionProvider: { (actions) -> UIMenu? in

            var actions = [UIMenuElement]()
            let action = UIAction(title: "Hello Action") { _ in
                //Do your stuffs here
            }
            actions.append(action)

            return UIMenu(title: "Nested Menu", children: actions)
        })

        return contextMenuConfiguration
    }
    
    func performPreviewAction(configuration: UIContextMenuConfiguration,
                              animator: UIContextMenuInteractionCommitAnimating) {
        if let previewViewController = animator.previewViewController, let parent = viewParentController {
            animator.addAnimations {
                (parent.navigationController ?? parent).show(previewViewController, sender: self)
            }
        }
    }
}

private extension UIView {
    var viewParentController: UIViewController? {
        var parentResponder: UIResponder? = self
        while let next = parentResponder?.next {
            if let viewController = next as? UIViewController {
                return viewController
            } else {  parentResponder = next  }
        }
        return nil
    }
}
```                   

Other useful delegate methods
==========================

```swift
extension UsersTableViewController: IQListViewDelegateDataSource {

    //...

    //Cell display
    func listView(_ listView: IQListView, willDisplay cell: some IQModelableCell, at indexPath: IndexPath)
    func listView(_ listView: IQListView, didEndDisplaying cell: some IQModelableCell, at indexPath: IndexPath)
    
    func listView(_ listView: IQListView, didSelect item: IQItem, at indexPath: IndexPath)
    func listView(_ listView: IQListView, didDeselect item: IQItem, at indexPath: IndexPath)
    
    func listView(_ listView: IQListView, didHighlight item: IQItem, at indexPath: IndexPath)
    func listView(_ listView: IQListView, didUnhighlight item: IQItem, at indexPath: IndexPath)
    
    func listView(_ listView: IQListView, performPrimaryAction item: IQItem, at indexPath: IndexPath)
    
    func listView(_ listView: IQListView, modifySupplementaryElement view: some IQModelableSupplementaryView,
                  section: IQSection, kind: String, at indexPath: IndexPath)
    func listView(_ listView: IQListView, willDisplaySupplementaryElement view: some IQModelableSupplementaryView,
                  section: IQSection, kind: String, at indexPath: IndexPath)
    func listView(_ listView: IQListView, didEndDisplayingSupplementaryElement view: some IQModelableSupplementaryView,
                  section: IQSection, kind: String, at indexPath: IndexPath)
               
    func listView(_ listView: IQListView, willDisplayContextMenu configuration: UIContextMenuConfiguration,
                  animator: UIContextMenuInteractionAnimating?, item: IQItem, at indexPath: IndexPath)
    func listView(_ listView: IQListView, willEndContextMenuInteraction configuration: UIContextMenuConfiguration,
                  animator: UIContextMenuInteractionAnimating?, item: IQItem, at indexPath: IndexPath)
}
```

Other useful data source methods
==========================

```swift
extension UsersTableViewController: IQListViewDelegateDataSource {

    //...

     //Return the size of an Item, for tableView the size.height will only be effective
    func listView(_ listView: IQListView, size item: IQItem, at indexPath: IndexPath) -> CGSize?

    //Return the custom header or footer View of section (or item in collection view)
    func listView(_ listView: IQListView, supplementaryElementFor section: IQSection,
                  kind: String, at indexPath: IndexPath) -> (any IQModelableSupplementaryView)?

    func sectionIndexTitles(_ listView: IQListView) -> [String]?
    
    func listView(_ listView: IQListView, prefetch items: [IQItem], at indexPaths: [IndexPath])
    
    func listView(_ listView: IQListView, cancelPrefetch items: [IQItem], at indexPaths: [IndexPath])
    
    func listView(_ listView: IQListView, canMove item: IQItem, at indexPath: IndexPath) -> Bool?
    
    func listView(_ listView: IQListView, move sourceItem: IQItem,
                  at sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
                  
    func listView(_ listView: IQListView, canEdit item: IQItem, at indexPath: IndexPath) -> Bool?
    
    func listView(_ listView: IQListView, commit item: IQItem,
                  style: UITableViewCell.EditingStyle, at indexPath: IndexPath)
}
```

Other useful IQModelableCell properties
==========================

```swift
class UserCell: UITableViewCell, IQModelableCell {

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

Other useful IQModelableCell methods
==========================

```swift
class UserCell: UITableViewCell, IQModelableCell {

    //...
    
    // IQViewSizeProvider protocol
    static func indentationLevel(for model: Model, listView: IQListView) -> Int {
        return 1
    }
    
    //IQCellActionsProvider protocol
    func contextMenuPreviewView(configuration: UIContextMenuConfiguration) -> UIView? {
        return viewToBePreview
    }
}
```

Workarounds
==========================
#### IQListKit! 😠 Why are you not loading my cell created in storyboard?
Well. If we are creating cell in storyboard, then to work with the IQListKit we must have to put the cell identifier exactly same as it's class name. If we are using The UICollectionView then we also have to manually register our cell using **list.registerCell(type: UserCell.self, registerType: .storyboard)** method because with the UICollectionView, there is no way to detect if a cell is created in storyboard.

#### I have a large data set and `list.reloadData` method takes time to animate the changes 😟. What can I do?
You would not believe the **reloadData** method already runs in a separate **Background Thread** 😍. But if you would like you can show a loadingIndicator. Thanks again to Apple for [NSDiffableDataSourceSnapshot](https://developer.apple.com/documentation/uikit/nsdiffabledatasourcesnapshot). The UITableView/UICollectionView will be reloaded in main thread. Please refer the below code:-

```swift
class UsersTableViewController: UITableViewController {

    //...

    func refreshUI(animated: Bool = true) {

        //Show loading indicator
        loadingIndicator.startAnimating()

        self.list.reloadData({ [users] builder in

            let section = IQSection(identifier: "section")
            builder.append(section)

            builder.append(UserCell.self, models: users, section: section)

        }, animatingDifferences: animated, completion: {
            //Hide loading indicator since the completion will be called in main thread
            self.loadingIndicator.stopAnimating()
        })
    }
}
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
