//
//  TabBarController.swift
//  ITSC
//
//  Created by nju on 2021/11/14.
//

import UIKit

class TabBarController: UITabBarController {
    let sites = ["http://itsc.nju.edu.cn/xwdt/", "http://itsc.nju.edu.cn/tzgg/", "http://itsc.nju.edu.cn/wlyxqk/", "http://itsc.nju.edu.cn/aqtg/"]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 0..<4{
            let navController = viewControllers?[i] as! UINavigationController
            let tableController = navController.topViewController as! TableController
            
            tableController.title = navController.tabBarItem.title
            tableController.site = sites[i]
        }
        // Do any additional setup after loading the view.
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
