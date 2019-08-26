//
//  ExampleCollectionViewController.swift
//  CardStackCollectionViewLayout
//
//  Created by Chris Stamper on 8/20/19.
//  Copyright © 2019 Chris Stamper. All rights reserved.
//
//  ExampleCollectionViewController is a very simple implementation of a
//  CardStackCollectionViewLayout. It's really as simple as setting the layout anf delegate,
//  and remembering to call -performBatchUpdates before changing the state (expanded or collapsed).

import UIKit
import CardStackCollectionViewLayout

class ExampleCollectionViewController: UICollectionViewController, CardStackLayoutDelegate {
    
    func currentState(section: Int) -> CardStackLayoutState {
        return section == 0 ? _topState : .regular
    }

    var _topState: CardStackLayoutState = .collapsed
    var count = 8
    
    override func viewDidLoad() {
        super.viewDidLoad()

        (self.collectionView?.collectionViewLayout as? CardStackCollectionViewLayout)?.delegate = self
    }
    
    @IBAction func toggle() {
//        collectionView?.performBatchUpdates({
            _topState = _topState == .collapsed ? .expanded : .collapsed
            collectionView?.reloadData()
//        }) { (success) in
//            print("changed state")
//        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            if indexPath.row < 1 {
                return CGSize(width: 100, height: 340)
            } else {
                return CGSize(width: 100, height: 208)
            }
        } else {
            return CGSize(width: 100, height: 240)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "example", for: indexPath) as! ExampleCollectionViewCell
        cell.label.text = "Row \(indexPath.row) : \(indexPath.section)"
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 5)
        cell.layer.shadowRadius = 10
        cell.layer.shadowOpacity = 0.5
        cell.layer.masksToBounds = false
        cell.clipsToBounds = false
        return cell
    }
}

class ExampleCollectionViewCell: UICollectionViewCell {
    @IBOutlet var label: UILabel!
}
