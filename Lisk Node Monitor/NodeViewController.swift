// Created by Sinisa Drpa on 2/7/18.

import UIKit

class NodeViewController: UIViewController {

   var server: Server?

   @IBOutlet weak var titleItem: UINavigationItem!

   @IBOutlet weak var syncingLabel: UILabel!
   @IBOutlet weak var heightLabel: UILabel!
   @IBOutlet weak var broadhashLabel: UILabel!
   @IBOutlet weak var consensusLabel: UILabel!

   override func viewDidLoad() {
      super.viewDidLoad()
      // Do any additional setup after loading the view, typically from a nib.
   }

   override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
   }

   override func viewWillAppear(_ animated: Bool) {
      super.viewDidAppear(animated)

      titleItem.title = server?.address

      if let syncing = server?.syncing, let height = server?.height, let broadhash = server?.broadhash, let consensus = server?.consensus {
         syncingLabel.text = String(syncing)
         heightLabel.text = String(height)
         broadhashLabel.text = broadhash
         consensusLabel.text = String(consensus)
      }

   }
}
