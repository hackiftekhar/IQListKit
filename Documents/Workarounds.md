
# 🛠️ **IQListKit Workarounds**

## 😠 **Cell Not Loading from Storyboard?**  
If your cell isn’t loading when created in a storyboard, ensure that:  
✅ The **cell identifier** matches the class name exactly.  
✅ For `UICollectionView`, you need to manually register the cell like this:  

```swift
list.registerCell(type: UserCell.self, registerType: .storyboard)
```

Unlike `UITableView`, `UICollectionView` cannot automatically detect storyboard cells — so manual registration is necessary.

---

## 🐢 **Large Data Set Causing Slow Animations?**  
Good news! The `reloadData` method already runs on a **background thread** — so you don’t need to worry about blocking the UI. However, if your data set is large, it’s good practice to show a loading indicator while the data is being processed.  

Here’s an example:  

```swift
class UsersTableViewController: UITableViewController {

    // Loading indicator setup
    private let loadingIndicator = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()
        loadingIndicator.center = view.center
        view.addSubview(loadingIndicator)
    }

    func refreshUI(animated: Bool = true) {

        // Start loading indicator
        loadingIndicator.startAnimating()

        list.reloadData({ [users] builder in

            let section = IQSection(identifier: "section")
            builder.append(section)

            builder.append(UserCell.self, models: users, section: section)

        }, animatingDifferences: animated, completion: {

            // Stop loading indicator once data is loaded
            self.loadingIndicator.stopAnimating()
        })
    }
}
```

> The `completion` block will be called on the **main thread**, ensuring smooth UI updates.  

---

