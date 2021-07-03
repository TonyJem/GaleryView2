import UIKit

class FlickrImage: Equatable {
    
    let photoID: String
    let farm: Int
    let server: String
    let secret: String
    
    var thumbnail: UIImage?
    var largeImage: UIImage?
    
    init (photoID: String, farm: Int, server: String, secret: String) {
        self.photoID = photoID
        self.farm = farm
        self.server = server
        self.secret = secret
    }
    
    func flickrImageURL(_ size: String = "m") -> URL? {
        return URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(photoID)_\(secret)_\(size).jpg")
    }
    
    private enum Error: Swift.Error {
        case invalidURL
        case noData
    }
    
    func loadLargeImage(_ completion: @escaping (Result<FlickrImage, Swift.Error>) -> Void) {
        guard let loadURL = flickrImageURL("b") else {
            DispatchQueue.main.async {
                completion(.failure(Error.invalidURL))
            }
            return
        }
        
        let loadRequest = URLRequest(url: loadURL)
        
        URLSession.shared.dataTask(with: loadRequest) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(Error.noData))
                    return
                }
                
                let returnedImage = UIImage(data: data)
                self.largeImage = returnedImage
                completion(.success(self))
            }
        }
        .resume()
    }
    
    static func == (lhs: FlickrImage, rhs: FlickrImage) -> Bool {
        return lhs.photoID == rhs.photoID
    }
}
