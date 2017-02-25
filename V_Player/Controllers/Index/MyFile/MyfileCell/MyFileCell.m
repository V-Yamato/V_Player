//
//  MyFileCell.m
//  V_Player
//
//  Created by 黄聪 on 2017/2/20.
//  Copyright © 2017年 黄聪. All rights reserved.
//

#import "MyFileCell.h"

@interface MyFileCell()
@property (weak, nonatomic) IBOutlet UILabel *fileNameLbl;
@property (weak, nonatomic) IBOutlet UILabel *fileSizeLbl;

@end

@implementation MyFileCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark --Custom Method
- (void)setCellContent:(NSMutableDictionary*)dic {
    _fileNameLbl.text = [dic objectForKey:@"fileName"];
    if ([[dic objectForKey:@"fileSize"] isEqualToString:@"directory"]) {
        _fileSizeLbl.text =@"我是一个文件夹";
    }else {
        _fileSizeLbl.text = [dic objectForKey:@"fileSize"];
    }
}

@end
