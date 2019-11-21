//
//  PhotoRecord.swift
//  PhotoFilter
//
//  Created by Illia Khrypunov on 11/21/19.
//  Copyright © 2019 Illia Khrypunov. All rights reserved.
//

import UIKit

class PhotoRecord {
  let name: String
  let url: URL
  var state: PhotoRecordState = .new
  var originalImage = UIImage(named: "Placeholder")
  var fileteredImages: [UIImage] = []
  
  init(name: String, url: URL) {
    self.name = name
    self.url = url
  }
}
