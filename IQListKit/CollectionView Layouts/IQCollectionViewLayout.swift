//
//  IQCollectionViewLayout.swift
//  https://github.com/hackiftekhar/IQListKit
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation

/*
 Here are some links where you can find more collection view layouts made by other developers and open source projects

 Swiggy
 https://github.com/dheerajghub/SwiggyClone
 https://github.com/aBhanuTeja/Swiggy-App-Clone

 App Store
 https://github.com/alexroemerdeveloper/AppStore
 https://github.com/MatthewFraser22/ios-appstore
 https://github.com/Slymn10/App-Store-Clone
 https://github.com/thethtun/App-Store-Demo
 https://github.com/charleshs/CompositionalAppStore
 https://github.com/howardC56/AppStoreStyle
 https://github.com/ashishbl86/MockAppStore

 iTunes
 https://github.com/SomuYadav/iTunes-ProgrammaticUI-UICompositionalLayout-NSDiffableDataSource-

 Others
 https://github.com/ugurhmz/ShoppingApp-MVVM-Ecommerce-Nostoryboard
 https://github.com/ugurhmz/CinemaApp-MVVM-Programmatically
 https://github.com/hybridcattt/IslandGuideSample
 https://github.com/jVirus/uicollectionview-layouts-kit
 https://github.com/jVirus/compositional-layouts-kit
 https://github.com/IceFloe/UICollectionViewCompositionalLayout
 https://github.com/DeluxeAlonso/UICollectionViewCompositionalLayoutDemo
 https://github.com/donggyushin/UICollectionViewCompositionalLayout
 https://github.com/kishikawakatsumi/UICollectionViewCompositionalLayout-Workshop-Starter
 https://github.com/DeluxeAlonso/ModernCollectionViews
 https://github.com/artem7498/LeroyMerlin-MainScreen
 https://github.com/yfujiki/CompositionalLayoutSample
 https://github.com/nggondaliya/CompositionalLayout_Demo
 https://github.com/Lagrange1813/WaterfallLayout
 https://github.com/Brothersoft-bro/Compositional-Layout-Demo
 https://github.com/jmindeveloper/uicollectionviewcompositionallayout
 https://github.com/imanoupetit/UICollectionViewCompositionalLayout
 https://github.com/hiep317/UICollectionViewCompositionalLayout
 https://github.com/rafaelnobrekz/UICollectionViewCompositionalLayout
 https://github.com/yash-np/CollectionView
 https://github.com/MaximovNick/Delivery
 https://github.com/Mutanntix/CompositionalLayoutApp
 https://github.com/rishadappat/listGridAnimation-Swift
 https://github.com/PhanithNY/PHImagePickerController
 https://github.com/nayaksushma/CompositionalLayout
 https://github.com/hcanfly/Digest
 https://github.com/hcanfly/Photos13
 https://github.com/ddd503/CompositionalLayout-Basic-Sample
 https://github.com/AhmedRagab99/musico

 */

final public class IQCollectionViewLayout {

    /*
     Examples
     let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.2),
     heightDimension: .fractionalHeight(1.0))

     let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
     heightDimension: .fractionalWidth(0.2))
     */

    public class func layout(scrollDirection: UICollectionView.ScrollDirection,
                             section: NSCollectionLayoutSection) -> UICollectionViewLayout {

        let configuration: UICollectionViewCompositionalLayoutConfiguration = .init()
        configuration.scrollDirection = scrollDirection

        return UICollectionViewCompositionalLayout(section: section, configuration: configuration)
    }

    @available(iOS 14.0, *)
    public class func listLayout(appearance: UICollectionLayoutListConfiguration.Appearance) -> UICollectionViewLayout {
        let config = UICollectionLayoutListConfiguration(appearance: appearance)
        return UICollectionViewCompositionalLayout.list(using: config)
    }
}
