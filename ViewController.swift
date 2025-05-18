//
//  ViewController.swift
//  artBookLastV
//
//  Created by Ali Ünal UZUNÇAYIR on 16.05.2025.
//

import UIKit
import CoreData

class ViewController : UIViewController , UITableViewDelegate , UITableViewDataSource {
    
    var nameArray = [String]()
    var UUIDArray = [UUID]()
    var selectedPainting = ""
    var selectedID = UUID()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action:#selector(addTapped))
        // getData uygulama başlamadan önce bir defa çalışır sonra
        getData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newData"), object: nil)
    }
    
    //TableView Delegations
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        cell.textLabel?.text = nameArray[indexPath.row]
        return cell
    }
    //didselectte aldıklarımızı segue öncesi DetailsVc ye aktarıyoruz
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tosec" {
            let destinationVc = segue.destination as! DetailsVc
            destinationVc.chosenID = selectedID
            destinationVc.chosenPainting = selectedPainting
        }
        
    }
    //**************
    
    
    //didselect eğer tableden birşey seçildiyse seçilenin idsini ve name ini alacak ve segue perform yapacak
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPainting = nameArray[indexPath.row]
        selectedID = UUIDArray[indexPath.row]
        performSegue(withIdentifier: "tosec", sender: nil)
        
    }
    
    
    //add button func
    @objc func addTapped()  {
        selectedPainting = ""
        performSegue(withIdentifier: "tosec", sender: nil)
    }
    
    //DeTailsVCd eki verileri çekelim
    @objc func getData()  {
        nameArray.removeAll(keepingCapacity: false)
        UUIDArray.removeAll(keepingCapacity: false)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchreq = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")//NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings") geri dizi veriyor verdiği veriler exception atabilir bu yüzden try catch kullandık ve for loop ile verileri nameArray ve UUIDarry e kaydettik
        fetchreq.returnsObjectsAsFaults = false
        /*📌 Kısa Anlamı:
         fetchreq.returnsObjectsAsFaults = false
         Eğer bu değer:
         •    true olursa (varsayılan): Sadece nesne kabuğu (boş bir obje) döner. Asıl veriler ihtiyaç duyulana kadar yüklenmez (bu tasarruf sağlar).
         •    false olursa: Verilerin tamamı hemen çekilir ve belleğe yüklenir.
         
         Ne Zaman Kullanılır?
         •    Eğer verileri anında ve tamamen kullanman gerekiyorsa (image, name, details vs.) bu ayarı false yaparsın.
         •    Ama performans önemliyse ve büyük veri çekiyorsan, true tutmak daha sağlıklı olur.
         */
        do{
            let result = try context.fetch(fetchreq)
            
            for res in result as! [NSManagedObject] { // gelen veri string mi kontrol etmek için optional kullandı
                if let name = res.value(forKey: "name") as? String
                {
                    nameArray.append(name)
                }
                if let UUID = res.value(forKey: "id") as? UUID
                {
                    UUIDArray.append(UUID)
                }
                print("success")
            }
            
        }catch {
            print("error")
        }
        
        self.tableView.reloadData() //veri geldi tableview güncellenmeli bu classta olduğu için self reloadData() verileri güncelliyor
        
        
    }
    // tableviewda edititng style ekledik
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {// eğer editing style delete ise coredatadan o veriyi silicez
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchreq = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")// fetchreq yapacağımız datanın ismi
            
            let idString = UUIDArray[indexPath.row].uuidString /*
            .uuidString: UUID → String dönüşümü (çünkü NSPredicate string ister)
            ➕ Örnek: 2F8A12C4-2D8F-4BEF-B382-C29FA5FC82C5
              indexpath.row ile seçilen satırın uuıdsini alıp uuid stringe çevirdik
                                                                */
            
            fetchreq.predicate = NSPredicate(format: "id = %@",idString) //nspredicate ile sadece istediğimiz id yi getirdik
            
            // Buradaki for döngüsünün nedeni genelde predicate doğru ayarlanmadıysa veya garantiye almak içindir.
          //  Ama aslında doğru predicate yazılmışsa bu loop gereksiz.
            do {
                let result = try context.fetch(fetchreq)
                for res in result as! [NSManagedObject]{
                    if let id = res.value(forKey: "id") as? UUID {
                        if id == UUIDArray[indexPath.row] {
                            context.delete(res)
                            nameArray.remove(at: indexPath.row)
                            UUIDArray.remove(at: indexPath.row)
                            self.tableView.reloadData()
                            
                        }
                        do{
                            try context.save()
                        }catch {
                            print("error2")
                        }
                    }
                }
            }catch {
                print("error")
            }
        }
    }
    
}


