//
//  DetailsVc.swift
//  artBookLastV
//
//  Created by Ali Ünal UZUNÇAYIR on 16.05.2025.
//

import UIKit
import CoreData

class DetailsVc: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var imgview: UIImageView!
    @IBOutlet weak var nametxt: UITextField!
    @IBOutlet weak var yeartxt: UITextField!
    @IBOutlet weak var artistxt: UITextField!
    var chosenPainting = ""
    var chosenID = UUID()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //didselectten gelen verileri textfieldlere işliicez ama buradaki filtreleme işlemi önemli!!
        
        if chosenPainting != "" {
            //CoreData
            saveButton.isHidden = true
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchreq = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            let idString = chosenID.uuidString
            fetchreq.predicate = NSPredicate(format: "id = %@",idString)
                        do {
                let result = try context.fetch(fetchreq)
                            
                            if result.count > 0 {
                                for res in result as! [NSManagedObject] {
                                    if chosenID == res.value(forKey: "id") as! UUID {
                                        imgview.image = UIImage(data: res.value(forKey: "image") as! Data)
                                        nametxt.text = res.value(forKey: "name") as? String
                                        artistxt.text = res.value(forKey: "artist") as? String
                                        if let year = res.value(forKey:"year") as? Int{
                                            yeartxt.text = String(year)
                                        }
                                    }
                               
                                }
                            }
             
            }catch{
                print("error")
            }
            
            
            
        }
        else {
            saveButton.isEnabled = true
            saveButton.isHidden = false
            nametxt.text = ""
            artistxt.text = ""
            yeartxt.text = ""
        }
        
        
        
        
        
        
        
        imgview.isUserInteractionEnabled = true
        let imgGesture = UITapGestureRecognizer(target:self, action: #selector(imgTap))
        imgview.addGestureRecognizer(imgGesture)
        let gesrec = UITapGestureRecognizer(target: self, action: #selector(isHid))
           view.addGestureRecognizer(gesrec)
       
      
    }
    //save button ile core data ya veri yüklüyoruz
    @IBAction func saveButtonCliccked(_ sender: Any) {
        let appDeleagte = UIApplication.shared.delegate as! AppDelegate // küçük bir app delegate hazırladık
        let context = appDeleagte.persistentContainer.viewContext//içindeki viewcontext e girdik
        
        //entityi tanıttık
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
    
        newPainting.setValue(nametxt.text, forKey: "name")// name e değer atadık
        
        
        if let year = Int(yeartxt.text!) {
            newPainting.setValue(year, forKey: "year") //yeara değer atadık
        }
        newPainting.setValue(artistxt.text, forKey: "artist") //artsite değer atadık
        
        if let imgData = imgview.image?.jpegData(compressionQuality: 0.5) {
            //img ı data olarak aldığımız için (yani 01FC12131 gibi)
            //onu datadan jpeg e çeviridik
            //compressionQuality sıkıştırma miktarını belirtir küçülsiün ki daha kolay alabilelim
            newPainting.setValue(imgData, forKey: "image")
        }
        
        newPainting.setValue(UUID(), forKey: "id")
        
        do {
            try context.save()
            print("success")
        }
        catch {
            print("hata")
        }
        self.navigationController?.popViewController(animated: true)// save e basınca viewcontrolerr e dönmemizi sağlar
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil) //tüm app a  Notification atar observer ı newData olan alır biz bunu view contolera yeniden gelince table view getdata işlemini yapıp tableviewa  yeni name gelen name ve ıd yi eklesin diye yapıyoruz
        
    }
    
    @objc func imgTap() {
        // image picker için deleagtion işlemi yapıldı UIImagePickerControllerDelegate & UINavigationControllerDelegate
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
       present(  picker, animated: true , completion: nil)
    }
    
    //foto seçilince çalışacak func
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imgview.image = info[.editedImage] as? UIImage
        saveButton.isEnabled = true 
        self.dismiss(animated: true)
        
        
    }
   //keybordHidder
    @objc func isHid()  {
        view.endEditing(true)
    }
    
}
