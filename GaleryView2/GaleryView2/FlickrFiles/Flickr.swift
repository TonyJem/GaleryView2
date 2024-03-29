import UIKit

private let apiKey = "1ee22a210a7e555666ba0fd78925619b"

class Flickr {
    private enum Error: Swift.Error {
        case unknownAPIResponse
        case generic
    }
    
    func searchFlickr(for searchText: String, completion: @escaping (Result<FlickrSearchResult, Swift.Error>) -> Void) {
        guard let searchURL = flickrSearchURL(for: searchText) else {
            completion(.failure(Error.unknownAPIResponse))
            return
        }
        
        URLSession.shared.dataTask(with: URLRequest(url: searchURL)) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard (response as? HTTPURLResponse) != nil,
                  let data = data else {
                completion(.failure(Error.unknownAPIResponse))
                return
            }
            
            do {
                guard let resultsDictionary = try JSONSerialization.jsonObject(with: data) as? [String: AnyObject],
                      let stat = resultsDictionary["stat"] as? String else {
                    completion(.failure(Error.unknownAPIResponse))
                    return
                }
                
                switch stat {
                case "ok":
                    print("🟢 Results processed OK")
                case "fail":
                    completion(.failure(Error.generic))
                    return
                default:
                    completion(.failure(Error.unknownAPIResponse))
                    return
                }
                
                guard let photosContainer = resultsDictionary["photos"] as? [String: AnyObject],
                      let photosReceived = photosContainer["photo"] as? [[String: AnyObject]] else {
                    completion(.failure(Error.unknownAPIResponse))
                    return
                }
                
                let flickrPhotos = self.getPhotos(photoData: photosReceived)
                let searchResults = FlickrSearchResult(searchText: searchText, filteredImages: flickrPhotos)
                completion(.success(searchResults))
            } catch {
                completion(.failure(error))
                return
            }
        }
        .resume()
    }
}

// MARK: - Private
private extension Flickr {
    func getPhotos(photoData: [[String: AnyObject]]) -> [FlickrImage] {
        let photos: [FlickrImage] = photoData.compactMap { photoObject in
            guard let photoID = photoObject["id"] as? String,
                  let farm = photoObject["farm"] as? Int,
                  let server = photoObject["server"] as? String,
                  let secret = photoObject["secret"] as? String else { return nil }
            
            let flickrPhoto = FlickrImage(photoID: photoID, farm: farm, server: server, secret: secret)
            
            guard let url = flickrPhoto.flickrImageURL(),
                  let imageData = try? Data(contentsOf: url as URL) else { return nil }
            
            if let image = UIImage(data: imageData) {
                flickrPhoto.thumbnail = image
                return flickrPhoto
            } else {
                return nil
            }
        }
        return photos
    }
    
    func flickrSearchURL(for searchText: String) -> URL? {
        guard let escapedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics) else {
            return nil
        }
        
        let URLString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&text=\(escapedText)&per_page=20&format=json&nojsoncallback=1"
        return URL(string: URLString)
    }
}
