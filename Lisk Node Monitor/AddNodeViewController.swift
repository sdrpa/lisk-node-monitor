// Created by Sinisa Drpa on 2/7/18.

import UIKit

final class AddNodeViewController: UIViewController {

   @IBOutlet weak var saveButton: UIBarButtonItem!
   @IBOutlet weak var addressTextField: UITextField!
   
   var server: Server?

   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      super.prepare(for: segue, sender: sender)
      
      guard let button = sender as? UIBarButtonItem, button === saveButton else {
         print("Cancel")
         return
      }

      server = Server(address: addressTextField.text ?? "0.0.0.0")
   }

   @IBAction func cancel(_ sender: UIBarButtonItem) {
      dismiss(animated: true, completion: nil)
   }
}
