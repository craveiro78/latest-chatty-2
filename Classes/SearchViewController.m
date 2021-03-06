//
//    SearchViewController.m
//    LatestChatty2
//
//    Created by Alex Wayne on 4/20/09.
//    Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SearchViewController.h"

@implementation SearchViewController

- (id)initWithNib {
    if (self = [super initWithNib]) {
        self.title = @"Search";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (![[LatestChatty2AppDelegate delegate] isPadDevice]) {
        UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"MenuIcon.24.png"]
                                                                       style:UIBarButtonItemStyleBordered
                                                                      target:self
                                                                      action:@selector(resignAndToggle)];
        self.navigationItem.leftBarButtonItem = menuButton;
        [menuButton release];
    }
    
//    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithTitle:@"Search"
//                                                                     style:UIBarButtonItemStyleDone
//                                                                    target:self
//                                                                    action:@selector(search)];
//	self.navigationItem.rightBarButtonItem = searchButton;
//	[searchButton release];
    
    CGRect fieldRect;
    if ([[LatestChatty2AppDelegate delegate] isPadDevice]) {
        fieldRect = CGRectMake(150, 7, inputTable.frame.size.width - 220, 20);
    } else {
        fieldRect = CGRectMake(110, 7, inputTable.frame.size.width - 120, 20);
    }
    
    [inputTable setSeparatorColor:[UIColor lcGroupedSeparatorColor]];
    [inputTable setBackgroundView:nil];
    [inputTable setBackgroundView:[[[UIView alloc] init] autorelease]];
    [inputTable setBackgroundColor:[UIColor clearColor]];
    
    termsField = [[UITextField alloc] initWithFrame:fieldRect];
    termsField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    termsField.borderStyle = UITextBorderStyleNone;
    termsField.returnKeyType = UIReturnKeySearch;
    termsField.clearButtonMode = UITextFieldViewModeAlways;
    termsField.delegate = self;
    
    authorField = [[UITextField alloc] initWithFrame:fieldRect];
    authorField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    authorField.borderStyle = UITextBorderStyleNone;
    authorField.returnKeyType = UIReturnKeySearch;
    authorField.clearButtonMode = UITextFieldViewModeAlways;
    authorField.delegate = self;
    
    parentAuthorField = [[UITextField alloc] initWithFrame:fieldRect];
    parentAuthorField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    parentAuthorField.borderStyle = UITextBorderStyleNone;
    parentAuthorField.returnKeyType = UIReturnKeySearch;
    parentAuthorField.clearButtonMode = UITextFieldViewModeAlways;
    parentAuthorField.delegate = self;
    
    // Set the appearance of the segemented control
    // Rounded edges
    UIImage *segmentSelected =
    [[UIImage imageNamed:@"segcontrol_sel.png"]
     resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 15)];
    UIImage *segmentUnselected =
    [[UIImage imageNamed:@"segcontrol_uns.png"]
     resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 15)];
    
    [segmentedBar setBackgroundImage:segmentUnselected
                            forState:UIControlStateNormal
                          barMetrics:UIBarMetricsDefault];
    [segmentedBar setBackgroundImage:segmentSelected
                            forState:UIControlStateSelected
                          barMetrics:UIBarMetricsDefault];
    // Various inner states
    UIImage *segmentSelectedUnselected = [UIImage imageNamed:@"segcontrol_sel-uns.png"];
    UIImage *segUnselectedSelected = [UIImage imageNamed:@"segcontrol_uns-sel.png"];
    UIImage *segmentUnselectedUnselected = [UIImage imageNamed:@"segcontrol_uns-uns.png"];
    
    [segmentedBar setDividerImage:segmentUnselectedUnselected
              forLeftSegmentState:UIControlStateNormal
                rightSegmentState:UIControlStateNormal
                       barMetrics:UIBarMetricsDefault];
    [segmentedBar setDividerImage:segmentSelectedUnselected
              forLeftSegmentState:UIControlStateSelected
                rightSegmentState:UIControlStateNormal
                       barMetrics:UIBarMetricsDefault];
    [segmentedBar setDividerImage:segUnselectedSelected
              forLeftSegmentState:UIControlStateNormal
                rightSegmentState:UIControlStateSelected
                       barMetrics:UIBarMetricsDefault];
    
    [inputTable reloadData];
    
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SearchLoaded" object:self];
    
    //moved call to modeChanged in viewDidLoad so that it only ever gets called on view load instead of everytime
    //the view appears, was causing a crash on iPhone landscape when scrolled down, did a search, and hit back to
    //bring search back into view
    [self modeChanged];
}

- (void)resignAndToggle {
    [[self view] endEditing:YES];
    
    [self.viewDeckController toggleLeftView];
}

- (IBAction)modeChanged {
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    NSArray *fields = [NSArray arrayWithObjects:termsField, authorField, parentAuthorField, nil];
    for (UITextField *field in fields) {
        field.enabled = YES;
        field.clearButtonMode = UITextFieldViewModeAlways;
        [field setKeyboardAppearance:UIKeyboardAppearanceAlert];
    }
    
    for (UITableViewCell *cell in [inputTable visibleCells]) {        
        cell.accessoryView.hidden = YES;
    }
    
    UITextField *usernameField = nil;
    
    switch (segmentedBar.selectedSegmentIndex) {
        case 0:
            usernameField = authorField;
            break;
        
        case 1:
            usernameField = termsField;
            break;
            
        case 2:
            usernameField = parentAuthorField;
            break;
            
        default:
            break;
    }
    
    if (usernameField) {
        for (UITextField *field in fields) {
            field.text = @"";
        }
        
        usernameField.text = username;
        usernameField.enabled = NO;
        usernameField.clearButtonMode = UITextFieldViewModeNever;
        [(UITableViewCell *)usernameField.superview accessoryView].hidden = NO;
    }
    
    //Patch-E: always keeping focus in one of the text fields upon segemented control mode change, made the search button under the table view unecessary for iPhone, removed from iPhone xib and programmatically create one on the top right of navigation bar. Always scrolling the text field with focus into view on iPhone.
    switch (segmentedBar.selectedSegmentIndex) {
        case 1:
            [authorField becomeFirstResponder];
            break;
        default:
            [termsField becomeFirstResponder];
            break;
    }
    if (![[LatestChatty2AppDelegate delegate] isPadDevice]) {
        [inputTable setContentOffset:CGPointZero animated:YES];
    }
}

- (IBAction)search {
    SearchResultsViewController *viewController = [[[SearchResultsViewController alloc] initWithTerms:termsField.text
                                                                                               author:authorField.text
                                                                                         parentAuthor:parentAuthorField.text] autorelease];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self search];
    return NO;
}

#pragma mark TableView Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero] autorelease];
    
    cell.backgroundColor = [UIColor lcGroupedCellColor];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIImageView *lockImage = [UIImageView viewWithImageNamed:@"Lock.16.png"];
    lockImage.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    lockImage.hidden = YES;
    cell.accessoryView = lockImage;
    
    CGFloat leftEdge = [[LatestChatty2AppDelegate delegate] isPadDevice] ? 40 : 0;
    UILabel *prompt = [UILabel viewWithFrame:CGRectMake(leftEdge, 7, 85, 22)];
    if (indexPath.row == 0) prompt.text = @"Terms:";
    if (indexPath.row == 1) prompt.text = @"Author:";
    if (indexPath.row == 2) prompt.text = @"Parent:";
    prompt.font = [UIFont boldSystemFontOfSize:16.0];
    prompt.textAlignment = UITextAlignmentRight;
    prompt.backgroundColor = [UIColor clearColor];
    prompt.textColor = [UIColor lcGroupedCellLabelColor];
    prompt.shadowColor = [UIColor lcTextShadowColor];
    [prompt setShadowOffset:CGSizeMake(0, -1.0)];
    [cell addSubview:prompt];
    
    UITextField *textField = nil;
    
    if (indexPath.row == 0) {
        textField = termsField;
        textField.textColor = [UIColor whiteColor];
    }
    if (indexPath.row == 1) {
        textField = authorField;
    }
    if (indexPath.row == 2) {
        textField = parentAuthorField;
    }
    if (indexPath.row == 1 || indexPath.row == 2) {
        textField.textColor = [UIColor lcAuthorColor];
    }
    
    if ([[LatestChatty2AppDelegate delegate] isPadDevice]) {
        textField.frameWidth = cell.frameWidth - 195;
    } else {
        textField.frameWidth = cell.frameWidth - 120;
    }
    [cell addSubview:textField];
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (NSUInteger)supportedInterfaceOrientations {
    return [LatestChatty2AppDelegate supportedInterfaceOrientations];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return [LatestChatty2AppDelegate shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

- (void)dealloc {
    [termsField release];
    [authorField release];
    [parentAuthorField release];
    [inputTable release];
    [segmentedBar release];
    [super dealloc];
}

@end
