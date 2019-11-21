//
//  PhotosTableViewCell.swift
//  PhotoFilter
//
//  Created by Illia Khrypunov on 11/21/19.
//  Copyright © 2019 Illia Khrypunov. All rights reserved.
//

import UIKit

class PhotosTableViewCell: UITableViewCell {
  
  @IBOutlet private weak var currentImageView: UIImageView!
  @IBOutlet private weak var filteredCollectionView: UICollectionView!
  @IBOutlet private weak var imageNameLabel: UILabel!
  @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
  @IBOutlet private weak var reloadButton: UIButton!
  
  private var photo: PhotoRecord?
  private let cellId = "FilteredCell"
  
  override func awakeFromNib() {
    super.awakeFromNib()
    setupCollectionView()
    setupReloadButton()
  }
  
  func setupCellForDownloadedState(photo: PhotoRecord) {
    self.photo = photo
    currentImageView.image = photo.originalImage
    imageNameLabel.text = photo.name
    filteredCollectionView.reloadData()
  }
  
  func setupCellForFailedState() {
    self.currentImageView.image = UIImage(named: "Failed")
  }
  
  func startActivityIndicator() {
    activityIndicator.startAnimating()
  }
  
  func stopActivityIndicator() {
    activityIndicator.stopAnimating()
  }
  
  @IBAction func reloadImageToOriginal(_ sender: Any) {
    currentImageView.image = photo?.originalImage
  }
}

// MARK: - Private
private extension PhotosTableViewCell {
  func setupCollectionView() {
    let nib = UINib(nibName: "FilteredImageCollectionViewCell", bundle: nil)
    filteredCollectionView.register(nib, forCellWithReuseIdentifier: cellId)
    filteredCollectionView.delegate = self
    filteredCollectionView.dataSource = self
    filteredCollectionView.becomeFirstResponder()
  }
  
  func setupReloadButton() {
    let icon = UIImage(named: "reload")?.withRenderingMode(.alwaysTemplate).withTintColor(.white)
    reloadButton.setImage(icon, for: .normal)
  }
}

// MARK: - UICollectionViewDelegate
extension PhotosTableViewCell: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let cell = collectionView.cellForItem(at: indexPath) as? FilteredImageCollectionViewCell else {
      return
    }
    currentImageView.image = cell.getCurrentImage()
  }
}

// MARK: - UICollectionViewDataSource
extension PhotosTableViewCell: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return photo?.fileteredImages.count ?? 0
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? FilteredImageCollectionViewCell else {
      fatalError("Error: no such cell")
    }
    if let photos = photo?.fileteredImages {
      cell.setup(image: photos[indexPath.item])
    } else {
      cell.setup(image: UIImage(named: "Failed"))
    }
    return cell
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension PhotosTableViewCell: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let height = collectionView.bounds.height
    let width = height * 1920 / 1080
    return CGSize(width: width, height: height)
  }
}
