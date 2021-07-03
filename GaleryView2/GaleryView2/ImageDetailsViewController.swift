import UIKit

class ImageDetailsViewController: UIViewController {
    
    @IBOutlet private weak var detailedImageView: UIImageView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    var flickrImage: FlickrImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchLargeImage()
    }
    
    private func fetchLargeImage() {
        
        guard flickrImage?.largeImage == nil else {
            detailedImageView.image = flickrImage?.largeImage
            return
        }
        activityIndicator.startAnimating()
        detailedImageView.image = flickrImage?.thumbnail
        
        flickrImage?.loadLargeImage { [weak self] result in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()
            
            switch result {
            case .success:
                self.detailedImageView.image = self.flickrImage?.largeImage
            case .failure:
                return
            }
        }
    }
}
