/**
* Tae Won Ha — @hataewon
*
* http://taewon.de
* http://qvacua.com
*
* See LICENSE
*/

#import "VRPrefWindow.h"
#import "VRUtils.h"
#import "VRGeneralPrefPane.h"
#import "VRFileBrowserPrefPane.h"


NSString *const qPrefWindowFrameAutosaveName = @"pref-window-frame-autosave";


#define CONSTRAIN(fmt) [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:fmt options:0 metrics:nil views:views]];


@implementation VRPrefWindow {
  NSArray *_prefPanes;
  NSOutlineView *_categoryOutlineView;
  NSScrollView *_paneScrollView;
}

@autowire(userDefaultsController)

#pragma mark NSWindow
- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag {
  self = [super initWithContentRect:contentRect styleMask:NSTitledWindowMask | NSResizableWindowMask | NSClosableWindowMask backing:NSBackingStoreBuffered defer:YES];
  RETURN_NIL_WHEN_NOT_SELF

  self.title = @"Preferences";
  self.releasedWhenClosed = NO;
  [self setFrameAutosaveName:qPrefWindowFrameAutosaveName];

  return self;
}

#pragma mark TBInitializingBean
- (void)postConstruct {
  _prefPanes = @[
      [[VRGeneralPrefPane alloc] initWithUserDefaultsController:_userDefaultsController],
      [[VRFileBrowserPrefPane alloc] initWithUserDefaultsController:_userDefaultsController],
  ];

  for (NSView *prefPane in _prefPanes) {
    prefPane.translatesAutoresizingMaskIntoConstraints = NO;
  }

  [self addViews];
}

#pragma mark NSOutlineViewDelegate
- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
  VRPrefPane *selectedPane = [_categoryOutlineView itemAtRow:_categoryOutlineView.selectedRow];
  _paneScrollView.documentView = selectedPane;
}

#pragma mark NSOutlineViewDataSource
- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
  if (item == nil) {
    return _prefPanes[(NSUInteger) index];
  }

  return nil;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
  return _prefPanes.count;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(VRPrefPane *)pane {
  return pane.displayName;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
  return NO;
}

#pragma mark Private
- (void)addViews {
  NSTableColumn *tableColumn = [[NSTableColumn alloc] initWithIdentifier:@"name"];
  tableColumn.dataCell = [[NSTextFieldCell alloc] init];
  [tableColumn.dataCell setAllowsEditingTextAttributes:YES];
  [tableColumn.dataCell setLineBreakMode:NSLineBreakByTruncatingTail];

  _categoryOutlineView = [[NSOutlineView alloc] initWithFrame:CGRectZero];
  [_categoryOutlineView addTableColumn:tableColumn];
  _categoryOutlineView.outlineTableColumn = tableColumn;
  [_categoryOutlineView sizeLastColumnToFit];
  _categoryOutlineView.allowsEmptySelection = NO;
  _categoryOutlineView.allowsMultipleSelection = NO;
  _categoryOutlineView.headerView = nil;
  _categoryOutlineView.focusRingType = NSFocusRingTypeNone;
  _categoryOutlineView.dataSource = self;
  _categoryOutlineView.delegate = self;
  _categoryOutlineView.allowsMultipleSelection = NO;
  _categoryOutlineView.allowsEmptySelection = NO;

  NSScrollView *categoryScrollView = [[NSScrollView alloc] initWithFrame:CGRectZero];
  categoryScrollView.translatesAutoresizingMaskIntoConstraints = NO;
  categoryScrollView.hasVerticalScroller = YES;
  categoryScrollView.hasHorizontalScroller = YES;
  categoryScrollView.borderType = NSBezelBorder;
  categoryScrollView.autohidesScrollers = YES;
  categoryScrollView.documentView = _categoryOutlineView;

  _paneScrollView = [[NSScrollView alloc] initWithFrame:CGRectZero];
  _paneScrollView.translatesAutoresizingMaskIntoConstraints = NO;
  _paneScrollView.hasVerticalScroller = YES;
  _paneScrollView.hasHorizontalScroller = YES;
  _paneScrollView.borderType = NSNoBorder;
  _paneScrollView.autohidesScrollers = YES;
  _paneScrollView.autoresizesSubviews = YES;
  _paneScrollView.documentView = _prefPanes[0];
  _paneScrollView.backgroundColor = [NSColor windowBackgroundColor];

  NSView *contentView = self.contentView;
  [contentView addSubview:categoryScrollView];
  [contentView addSubview:_paneScrollView];

  NSDictionary *views = @{
      @"catView" : categoryScrollView,
      @"paneView" : _paneScrollView,
  };

  [contentView addConstraint:[NSLayoutConstraint constraintWithItem:categoryScrollView
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1
                                                           constant:150]];
  [contentView addConstraint:[NSLayoutConstraint constraintWithItem:_paneScrollView
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1
                                                           constant:200]];
  CONSTRAIN(@"H:|-(-1)-[catView][paneView]|")
  CONSTRAIN(@"V:|-(-1)-[catView]-(-1)-|")
  CONSTRAIN(@"V:|[paneView]|")
}

@end
