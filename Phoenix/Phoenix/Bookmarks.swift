import Foundation
import Cocoa

var bookmarks = [URL: Data]()

func openFolderSelection() -> URL? {
    let openPanel = NSOpenPanel()
    openPanel.allowsMultipleSelection = false
    openPanel.canChooseDirectories = true
    openPanel.canCreateDirectories = true
    openPanel.canChooseFiles = false
    let result = openPanel.runModal()
    if result == NSApplication.ModalResponse.OK {
        let url = openPanel.url
        storeFolderInBookmark(url: url!)
        return url
    }
    return nil
}

func saveBookmarksData()
{
    let path = getBookmarkPath()
    print(path)
    NSKeyedArchiver.archiveRootObject(bookmarks, toFile: path)
}

func storeFolderInBookmark(url: URL)
{
    do
    {
        let data = try url.bookmarkData(options: NSURL.BookmarkCreationOptions.withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
        bookmarks[url] = data
    }
    catch
    {
        Swift.print ("Error storing bookmarks")
    }
    
}

//func getBookmarkPath() -> String
//{
//    var url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
//    url = url.appendingPathComponent("Bookmarks.dict")
//    return url.path
//}

func getBookmarkPath() -> String {
    let fileManager = FileManager.default
    let supportDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0] as URL
    let phoenixDirectory = supportDirectory.appendingPathComponent("Phoenix")  // Add the 'Phoenix' directory to the Application Support directory URL
    let url = phoenixDirectory.appendingPathComponent("Bookmarks.dict")  // Add the 'Bookmarks.dict' file to the 'Phoenix' directory URL
    return url.path  // Return the path to the 'Bookmarks.dict' file
}




func loadBookmarks()
{
    let path = getBookmarkPath()
    bookmarks = NSKeyedUnarchiver.unarchiveObject(withFile: path) as! [URL: Data]
    for bookmark in bookmarks
    {
        restoreBookmark(bookmark)
    }
}



func restoreBookmark(_ bookmark: (key: URL, value: Data))
{
    let restoredUrl: URL?
    var isStale = false
    
    Swift.print ("Restoring \(bookmark.key)")
    do
    {
        restoredUrl = try URL.init(resolvingBookmarkData: bookmark.value, options: NSURL.BookmarkResolutionOptions.withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
    }
    catch
    {
        Swift.print ("Error restoring bookmarks")
        restoredUrl = nil
    }
    
    if let url = restoredUrl
    {
        if isStale
        {
            Swift.print ("URL is stale")
        }
        else
        {
            if !url.startAccessingSecurityScopedResource()
            {
                Swift.print ("Couldn't access: \(url.path)")
            }
        }
    }
    
}
