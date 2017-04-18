import UIKit
import Foundation

func getQueryStringParameter(url: URL, param: String) -> String? {
    
    let url = URLComponents(string: url.absoluteString)!
    
    return
        (url.queryItems as [URLQueryItem]!)
            .filter({ (item) in item.name == param }).first?.value
}

class BlogPostController: BaseTableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var subtitleField: UITextField!
    @IBOutlet weak var authorField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var headerPhotoCell: UITableViewCell!
    @IBOutlet weak var addPhotoCell: UITableViewCell!
    @IBOutlet weak var addYoutubeCell: UITableViewCell!
    
    private var headerImageURL: URL? = nil
    private var imageExtension = ""
    private var addHeader = true
    
    private var photoURLs: [URL] = []
    private var youtubeURLs: [URL] = []
    
    @IBAction func createPost(_ sender: Any) {
        guard let headerImageURL = headerImageURL else {
            alertWithTitle("Add Header Image")
            return
        }
        
        let activityController = UIActivityViewController(activityItems: [headerImageURL] + photoURLs, applicationActivities: [])
        present(activityController, animated: true, completion: nil)
        
        let handler = SegueHandler(identifier: "BlogPostToBlogText") { controller in
            guard let destination = controller as? GeneratedPostController else {
                return
            }
            
            destination.title = self.titleField.text!
            destination.blogText = self.blogText()
        }
        
        handler.performSegue(on: self)
    }
    
    private func headerFileName() -> String {
        return  self.titleField.text!.replacingOccurrences(of: " ", with: "-") + "Header." + self.imageExtension
    }
    
    private func postFileName() -> String {
        return self.titleField.text! + "Post" + "\(photoURLs.count)" + "." + self.imageExtension
    }
    
    private func blogText() -> String {
        var blogString = "---\n"
        blogString += "layout:     post\n"
        blogString += "title:      \"\(titleField.text!)\"\n"
        blogString += "subtitle:   \"\(subtitleField.text!)\"\n"
        blogString += "date:       \"\(dateField.text!)\"\n"
        blogString += "author:     \"\(authorField.text!)\"\n"
        blogString += "header-img: \"img/\(headerFileName())\"\n"
        blogString += "---\n"
        
        for (i, url) in photoURLs.enumerated() {
            let fileName = url.lastPathComponent
            blogString += "![photo\(i)](/img/\(fileName))\n"
        }
        
        for url in youtubeURLs {
            let videoID = url.lastPathComponent
            blogString += "<iframe width=\"560\" height=\"315\" src=\"https://www.youtube.com/embed/\(videoID)\" frameborder=\"0\" allowfullscreen></iframe>\n"
        }

        return blogString
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        dateField.text = dateFormatter.string(from: Date())
    }
    
    private func chooseHeaderPhoto() {
        guard titleField.text!.characters.count > 0 else {
            alertWithTitle("Add Post Title")
            return
        }
        
        addHeader = true
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func addPhoto() {
        guard titleField.text!.characters.count > 0 else {
            alertWithTitle("Add Post Title")
            return
        }
        
        addHeader = false
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func addYoutubeVideo() {
        let alertController = UIAlertController(title: "Paste Youtube URL", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "YouTube Link"
        }
        
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            guard let string = alertController.textFields![0].text, let url = URL(string: string) else {
                return
            }
            
            self.youtubeURLs.append(url)
        }
        
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func alertWithTitle(_ title: String) {
        let alertView = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertView.addAction(action)
        
        present(alertView, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)!
        
        switch cell {
        case headerPhotoCell:
            chooseHeaderPhoto()
        case addPhotoCell:
            addPhoto()
        case addYoutubeCell:
            addYoutubeVideo()
        default:
            return
        }
    }
    
    private func darkenImage(_ image: UIImage) -> UIImage? {
       
        guard let inputImage = CIImage(image: image),
            let filter = CIFilter(name: "CIExposureAdjust") else { return nil }
        
        // The inputEV value on the CIFilter adjusts exposure (negative values darken, positive values brighten)
        filter.setValue(inputImage, forKey: "inputImage")
        filter.setValue(-2.0, forKey: "inputEV")
        
        // Break early if the filter was not a success (.outputImage is optional in Swift)
        guard let filteredImage = filter.outputImage else { return nil }
        
        let context = CIContext(options: nil)
        let outputImage = UIImage(cgImage: context.createCGImage(filteredImage, from: filteredImage.extent)!)
        
        return outputImage
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var image = info[UIImagePickerControllerOriginalImage] as? UIImage
        let url = info[UIImagePickerControllerReferenceURL] as! URL
        imageExtension = getQueryStringParameter(url: url, param: "ext")!
        
        image = image!.scaleAndRotateImage(maxSize: image!.size.width)
        dismiss(animated: true, completion: nil)
        
        if addHeader {
            
            let darkImage = darkenImage(image!)
            
            let imageData = UIImageJPEGRepresentation(darkImage!, 0.6)
            
            let imageURL = URL(fileURLWithPath: NSTemporaryDirectory() + self.headerFileName())
            try! imageData?.write(to: imageURL)
            
            headerImageURL = imageURL
        }
        else {
            let imageData = UIImageJPEGRepresentation(image!, 0.6)
            
            let imageURL = URL(fileURLWithPath: NSTemporaryDirectory() + self.postFileName())
            try! imageData?.write(to: imageURL)
            photoURLs.append(imageURL)
        }
        

    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
