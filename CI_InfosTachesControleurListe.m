#import <Cocoa/Cocoa.h>

#import "CI_InfosTachesControleurListe.h"
#import "CI_InfosTachesCelluleInfo.h"


@implementation CI_InfosTachesControleurListe


- (id) initWithViewColumn:(NSTableColumn *) vCol
{
    if ((self = [super init]) != nil)
    {
        // Weak references
        colonneListeDesInfoTaches = vCol;
        listeDesInfosTaches = [colonneListeDesInfoTaches tableView];
        
        // Setup table view delegate and data source
        [listeDesInfosTaches setDataSource: self];
        [listeDesInfosTaches setDelegate: self];
        
        // Setup cell type for views column
        [colonneListeDesInfoTaches setDataCell: [[[CI_InfosTachesCelluleInfo alloc] init] autorelease]];
        
        // Setup column properties
        [colonneListeDesInfoTaches setEditable: NO];
    }
    
    return self;
}


- (void) dealloc
{
    listeDesInfosTaches = nil;
    colonneListeDesInfoTaches = nil;
    delegate = nil;
    
    [super dealloc];
}


+ (id) controllerWithViewColumn:(NSTableColumn *) vCol
{
    return [[[self alloc] initWithViewColumn: vCol] autorelease];
}


- (void) setDelegate:(id) obj
{
    // Check that the object passed to this method supports the required methods
//    NSParameterAssert([obj conformsToProtocol: @protocol(CI_InfosTachesControleurListeDataSourceProtocol)]);
    
    // Weak reference
    delegate = obj;
}


- (id) delegate
{
    return delegate;
}


- (void) reloadTableView
{
    while ([[listeDesInfosTaches subviews] count] > 0)
    {
		[[[listeDesInfosTaches subviews] lastObject] removeFromSuperviewWithoutNeedingDisplay];
    }
    
    [listeDesInfosTaches reloadData];
}


- (BOOL) isValidDelegateForSelector:(SEL) command
{
    return (([self delegate] != nil) && [[self delegate] respondsToSelector: command]);
}


// Methods from NSTableViewDelegate category
- (BOOL) selectionShouldChangeInTableView:(NSTableView *) tableView
{
	return NO;
/*
    if ([self isValidDelegateForSelector: _cmd])
    {
		return [[self delegate] selectionShouldChangeInTableView: tableView];
    }
    else
    {
		return YES;
    }
*/
}


- (void) tableView:(NSTableView *) tableView didClickTableColumn:(NSTableColumn *) tableColumn
{
    if ([self isValidDelegateForSelector: _cmd])
    {
		[[self delegate] performSelector: _cmd withObject: tableView withObject: tableColumn];
    }
}


- (void) tableView:(NSTableView *) tableView didDragTableColumn:(NSTableColumn *) tableColumn
{
    if ([self isValidDelegateForSelector: _cmd])
    {
		[[self delegate] performSelector: _cmd withObject: tableView withObject: tableColumn];
    }
}


- (void) tableView:(NSTableView *) tableView mouseDownInHeaderOfTableColumn:(NSTableColumn *) tableColumn
{
    if ([self isValidDelegateForSelector: _cmd])
    {
		[[self delegate] performSelector: _cmd withObject: tableView withObject: tableColumn];
    }
}


- (BOOL) tableView:(NSTableView *) tableView shouldEditTableColumn:(NSTableColumn *) tableColumn row:(int) row
{
	return NO;
/*
    if ([self isValidDelegateForSelector: _cmd])
    {
		return [[self delegate] tableView: tableView shouldEditTableColumn: tableColumn row: row];
    }
    else
    {
		return YES;
    }
*/
}


- (BOOL) tableView:(NSTableView *) tableView shouldSelectRow:(int) row
{
	return NO;
/*
    if ([self isValidDelegateForSelector: _cmd])
    {
		return [[self delegate] tableView: tableView shouldSelectRow: row];
    }
    else
    {
		return YES;
    }
*/
}


- (BOOL) tableView:(NSTableView *) tableView shouldSelectTableColumn:(NSTableColumn *) tableColumn
{
	return NO;
/*
    if ([self isValidDelegateForSelector: _cmd])
    {
		return [[self delegate] tableView: tableView shouldSelectTableColumn: tableColumn];
    }
    else
    {
		return YES;
    }
*/
}


- (void) tableView:(NSTableView *) tableView willDisplayCell:(id) cell forTableColumn:(NSTableColumn *) tableColumn row:(int) row
{
    if (tableColumn == colonneListeDesInfoTaches)
    {
        if ([self isValidDelegateForSelector: @selector(tableView:viewForRow:)])
		{
            // This is one of the few interesting things going on in this class. This is where
            // our custom cell class is assigned the custom view that should be displayed for
            // a particular row.
            [(CI_InfosTachesCelluleInfo *)cell addSubview: [[self delegate] tableView: tableView viewForRow: row]];
		}
    }
    else
    {
        if ([self isValidDelegateForSelector: _cmd])
		{
			[[self delegate] tableView: tableView willDisplayCell: cell forTableColumn: tableColumn row: row];
		}
    }
}


- (void) tableViewColumnDidMove:(NSNotification *) notification
{
    if ([self isValidDelegateForSelector: _cmd])
    {
		[[self delegate] performSelector: _cmd withObject: notification];
    }
}


- (void) tableViewColumnDidResize:(NSNotification *) notification
{
    if ([self isValidDelegateForSelector: _cmd])
    {
		[[self delegate] performSelector: _cmd withObject: notification];
    }
}


- (void) tableViewSelectionDidChange:(NSNotification *) notification
{
    if ([self isValidDelegateForSelector: _cmd])
    {
		[[self delegate] performSelector: _cmd withObject: notification];
    }
}


- (void) tableViewSelectionIsChanging:(NSNotification *) notification
{
    if ([self isValidDelegateForSelector: _cmd])
    {
		[[self delegate] performSelector: _cmd withObject: notification];
    }
}


// Methods from NSTableDataSource protocol
- (int) numberOfRowsInTableView:(NSTableView *) tableView
{
    int count = 0;
    
    if ([self isValidDelegateForSelector: _cmd])
    {
		count = [[self delegate] numberOfRowsInTableView: tableView];
    }

    return count;
}


- (BOOL) tableView:(NSTableView *) tableView acceptDrop:(id <NSDraggingInfo>) info row:(int) row dropOperation:(NSTableViewDropOperation) operation
{
    if ([self isValidDelegateForSelector: _cmd])
    {
		return [[self delegate] tableView: tableView acceptDrop: info row: row dropOperation: operation];
    }
    else
    {
		return NO;
    }
}


- (id) tableView:(NSTableView *) tableView objectValueForTableColumn:(NSTableColumn *) tableColumn row:(int) row
{
    id obj = nil;

    if ((tableColumn != colonneListeDesInfoTaches) && [self isValidDelegateForSelector: _cmd])
    {
		obj = [[self delegate] tableView: tableView objectValueForTableColumn: tableColumn row: row];
    }

    return obj;
}


- (void) tableView:(NSTableView *) tableView setObjectValue:(id) obj forTableColumn:(NSTableColumn *) tableColumn row:(int) row
{
    if ((tableColumn != colonneListeDesInfoTaches) && [self isValidDelegateForSelector: _cmd])
    {
		[[self delegate] tableView: tableView setObjectValue: obj forTableColumn: tableColumn row: row];
    }
}


- (NSDragOperation) tableView:(NSTableView *) tableView validateDrop:(id <NSDraggingInfo>) info proposedRow:(int) row proposedDropOperation:(NSTableViewDropOperation) operation
{
    if ([self isValidDelegateForSelector: _cmd])
    {
		return [[self delegate] tableView: tableView validateDrop: info proposedRow: row proposedDropOperation: operation];
    }
    else
    {
		return NO;
    }
}


- (BOOL) tableView:(NSTableView *) tableView writeRows:(NSArray *) rows toPasteboard:(NSPasteboard *) pboard
{
    if ([self isValidDelegateForSelector: _cmd])
    {
		return [[self delegate] tableView: tableView writeRows: rows toPasteboard: pboard];
    }
    else
    {
		return NO;
    }
}

@end
