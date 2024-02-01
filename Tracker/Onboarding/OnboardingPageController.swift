//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Eugene Dmitrichenko on 29.01.2024.
//

import UIKit

class OnboardingPageController: UIPageViewController {
    
    private var currentPageIndex: Int = 0
    private lazy var pages: [UIViewController] = {
        
        let blueViewController = OnboardingViewController()
        let redViewController = OnboardingViewController()
        
        blueViewController.setupUI(image: OnboardImagesNames.backgroundBlue,
                                   label: OnboardLabels.labelBlue)
        redViewController.setupUI(image: OnboardImagesNames.backgroundRed,
                                  label: OnboardLabels.labelRed)
        return [
            blueViewController,
            redViewController
        ]
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = UIColor(named: ColorNames.black)
        pageControl.pageIndicatorTintColor = UIColor(named: ColorNames.gray)
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        return pageControl
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        if let firstPage = pages.first {
            setViewControllers([firstPage], direction: .forward, animated: true)
        }
        
        view.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            pageControl.topAnchor.constraint(equalTo: view.topAnchor, constant: 638),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        
    }
}

extension OnboardingPageController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else { return nil }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        
        let nextIndex = viewControllerIndex + 1
        guard nextIndex < pages.count else { return nil }
        
        return pages[nextIndex]
    }
}

extension OnboardingPageController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}
