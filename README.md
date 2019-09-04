# CardStackCollectionViewLayout

![](https://media.giphy.com/media/YpYJ6KownyKyuRfRLJ/giphy.gif)

## What is it?
CardStackCollectionViewLayout provides UICollectionViewLayout using a stacked card metaphore, similar to Apple Wallet's Card view. The 0th (uppermost) card is displayed on the top of the stack, and the stack may be expanded (fanned-out) or displayed normally as a stack of cards with a small portion of the bottom of each card visible. 

Cell/card insert and delete transitions are provided. They continue the card stack metaphor by visually 'swiping' a deleted row from the stack, or by adding a newly inserted rom from the bottom.

## Example

To run the example project, clone the repo, and run `pod install`

## Requirements
iOS 9+

## Installation

CardStackCollectionViewLayout is available through [CocoaPods](https://cocoapods.org) or Swift Package Manager (SPM). 

To install it, simply add the following line to your Podfile:

```ruby
pod 'CardStackCollectionViewLayout'
```

## Contributing

Please send PRs!

## Known Issues
Currently the delete animation is shown when changing modes if -performBatchUpdates is used (for example when expanding the card stack).

## Author

cdstamper, chris@cdstamper.co

## License

CardStackCollectionViewLayout is available under the MIT license. See the LICENSE file for more info.
