//
//  VosboxViewController.m
//  VosboxHD
//
//  Created by Lorenzo Primiterra on 02/06/2012.
//  Copyright (c) 2012 K2 Technology. All rights reserved.
//

#import "VosboxViewController.h"

@interface VosboxViewController ()

@end

@implementation VosboxViewController
@synthesize custom_srv;
@synthesize srv_addr;
@synthesize playlistsList;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    playlist = [[NSMutableArray alloc] init];
    covers = [NSMutableDictionary dictionary];
    currentSongINDEX = -1;
    
    [tableView2 setEditing:TRUE];
    tableView2.allowsMultipleSelectionDuringEditing = TRUE;
    
    MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:volumeSlider.bounds];
	[volumeSlider addSubview:volumeView];
	[volumeView sizeToFit];
    
    // Player is initially off
    playerON = NO;
    // Music is not playing
    playON = NO;
    [self resetScreen];
    [self loadPlaylist];
}

- (void)viewWillAppear:(BOOL)animated {
    [tableView2 reloadData];
    [self setPlayStatus];
}

- (void)reloadSettings {
    [self stopPlaying];
    [searchArray removeAllObjects];
    [playlist removeAllObjects];
    [covers removeAllObjects];
    mySearchBar.text = @"";
    currentSongINDEX = -1;
    [tableView1 reloadData];
    [tableView2 reloadData];
    startText.hidden = NO;
    [self loadPlaylist];
}

- (void)loadPlaylist {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[[self getUrl] MD5]];
    
    if ([[NSArray arrayWithContentsOfFile:filePath] count] > 0)
        playlistsList = [NSArray arrayWithContentsOfFile:filePath];
    else playlistsList = [[NSMutableArray alloc] init];
}

- (NSString*) getUrl {
    
    NSString *url;
    if([custom_srv isEqualToString:@"0"]){
        url = [NSString stringWithFormat: @"%@", BASE_URL];
    }
    else {
        url = [NSString stringWithFormat: @"%@", srv_addr];
    }
    return url;
}

#pragma mark - 
#pragma mark Search methods

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    searchBar.text = @"";
    [searchBar resignFirstResponder];
}

- (void) searchBarSearchButtonClicked:(UISearchBar *) searchBar 
{ 
    searchString = searchBar.text;
    UIActivityIndicatorView * activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.frame = CGRectMake(121.0f, 50.0f, 37.0f, 37.0f);
    [activityView startAnimating];
    
    alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Loading...", @"") message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [alertView addSubview:activityView];
    [alertView show];
    [searchBar resignFirstResponder];
    [NSThread detachNewThreadSelector:@selector(vosSearch) toTarget:self withObject:nil];
}

-(void) vosSearch {
    
    searchString = [searchString stringByReplacingOccurrencesOfString:@" "
                                                           withString:@"%20"];
    
    NSString *url = [NSString stringWithFormat: @"http://vosbox.org/dev/api/search.php?keywords=%@", searchString];
    
    NSLog(@"URL: %@",url);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString: url]];
    [request setTimeoutInterval:30];
    [request setHTTPMethod: @"GET"];
    
    NSData *response = [NSURLConnection sendSynchronousRequest: request returningResponse: nil error: nil];
    NSString *stringResponse = [[NSString alloc] initWithData: response encoding: NSUTF8StringEncoding];
    //NSLog(@"my string = %@",response);
    //NSLog(@"my response string = %@",stringResponse);
    
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
    if(response == nil){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Timeout", @"") message:NSLocalizedString(@"Connection timeout", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"Close", @"") otherButtonTitles:nil ];
        [alert show];
    }
    else if([stringResponse length]  < 3){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sorry!", @"") message:NSLocalizedString(@"Search returned no results", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"Close", @"") otherButtonTitles:nil ];
        [alert show];
    }
    else {
        NSError* error;
        searchArray = [NSJSONSerialization 
                     JSONObjectWithData:response
                     options:NSJSONReadingMutableContainers 
                     error:&error];
        startText.hidden = YES;
        [tableView1 reloadData];
    }
}

- (IBAction)enqueueAll;
{
    if ([searchArray count] > 0){
        for(NSObject *obj in searchArray) {
    //NSObject *obj = [searchArray objectAtIndex: indexPath.row];
    [playlist addObject:obj];
    [tableView2 reloadData];
        }
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:NSLocalizedString(@"Search is empty", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"Close", @"") otherButtonTitles:nil ];
        [alert show];
    }
}

#pragma mark - 
#pragma mark Table methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView.tag == 1)	return [searchArray count];
    else return [playlist count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 1) {
    static NSString *CellIdentifier = @"searchCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    UILabel *title = (UILabel *)[cell viewWithTag:1];
    UILabel *album = (UILabel *)[cell viewWithTag:2];
    UILabel *time = (UILabel *)[cell viewWithTag:3];
    UIImageView *image = (UIImageView *)[cell viewWithTag:4];
    
    NSDictionary *dictionary = [searchArray objectAtIndex: indexPath.row];
    NSString *titleValue = [NSString stringWithFormat: @"%@ - %@",[dictionary objectForKey:@"artist"], [dictionary objectForKey:@"title"]];
    NSString *timeValue = [NSString stringWithFormat: @"%@",[dictionary objectForKey:@"time"]];
    NSString *albumValue = [NSString stringWithFormat: @"%@",[dictionary objectForKey:@"album"]];
    NSString *albumArtIdValue = [NSString stringWithFormat: @"%@",[dictionary objectForKey:@"albumArtId"]];
    
    // Set up the cell
    [title setText:titleValue];
    [time setText:timeValue];
    [album setText:albumValue];
    UIImage *thumbnail;
        if ([albumArtIdValue length] == 32){
            if ([covers objectForKey:albumArtIdValue] != nil){
                thumbnail = [covers objectForKey:albumArtIdValue];
            }
            else{
                NSString *url = [NSString stringWithFormat: @"http://%@/api/albumArt.php?id=%@", [self getUrl], albumArtIdValue];
                
                thumbnail = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
                [covers setObject:thumbnail forKey:albumArtIdValue];
            }
        }
        else thumbnail = [UIImage imageNamed:@"no_cover.png"];
    [image setImage:thumbnail];
    return cell;
    }
else {
    static NSString *CellIdentifier = @"playlistCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    UILabel *title = (UILabel *)[cell viewWithTag:1];
    UILabel *album = (UILabel *)[cell viewWithTag:2];
    UILabel *time = (UILabel *)[cell viewWithTag:3];
    UIImageView *image = (UIImageView *)[cell viewWithTag:4];
    UIImageView *imageplay = (UIImageView *)[cell viewWithTag:5];
    
    NSDictionary *dictionary = [playlist objectAtIndex: indexPath.row];
    NSString *titleValue = [NSString stringWithFormat: @"%@ - %@",[dictionary objectForKey:@"artist"], [dictionary objectForKey:@"title"]];
    NSString *timeValue = [NSString stringWithFormat: @"%@",[dictionary objectForKey:@"time"]];
    NSString *albumValue = [NSString stringWithFormat: @"%@",[dictionary objectForKey:@"album"]];
    NSString *albumArtIdValue = [NSString stringWithFormat: @"%@",[dictionary objectForKey:@"albumArtId"]];
    
    // Set up the cell
    [title setText:titleValue];
    [time setText:timeValue];
    [album setText:albumValue];
    if (indexPath.row == currentSongINDEX) [imageplay setHidden:FALSE];
    else [imageplay setHidden:TRUE];
    
    cell.showsReorderControl = YES;
    
    UIImage *thumbnail;
    if ([albumArtIdValue length] == 32){
        if ([covers objectForKey:albumArtIdValue] != nil){
            thumbnail = [covers objectForKey:albumArtIdValue];
        }
        else{
            NSString *url = [NSString stringWithFormat: @"http://%@/api/albumArt.php?id=%@", [self getUrl], albumArtIdValue];
            
            thumbnail = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
            [covers setObject:thumbnail forKey:albumArtIdValue];
        }
    }
    else thumbnail = [UIImage imageNamed:@"no_cover.png"];
    [image setImage:thumbnail];
    return cell;
}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   if (tableView.tag == 1) {
    NSObject *obj = [searchArray objectAtIndex: indexPath.row];
    [playlist addObject:obj];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView2 reloadData];
   }
else {
    [self play_current_song:indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    currentSongINDEX = indexPath.row;
    [self setPlayStatus];
    [tableView2 reloadData];
}
}

#pragma mark - 
#pragma mark Table methods edit

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
            return UITableViewCellEditingStyleNone;
}

/*- (void)tableView:(UITableView *)tableView commitEditingStyle:
(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSUInteger row = [indexPath row];
        int count = [playlist count];
        [playlist removeObjectAtIndex:row];
        
        if (row == currentSongINDEX) {
            if (count == 1) [delegate stopPlaying];
            else {
                if (currentSongINDEX == count - 1) currentSongINDEX = 0;
                [delegate play_current_song:currentSongINDEX:FALSE];
                [self setPlayStatus];
            }
        }
        [tableView reloadData];
    } 
}*/

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 2) return YES;
    else return NO;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSString *stringToMove = [playlist objectAtIndex:sourceIndexPath.row];
    [playlist removeObjectAtIndex:sourceIndexPath.row];
    [playlist insertObject:stringToMove atIndex:destinationIndexPath.row];
    if (sourceIndexPath.row == currentSongINDEX) currentSongINDEX = destinationIndexPath.row;
    else if (destinationIndexPath.row == currentSongINDEX) currentSongINDEX = sourceIndexPath.row;
}

- (BOOL)tableView:(UITableView *)tableview shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - 
#pragma mark App methods

- (void)setPlayStatus {
    
    UITableViewCell *cell;    
    NSIndexPath *index;
    
    for (int i = 0 ; i < [playlist count]; i++) {
        index = [NSIndexPath indexPathForRow:i inSection:0];
        cell = [tableView2 cellForRowAtIndexPath:index];
        UIImageView *image = (UIImageView *)[cell viewWithTag:5];
        [image setHidden:TRUE];
    }
    
    if (currentSongINDEX != -1){
        NSIndexPath *index2 = [NSIndexPath indexPathForRow:currentSongINDEX inSection:0];
        UITableViewCell *cella = [tableView2 cellForRowAtIndexPath:index2];
        UIImageView *image = (UIImageView *)[cella viewWithTag:5];
        [image setHidden:FALSE];
    }
    
}

- (IBAction) shufflePlaylist {
    if ([playlist count] > 1){
        NSUInteger count = [playlist count];
        for (NSUInteger i = 0; i < count; ++i) {
            // Select a random element between i and end of array to swap with.
            int nElements = count - i;
            int n = (random() % nElements) + i;
            [playlist exchangeObjectAtIndex:i withObjectAtIndex:n];
            if (i == currentSongINDEX) currentSongINDEX = n;
            else if (n == currentSongINDEX) currentSongINDEX = i;
        }
        [tableView2 reloadData];
        [self setPlayStatus];
    }
}

- (IBAction) emptyPlaylist {
    if ([playlist count] > 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Empty playlist", nil) message:NSLocalizedString(@"Player will be stopped and playlist cleared", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        [alert setTag:2];
        [alert show];
    }
}

- (IBAction)savePlaylist {    
    if ([playlist count] > 0){
        myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Playlist name", nil) message:@"this gets covered" delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Save", nil), nil];
        [myAlertView setTag:1];
        myTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)];
        myTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        [myTextField setBackgroundColor:[UIColor whiteColor]];
        [myAlertView addSubview:myTextField];
        [myAlertView show];
        [myTextField becomeFirstResponder];
    }
    else {
        myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Playlist is empty", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Close", nil) otherButtonTitles:nil ];
        [myAlertView show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1){
        if (buttonIndex==1){
            if ([myTextField.text length] > 0){
                NSDictionary *dictionary;
                NSMutableString *ids = [[NSMutableString alloc] init];
                for (int i = 0; i < [playlist count]; i++){
                    dictionary = [playlist objectAtIndex: i];
                    NSString *idValue = [NSString stringWithFormat: @"%@",[dictionary objectForKey:@"id"]];
                    [ids appendString:[NSString stringWithFormat:@"%@,",idValue]];
                }
                NSString *url = [NSString stringWithFormat: @"http://%@/api/playlist.php?save=%@", [self getUrl], [ids substringToIndex:[ids length] - 1]];
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
                    NSDictionary* jsonArray = [NSJSONSerialization 
                                               JSONObjectWithData:response
                                               options:kNilOptions 
                                               error:&error];
                    NSArray* responseID = [jsonArray objectForKey:@"id"]; 
                    
                    NSMutableDictionary *currentPlaylist = [NSMutableDictionary dictionary];
                    
                    [currentPlaylist setObject:responseID forKey:@"ID"];
                    [currentPlaylist setObject:myTextField.text forKey:@"NAME"];
                    
                    [playlistsList addObject:currentPlaylist];
                    [self writeToDisk];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Playlist Saved", nil) message:[NSString stringWithFormat:@"%@", responseID] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil ];
                    [alert show];
                }
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"No name entered", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Close", nil) otherButtonTitles:nil ];
                [alert show];
            }
        }
    }
    else if (alertView.tag == 2) {
        if (buttonIndex==1){
            //[self stopPlaying];
            [playlist removeAllObjects];
            [tableView2 reloadData];
        }
    }    
}

- (void)writeToDisk {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *arrayPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[[self getUrl] MD5]];
    
    [playlistsList writeToFile:arrayPath atomically:YES];
}

#pragma mark - 
#pragma mark Music

- (void)play_current_song:(int)index{    
    if (!playerON)
        playerON = YES;
    currentSongINDEX = index;
    current_song = [playlist objectAtIndex: currentSongINDEX];
	[artist_label setText:[current_song objectForKey:@"artist"]];
	[album_label setText:[current_song objectForKey:@"album"]];
	[song_label setText:[current_song objectForKey:@"title"]];
    [year_label setText:[current_song objectForKey:@"year"]];
	//STATIC TIME
    [time_song setText:[current_song objectForKey:@"time"]];
    NSString *albumArtIdValue = [NSString stringWithFormat: @"%@",[current_song objectForKey:@"albumArtId"]];
    UIImage *thumbnail;
    if ([covers objectForKey:albumArtIdValue] != nil)
        thumbnail = [covers objectForKey:albumArtIdValue];
    else 
        thumbnail = [UIImage imageNamed:@"no_cover_320.png"];
    
    [album_art setImage:thumbnail];
    [self destroyStreamer];
    [self createStreamer];
    [streamer start];
}


- (IBAction)play {
    if ([playlist count] > 0) {
        if (!playON){
            //[playButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
            //playON = YES;
            if (!playerON) {
                currentSongINDEX = 0;
                [self play_current_song:currentSongINDEX];
                playerON = YES;
                [self setPlayStatus];
            }
            else {
                [self createStreamer];
                [streamer start];
            }
        }
        else {
            [playButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
            playON = NO;
            [streamer pause];
        }
    }
    else [self playlistisEmpty];
}

- (IBAction)nextSong {
    if ([playlist count] > 0) {
        if ([playlist count] > 1) {
            if (currentSongINDEX == [playlist count]-1) currentSongINDEX = 0;
            else currentSongINDEX+=1;
            [self play_current_song:currentSongINDEX];
            [playButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
            playON = YES;
            [self setPlayStatus];
        }
    }
    else [self playlistisEmpty];
}

- (IBAction)prevSong {
    if ([playlist count] > 0) {
        if ([playlist count] > 1) {
            if (currentSongINDEX > 0) currentSongINDEX-=1;
            else currentSongINDEX = [playlist count]-1;
            [self play_current_song:currentSongINDEX];
            [playButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
            playON = YES;
            [self setPlayStatus];
        }
    }
    else [self playlistisEmpty];
}

- (IBAction)stopPlaying {
    [playButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    currentSongINDEX = -1;
    playON = NO;
    playerON = NO;
    [self destroyStreamer];
    [self setPlayStatus];
    [activity stopAnimating];
    [waitingView setHidden:TRUE];
    [playButton setEnabled:TRUE];
    [self resetScreen];
}

- (void)resetScreen {
    [artist_label setText:@""];
	[album_label setText:@""];
    [year_label setText:@""];
	[song_label setText:NSLocalizedString(@"Nothing Playing", @"")];
	//[time_song setText:@""];    
    [album_art setImage:nil];
    [time_elapsed setText:@"0:00"];
    [time_song setText:@"0:00"];
    [progressSlider setValue:0];
}

- (void)playlistisEmpty {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:NSLocalizedString(@"Playlist is empty", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"Close", @"") otherButtonTitles:nil ];
    [alert show];
}

//
// destroyStreamer
//
// Removes the streamer, the UI update timer and the change notification
//
- (void)destroyStreamer
{
	if (streamer)
	{
		[[NSNotificationCenter defaultCenter]
         removeObserver:self
         name:ASStatusChangedNotification
         object:streamer];
		[progressUpdateTimer invalidate];
		progressUpdateTimer = nil;
		
		[streamer stop];
		streamer = nil;
	}
}

//
// createStreamer
//
// Creates or recreates the AudioStreamer object.
//

- (void)createStreamer
{
	if (streamer)
	{
		return;
	}
    
	[self destroyStreamer];
	
    NSDictionary *dictionary = [playlist objectAtIndex:currentSongINDEX];
    NSString *songIdValue = [NSString stringWithFormat: @"%@",[dictionary objectForKey:@"id"]];
    NSString *songUrl = [NSString stringWithFormat: @"http://%@/api/download.php?id=%@",[self getUrl], songIdValue];
    
	NSString *escapedValue =
    (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                 nil,
                                                                 (__bridge CFStringRef)songUrl,
                                                                 NULL,
                                                                 NULL,
                                                                 kCFStringEncodingUTF8);
    
	NSURL *url = [NSURL URLWithString:escapedValue];
	streamer = [[AudioStreamer alloc] initWithURL:url];
	NSLog ( @"url: %@", url);
	progressUpdateTimer =
    [NSTimer
     scheduledTimerWithTimeInterval:0.1
     target:self
     selector:@selector(updateProgress:)
     userInfo:nil
     repeats:YES];
	[[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(playbackStateChanged:)
     name:ASStatusChangedNotification
     object:streamer];
}

//
// sliderMoved:
//
// Invoked when the user moves the slider
//
// Parameters:
//    aSlider - the slider (assumed to be the progress slider)
//
- (IBAction)sliderMoved:(UISlider *)aSlider
{
	if (streamer.duration)
	{
        [progressSlider setEnabled:FALSE];
		double newSeekTime = (aSlider.value / 100.0) * streamer.duration;
		[streamer seekToTime:newSeekTime];
	}
}

// updateProgress:
//
// Invoked when the AudioStreamer
// reports that its playback progress has changed.
//
- (void)updateProgress:(NSTimer *)updatedTimer
{
	if (streamer.bitRate != 0.0)
	{
		double progress = streamer.progress;
		double duration = streamer.duration;
        
        if (duration > 0)
		{
            //[time_song setText:[NSString stringWithFormat:@"%@", [self seconds_to_human_readable:duration]]];
            [time_elapsed setText:[NSString stringWithFormat:@"%@", [self seconds_to_human_readable:progress]]];
            /*[positionLabel setText:
             [NSString stringWithFormat:@"Time Played: %.1f/%.1f seconds",
             progress,
             duration]];*/
			//[progressSlider setEnabled:YES]; //should be yes
			[progressSlider setValue:100 * progress / duration];
		}
		else
		{
			[progressSlider setEnabled:NO];
		}
	}
	else
	{
		positionLabel.text = @"0:00";
	}
}

//
// playbackStateChanged:
//
// Invoked when the AudioStreamer
// reports that its playback status has changed.
//
- (void)playbackStateChanged:(NSNotification *)aNotification
{
	if ([streamer isWaiting])
	{
		[waitingView setHidden:FALSE];
        [activity startAnimating];
        [playButton setEnabled:FALSE];
        [progressSlider setEnabled:FALSE];
	}
	else if ([streamer isPlaying])
	{
        [activity stopAnimating];
        [waitingView setHidden:TRUE];
        [playButton setEnabled:TRUE];
        [progressSlider setEnabled:YES];
		[playButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
        playON = YES;
	}
	else
        if ([streamer isIdle])
        {
            [self destroyStreamer];
            [progressSlider setEnabled:FALSE];
            [self nextSong];
        }
}

- (NSString *)seconds_to_human_readable:(int)total_seconds{
    int seconds = total_seconds % 60; // get the remainder  
    int minutes = (total_seconds / 60) % 60; // get minutes the same way
    int hours   = total_seconds / 60 / 60;  // this function won't go higher than hours.. shouldn't be a problem
	if (hours == 0) { // don't print hours then
		return [NSString stringWithFormat:@"%2d:%02d", minutes, seconds]; 
	}
	return [NSString stringWithFormat:@"%2d:%02d:%02d", hours, minutes, seconds]; 
}

- (void)checkPaused {
    if ([streamer isPaused])
	{
        [playButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        playON = NO;
        
	}
    
} 

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender 
{
    PlaylistViewController *playlistVC = (PlaylistViewController *)[segue destinationViewController];
    [playlistVC setCurrentUrl:[self getUrl]];
    [playlistVC setPlaylist:playlist];
    [playlistVC setPlaylistsList:playlistsList];
    playlistVC.myDelegate = self;
}

-(void) PlaylistViewControllerDismissed:(NSMutableArray *)newPlaylist argument2:(NSMutableArray*)newplaylistsList
{
    playlist = newPlaylist;
    playlistsList = newplaylistsList;
}


- (void)handleOpenURL:(NSURL *)url {
    NSString *text = [[url host] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if ([self checkPlaylist:text])  {
        alertView = [[UIAlertView alloc] initWithTitle:text message:NSLocalizedString(@"Playlist loaded", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    }
    else
        alertView = [[UIAlertView alloc] initWithTitle:text message:NSLocalizedString(@"Playlist ID not valid", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

- (BOOL)checkPlaylist:(NSString *)playlistID {
    NSString *url = [NSString stringWithFormat: @"http://%@/api/playlist.php?load=%@", [self getUrl], playlistID];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString: url]];
    [request setTimeoutInterval:30];
    [request setHTTPMethod: @"GET"];
    
    NSData *response = [NSURLConnection sendSynchronousRequest: request returningResponse: nil error: nil];
    
    if(response == nil){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Timeout", @"") message:NSLocalizedString(@"Connection timeout", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"Close", @"") otherButtonTitles:nil ];
        [alert show];
        return FALSE;
    }    
    else if ([response length] == 30) return FALSE;
    else {
        //TODO useful?
        [self stopPlaying];
        NSError* error;
        playlist = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:&error];
        [tableView2 reloadData];
        return TRUE;
    }
}

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
