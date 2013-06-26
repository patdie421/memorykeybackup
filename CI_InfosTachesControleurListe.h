#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>

@interface CI_InfosTachesControleurListe : NSObject
{
    @private

	NSTableView *listeDesInfosTaches;
    NSTableColumn *colonneListeDesInfoTaches;

    id delegate;
}

+ (id) controllerWithViewColumn:(NSTableColumn *) vCol;

- (void) setDelegate:(id) obj;
- (id) delegate;

- (void) reloadTableView;

@end

@protocol CI_InfosTachesControleurListeDataSourceProtocol

- (NSView *) tableView:(NSTableView *) tableView viewForRow:(int) row;

@end
