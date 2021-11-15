//
//  TableController.swift
//  ITSC
//
//  Created by nju on 2021/11/14.
//

import UIKit
import SwiftSoup
struct News{
    let title: String
    let date: String
    let href: String
    init(title: String, date: String, href:String){
        self.title = title
        self.date = date
        self.href = href
    }
}
class TableController: UITableViewController {

    var site:String = ""
    var news_list:[News] = []
    var searchMode: Bool = false
    var searching_list:[News] = []
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var onfly: Int = 0{
        didSet{
            if(onfly == 0){
                indicator.stopAnimating()
            }else{
                indicator.startAnimating()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        func getNews(data:Data?, response:URLResponse?, error:Error?){
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
                    let list = try SwiftSoup.parse(string).select(".list2 > .news")
                    for item in list{
                        let date = try item.select(".news_meta").text()
                        let title = try item.select(".news_title").text()
                        let href = try item.select("a").attr("href")
                        DispatchQueue.main.async {
                            self.news_list.append(News(title: title, date: date, href: href))
                        }
                        
                    }
                    DispatchQueue.main.async {
                        self.news_list.sort(by: {$0.date > $1.date})
                        self.tableView.reloadData()
                    }
                }catch{
                    print("Trying to get new error!")
                }
            }
            DispatchQueue.main.async {
                self.onfly -= 1
            }
        }
        
        func getPageNum(data:Data?, response:URLResponse?, error:Error?){
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
                        let all_pages = try SwiftSoup.parse(string).select(".all_pages").text()
                        let page_num = Int(all_pages)!
                        print(page_num)
                        DispatchQueue.main.async {
                            self.onfly += page_num
                        }
                        URLSession.shared.dataTask(with: URL(string:self.site)!, completionHandler: getNews).resume()
                        if(page_num >= 2){
                            for i in 2...page_num{
                                URLSession.shared.dataTask(with: URL(string:self.site + "list\(i).htm")!, completionHandler: getNews).resume()
                            }
                        }
                        
                    }catch{
                        print("Trying to get page number error!")
                    }
                }
                DispatchQueue.main.async {
                    self.onfly -= 1
                }
        }
        
        onfly += 1;
        URLSession.shared.dataTask(with: URL(string:site)!, completionHandler: getPageNum).resume()
        
        
        
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        if(searchMode){
            return searching_list.count
        }else{
            return news_list.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! TableCell
        let row = indexPath.row
        if(searchMode){
            cell.title.text = searching_list[row].title
            cell.date.text = searching_list[row].date
        }else{
            cell.title.text = news_list[row].title
            cell.date.text = news_list[row].date
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showDetail"){
            guard let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) else{
                print("Not a cell or not present?")
                return
            }
            
            var href = ""
            if(searchMode){
                href = searching_list[indexPath.row].href.replacingOccurrences(of: "page.htm", with: "pagem.htm")
            }else{
                href = news_list[indexPath.row].href.replacingOccurrences(of: "page.htm", with: "pagem.htm")
            }
            let detailController = segue.destination as! DetailController
            detailController.site = "http://itsc.nju.edu.cn" + href
        }
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension TableController: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText.trimmingCharacters(in: .whitespaces).isEmpty){
            searchMode = false
        }else{
            searchMode = true
            let keywords = searchText.components(separatedBy: .whitespaces)
            searching_list.removeAll()
            for news in news_list{
                var notIncluded = false
                for keyword in keywords {
                    if !news.title.contains(keyword) && !news.date.contains(keyword){
                        notIncluded = true
                        break
                    }
                }
                if(!notIncluded){
                    searching_list.append(news)
                }
            }
        }
        self.tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchMode = false
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
}
