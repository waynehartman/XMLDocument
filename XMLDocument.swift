/*  Copyright (c) 2016, Wayne Hartman
 *  All rights reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions are met:
 *       1.  Redistributions of source code must retain the above copyright
 *           notice, this list of conditions and the following disclaimer.
 *       2.  Redistributions in binary form must reproduce the above copyright
 *           notice, this list of conditions and the following disclaimer in the
 *           documentation and/or other materials provided with the distribution.
 *       3.  All advertising materials mentioning features or use of this software
 *           must display the following acknowledgement:
 *           This product includes software developed by Wayne Hartman.
 *       4.  Neither the name of Wayne Hartman nor the
 *           names of its contributors may be used to endorse or promote products
 *           derived from this software without specific prior written permission.
 *
 *   THIS SOFTWARE IS PROVIDED BY Wayne Hartman ''AS IS'' AND ANY
 *   EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 *   WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 *   DISCLAIMED. IN NO EVENT SHALL Wayne Hartman BE LIABLE FOR ANY
 *   DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 *   (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 *   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 *   ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 *   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import Foundation

class XMLNode {
    lazy var children = [XMLNode]()
    var name: String
    
    init(name: String) {
        self.name = name
    }
    
    fileprivate func appendData(data: inout Data, indentLevel: Int) {
        // Do Nothing
    }
}

class XMLElement: XMLNode {
    lazy var attributes = [String: String]()
    var innerValue: String?
    
    init(name: String, innerValue: String?) {
        self.innerValue = innerValue
        
        super.init(name: name)
    }
    
    func addChild(child: XMLNode) {
        self.children.append(child)
    }
    
    func addAttribute(name: String, value: String) {
        self.attributes[name] = value
    }
    
    override fileprivate func appendData(data: inout Data, indentLevel: Int) {
        var string = String()
        
        for _ in 0..<indentLevel {
            string.append("\t")
        }
        
        string.append("<\(self.name)")
        
        for (attribute, value) in self.attributes {
            string.append(" \(attribute)=\"\(value)\"")
        }
        
        if let inner = self.innerValue {
            string.append(">\(inner)</\(self.name)>\n")
        } else if self.children.count > 0 {
            string.append(">\n")
            
            data.append(string.data(using: .utf8)!)
            string = "" // Zero it out
            
            for childNode in self.children {
                childNode.appendData(data: &data, indentLevel: indentLevel + 1)
            }
            
            string.append("</\(self.name)>")
        } else {
            string.append(" />\n")
        }
        
        data.append(string.data(using: .utf8)!)
    }
}

class XMLDocument : XMLElement {
    let version: Float
    
    init(version: Float) {
        self.version = version
        super.init(name: "xml", innerValue: nil)
    }
    
    func xmlData() -> Data {
        var data = Data()
        
        self.appendData(data: &data, indentLevel: 0)
        
        return data
    }
    
    override fileprivate func appendData(data: inout Data, indentLevel: Int) {
        let string = "<?xml version=\"\(self.version)\"?>\n"
        
        data.append(string.data(using: .utf8)!)
        
        for child in self.children {
            child.appendData(data: &data, indentLevel: 0)
        }
    }
}
