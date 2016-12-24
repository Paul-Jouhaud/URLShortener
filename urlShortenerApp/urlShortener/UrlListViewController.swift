//
//  UrlListView.swift
//  urlShortener
//
//  Created by Paul Jouhaud on 23/12/2016.
//  Copyright © 2016 Paul Jouhaud. All rights reserved.
//

import Foundation
import UIKit

class UrlListViewController: UITableViewController, ShortenerViewControllerDelegate {
    
    var items: [UrlItem]
    
    required init?(coder aDecoder: NSCoder) {
        items = [UrlItem]()
        super.init(coder: aDecoder)
        loadUrlItems()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "UrlItem", for: indexPath)
        
        let item = items[indexPath.row]
        
        configureRealUrl(for: cell, with: item)
        configureShortUrl(for: cell, with: item)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            if let short_url = cell.viewWithTag(2000) as! UILabel? {
                UIPasteboard.general.string = short_url.text
                let alert = UIAlertController(title: "Copy to Pasteboard", message: "The short url was copied in your pasteboard", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func configureRealUrl(for cell: UITableViewCell,
                       with item: UrlItem) {
        let label = cell.viewWithTag(1000) as! UILabel
        label.text = item.real_url
    }
    
    func configureShortUrl(for cell: UITableViewCell,
                       with item: UrlItem) {
        let label = cell.viewWithTag(2000) as! UILabel
        label.text = item.short_url
    }
    
    func documentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func dataFilePath() -> URL {
        return documentsDirectory().appendingPathComponent("urlShortenerApp.plist")
    }
    
    func loadUrlItems() {
        let path = dataFilePath()
        if let data = try? Data(contentsOf: path) {
            let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
            items = unarchiver.decodeObject(forKey: "UrlItems") as! [UrlItem]
            unarchiver.finishDecoding()
        }
    }
    
    func saveUrlItems() {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        archiver.encode(items, forKey: "UrlItems")
        archiver.finishEncoding()
        data.write(to: dataFilePath(), atomically: true)
    }
    
    func shortenerViewController(_ controller: ShortenerViewController,
                                 didFinishAdding item: UrlItem) {
        print("In da delegate !")
        let newRowIndex = items.count
        items.append(item)
        print(item)
        let indexPath = IndexPath(row: newRowIndex, section: 0)
        let indexPaths = [indexPath]
        tableView.insertRows(at: indexPaths, with: .automatic)
        
        dismiss(animated: true, completion: nil)
        saveUrlItems()
    }
}
