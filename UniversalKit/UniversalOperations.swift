//
//  UniversalOperations.swift
//  UniversalKit
//
//  Created by Erick Sanchez on 8/11/17.
//
//

import Foundation

public struct UniversalOperations {
    
    public static var `default` = UniversalOperations()
    
    public var value = 5
    
    public static let sharedAppGroup: String = "group.linniergames.iWorks"
    
    public static let groupContainerPath: URL? = {
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: UniversalOperations.sharedAppGroup)
    }()
    
    //    public static let groupContainerForCoreDataModel: URL? = {
    //        let proxyBundle = Bundle(identifier: "com.linniergames.iWorks")
    //
    //        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
    //        return proxyBundle!.url(forResource: "iWork", withExtension: "momd")
    //    }()
    
}
