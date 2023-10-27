//
//  SceneDelegate.swift
//  MarvelApp
//
//  Created by Sam on 27/10/2023.
//

import UIKit
import Marvel
import CharacteriOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    private let baseURL = URL(string: "https://gateway.marvel.com:443")!
    private let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    private lazy var url = CharacterEndpoint.get.url(baseURL: baseURL)
    private lazy var remoteCharacterLoader: RemoteCharacterLoader = {
        RemoteCharacterLoader(url: url, client: client)
    }()
    
    private let remoteImageLoader = RemoteImageLoader(session: URLSession(configuration: .ephemeral))

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let scene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: scene)
        
        configureWindow()
    }
    
    func configureWindow() {
        
        let vc = CharacterUIComposer.characterComposeWith(characterLoader: remoteCharacterLoader, imageLoader: remoteImageLoader)
        vc.title = "Marvel Heroes"
        
        let navigationController = UINavigationController(rootViewController: vc)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}
