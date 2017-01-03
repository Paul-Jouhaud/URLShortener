//
//  FirstViewController.swift
//  urlShortenerApp
//
//  Created by Paul Jouhaud on 20/12/2016.
//  Copyright © 2016 Paul Jouhaud. All rights reserved.
//

import UIKit

protocol ShortenerViewControllerDelegate: class {
    func shortenerViewController(_ controller: ShortenerViewController, didFinishAdding item: UrlItem)
}

class ShortenerViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    weak var delegate: ShortenerViewControllerDelegate?
    @IBOutlet weak var shortURL: UILabel!
    @IBOutlet weak var realURL: UITextField!
    @IBAction func generateShortenedURL() {
        let realUrlText = realURL.text!
        let requestData = ["real_url": realURL.text!]
        let url = URL(string: "http://localhost:8000/api/")!
        let jsonData = try! JSONSerialization.data(withJSONObject: requestData, options: [])
        
        var request = URLRequest(url: url)
        request.httpMethod = "post"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request ) { (data, response, error) in
            if let error = error {
                print("error:", error)
                return
            }
            
            do {
                guard let data = data else { return }
                guard let response = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] else { return }
                let shortUrlText = response["short_url"]! as! String
                self.shortURL.text = shortUrlText
                let newShortUrl = UrlItem()
                newShortUrl.real_url = realUrlText
                newShortUrl.short_url = shortUrlText
                print(newShortUrl)
                self.delegate?.shortenerViewController(self, didFinishAdding: newShortUrl)
            } catch {
                print("error:", error)
            }
        }
        
        task.resume()
    }
}

