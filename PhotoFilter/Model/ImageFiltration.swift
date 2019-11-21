//
//  ImageFiltration.swift
//  PhotoFilter
//
//  Created by Illia Khrypunov on 11/21/19.
//  Copyright © 2019 Illia Khrypunov. All rights reserved.
//

import UIKit

class ImageFiltration: Operation {
  let photoRecord: PhotoRecord
  
  init(photoRecord: PhotoRecord) {
    self.photoRecord = photoRecord
  }
  
  override func main() {
    if isCancelled { return }
    guard self.photoRecord.state == .downloaded else { return }
    for filter in Filters.filtersNames {
      if let image = photoRecord.originalImage,
        let filteredImage = applyFilter(image, name: filter) {
        photoRecord.fileteredImages.append(filteredImage)
      }
      photoRecord.state = .filtered
    }
  }
  
  func applyFilter(_ image: UIImage, name: String) -> UIImage? {
    guard let data = image.pngData() else { return nil }
    let inputImage = CIImage(data: data)
    
    if isCancelled {
      return nil
    }
    
    let context = CIContext(options: nil)
    
    guard let filter = CIFilter(name: name) else { return nil }
    filter.setValue(inputImage, forKey: kCIInputImageKey)
    
    if isCancelled {
      return nil
    }
    
    guard
      let outputImage = filter.outputImage,
      let outImage = context.createCGImage(outputImage, from: outputImage.extent)
      else {
        return nil
    }
    
    return UIImage(cgImage: outImage)
  }
}
