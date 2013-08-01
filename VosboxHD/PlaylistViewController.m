//
//  PlaylistViewController.m
//  Vosbox
//
//  Created by Lorenzo Primiterra on 15/04/2012.
//  Copyright (c) 2012 Lorenzo Primiterra. All rights reserved.
//

#import "PlaylistViewController.h"

@interface PlaylistViewController ()

@end

@implementation PlaylistViewController

@synthesize currentUrl;
@synthesize playlistsList;
@synthesize playlist;
@synthesize myDelegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)cancel:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
	//[self.delegate playerDetailsViewControllerDidCancel:self];
}



#pragma mark - 
#pragma mark Table methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	return [playlistsList count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }    
    
    NSMutableDictionary *currentPlaylist = [playlistsList objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Name", nil), [currentPlaylist objectForKey:@"NAME"]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"ID", nil), [currentPlaylist objectForKey:@"ID"]];

        
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary *currentPlaylist = [playlistsList objectAtIndex:indexPath.row];

	NSString *url = [NSString stringWithFormat: @"http://%@/api/playlist.php?load=%@", currentUrl, [currentPlaylist objectForKey:@"ID"]];
    
    NSLog(@"URL: %@",url);
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString: url]];
	[request setTimeoutInterval:30];
	[request setHTTPMethod: @"GET"];
	
	NSData *response = [NSURLConnection sendSynchronousRequest: request returningResponse: nil error: nil];
    if(response == nil){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Timeout", @"") message:NSLocalizedString(@"Connection timeout", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"Close", @"") otherButtonTitles:nil ];
        [alert show];
    }
    else {
    NSError* error;
    playlist = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:&error];

    /*delegate.playlist = [NSJSONSerialization 
                 JSONObjectWithData:response
                 options:kNilOptions 
                 error:&error];*/
	//	delegate.playlist = [stringResponse JSONValue];
    if([self.myDelegate respondsToSelector:@selector(PlaylistViewControllerDismissed:argument2:)])
    {
        [self.myDelegate PlaylistViewControllerDismissed:playlist argument2:playlistsList];
    }
    [self dismissModalViewControllerAnimated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger row = [indexPath row];

    [playlistsList removeObjectAtIndex:row];
    [self writeToDisk];
}

- (void)writeToDisk {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *arrayPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[currentUrl MD5]];
    
    [playlistsList writeToFile:arrayPath atomically:YES];
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView reloadData];
}

#pragma mark -
#pragma mark Dealloc


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft) ||  (interfaceOrientation == UIInterfaceOrientationLandscapeRight)) return YES;
    return NO;
}

@end
