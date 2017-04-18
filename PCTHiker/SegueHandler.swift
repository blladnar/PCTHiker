import Foundation
import UIKit

class SegueHandler {
    let handle: (UIViewController) -> ()
    private let identifier: String
    
    init(identifier: String, _ handler: @escaping (UIViewController) -> ()) {
        self.handle = handler
        self.identifier = identifier
    }
    
    func performSegue(on: UIViewController) {
        on.performSegue(withIdentifier: identifier, sender: self)
    }
}

class BaseViewController: UIViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueHandler = sender as? SegueHandler {
            segueHandler.handle(segue.destination)
        }
    }
}

class BaseTableViewController: UITableViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueHandler = sender as? SegueHandler {
            segueHandler.handle(segue.destination)
        }
    }
}
