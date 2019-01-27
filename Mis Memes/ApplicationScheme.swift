/*
 Copyright 2018-present the Material Components for iOS authors. All Rights Reserved.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import UIKit

import MaterialComponents

class ApplicationScheme: NSObject {
    
    private static var singleton = ApplicationScheme()
    
    static var shared: ApplicationScheme {
        return singleton
    }
    
    override init() {
        self.buttonScheme.colorScheme = self.colorScheme
        self.buttonScheme.typographyScheme = self.typographyScheme
        super.init()
    }
    
    public let buttonScheme = MDCButtonScheme()
    
    public let colorScheme: MDCColorScheming = {
        let scheme = MDCSemanticColorScheme(defaults: .material201804)
        scheme.primaryColor =
            UIColor(red: 87.0/255.0, green: 31.0/255.0, blue: 229.0/255.0, alpha: 1.0)
        scheme.onPrimaryColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        scheme.surfaceColor = #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1)
        
        return scheme
    }()
    
    public let typographyScheme: MDCTypographyScheming = {
        let scheme = MDCTypographyScheme()
        //TODO: Add our custom fonts after this line
        
        return scheme
    }()
}
