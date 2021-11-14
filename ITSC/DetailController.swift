//
//  DetailController.swift
//  ITSC
//
//  Created by nju on 2021/11/14.
//

import UIKit
import WebKit
import SwiftSoup
class DetailController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var site:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        webView.navigationDelegate = self
        webView.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        URLSession.shared.dataTask(with: URL(string:site)!, completionHandler: {
            data, response, error in
            if let error = error {
                print("\(error.localizedDescription)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("server error")
                return
            }
            if let mimeType = httpResponse.mimeType, mimeType == "text/html",
                let data = data,
                let string = String(data: data, encoding: .utf8) {
                do{
                    let doc = try SwiftSoup.parse(string)
                    let body = try doc.select(".container").html()
                    let head = try doc.head()!.html()
                    let newHTML = "<html>" + head + "<body>" + body + "</body>" + "</html>"
                    
                    DispatchQueue.main.async {
                        self.webView.loadHTMLString(newHTML, baseURL: URL(string: self.site))
                    }
                }catch{
                    print("Parsing detail error!")
                }
                
            }
        }).resume()
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension DetailController: WKNavigationDelegate{
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.indicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url{
            if(url.absoluteString == site){
                decisionHandler(.allow)
            }else{
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
            }
        }else{
            decisionHandler(.cancel)
        }
    }
}
