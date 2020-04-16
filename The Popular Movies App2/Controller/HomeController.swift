

import UIKit
import SDWebImage
import CoreData
import BTNavigationDropdownMenu

class HomeController: UICollectionViewController,UICollectionViewDelegateFlowLayout {
    
    var  json :Dictionary<String, Any> = [:]
    var result :Array<Dictionary<String, Any>> = []
    var moviManagedObject :[NSManagedObject] = []
    var path = "https://image.tmdb.org/t/p/w185/"
   // var Jsonpath = "https://api.themoviedb.org/3/discover/movie?api_key=89a950a1ef8df94c9deb0b5ea3f4254f&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&page=1"
    let items = ["Most Popular", "Top Rated"]
    var menuView:BTNavigationDropdownMenu!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuView = BTNavigationDropdownMenu(navigationController: self.navigationController, containerView: self.navigationController!.view, title: BTTitle.title("Dropdown Menu"), items: items)
        
        self.navigationItem.titleView = menuView
       /* if(Reachability.isConnectedToNetwork())
        {
            print("connect")
           /* fetchingFromeCoreData ()
            print(moviManagedObject.count)
            if(moviManagedObject.count == 0)
            {
                for item in 0..<result.count
                {
                    SavingInCoreData (dict:result[item])
                }
                
                fetchingFromeCoreData ()
            }
            
        }
        else{
            fetchingFromeCoreData ()
            print ("not connect")*/
            
        }else
        {
            let alert = UIAlertController(title: "Network Connection", message: "Check your connection !", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancle", style: .cancel, handler: nil))
            self.present(alert,animated: true)
        }*/
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        
        if(Reachability.isConnectedToNetwork())
        {
            getDataOnline(Jsonpath:"https://api.themoviedb.org/3/discover/movie?api_key=89a950a1ef8df94c9deb0b5ea3f4254f&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&page=1")
        
        
            menuView!.didSelectItemAtIndexHandler = {[weak self] (indexPath: Int) -> () in
           // print("Did select item at index: \(indexPath)")
                
                self!.json = [:]
                self!.result = []
                if indexPath == 0
                {
                    print("Did select item at index: \(indexPath)")
                    if(Reachability.isConnectedToNetwork())
                    {
                        self!.getDataOnline(Jsonpath:"https://api.themoviedb.org/3/discover/movie?api_key=89a950a1ef8df94c9deb0b5ea3f4254f&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&page=1")
                        self?.collectionView.reloadData()
                    }
                    else
                    {
                        let alert = UIAlertController(title: "Network Connection", message: "Check your connection !", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Cancle", style: .cancel, handler: nil))
                        self!.present(alert,animated: true)
                    }
                }
                else
                {
                    if indexPath == 1
                    {
                        if(Reachability.isConnectedToNetwork())
                        {
                            self!.getDataOnline(Jsonpath:"https://api.themoviedb.org/3/movie/top_rated?api_key=89a950a1ef8df94c9deb0b5ea3f4254f&language=en-US&page=1")
                            self?.collectionView.reloadData()
                        }else
                        {
                            let alert = UIAlertController(title: "Network Connection", message: "Check your connection !", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Cancle", style: .cancel, handler: nil))
                            self!.present(alert,animated: true)
                        }
                    }
                   
                }
                
            
        }
            
        } else
        {
            let alert = UIAlertController(title: "Network Connection", message: "Check your connection !", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancle", style: .cancel, handler: nil))
            self.present(alert,animated: true)
        }
        
        
    }
    
   
    func getDataOnline(Jsonpath:String)  {
        let url = URL(string:Jsonpath)
        let request = URLRequest(url: url!)
        let session = URLSession(configuration: URLSessionConfiguration.default)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let _ = session.dataTask(with: request) { (data, response, error) in
            
            do{
                self.json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! Dictionary<String, Any>
                
                let arr = self.json["results"] as! NSArray
                for i in 0..<arr.count
                {
                    if let film = (arr[i] as? Dictionary<String,Any>)
                    {
                      self.result.append(film)
                    }
                }
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                   
                }
                
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }catch let error{
                print("Json Error")
                print(error)
            }
            
            }.resume()
        
    }
    
    @IBAction func menu(_ sender: Any) {
        if(Reachability.isConnectedToNetwork())
        {
          menuView.show()
        }
        else
        {
            let alert = UIAlertController(title: "Network Connection", message: "Check your connection !", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancle", style: .cancel, handler: nil))
            self.present(alert,animated: true)
        }
    }
    
    func SavingInCoreData (dict:Dictionary<String, Any>){
        let AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = AppDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName:"Movi",in:managedContext)
        let mo = NSManagedObject(entity:entity! , insertInto: managedContext)
        mo.setValue(dict["popularity"]!, forKey: "popularity")
        mo.setValue(dict["vote_count"]!, forKey: "vote_count")
        mo.setValue(dict["poster_path"]!, forKey: "poster_path")
        mo.setValue(dict["id"]!, forKey: "id")
        var type:String = ""
        var ty:[String] = dict["genre_ids"] as! [String]
        for i in 0..<ty.count
        {
            type.append(ty[i])
            type.append(" ")
            type.append(" ")
            type.append(" ")
        }
        mo.setValue(type, forKey: "genre_ids")
        mo.setValue(dict["backdrop_path"]!, forKey: "backdrop_path")
        mo.setValue(dict["original_language"]!, forKey: "original_language")
        mo.setValue(dict["original_title"]!, forKey: "original_title")
        mo.setValue(dict["vote_average"]!, forKey: "vote_average")
        mo.setValue(dict["overview"]!, forKey: "overview")
        mo.setValue(dict["title"]!, forKey: "title")
        mo.setValue(dict["release_date"]!, forKey: "release_date")
        
        do
        {
            try managedContext.save()
            
        }catch let error as NSError
        {
            print(error)
        }
    }
    
    func fetchingFromeCoreData (){
        let AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = AppDelegate.persistentContainer.viewContext
        let fetchRequset = NSFetchRequest<NSManagedObject>(entityName:"Movi")
        do
        {
            moviManagedObject = try managedContext.fetch(fetchRequset )
            
        }catch let error as NSError
        {
            print(error)
        }

        
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return result.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         let cell:HomeCell = collectionView.dequeueReusableCell(withReuseIdentifier:"cell", for: indexPath) as! HomeCell
        if(Reachability.isConnectedToNetwork())
        {
            if let imagePath = (result[indexPath.row]["poster_path"] as? String)
            {
                cell.imv.sd_setImage(with:URL(string: path + imagePath ))
            }
        }
        else
        {
            let alert = UIAlertController(title: "Network Connection", message: "Check your connection !", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancle", style: .cancel, handler: nil))
            self.present(alert,animated: true)
        }
        
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:self.view.frame.size.width/2, height:self.view.frame.size.height/2)
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sh =  self.storyboard?.instantiateViewController(withIdentifier: "View") as! ShowDetailes
        if(Reachability.isConnectedToNetwork())
        {
            
            if let idd = result[indexPath.row]["id"] as? Int
            {
                sh.iid = idd
            }
            if let original_title = result[indexPath.row]["original_title"] as? String
            {
                sh.titstring = original_title
            }
            if let poster_path = result[indexPath.row]["poster_path"] as? String
            {
                sh.imstring  = path + poster_path
            }
            if let vote_average = result[indexPath.row]["vote_average"] as? Double
            {
            
                sh.Ratestring = String (vote_average)
            }
            if let release_date = result[indexPath.row]["release_date"] as? String
            {
                sh.releaseYestring  = release_date
            }
            if let overview = result[indexPath.row]["overview"] as? String
            {
                sh.overviewstring =  overview
            }
            sh.dicti = result[indexPath.row]
            self.navigationController?.pushViewController(sh, animated: true)
        
    }
    else
    {
        let alert = UIAlertController(title: "Network Connection", message: "Check your connection !", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancle", style: .cancel, handler: nil))
        self.present(alert,animated: true)
    }

}
}
