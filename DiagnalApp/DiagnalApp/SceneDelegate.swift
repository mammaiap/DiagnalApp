//
//  SceneDelegate.swift
//  DiagnalApp
//
//  Created by Muthulingam on 10/06/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    private var baseFileName = "CONTENTLISTINGPAGE-PAGE"
    
    private lazy var client: FileLoaderClient = {
            JSONFileLoaderClient()
        }()
    
    private lazy var navigationController = UINavigationController(rootViewController: makeAndShowMoviesFeedScene())

    convenience init(client: FileLoaderClient) {
            self.init()
            self.client = client
    }
    
  
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
       
        guard let _ = (scene as? UIWindowScene) else { return }
        //UIFont.loadCustomFonts
        configureWindow()
    }
    
    func configureWindow(){
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    func makeAndShowMoviesFeedScene() -> MoviesFeedViewController {
        let remoteFeedLoader = RemoteMockedMoviesFeedLoader(baseFileName: baseFileName, client: client)
        
        let feedViewController = MoviesFeedUIComposer.moviesFeedComposedWith(feedLoader: remoteFeedLoader)
        
        return feedViewController
        
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

