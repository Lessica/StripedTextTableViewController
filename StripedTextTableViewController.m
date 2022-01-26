//
//  StripedTextTableViewController.m
//  CommonViewControllers
//
//  Created by Lessica <82flex@gmail.com> on 2022/1/20.
//  Copyright © 2022 Zheng Wu. All rights reserved.
//

#import "StripedTextTableViewController.h"

@interface StripedTextTableViewController () <UISearchResultsUpdating>

@property (nonatomic, strong) NSArray <NSString *> *filteredTextRows;
@property (nonatomic, strong) NSArray <NSString *> *textRows;

@property (nonatomic, strong) UIBarButtonItem *trashItem;
@property (nonatomic, strong) UISearchController *searchController;

@end

@implementation StripedTextTableViewController
@synthesize entryPath = _entryPath;

+ (NSString *)viewerName {
    return @"Log Viewer";
}

- (instancetype)initWithPath:(NSString *)path {
    if (self = [super init]) {
        _entryPath = path;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (self.title.length == 0) {
        if (self.entryPath) {
            NSString *entryName = [self.entryPath lastPathComponent];
            self.title = entryName;
        } else {
            self.title = [[self class] viewerName];
        }
    }

    self.view.backgroundColor = [UIColor systemBackgroundColor];

    self.searchController = ({
        UISearchController *searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        searchController.searchResultsUpdater = self;
        searchController.obscuresBackgroundDuringPresentation = NO;
        searchController.hidesNavigationBarDuringPresentation = YES;
        searchController;
    });

    self.refreshControl = ({
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self action:@selector(reloadTextDataFromEntry:) forControlEvents:UIControlEventValueChanged];
        refreshControl;
    });

    if (self.allowTrash) {
        self.navigationItem.rightBarButtonItem = self.trashItem;
    }

    if (self.allowSearch) {
        self.navigationItem.hidesSearchBarWhenScrolling = YES;
        self.navigationItem.searchController = self.searchController;
    }

    [self.tableView setSeparatorInset:UIEdgeInsetsZero];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"StripedTextCell"];
    [self loadTextDataFromEntry];
}

- (void)reloadTextDataFromEntry:(UIRefreshControl *)sender {
    if (self.searchController.isActive) {
        return;
    }
    [self loadTextDataFromEntry];
    if ([sender isRefreshing]) {
        [sender endRefreshing];
    }
}

- (void)loadTextDataFromEntry {
    NSString *entryPath = self.entryPath;
    if (!entryPath) {
        return;
    }
    if (0 != access(entryPath.fileSystemRepresentation, W_OK)) {
        [[NSData data] writeToFile:entryPath atomically:YES];
    }
    NSURL *fileURL = [NSURL fileURLWithPath:entryPath];
    NSError *readError = nil;
    NSFileHandle *textHandler = [NSFileHandle fileHandleForReadingFromURL:fileURL error:&readError];
    if (readError) {
        self.textRows = [NSArray arrayWithObjects:readError.localizedDescription, nil];
        [self.tableView reloadData];
        return;
    }
    if (!textHandler) {
        return;
    }
    NSData *dataPart = [textHandler readDataOfLength:1024 * 1024];
    [textHandler closeFile];
    if (!dataPart) {
        return;
    }
    NSString *stringPart = [[NSString alloc] initWithData:dataPart encoding:NSUTF8StringEncoding];
    if (!stringPart) {
        self.textRows = [NSArray arrayWithObjects:[NSString stringWithFormat:NSLocalizedString(@"Cannot parse text with UTF-8 encoding: \"%@\".", nil), [entryPath lastPathComponent]], nil];
        [self.tableView reloadData];
        return;
    }
    if (stringPart.length == 0) {
        self.textRows = [NSArray arrayWithObjects:[NSString stringWithFormat:NSLocalizedString(@"The content of text file \"%@\" is empty.", nil), [entryPath lastPathComponent]], nil];
        [self.tableView reloadData];
    } else {
        NSMutableArray <NSString *> *rowTexts = [[stringPart componentsSeparatedByString:self.rowSeparator ?: @"\n["] mutableCopy];
        if (!self.preserveEmptyLines) {
            [rowTexts removeObject:@""];
        }
        if (self.reversed) {
            rowTexts = [[[rowTexts reverseObjectEnumerator] allObjects] mutableCopy];
        }
        self.textRows = rowTexts;
        [self.tableView reloadData];
    }
}

- (void)trashItemTapped:(UIBarButtonItem *)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Confirm" message:[NSString stringWithFormat:@"Do you want to clear this log file \"%@\"?", [self.entryPath lastPathComponent]] preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *_Nonnull action) {

                      }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
                          [[NSData data] writeToFile:self.entryPath atomically:YES];
                          [self loadTextDataFromEntry];
                      }]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchController.isActive ? self.filteredTextRows.count : self.textRows.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StripedTextCell" forIndexPath:indexPath];

    NSString *rowText = self.searchController.isActive ? self.filteredTextRows[indexPath.row] : self.textRows[indexPath.row];

    NSString *searchContent = self.searchController.isActive ? self.searchController.searchBar.text : nil;

    NSDictionary *rowAttrs = @{ NSFontAttributeName: [UIFont fontWithName:@"Courier" size:14.0], NSForegroundColorAttributeName: [UIColor labelColor] };

    NSMutableAttributedString *mRowText = [[NSMutableAttributedString alloc] initWithString:rowText attributes:rowAttrs];
    if (searchContent) {
        NSRange searchRange = [rowText rangeOfString:searchContent options:NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch range:NSMakeRange(0, rowText.length)];
        if (searchRange.location != NSNotFound) {
            [mRowText addAttributes:@{ NSBackgroundColorAttributeName: [UIColor colorWithRed:253.0/255.0 green:247.0/255.0 blue:148.0/255.0 alpha:1.0] } range:searchRange];
        }
    }

    [cell.textLabel setAttributedText:mRowText];
    [cell.textLabel setNumberOfLines:0];
    [cell.textLabel setLineBreakMode:NSLineBreakByCharWrapping];

    if (indexPath.row % 2 == 0) {
        [cell setBackgroundColor:[UIColor systemBackgroundColor]];
    } else {
        [cell setBackgroundColor:[UIColor secondarySystemBackgroundColor]];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.tapToCopy) {
        NSString *content = (self.searchController.isActive ? self.filteredTextRows[indexPath.row] : self.textRows[indexPath.row]);
        [[UIPasteboard generalPasteboard] setString:content];
    }
}

- (UIContextMenuConfiguration *)tableView:(UITableView *)tableView contextMenuConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath point:(CGPoint)point {
    if (self.pressToCopy) {
        NSString *content = (self.searchController.isActive ? self.filteredTextRows[indexPath.row] : self.textRows[indexPath.row]);
        NSArray <UIAction *> *cellActions = @[
            [UIAction actionWithTitle:@"Copy" image:[UIImage systemImageNamed:@"doc.on.doc"] identifier:nil handler:^(__kindof UIAction *_Nonnull action) {
                 [[UIPasteboard generalPasteboard] setString:content];
             }],
        ];
        return [UIContextMenuConfiguration configurationWithIdentifier:nil previewProvider:nil actionProvider:^UIMenu *_Nullable (NSArray<UIMenuElement *> *_Nonnull suggestedActions) {
                    UIMenu *menu = [UIMenu menuWithTitle:@"" children:cellActions];
                    return menu;
                }];
    }
    return nil;
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *text = self.searchController.searchBar.text;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", text];
    if (predicate) {
        self.filteredTextRows = [self.textRows filteredArrayUsingPredicate:predicate];
    }
    [self.tableView reloadData];
}

#pragma mark - UIView Getters

- (UIBarButtonItem *)trashItem {
    if (!_trashItem) {
        _trashItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(trashItemTapped:)];
    }
    return _trashItem;
}

#pragma mark -

- (void)dealloc {
#if DEBUG
    NSLog(@"-[%@ dealloc]", [self class]);
#endif
}

@end
