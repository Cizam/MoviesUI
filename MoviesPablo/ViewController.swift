//
//  ViewController.swift
//  MoviesPablo
//
//  Created by movil6 on 08/09/16.
//  Copyright © 2016 movil6. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imgTop: UIImageView!
    @IBOutlet weak var imgPoster: ImageShadow!
    
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var lbl_year: UILabel!
    @IBOutlet weak var lbl_clasification: UILabel!
    @IBOutlet weak var lbl_runTime: UILabel!
    @IBOutlet weak var lbl_criticsScore: UILabel!
    @IBOutlet weak var lbl_audienceScore: UILabel!
    @IBOutlet weak var lbl_synopsis: UILabel!
    
    
    var resultsMovie = MoviesModel()!
    var resultsActors = [ActorsModel]()
    var resultsRatings = RatingsModel()!
    
    let defaultSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    var dataTask : NSURLSessionDataTask?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        tableView.dataSource = self
        tableView.delegate = self
        
        // Se cargan las imágenes en los ImageViews
        cargarImagen("http://www.impawards.com/2012/posters/avengers_ver21_xlg.jpg", imagen: imgTop)
        cargarImagen("http://static.srcdn.com/slir/w280-h414-q90-c280:414/wp-content/uploads/AVG_Payoff_1-Sht_v13-280x414.jpg", imagen: imgPoster)

        
        consumirWS()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cargarImagen(imageUrl: String, imagen: UIImageView) {
        
        let imageUrl = NSURL(string: imageUrl)
        let request: NSURLRequest = NSURLRequest(URL: imageUrl!)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse?, data: NSData?, error: NSError?) in
            
            if error == nil {
                imagen.image = UIImage(data: data!)
            }
            
        }
        
    }
    func consumirWS() -> Void {
        if dataTask != nil {
            dataTask?.cancel()
        }
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        //URL a consumir.
        let url = NSURL(string: "http://api.rottentomatoes.com/api/public/v1.0/movies.json?apikey=sabsf6qka779gqe3shgmf8da&q=The+Avengers&page_limit=1")
        
        dataTask = defaultSession.dataTaskWithURL(url!) {
            data, response, error in dispatch_async(dispatch_get_main_queue()) {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            }
            
            if let error = error {
                print(error.localizedDescription)
            } else if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode == 200 { //Si se obtiene una respuesta exitosa, actualizar los elementos de la pantalla.
                    print(data)
                    self.updateSearchResults(data)
                }
            }
        }
        dataTask?.resume()
    }

    /** MÉTODO QUE PARSEA LA RESPUESTA JSON EN UN ARRAY DE OBJETOS **/
    func updateSearchResults(data: NSData?) {

        do {
            if let data = data, response = try NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions(rawValue:0)) as? [String: AnyObject] {
                
                // Se obtiene el arreglo de "movies"
                if let array: AnyObject = response["movies"] {
                        for trackDictonary in array as! [AnyObject] {
                            //Se recuperan los datos correspondientes a la película.
                            resultsMovie.title = trackDictonary["title"] as? String
                            resultsMovie.year = trackDictonary["year"] as? Int
                            resultsMovie.mpaa_rating = trackDictonary["mpaa_rating"] as? String
                            resultsMovie.runtime = trackDictonary["runtime"] as? Int
                            resultsMovie.synopsis = trackDictonary["synopsis"] as? String
                            
                            //Se recuperan los datos correspondientes a las crìticas.
                            resultsRatings.critics_score = (trackDictonary["ratings"] as? [String:AnyObject])!["critics_score"] as? Int
                            resultsRatings.audience_score = (trackDictonary["ratings"] as? [String:AnyObject])!["audience_score"] as? Int
                            
                            //Se recuperan los datos correspondientes a los actores y sus personajes.
                            if let characters: AnyObject = trackDictonary["abridged_cast"] {
                                for charactersDictionary in characters as! [AnyObject] {
                                    let nameMovie = charactersDictionary["name"] as? String
                                    var characterMovie = charactersDictionary["characters"] as?  [String]
                                    resultsActors.append(ActorsModel(name: nameMovie!, characters: characterMovie![0])!)
                                
                                }
                            }
                        }
                    
                } else {
                    print("Results key not found in dictionary")
                }
            } else {
                print("JSON Error")
            }
        } catch let error as NSError {
            print("Error parsing results: \(error.localizedDescription)")
        }
        
        dispatch_async(dispatch_get_main_queue()) { //Una vez parseado el JSON, se imprimen los resultados en la pantalla.
            
            self.tableView.reloadData()
            self.tableView.setContentOffset(CGPointZero, animated: false)
            
            self.lbl_title.text = self.resultsMovie.title
            self.lbl_year.text! = "\(self.resultsMovie.year!)"
            self.lbl_clasification.text = self.resultsMovie.mpaa_rating
            self.lbl_runTime.text! = "\(self.resultsMovie.runtime!) minutes"
            self.lbl_synopsis.text = self.resultsMovie.synopsis
            
            self.lbl_criticsScore.text! = "Critics Score: \(self.resultsRatings.critics_score!)"
            self.lbl_audienceScore.text! = "Audience Score: \(self.resultsRatings.audience_score!)"

        }
    }


    //Número de secciones.
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    //Número de filas.
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsActors.count
    }
    
    //Va a regresar una celda, la cual es segura, no es opcional, es por ello que se colocan los signos de admiración.
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //Se coloca el identificador que se puso en el elemento TableViewCell.
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")
        let moviesResult = resultsActors[indexPath.row]
        
        //Se imprime el actor y su personaje.
        cell!.textLabel!.text = "\(moviesResult.name) as \(moviesResult.characters)"
        
        return cell!
    }}

