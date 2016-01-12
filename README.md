# KKActionSheet
Full-page alert view written in Swift.


#Synopsis
A simple implementation of a custom ActionSheet with modern UI. Icon over a blurView in the top, action sheet for multiple selections in the bottom, all without leaving the root window.

[See Demo](https://vimeo.com/151548427)

#Code Example
As of now, the selections/options that need to be displayed to the user are arranged as a `UICollectionView` or a `UIView`. If multiple selections have to be made, `UICollectionView` is preferred; a single `UIView` with several `UIButton`s for a single selection.

The `UICollectionView`/`UIView` will be passed into the method as arguments and the root VC will handle 

You can alter the default font families and sizes on the page or on-the-fly:


#Motivation
The standard `UIAlertController` is not aesthetically pleasing and does not make full use of the top half of the screen. For a fleeting moment, it also removes the user from the beautifully crafted UX of any app and plops them into a bland generic world.

The `blurView` displayed on top is a beautiful way to free up space for your branding (awesome icons or instructions) while keeping the user engaged with the workflow at hand.


#Installation
Copy the KKActionSheet.swift file into your project and call it like so:

```
let actionSheet = KKActionSheet()
actionSheet.addAction(self.handleData)
actionSheet.addBlurIcon("apple")
actionSheet.display(self, selectionView: self.collectionView, title: "Choose from Options")
```

#Future Improvements
- Dynamically sized ActionSheet
- `UICollectionView` created inside KKActionSheet.swift (no need to pass it as argument, only text of the options)
- `UILabel` inside `blurView`

#Contributors
Feel free to get in touch if you'd like to contribute!
