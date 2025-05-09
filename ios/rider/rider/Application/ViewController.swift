//
//  ViewController.swift
//  OnboardingScreens
//
//  Created by Janarthanan Kannan on 09/04/24.
//

import UIKit

class ViewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var skipButton: UIButton!
    ///Properties
    private var onboardingSlides: [OnboardingModel] = []
    private var currentPage = 0 {
        didSet {
            updateCurrentPage()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nextButton.titleLabel?.textColor =  UIColor.black
        nextButton.layer.cornerRadius = 10
        nextButton.layer.borderColor = UIColor.black.cgColor
        nextButton.layer.borderWidth = 1
        nextButton.titleLabel?.textColor =  UIColor.black
        setupUI()
    }
    
    @IBAction func skipbutton(_ sender: Any) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SplashViewController") as? SplashViewController {

            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func GetStarted() {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SplashViewController") as? SplashViewController {

            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //MARK: - SetupUI
    
    private func setupUI() {
        onboardingSlides = [
            OnboardingModel(title: "Your next ride is just a tap away",
                            description: "",
                            image: UIImage(named: "info_2")!),
            OnboardingModel(title: "Book rides with your preferred drivers",
                            description: "",
                            image: UIImage(named: "info_1")!),
            OnboardingModel(title: "Choose the ride that suits you best",
                            description: "",
                            image: UIImage(named: "info_3")!),
            OnboardingModel(title: "Meet trusted drivers. Your safety is our priority",
                            description: "",
                            image: UIImage(named: "info_4")!)
        ]
        
        //PageControl
        pageControl.numberOfPages = onboardingSlides.count
    }
    
    private func updateCurrentPage() {
        pageControl.currentPage = currentPage
        
        // Check if it's the last page
        if currentPage == onboardingSlides.count - 1 {
            // Style the "Get Started" button
            nextButton.isHidden = false // Ensure button is visible
            nextButton.setTitle("Get Started", for: .normal)
            nextButton.setTitleColor(UIColor(named: "ThemeYellow"), for: .normal) // Yellow text color
            nextButton.backgroundColor = .clear // Transparent background
            nextButton.layer.borderColor = UIColor(named: "ThemeYellow")?.cgColor // Yellow border
            nextButton.layer.borderWidth = 2
            nextButton.layer.cornerRadius = 10 // Rounded button
            
            // Hide the skip button
            skipButton.isHidden = true
            
            // Center the button and adjust its size
            nextButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                nextButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
                nextButton.widthAnchor.constraint(equalToConstant: 100),
                nextButton.heightAnchor.constraint(equalToConstant: 50)
            ])
            
        }
        
        else {
            // Style the "Next" button for other pages
            nextButton.isHidden = false // Ensure button is visible
            nextButton.setTitle("Next", for: .normal)
            nextButton.setTitleColor(UIColor.black, for: .normal) // Black text color
            nextButton.backgroundColor = .clear // Transparent background
            nextButton.layer.borderColor = UIColor.black.cgColor // Black border
            nextButton.layer.borderWidth = 1
            nextButton.layer.cornerRadius = 10 // Slightly rounded corners
            skipButton.isHidden = false
            
        }
    }

    
    
//    private func updateCurrentPage() {
//        pageControl.currentPage = currentPage
//        
//        // Check if it's the last page
//        if currentPage == onboardingSlides.count - 1 {
//            // Style the "Get Started" button
//            nextButton.isHidden = false // Ensure button is visible
//            nextButton.setTitle("Get Started", for: .normal)
//            nextButton.setTitleColor(UIColor.white, for: .normal) // White text color
//            nextButton.backgroundColor = UIColor(named: "ThemeYellow") // Yellow background
//            skipButton.isHidden = true // Hide the skip button
//            
//            nextButton.layer.cornerRadius = 10
//            nextButton.layer.borderWidth = 0 // Remove border for cleaner look
//            nextButton.contentHorizontalAlignment = .center // Center text inside button
//
//            // Center the button in the view
//            nextButton.translatesAutoresizingMaskIntoConstraints = false
//            NSLayoutConstraint.activate([
//                nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//                nextButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
//                nextButton.widthAnchor.constraint(equalToConstant: 200),
//                nextButton.heightAnchor.constraint(equalToConstant: 50)
//            ])
//        } else {
//            // Style the "Next" button
//            nextButton.isHidden = false // Ensure button is visible
//            nextButton.setTitle("Next", for: .normal)
//            nextButton.setTitleColor(UIColor.black, for: .normal) // Black text color
//            nextButton.backgroundColor = UIColor.clear // Transparent background
//            skipButton.isHidden = false // Show the skip button
//            
//            nextButton.layer.cornerRadius = 10
//            nextButton.layer.borderColor = UIColor.black.cgColor // Black border
//            nextButton.layer.borderWidth = 1
//            nextButton.contentHorizontalAlignment = .center // Center text inside button
//        }
//    }

    
    
//    private func updateCurrentPage() {
//        pageControl.currentPage = currentPage
//        
//        nextButton.setTitle(
//            currentPage == onboardingSlides.count - 1 ? "Get Started" : "Next" ,
//            for: .normal)
//        if(currentPage == 3){
//            nextButton.titleLabel?.textColor =  UIColor(named: "ThemeYellow")
//            skipButton.isHidden = true
//            nextButton.layer.cornerRadius = 10
//            nextButton.layer.borderColor = UIColor(named: "ThemeYellow")?.cgColor
//            nextButton.layer.borderWidth = 1
//            nextButton.contentHorizontalAlignment = .center // Center the text
//
//        }
//        else {
//            
//            nextButton.titleLabel?.textColor =  UIColor.black
//            skipButton.isHidden = false
//            nextButton.layer.cornerRadius = 10
//            nextButton.layer.borderColor = UIColor.black.cgColor
//            nextButton.layer.borderWidth = 1
//        }
//    }
    
    //MARK: - UIButton Action
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        currentPage == onboardingSlides.count - 1 ? GetStarted() : moveToNext()
//        if currentPage == 3{
//            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SplashViewController") as? SplashViewController {
//
//                self.navigationController?.pushViewController(vc, animated: true)
//            }
//        }
//
    }
    
    private func moveToNext() {
        currentPage += 1
        let indexPath = IndexPath(item: currentPage, 
                                  section: 0)
        collectionView.scrollToItem(at: indexPath, 
                                    at: .centeredHorizontally,
                                    animated: true)
    }

}

//MARK: - UICollectionView DataSource
extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return onboardingSlides.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnboardingCollectionCell.identifier,
                                                      for: indexPath) as! OnboardingCollectionCell
        cell.setupCell(onboardingSlides[indexPath.row])
        return cell
    }
}

//MARK: - UICollectionView Delegates
extension ViewController: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width
        currentPage = Int(scrollView.contentOffset.x / width)
    }
}

//MARK: - UICollectionView Delegate FlowLayout
extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width,
                      height: collectionView.frame.height)
    }
}

struct OnboardingModel {
    let title: String
    let description: String
    let image: UIImage
}
class OnboardingCollectionCell: UICollectionViewCell {
    
    //MARK: - Constants
    
    ///Reuse cell identifier
    static let identifier = "onboardingCell"
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    /// Method to configure cell
    func setupCell(_ item: OnboardingModel) {
        imageView.image = item.image
        titleLabel.text = item.title
        descriptionLabel.text = item.description
    }
}
