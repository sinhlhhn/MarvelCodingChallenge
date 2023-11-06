//
//  CharacterUIIntegrationTests.swift
//  CharacterUIIntegrationTests
//
//  Created by Sam on 06/11/2023.
//

import XCTest
import Marvel
import CharacteriOS
import MarvelApp

final class CharacterUIIntegrationTests: XCTestCase {

    func test_characterView_hasTitle() {
        let (sut, _) = makeSUT()
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.title, "Marvel Heros")
    }

    func test_loadCharacterActions_requestCharacterFromLoader() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadCharacterCallCount, 0, "Expected no loading requests before view is loaded")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCharacterCallCount, 1, "Expected a loading request once view is loaded")
        
        sut.simulateUserInitiatedCharacterReload()
        XCTAssertEqual(loader.loadCharacterCallCount, 2, "Expected another loading request once user initiates a reload")
        
        sut.simulateUserInitiatedCharacterReload()
        XCTAssertEqual(loader.loadCharacterCallCount, 3, "Expected yet another loading request once user initiates another reload")
    }
    
    func test_loadingCharacterIndicator_isVisibleWhileLoadingCharacter() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")

        loader.completeLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes successfully")

        sut.simulateUserInitiatedCharacterReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")

        loader.completeLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completes with error")
    }

    func test_loadCharacterCompletion_rendersSuccessfullyLoadedCharacter() {
        let image0 = makeCharacter(id: 0, name: "Iron man", thumbnail: URL(string: "http://any-url-1.com")!)
        let image1 = makeCharacter(id: 1, name: "Captain America", thumbnail: URL(string: "http://any-url-2.com")!)
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])

        loader.completeLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])

        sut.simulateUserInitiatedCharacterReload()
        loader.completeLoading(with: [image0, image1], at: 1)
        assertThat(sut, isRendering: [image0, image1])
    }

    func test_loadCharacterCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let image0 = makeCharacter(id: 0, name: "Iron man", thumbnail: URL(string: "http://any-url-1.com")!)
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])

        sut.simulateUserInitiatedCharacterReload()
        loader.completeLoadingWithError(at: 1)
        assertThat(sut, isRendering: [image0])
    }


    func test_characterImageView_loadsImageURLWhenVisible() {
        let image0 = makeCharacter(id: 0, name: "Iron man", thumbnail: URL(string: "http://any-url-1.com")!)
        let image1 = makeCharacter(id: 1, name: "Captain America", thumbnail: URL(string: "http://any-url-2.com")!)
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeLoading(with: [image0, image1])

        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until views become visible")

        sut.simulateCharacterImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.thumbnail], "Expected first image URL request once first view becomes visible")

        sut.simulateCharacterImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.thumbnail, image1.thumbnail], "Expected second image URL request once second view also becomes visible")
    }

    func test_characterImageView_cancelsImageLoadingWhenNotVisibleAnymore() {
        let image0 = makeCharacter(id: 0, name: "Iron man", thumbnail: URL(string: "http://any-url-1.com")!)
        let image1 = makeCharacter(id: 1, name: "Captain America", thumbnail: URL(string: "http://any-url-2.com")!)
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeLoading(with: [image0, image1])
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image URL requests until image is not visible")

        sut.simulateCharacterImageViewNotVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.thumbnail], "Expected one cancelled image URL request once first image is not visible anymore")

        sut.simulateCharacterImageViewNotVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.thumbnail, image1.thumbnail], "Expected two cancelled image URL requests once second image is also not visible anymore")
    }
    
    //MARK: -Helpers
    
    private func makeSUT(
        selection: @escaping (CharacterItem) -> Void = { _ in },
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (CharacterCollectionController, LoaderSpy) {
        let baseURL = URL(string: "https://gateway.marvel.com:443")!
        let url = CharacterEndpoint.get(0).url(baseURL: baseURL)
        let loader = LoaderSpy()
        let sut = CharacterUIComposer.characterComposeWith(
            with: url,
            characterLoader: loader,
            imageLoader: loader,
            onSelect: selection)
        
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(loader, file: file, line: line)
        
        return (sut, loader)
    }
    
    private func makeCharacter(id: Int, name: String, thumbnail: URL = URL(string: "http://any-url")!) -> CharacterItem {
        CharacterItem(id: id, name: name, thumbnail: thumbnail)
    }
    
    class LoaderSpy: CharacterLoader, CharacterImageDataLoader {
        
        // MARK: - CharacterLoader
        typealias LoaderResult = Swift.Result<Paginated, Error>
        private var characterRequests = [(LoaderResult) -> Void]()
        
        var loadCharacterCallCount: Int {
            return characterRequests.count
        }
        
        func load(from url: URL, completion: @escaping ((Result<Paginated, Error>) -> Void)) {
            characterRequests.append(completion)
        }
        
        func completeLoading(with characters: [CharacterItem] = [], at index: Int = 0) {
            characterRequests[index](.success(Paginated(characters: characters, isLast: false)))
        }
        
        func completeLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            characterRequests[index](.failure(error))
        }
        
        // MARK: - CharacterImageDataLoader
        
        private struct TaskSpy: CharacterImageDataLoaderTask {
            let cancelCallback: () -> Void
            func cancel() {
                cancelCallback()
            }
        }
        
        private var imageRequests = [(url: URL, completion: (CharacterImageDataLoader.Result) -> Void)]()
        
        var loadedImageURLs: [URL] {
            return imageRequests.map { $0.url }
        }
        
        private(set) var cancelledImageURLs = [URL]()
        
        func loadImageData(from url: URL, completion: @escaping (CharacterImageDataLoader.Result) -> Void) -> CharacterImageDataLoaderTask {
            imageRequests.append((url, completion))
            return TaskSpy { [weak self] in self?.cancelledImageURLs.append(url) }
        }
        
        func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
            imageRequests[index].completion(.success(imageData))
        }
        
        func completeImageLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            imageRequests[index].completion(.failure(error))
        }
    }
}

extension CharacterUIIntegrationTests {
    
    func assertThat(_ sut: CharacterCollectionController, isRendering characters: [CharacterItem], file: StaticString = #filePath, line: UInt = #line) {
        sut.view.enforceLayoutCycle()
        
        guard sut.numberOfRenderedCharacterImageViews() == characters.count else {
            XCTFail("Expected \(characters.count) characters, got \(sut.numberOfRenderedCharacterImageViews()) instead", file: file, line: line)
            return
        }
        
        characters.enumerated().forEach {
            assertThat(sut, hasViewConfigFor: $0.element, in: $0.offset, file: file, line: line)
        }
    }
    
    func assertThat(_ sut: CharacterCollectionController, hasViewConfigFor character: CharacterItem, in index: Int, file: StaticString = #filePath, line: UInt = #line) {
        let view = sut.characterImageView(at: index)
        
        guard let cell = view as? CharacterCollectionCell else {
            XCTFail("Expected \(CharacterCollectionCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
            return
        }
        
        XCTAssertEqual(cell.characterName, character.name, "Expected `characterName` to be \(String(describing: character.name)) for image view at index \(index) got \(String(describing: cell.characterName)) instead", file: file, line: line)
    }
}

extension CharacterCollectionCell {
    var characterName: String? {
        characterNameLabel.text
    }
    
    var isShowingImageLoadingIndicator: Bool {
        characterImageContainerView.isShimmering
    }
    
    func simulateRetryAction() {
        retryButton.simulateTap()
    }
}

extension XCTestCase {
    func trackForMemoryLeak(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should has been deallocated. Potential memory leak", file: file, line: line)
        }
    }
}
