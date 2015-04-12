//
//  BoardCell.m
//  Minesweeper
//
//  Created by Chaitanya Pandit on 12/04/15.
//  Copyright (c) 2015 Chaitanya Pandit. All rights reserved.
//

#import "BoardCell.h"

@implementation BoardCell

- (void)initialize {
    
    self.label = [[UILabel alloc] init];
    [self.contentView addSubview:self.label];
    self.label.textAlignment = NSTextAlignmentCenter;
    
    self.imageView = [[UIImageView alloc] init];
    [self.contentView addSubview:self.imageView];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        [self initialize];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        [self initialize];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.label.frame = self.contentView.bounds;
    self.imageView.frame = self.contentView.bounds;
}

@end
