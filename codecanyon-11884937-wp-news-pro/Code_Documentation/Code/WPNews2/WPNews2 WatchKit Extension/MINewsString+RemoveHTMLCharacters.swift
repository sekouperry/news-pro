//
//  MINewsString+RemoveHTMLCharacters.swift
//  WPNews2 WatchKit Extension
//
//  Created by Istvan Szabo on 2015. 06. 15..
//  Copyright (c) 2015. Istvan Szabo. All rights reserved.
//

import Foundation
import WatchKit

extension String {
    
    
    func stringByDecodingNewsHTMLEntities() -> String? {
        var r: NSRange
        let pattern = "<[^>]+>"
        var s = self.stringByDecodingNewsHTMLEscapeCharacters()
        r = (s as NSString).rangeOfString(pattern, options: NSStringCompareOptions.RegularExpressionSearch)
        while (r.location != NSNotFound) {
            s = (s as NSString).stringByReplacingCharactersInRange(r, withString: " ")
            r = (s as NSString).rangeOfString(pattern, options: NSStringCompareOptions.RegularExpressionSearch)
        }
        return s.stringByReplacingOccurrencesOfString("  ", withString: " ")
    }
    
    func stringByDecodingNewsHTMLEscapeCharacters() -> String {
        var s = self.stringByReplacingOccurrencesOfString("&quot;", withString: "\"")
        s = s.stringByReplacingOccurrencesOfString("&apos;", withString: "'")
        s = s.stringByReplacingOccurrencesOfString("&amp;", withString: "&")
        s = s.stringByReplacingOccurrencesOfString("&lt;", withString: "<")
        s = s.stringByReplacingOccurrencesOfString("&gt;", withString: ">")
        s = s.stringByReplacingOccurrencesOfString("&#39;", withString: "'")
        s = s.stringByReplacingOccurrencesOfString("&ldquot;", withString: "\"")
        s = s.stringByReplacingOccurrencesOfString("&rdquot;", withString: "\"")
        s = s.stringByReplacingOccurrencesOfString("&#8217;", withString: "'")
        s = s.stringByReplacingOccurrencesOfString("&#8220;", withString: "\"")
        s = s.stringByReplacingOccurrencesOfString("&#8221;", withString: "\"")
        s = s.stringByReplacingOccurrencesOfString("&#8216;", withString: "'")
        s = s.stringByReplacingOccurrencesOfString("&#8211;", withString: "-")
        s = s.stringByReplacingOccurrencesOfString("&nbsp;", withString: " ")
        s = s.stringByReplacingOccurrencesOfString("&euro;", withString: "€")
        s = s.stringByReplacingOccurrencesOfString("&pound;", withString: "£")
        s = s.stringByReplacingOccurrencesOfString("&laquo;", withString: "«")
        s = s.stringByReplacingOccurrencesOfString("&raquo;", withString: "»")
        s = s.stringByReplacingOccurrencesOfString("&bull;", withString: "•")
        s = s.stringByReplacingOccurrencesOfString("&dagger;", withString: "†")
        s = s.stringByReplacingOccurrencesOfString("&copy;", withString: "©")
        s = s.stringByReplacingOccurrencesOfString("&reg;", withString: "®")
        s = s.stringByReplacingOccurrencesOfString("&trade;", withString: "™")
        s = s.stringByReplacingOccurrencesOfString("&deg;", withString: "°")
        s = s.stringByReplacingOccurrencesOfString("&permil;", withString: "‰")
        s = s.stringByReplacingOccurrencesOfString("&micro;", withString: "µ")
        s = s.stringByReplacingOccurrencesOfString("&middot;", withString: "·")
        s = s.stringByReplacingOccurrencesOfString("&ndash;", withString: "–")
        s = s.stringByReplacingOccurrencesOfString("&mdash;", withString: "—")
        s = s.stringByReplacingOccurrencesOfString("&#8212;", withString: "—")
        s = s.stringByReplacingOccurrencesOfString("&#8470;", withString: "№")
        s = s.stringByReplacingOccurrencesOfString("&#36;;", withString: "$")
        s = s.stringByReplacingOccurrencesOfString("&#37;", withString: "%")
        
        
        
        //Hungarian (add other language support)
       
        s = s.stringByReplacingOccurrencesOfString("&Aacute;", withString: "Á")
        s = s.stringByReplacingOccurrencesOfString("&aacute;", withString: "á")
        s = s.stringByReplacingOccurrencesOfString("&Eacute;", withString: "É")
        s = s.stringByReplacingOccurrencesOfString("&eacute;", withString: "é")
        s = s.stringByReplacingOccurrencesOfString("&Iacute;", withString: "Í")
        s = s.stringByReplacingOccurrencesOfString("&iacute;", withString: "í")
        s = s.stringByReplacingOccurrencesOfString("&Oacute;", withString: "Ó")
        s = s.stringByReplacingOccurrencesOfString("&oacute;", withString: "ó")
        s = s.stringByReplacingOccurrencesOfString("&#336;", withString: "Ő")
        s = s.stringByReplacingOccurrencesOfString("&#337;", withString: "ő")
        s = s.stringByReplacingOccurrencesOfString("&Uacute;", withString: "Ú")
        s = s.stringByReplacingOccurrencesOfString("&uacute;", withString: "ú")
        s = s.stringByReplacingOccurrencesOfString("&Uuml;", withString: "Ü")
        s = s.stringByReplacingOccurrencesOfString("&uuml;", withString: "ü")
        s = s.stringByReplacingOccurrencesOfString("&#368;", withString: "Ű")
        s = s.stringByReplacingOccurrencesOfString("&#369;", withString: "ű")
       
        return s
    }
}


/* http://www.thesauruslex.com/typo/eng/enghtml.htm
Support for additional languages

Add hungarian Ő and ő caracters support

s = s.stringByReplacingOccurrencesOfString("&#336;", withString: "Ő")
s = s.stringByReplacingOccurrencesOfString("&#337;", withString: "ő")

*/