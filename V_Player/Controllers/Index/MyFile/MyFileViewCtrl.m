//
//  MyFileViewCtrl.m
//  V_Player
//
//  Created by 黄聪 on 2017/2/20.
//  Copyright © 2017年 黄聪. All rights reserved.
//

#import "MyFileViewCtrl.h"
#import "MyFileCell.h"
#import "avformat.h"

@interface MyFileViewCtrl (){
    NSMutableArray *fileArray;
}
@property (weak, nonatomic) IBOutlet UITableView *fileTable;

@end

@implementation MyFileViewCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *contentArray = [[NSArray alloc]init];
    fileArray = [[NSMutableArray alloc]init];
//    NSMutableDictionary *sizeDic = [[NSMutableDictionary alloc]init];
    contentArray = [fileManager contentsOfDirectoryAtPath:[self getDocumentsPath] error:nil];
    
    for (NSString *name in contentArray) {
        
        NSMutableDictionary *sizeDic = [[NSMutableDictionary alloc]init];
        NSString *fullName =[[self getDocumentsPath]stringByAppendingString:[NSString stringWithFormat:@"/%@",name]];
        NSString *sizeText = [[NSString alloc]init];
        NSLog(@"%@",fullName);
        long size = [[fileManager attributesOfItemAtPath:fullName error:nil] fileSize];
        if ([[[fileManager attributesOfItemAtPath:fullName error:nil] fileType] isEqualToString:NSFileTypeDirectory]) {
            sizeText = @"directory";
        }else{
            if (size >= pow(10, 9)) { // size >= 1GB
                sizeText = [NSString stringWithFormat:@"%.2fGB", size / pow(10, 9)];
            } else if (size >= pow(10, 6)) { // 1GB > size >= 1MB
                sizeText = [NSString stringWithFormat:@"%.2fMB", size / pow(10, 6 )];
            } else if (size >= pow(10, 3)) { // 1MB > size >= 1KB
                sizeText = [NSString stringWithFormat:@"%.2fKB", size / pow(10, 3)];
            } else { // 1KB > size
                sizeText = [NSString stringWithFormat:@"%zdB", size];
            }
            NSLog(@"%@",sizeText);
        }
        
        [sizeDic setValue:name forKey:@"fileName"];
        [sizeDic setObject:sizeText forKey:@"fileSize"];
        [fileArray addObject:sizeDic];

        
    }
    
    [fileArray removeObjectAtIndex:0];
    
    NSLog(@"%@",fileArray);
    
    _fileTable.dataSource = self;
    _fileTable.delegate =self;

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark --TableView Delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [fileArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellReuseID = @"fileCell";
    MyFileCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseID];
    if (!cell) {
        cell = [[MyFileCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseID];
    }
    
    [cell setCellContent:fileArray[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

#pragma mark --Custom Methods
- (NSString *)getDocumentsPath
{
    NSArray *DocuDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *DocuDirStr = [DocuDir objectAtIndex:0];
    return DocuDirStr;
}

@end
