//
//  FilteredImageCollectionViewCell.swift
//  PhotoFilter
//
//  Created by Illia Khrypunov on 11/21/19.
//  Copyright © 2019 Illia Khrypunov. All rights reserved.
//

import UIKit

class FilteredImageCollectionViewCell: UICollectionViewCell {
  
  @IBOutlet private weak var imageView: UIImageView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  func setup(image: UIImage?) {
    imageView.image = image
  }
  
  func getCurrentImage() -> UIImage? {
    return imageView.image
  }
}
