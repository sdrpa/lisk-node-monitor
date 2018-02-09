// Created by Sinisa Drpa on 2/7/18.

import UIKit

class MasterTableViewController: UITableViewController {

   let filename = "nodes.json"
   var servers: [Server] = []

   private let metronome = Metronome()

   override func viewDidLoad() {
      super.viewDidLoad()
      //Storage.clear(.documents)
      retrieve()

      self.metronome.tick = { [unowned self] in
         for server in self.servers {
            server.getStatus { [unowned self] in
               DispatchQueue.main.async {
                  self.tableView?.reloadData()
               }
            }
         }
      }
   }

   override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
   }
}

extension MasterTableViewController {
   private func retrieve() {
      if Storage.fileExists(filename, in: .documents) {
         let nodes = Storage.retrieve(filename, from: .documents, as: [Node].self)
         servers = nodes.map { Server(address: $0.address) }
      }

   }

   private func store() {
      Storage.store(servers.map { Node(address: $0.address) }, to: .documents, as: filename)
   }
}

extension MasterTableViewController {
   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return servers.count
   }

   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? NodeTableViewCell else {
         fatalError()
      }
      let server = servers[indexPath.row]
      cell.cellTextLabel?.text = server.address
      if let error = server.error {
         cell.cellDetailTextLabel?.text = "\(error.localizedDescription)"
      } else if let height = server.height, let consensus = server.consensus {
         cell.cellDetailTextLabel?.text = "height: \(height), consensus: \(consensus)"
      }
      cell.cellImageView?.image = (server.error == nil)
         ? UIImage(named: "green-circle")
         : UIImage(named: "red-circle")
      return cell
   }

   override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
      if editingStyle == .delete {
         // Delete the row from the data source
         servers.remove(at: indexPath.row)
         tableView.deleteRows(at: [indexPath], with: .fade)
      } else if editingStyle == .insert {
         // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
      }
   }

   override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
      return true
   }
}

extension MasterTableViewController {
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if let destination = segue.destination as? NodeViewController,
         let selectedCell = sender as? NodeTableViewCell,
         let indexPath = tableView.indexPath(for: selectedCell) {
            destination.server = servers[indexPath.row]
      }
   }

   @IBAction func unwindToViewController(sender: UIStoryboardSegue) {
      if let source = sender.source as? AddNodeViewController, let server = source.server {
         let newIndexPath = IndexPath(row: servers.count, section: 0)
         servers.append(server)
         store()
         tableView.insertRows(at: [newIndexPath], with: .automatic)

         server.getStatus() { [unowned self] in
            DispatchQueue.main.async {
               self.tableView?.reloadData()
            }
         }
      }
   }
}
