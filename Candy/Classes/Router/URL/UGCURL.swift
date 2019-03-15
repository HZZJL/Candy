//
//  UGCURL.swift
//  QYNews
//
//  Created by Insect on 2019/2/1.
//  Copyright © 2019 Insect. All rights reserved.
//

import Foundation

enum UGCURL {
    /// 小视频详情
    case detail
}

extension UGCURL {

    var path: String {

        switch self {

        case .detail:
            return "navigator://UGCURL/detail"
        }
    }

    static func initRouter() {

        navigator.register(UGCURL.detail.path) { url, values, context in

            guard let context = context as? [String: Any],
                let indexPath = context[indexPathTypedKey],
                let items = context[UGCVideoListTypedKey],
                let category = context[categoryTypedKey] else { return nil }
            let vc = UGCVideoDetailViewController(category: category, videoItems: items, indexPath: indexPath)
            return vc
        }
    }
}
