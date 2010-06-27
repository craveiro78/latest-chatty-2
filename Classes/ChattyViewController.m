//
//  ChattyViewController.m
//  LatestChatty2
//
//  Created by Alex Wayne on 3/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ChattyViewController.h"
#import "LatestChatty2AppDelegate.h"

#include "ThreadViewController.h"
#include "NoContentController.h"

@implementation ChattyViewController

@synthesize threadController;
@synthesize storyId;
@synthesize threads;

+ (ChattyViewController*)chattyControllerWithLatest {
    return [self chattyControllerWithStoryId:0];
}

+ (ChattyViewController*)chattyControllerWithStoryId:(NSUInteger)aStoryId {//
//    LatestChatty2AppDelegate *appDelegate = (LatestChatty2AppDelegate*)[[UIApplication sharedApplication] delegate];
//    if ([appDelegate isPadDevice]) {
//        ChattyViewController *chattyController = [[[ChattyViewController alloc] initWithStoryId:aStoryId] autorelease];
//        ThreadViewController *threadController = [ThreadViewController controllerWithNib];
//        chattyController.threadController = threadController;
//        
//        UISplitViewController *splitController = [[[UISplitViewController alloc] init] autorelease];
//        splitController.delegate = threadController;
//        splitController.viewControllers = [NSArray arrayWithObjects:chattyController, threadController, nil];        
//        return splitController;
//    } else {
        return [[[ChattyViewController alloc] initWithStoryId:aStoryId] autorelease];
//    }
}


- (id)initWithLatestChatty {
    return [self initWithStoryId:0];
}

- (id)initWithStoryId:(NSUInteger)aStoryId {
	self = [super initWithNib];
    self.storyId = aStoryId;
    if ([[LatestChatty2AppDelegate delegate] isPadDevice]) {
        self.threadController = [[[ThreadViewController alloc] initWithThreadId:0] autorelease];
        //threadController.navigationItem.leftBarButtonItem = [LatestChatty2AppDelegate delegate].contentNavigationController.topViewController.navigationItem.leftBarButtonItem;
    }
    
    self.title = @"Loading...";
    
	return self;
}



- (id)initWithStateDictionary:(NSDictionary *)dictionary {
	if( self = [self initWithStoryId:[[dictionary objectForKey:@"storyId"] intValue]] ){
		
		self.storyId = [[dictionary objectForKey:@"storyId"] intValue];
		self.threads = [dictionary objectForKey:@"threads"];
		self.title =   [dictionary objectForKey:@"title"];
		lastPage =     [[dictionary objectForKey:@"lastPage"] intValue];
		currentPage =  [[dictionary objectForKey:@"currentPage"] intValue];
		
		indexPathToSelect = [[dictionary objectForKey:@"selectedIndexPath"] retain];
	}
	return self;
}

- (NSDictionary *)stateDictionary {
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Chatty", @"type",
									   [NSNumber numberWithInt:self.storyId], @"storyId",
									   threads, @"threads",
									   self.title, @"title",
									   [NSNumber numberWithInt:lastPage], @"lastPage",
									   [NSNumber numberWithInt:currentPage], @"currentPage", nil];
	
	NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
	if (selectedIndexPath) [dictionary setObject:selectedIndexPath forKey:@"selectedIndexPath"];
	
	return dictionary;
}

- (void)setTitle:(NSString *)newTitle {
    newTitle = [newTitle stringByReplacingOccurrencesOfString:@": " withString:@":\n"];
    [(UILabel*)self.navigationItem.titleView setText:newTitle];
    [super setTitle:newTitle];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[LatestChatty2AppDelegate delegate].contentNavigationController.delegate = self;
	
	if (threads == nil || [threads count] == 0) {
		[self refresh:self];
	} else {
		[self.tableView reloadData];
		if (indexPathToSelect) [self.tableView selectRowAtIndexPath:indexPathToSelect animated:NO scrollPosition:UITableViewScrollPositionTop];
	}
	
	UIBarButtonItem *composeButton = [UIBarButtonItem itemWithSystemType:UIBarButtonSystemItemCompose
                                                                  target:self
                                                                  action:@selector(tappedComposeButton)];
	composeButton.enabled = (self.storyId > 0);
    if ([[LatestChatty2AppDelegate delegate] isPadDevice]) {
        UIToolbar *rightToolbar = [UIToolbar viewWithFrame:self.navigationController.navigationBar.bounds];
        rightToolbar.tintColor = self.navigationController.navigationBar.tintColor;
        rightToolbar.frameWidth = 70;
        
        rightToolbar.items = [NSArray arrayWithObjects:
                              [UIBarButtonItem itemWithSystemType:UIBarButtonSystemItemCompose target:self action:@selector(tappedComposeButton)],
                              [UIBarButtonItem itemWithSystemType:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)],
                              nil];
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:rightToolbar] autorelease];
    } else {
        self.navigationItem.rightBarButtonItem = composeButton;
    }
    
    UILabel *titleLabel = [UILabel viewWithFrame:self.navigationController.navigationBar.frame];
    titleLabel.font = [UIFont boldSystemFontOfSize:14];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.numberOfLines = 2;
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    titleLabel.opaque = NO;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.shadowColor = [UIColor blackColor];
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.text = self.title;
    self.navigationItem.titleView = titleLabel;    
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	if(viewController == self.threadController)
		[threadController resetLayout];
}

- (IBAction)tappedComposeButton {
    ComposeViewController *viewController = [[[ComposeViewController alloc] initWithStoryId:storyId post:nil] autorelease];
    
    if ([[LatestChatty2AppDelegate delegate] isPadDevice]) {
        viewController.navigationItem.leftBarButtonItem = [LatestChatty2AppDelegate delegate].navPopoverButton;
        [LatestChatty2AppDelegate delegate].contentNavigationController.viewControllers = [NSArray arrayWithObject:viewController];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"ComposeAppeared" object:self];
        [[LatestChatty2AppDelegate delegate] dismissPopover];
    } else {
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (IBAction)refresh:(id)sender {
	[super refresh:self];
	currentPage = 1;
	
//	if (storyId > 0) {
//        loader = [[Post findAllWithStoryId:self.storyId delegate:self] retain];        
//    } else {
//        loader = [[Post findAllInLatestChattyWithDelegate:self] retain];
//    }
    
    if (storyId > 0) {
        loader = [[PinnedThreadsLoader loadPinnedThreadsThenStoryId:self.storyId for:self] retain];        
    } else {
        loader = [[PinnedThreadsLoader loadPinnedThreadsThenLatestChattyFor:self] retain];
    }
}

- (void)didFinishLoadingAllModels:(NSArray *)models otherData:(id)otherData {
	NSUInteger page = [[otherData objectForKey:@"page"] intValue];
	self.navigationItem.rightBarButtonItem.enabled = YES;
	BOOL hasPosts = [models count] > 0;
	self.navigationItem.rightBarButtonItem.enabled = hasPosts;
    
	if (page <= 1) {
		if (hasPosts) self.storyId = [[models objectAtIndex:0] storyId];
		self.threads = models;
	} else {
		NSMutableArray *newThreadsArray = [NSMutableArray arrayWithArray:self.threads];
		[newThreadsArray addObjectsFromArray:models];
		self.threads = newThreadsArray;
		[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	}
	
	lastPage = [[otherData objectForKey:@"lastPage"] intValue];
	
	NSMutableDictionary* postHistoryDict = [NSMutableDictionary dictionaryWithDictionary:
                                            [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"PostCountHistory"]];
	
	// Filter Posts
	NSMutableArray *filteredThreads = [NSMutableArray array];
	for (Post *rootPost in self.threads) {
		NSString* modelID = [NSString stringWithFormat:@"%d", rootPost.modelId];
		NSNumber* numPosts = [postHistoryDict objectForKey:modelID];
		if( numPosts ){
			rootPost.newReplies = rootPost.replyCount-[numPosts intValue];
		}
		else rootPost.newReplies = rootPost.replyCount;
		
		[postHistoryDict setObject:[NSNumber numberWithInt:rootPost.replyCount] forKey:modelID];
		if ([rootPost.category isEqualToString:@"ontopic"]) {
			[filteredThreads addObject:rootPost];
		} else if ([[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"postCategory.%@", rootPost.category]]) {
			[filteredThreads addObject:rootPost];
		}
	}
	self.threads = filteredThreads;
	
	[[NSUserDefaults standardUserDefaults] setValue:postHistoryDict forKey:@"PostCountHistory"];
	[[NSUserDefaults standardUserDefaults] synchronize];

	
	[self.tableView reloadData];
	[loader release];
	loader = nil;
	
	NSDictionary *dataDictionary = (NSDictionary *)otherData;
	self.storyId = [[dataDictionary objectForKey:@"storyId"] intValue];
	self.title   = [dataDictionary objectForKey:@"storyName"];

    // Override super method so there is no fade if we are loading a second page.
	if (page <= 1) {
		[super didFinishLoadingAllModels:models otherData:otherData];
	} else {
		// Hide the loader
		[self hideLoadingSpinner];
		
		// Refresh the table
		[self.tableView reloadData];
		
		// Scroll the table so that the first thread from the next page is at the top of the screen
		NSUInteger firstThreadIndex = [self.threads indexOfObject:[models objectAtIndex:0]];
		[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:firstThreadIndex inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
	}
	
	// Record this refresh
	if (hasPosts) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSUInteger oldLastRefresh = [defaults integerForKey:@"lastRefresh"];
		NSUInteger newLastRefresh = [[models objectAtIndex:0] lastReplyId];
		if (newLastRefresh > oldLastRefresh) {
            [defaults setInteger:newLastRefresh forKey:@"lastRefresh"];
        }
	}
    
    if ([[LatestChatty2AppDelegate delegate] isPadDevice]) {
        [LatestChatty2AppDelegate delegate].contentNavigationController.viewControllers = [NSArray arrayWithObject:threadController];
    }
    
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (currentPage < lastPage) return [threads count] + 1;
	return [threads count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row < [threads count]) {
		ThreadCell *cell = (ThreadCell *)[aTableView dequeueReusableCellWithIdentifier:@"ThreadCell"];
		if (cell == nil) {
			cell = [[[ThreadCell alloc] init] autorelease];
		}
		
		// Set up the cell...
        if ([[LatestChatty2AppDelegate delegate] isPadDevice]) {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
		cell.storyId = storyId;
		cell.rootPost = [threads objectAtIndex:indexPath.row];
		
		return cell;
	} else {
		UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero] autorelease];
		cell.textLabel.text = @"Load More";
		cell.textLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.5];
		cell.textLabel.textAlignment = UITextAlignmentCenter;
		return cell;
	}
	
	return nil;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//	return [ThreadCell cellHeight];
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row < [threads count]) {
        Post *thread = [threads objectAtIndex:indexPath.row];
        //threadController.navigationItem.leftBarButtonItem = [LatestChatty2AppDelegate delegate].navPopoverButton;
        
        [LatestChatty2AppDelegate delegate].contentNavigationController.viewControllers = [NSArray array];
        [[LatestChatty2AppDelegate delegate].contentNavigationController pushViewController:threadController animated:NO];
        
        if ([[LatestChatty2AppDelegate delegate] isPadDevice]) {
            [threadController refreshWithThreadId:thread.modelId];
            [[LatestChatty2AppDelegate delegate] dismissPopover];
            
        } else {
            [self.navigationController pushViewController:[[[ThreadViewController alloc] initWithThreadId:thread.modelId] autorelease] animated:YES];
        }
    } else {
		[self showLoadingSpinner];
		[loader cancel];
		[loader release];
		currentPage++;
		loader = [[Post findAllWithStoryId:storyId pageNumber:currentPage delegate:self] retain];
	}
}


- (void)dealloc {
	NSLog(@"Dealloc ChattyViewController");

	if([LatestChatty2AppDelegate delegate] != nil && [LatestChatty2AppDelegate delegate].contentNavigationController != nil)
		[LatestChatty2AppDelegate delegate].contentNavigationController.delegate = nil;
    self.threadController = nil;
	self.threads = nil;
	[super dealloc];
}


@end

