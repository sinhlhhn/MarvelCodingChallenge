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
    private let client = URLSessionHTTPClient(session: URLSession.shared)
    private lazy var remoteCharacterLoader: RemoteLoader = {
        RemoteLoader(client: client, mapper: CharacterMapper.map)
    }()
    
    private lazy var remoteCharacterDetailLoader: RemoteLoader<CharacterDetailItem> = {
        RemoteLoader(client: client, mapper: CharacterDetailMapper.map)
    }()
    
    private let remoteImageLoader = RemoteImageLoader(session: URLSession.shared)
    
    private lazy var navigationController = UINavigationController(rootViewController: makeRootView())

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let scene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: scene)
        
        configureWindow()
    }
    
    func configureWindow() {
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    private func makeRootView() -> UIViewController {
        let vc = CharacterUIComposer.characterComposeWith(with: baseURL,
            characterLoader: MainQueueDispatchDecorator(decoratee: remoteCharacterLoader),
            imageLoader: MainQueueDispatchDecorator(decoratee: remoteImageLoader),
            onSelect: showDetail)
        
        return vc
    }
    
    private func showDetail(item: CharacterItem) {
        let url = CharacterEndpoint.getDetail(item).url(baseURL: baseURL)
        let vc = CharacterUIComposer.characterDetailComposeWith(
            url: url,
            loader: MainQueueDispatchDecorator(decoratee: remoteCharacterDetailLoader))
        
        navigationController.pushViewController(vc, animated: true)
    }
}
