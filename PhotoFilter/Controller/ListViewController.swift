//
//  ListViewController.swift
//  PhotoFilter
//
//  Created by Illia Khrypunov on 11/21/19.
//  Copyright © 2019 Illia Khrypunov. All rights reserved.
//

import UIKit
import CoreImage

let dataSourceURL = URL(string:"http://www.raywenderlich.com/downloads/ClassicPhotosDictionary.plist")!

class ListViewController: UIViewController {
  
  @IBOutlet weak var photosTableView: UITableView!
  
  var photos: [PhotoRecord] = []
  let pendingOperations = PendingOperations()
  private let cellId = "PhotoCell"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupTableView()
    fetchPhotoDetails()
    self.title = "Filtered Images"
  }
}

// MARK: - Private
private extension ListViewController {
  func setupTableView() {
    let nib = UINib(nibName: "PhotosTableViewCell", bundle: nil)
    photosTableView.register(nib, forCellReuseIdentifier: cellId)
    photosTableView.delegate = self
    photosTableView.dataSource = self
  }
  
  func fetchPhotoDetails() {
    let request = URLRequest(url: dataSourceURL)
    let task = URLSession(configuration: .default).dataTask(with: request) { data, response, error in
      if let data = data {
        do {
          let datasourceDictionary =
            try PropertyListSerialization.propertyList(from: data,
                                                       options: [],
                                                       format: nil) as! [String: String]
          for (name, value) in datasourceDictionary {
            let url = URL(string: value)
            if let url = url {
              let photoRecord = PhotoRecord(name: name, url: url)
              self.photos.append(photoRecord)
            }
          }
          DispatchQueue.main.async {
            self.photosTableView.reloadData()
          }
        } catch {
          DispatchQueue.main.async {
            self.present(self.fetchErrorAlert(), animated: true, completion: nil)
          }
        }
      }
      if error != nil {
        DispatchQueue.main.async {
          self.present(self.fetchErrorAlert(), animated: true, completion: nil)
        }
      }
    }
    task.resume()
  }
  
  func fetchErrorAlert() -> UIAlertController {
    let alert = UIAlertController(title: "Oops!",
                                  message: "Something went wrong while fetching photo details.",
                                  preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK", style: .default)
    alert.addAction(okAction)
    return alert
  }
  
  func startOperations(for photoRecord: PhotoRecord, at indexPath: IndexPath) {
    switch (photoRecord.state) {
    case .new:
      startDownload(for: photoRecord, at: indexPath)
    case .downloaded:
      startFiltration(for: photoRecord, at: indexPath)
    default:
      NSLog("do nothing")
    }
  }
  
  func startDownload(for photoRecord: PhotoRecord, at indexPath: IndexPath) {
    guard pendingOperations.downloadsInProgress[indexPath] == nil else {
      return
    }
    let downloader = ImageDownloader(photoRecord: photoRecord)
    downloader.completionBlock = {
      if downloader.isCancelled {
        return
      }
      
      DispatchQueue.main.async {
        self.pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
        self.photosTableView.reloadRows(at: [indexPath], with: .fade)
      }
    }
    pendingOperations.downloadsInProgress[indexPath] = downloader
    pendingOperations.downloadQueue.addOperation(downloader)
  }
  
  func startFiltration(for photoRecord: PhotoRecord, at indexPath: IndexPath) {
    guard pendingOperations.filtrationsInProgress[indexPath] == nil else {
      return
    }
    
    let filterer = ImageFiltration(photoRecord: photoRecord)
    filterer.completionBlock = {
      if filterer.isCancelled {
        return
      }
      
      DispatchQueue.main.async {
        self.pendingOperations.filtrationsInProgress.removeValue(forKey: indexPath)
        self.photosTableView.reloadRows(at: [indexPath], with: .fade)
      }
    }
    
    pendingOperations.filtrationsInProgress[indexPath] = filterer
    pendingOperations.filtrationQueue.addOperation(filterer)
  }
  
  func suspendAllOperations() {
    pendingOperations.downloadQueue.isSuspended = true
    pendingOperations.filtrationQueue.isSuspended = true
  }
  
  func resumeAllOperations() {
    pendingOperations.downloadQueue.isSuspended = false
    pendingOperations.filtrationQueue.isSuspended = false
  }
  
  func loadImagesForOnscreenCells() {
    if let pathsArray = photosTableView.indexPathsForVisibleRows {
      var allPendingOperations = Set(pendingOperations.downloadsInProgress.keys)
      allPendingOperations.formUnion(pendingOperations.filtrationsInProgress.keys)
      
      var toBeCancelled = allPendingOperations
      let visiblePaths = Set(pathsArray)
      toBeCancelled.subtract(visiblePaths)
      
      var toBeStarted = visiblePaths
      toBeStarted.subtract(allPendingOperations)
      
      for indexPath in toBeCancelled {
        if let pendingDownload = pendingOperations.downloadsInProgress[indexPath] {
          pendingDownload.cancel()
        }
        
        pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
        if let pendingFiltration = pendingOperations.filtrationsInProgress[indexPath] {
          pendingFiltration.cancel()
        }
        
        pendingOperations.filtrationsInProgress.removeValue(forKey: indexPath)
      }
      
      for indexPath in toBeStarted {
        let recordToProcess = photos[indexPath.row]
        startOperations(for: recordToProcess, at: indexPath)
      }
    }
  }
}

// MARK: - UITableViewDelegate
extension ListViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 380
  }
}

// MARK: - UITableViewDataSource
extension ListViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return photos.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? PhotosTableViewCell else {
      fatalError("Error: no such cell")
    }
    
    let photoDetails = photos[indexPath.row]
    cell.setupCellForDownloadedState(photo: photoDetails)
    
    switch (photoDetails.state) {
    case .filtered:
      cell.stopActivityIndicator()
    case .failed:
      cell.stopActivityIndicator()
      cell.setupCellForFailedState()
    case .new, .downloaded:
      cell.startActivityIndicator()
      if !photosTableView.isDragging && !photosTableView.isDecelerating {
        startOperations(for: photoDetails, at: indexPath)
      }
    }
    
    return cell
  }
}

// MARK: - ScrollViewDelegate
extension ListViewController: UIScrollViewDelegate {
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    suspendAllOperations()
  }
  
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if !decelerate {
      loadImagesForOnscreenCells()
      resumeAllOperations()
    }
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    loadImagesForOnscreenCells()
    resumeAllOperations()
  }
}
