//
//  GeneratedPostController.swift
//  PCTHiker
//
//  Created by Randall Brown on 4/17/17.
//  Copyright © 2017 Randall Brown. All rights reserved.
//

import Foundation
import UIKit

class GeneratedPostController: BaseViewController {
    
    @IBOutlet weak var textView: UITextView!
    
    var blogText: String = ""
    var headerImage: URL? = nil
    var postImages: [URL]? = nil
    
    override func viewDidLoad() {
        textView.text = blogText
    }
    
    @IBAction func export(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        var fileName = dateFormatter.string(from: Date())
        fileName += "-"
        fileName += title!.replacingOccurrences(of: " ", with: "-")
        fileName += ".markdown"
        
        
        let url = URL(fileURLWithPath: NSTemporaryDirectory() + fileName)
        try! textView.text!.write(to: url, atomically: true, encoding: .utf8)
        
        let activityController = UIActivityViewController(activityItems: [url], applicationActivities: [])
        
        present(activityController, animated: true, completion: nil)
        
    }
    
}
