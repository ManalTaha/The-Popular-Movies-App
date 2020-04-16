

import UIKit
import CoreData
import SDWebImage

private let reuseIdentifier = "CellF"
 var moviManagedObject :[NSManagedObject] = []

class FavouriteController: UICollectionViewController,UICollectionViewDelegateFlowLayout {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    override func viewWillAppear(_ animated: Bool) {
        fetchingFromeCoreData ()
         if moviManagedObject.count == 0
         {
            let alert = UIAlertController(title: "Alert", message: " You Don't have any favourit movi yet", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancle", style: .cancel, handler: nil))
            self.present(alert,animated: true)
         }
        self.collectionView.reloadData()
    }
    func fetchingFromeCoreData (){
        let AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = AppDelegate.persistentContainer.viewContext
        let fetchRequset = NSFetchRequest<NSManagedObject>(entityName:"MovFav")
        
        //let mypredicate = NSPredicate (format:"title == %@","movi 1")
        // fetchRequset.predicate = mypredicate
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
        return moviManagedObject.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:HomeCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HomeCell
         let mov = moviManagedObject[indexPath.row]
        if let imagePath =  mov.value(forKeyPath:"poster_pathFav") as? String
        {
            cell.FavimVi.sd_setImage(with:URL(string:"https://image.tmdb.org/t/p/w185/" + imagePath ))
        }
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:self.view.frame.size.width/2, height:self.view.frame.size.height/2 )
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(Reachability.isConnectedToNetwork())
        {
        let sh =  self.storyboard?.instantiateViewController(withIdentifier: "View") as! ShowDetailes
        
        let mov = moviManagedObject[indexPath.row]
        
        if let idd = mov.value(forKeyPath:"idFav") as? Int
        {
            sh.iid = idd
        }
        if let original_title = mov.value(forKeyPath:"original_titleFav") as? String
        {
            sh.titstring = original_title
        }
        if let poster_path = mov.value(forKeyPath:"poster_pathFav") as? String
        {
            sh.imstring  = "https://image.tmdb.org/t/p/w185/" + poster_path
        }
        //print(result[indexPath.row]["vote_average"]as! Double)
        if let vote_average = mov.value(forKeyPath:"vote_averageFav") as? Double
        {
            
            sh.Ratestring = String (vote_average)
        }
        if let release_date = mov.value(forKeyPath:"releaseYearFav") as? String
        {
            sh.releaseYestring  = release_date
        }
        if let overview = mov.value(forKeyPath:"overviewFav") as? String
        {
            sh.overviewstring =  overview
        }
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
