

import UIKit
import SDWebImage
import CoreData

class ShowDetailes: UIViewController , UITableViewDelegate ,UITableViewDataSource {
    
    @IBOutlet weak var favbtn: UIButton!
    @IBOutlet weak var tit: UILabel!
    @IBOutlet weak var im: UIImageView!
    @IBOutlet weak var releaseYe: UILabel!
    @IBOutlet weak var Rat: UILabel!
    @IBOutlet weak var overview: UITextView!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var RRate: UILabel!
    var titstring :String = ""
    var imstring :String = ""
    var releaseYestring  :String = ""
    var Ratestring :String = ""
    var overviewstring :String = ""
    var iid :Int = 0
    var path1 :String = "https://api.themoviedb.org/3/movie/"
    var path2 :String = "/videos?api_key=89a950a1ef8df94c9deb0b5ea3f4254f&language=en-US"
    var moviManagedObject :[NSManagedObject] = []
    var Mov:[NSManagedObject] = []
    var dicti:Dictionary<String, Any> = [:]
    var videojson:Dictionary<String, Any> = [:]
    var videoResult:[Dictionary<String, Any>] = []
    var Reviewjson:Dictionary<String, Any> = [:]
    var ReviewResult:[Dictionary<String, Any>] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        
        tit.text = titstring
        im.sd_setImage(with:URL(string:imstring ))
        releaseYe.text = releaseYestring
        if(dicti.count != 0)
        {
            let rating = Int(dicti["vote_average"]! as! NSNumber)
            let ratingText = (0..<rating).reduce("") { (acc, _) -> String in
                return acc + "⭐"
            }
            Rat.text = ratingText
        }
       else
        {
             Rat.text = " "
            /*var ratingText:String = " "
            let rating = Int(Ratestring as! NSNumber )
            for _ in 0 ..< rating
            {
                ratingText.append("⭐")
            }
            
            
            Rat.text = ratingText*/
        }
        
        RRate.text = Ratestring+"/10"
        overview.text = overviewstring
        print(iid)
        getVidio()
        getReview()
        table.reloadData()
        
    }

    @IBAction func makefav(_ sender: Any) {
        let AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = AppDelegate.persistentContainer.viewContext
        let fetchRequset = NSFetchRequest<NSManagedObject>(entityName:"MovFav")
        
        let mypredicate = NSPredicate (format:"idFav == %i",iid)
        fetchRequset.predicate = mypredicate
        do
        {
            Mov = try managedContext.fetch(fetchRequset )
            if(Mov.count == 0)
            {
                if(dicti.count != 0)
                {
                    SavingInCoreData (dict:dicti)
                    favbtn.setTitle("UnFavourit", for: .normal)
                }
            }
            else
            {
                for item in 0..<Mov.count
                {
                    DeleteFromeCoreData(object: Mov[item])
                    favbtn.setTitle("Favourit", for: .normal)
                }
            }
            
        }catch let error as NSError
        {
            print (error)
        }
        
        
        
    }
    
    func SavingInCoreData (dict:Dictionary<String, Any>){
        let AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = AppDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName:"MovFav",in:managedContext)
        let mo = NSManagedObject(entity:entity! , insertInto: managedContext)
       // print(dict["poster_path"]!)
        mo.setValue(dict["poster_path"] as! String, forKey:"poster_pathFav")
       // print(dict["poster_path"]!)
        mo.setValue(dict["id"]!, forKey: "idFav")
        //print(dict["id"]!)
        mo.setValue(dict["original_title"]!, forKey:"original_titleFav")
       // print(dict["original_title"]!)
        mo.setValue(dict["vote_average"]!, forKey:"vote_averageFav")
       // print(dict["vote_average"]!)
        mo.setValue(dict["overview"]!, forKey:"overviewFav")
        //print(dict["overview"]!)
        mo.setValue(dict["release_date"]!, forKey:"releaseYearFav")
       // print(dict["release_date"]!)
        
        do
        {
            try managedContext.save()
            
        }catch let error as NSError
        {
            print(error)
        }
    }
    func DeleteFromeCoreData(object:NSManagedObject)
    {
        let AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = AppDelegate.persistentContainer.viewContext
        managedContext.delete(object)
        do
        {
            try managedContext.save()
            
        }catch let error as NSError
        {
            print(error)
        }
        
    }
    
    func getVidio()  {
        let url = URL(string:path1+String(iid)+path2)
        let request = URLRequest(url: url!)
        let session = URLSession(configuration: URLSessionConfiguration.default)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let _ = session.dataTask(with: request) { (data, response, error) in
            
            do{
                self.videojson = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! Dictionary<String, Any>
                
                let arr = self.videojson["results"] as! NSArray
                for i in 0..<arr.count
                {
                    if let video = (arr[i] as? Dictionary<String,Any>)
                    {
                        self.videoResult.append(video)
                    }
                }
                
                DispatchQueue.main.async {
                    self.table.reloadData()
                    
                }
                
                
                //  UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }catch let error{
                print("Json Error")
                print(error)
            }
            
            }.resume()
        
    }
    func getReview()  {
        let url = URL(string:"https://api.themoviedb.org/3/movie/"+String(iid)+"/reviews?api_key=89a950a1ef8df94c9deb0b5ea3f4254f&language=en-US&page=1")
        let request = URLRequest(url: url!)
        let session = URLSession(configuration: URLSessionConfiguration.default)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let _ = session.dataTask(with: request) { (data, response, error) in
            
            do{
                self.Reviewjson = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! Dictionary<String, Any>
                
                let arr = self.Reviewjson["results"] as! NSArray
                for i in 0..<arr.count
                {
                    if let video = (arr[i] as? Dictionary<String,Any>)
                    {
                        self.ReviewResult.append(video)
                    }
                }
                
                DispatchQueue.main.async {
                    self.table.reloadData()
                    
                }
                
                
                //  UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }catch let error{
                print("Json Error")
                print(error)
            }
            
            }.resume()
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2;
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0 ;
        switch (section) {
        case 0:
            count = videoResult.count
            break;
        case 1:
            count = ReviewResult.count
            break;
        default:
            break;
        }
        
        return count;
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"cell", for: indexPath)
        ///let cell2:ReviewCell = tableView.dequeueReusableCell(withIdentifier:"cell2", for: indexPath) as! ReviewCell
        switch (indexPath.section) {
        case 0:
           cell.textLabel?.text = "Trailer\(indexPath.row+1)"
           cell.imageView?.image = UIImage(named: "youtlogo.jpg")
           cell.detailTextLabel?.text = "Click to show the Trailer"
           //return cell
            break;
        case 1:
            if let author = ReviewResult[indexPath.row]["author"] as? String
            {
                //cell2.name.text = author
                cell.textLabel?.text = author
            }
            if let content = ReviewResult[indexPath.row]["content"] as? String
            {
                //cell2.Review.text = content
                cell.detailTextLabel?.text = content
            }
             cell.imageView?.image = nil
             //return cell2
            break;
        default:
            break;
        }
        return cell
        
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var secTitle = " "
        switch (section) {
        case 0:
            secTitle = "Trailers : ";
            break;
        case 1:
            secTitle = "Reviews : ";
            break;
        default:
            break;
        }
        
        return secTitle;
        
    }
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    var high:CGFloat = 0
    switch (indexPath.section) {
    case 0:
        high = 60
        break;
    case 1:
        high = 800
        break;
    default:
        break;
    }
    
    return high;
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section) {
        case 0:
            if let Key = videoResult[indexPath.row]["key"] as? String
                {
                    UIApplication.shared.open(URL(string:"https://www.youtube.com/watch?v=" + Key)!,options: [:],completionHandler: nil)
                }
            break
        default:
            break;
        }
       
    }
    

}
