//
//  ImageDownloader.swift
//  PhotoFilter
//
//  Created by Illia Khrypunov on 11/21/19.
//  Copyright © 2019 Illia Khrypunov. All rights reserved.
//

import UIKit

class ImageDownloader: Operation {
  let photoRecord: PhotoRecord
  
  init(photoRecord: PhotoRecord) {
    self.photoRecord = photoRecord
  }
  
  override func main() {
    if isCancelled { return }
    guard let imageData = try? Data(contentsOf: photoRecord.url) else { return }
    if isCancelled { return }
    if !imageData.isEmpty {
      photoRecord.originalImage = UIImage(data: imageData)
      photoRecord.state = .downloaded
    } else {
      photoRecord.state = .failed
      photoRecord.originalImage = UIImage(named: "Failed")
    }
  }
}
