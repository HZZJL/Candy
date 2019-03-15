//
//  VideoHallIntroCell.swift
//  QYNews
//
//  Created by Insect on 2018/12/21.
//  Copyright © 2018 Insect. All rights reserved.
//

import UIKit

class VideoHallIntroCell: TableViewCell, NibReusable {

    @IBOutlet private weak var introLabel: Label!

    public var item: VideoHallDetailModel? {
        didSet {

            guard let item = item else { return }
            introLabel.attributedText = item.album.intro.lineSpace(10)
        }
    }
}
