import Foundation
import Cocoa

var bookmarks = [URL: Data]()

func openFolderSelection() -> URL?
{
    let openPanel = NSOpenPanel()
    openPanel.allowsMultipleSelection = false
    openPanel.canChooseDirectories = true
    openPanel.canCreateDirectories = true
    openPanel.canChooseFiles = false
    openPanel.begin
        { (result) -> Void in
            if result.rawValue == NSApplication.ModalResponse.OK.rawValue
            {
                let url = openPanel.url
                storeFolderInBookmark(url: url!)
            }
    }
    return openPanel.url
}

func saveBookmarksData()
{
    let path = getBookmarkPath()
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

func getBookmarkPath() -> String
{
    var url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
    url = url.appendingPathComponent("Bookmarks.dict")
    return url.path
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
