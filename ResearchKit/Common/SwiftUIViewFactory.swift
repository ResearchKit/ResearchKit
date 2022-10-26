/*
 Copyright (c) 2021, Apple Inc. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3.  Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import Foundation
import SwiftUI

@objc
public class SwiftUIViewFactory: NSObject {
    
    @objc public var answerDidUpdateClosure: ((Any) -> Void)?
    
    @objc public func makeSwiftUIView(answerFormat: ORKAnswerFormat, answer: Any) -> UIView? {
        
        if #available(iOS 13.0, *) {
            
            // SwiftUI view for ORKTextChoiceAnswerFormat when at least one of the textChoices
            // has an image passed along with it
            if let textChoiceAnswerFormat = answerFormat as? ORKTextChoiceAnswerFormat {
                let textChoiceHelper = SwiftUITextChoiceHelper(answer: answer,
                                                               answerFormat: textChoiceAnswerFormat)
                var textChoiceView = TextChoiceView(textChoiceHelper: textChoiceHelper)
                textChoiceView.answerDidUpdateClosure = { answer in

                    if let closure = self.answerDidUpdateClosure {
                        closure(answer)
                    }
                }

                let hostingController = UIHostingController(rootView: textChoiceView)
                hostingController.view.backgroundColor = .clear
                return hostingController.view
            }
            
        }
        
        return nil
    }
    
}

@available(iOS 13.0, *)
struct WidthPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat?

    static func reduce(
        value: inout CGFloat?,
        nextValue: () -> CGFloat?
    ) {
        if value == nil {
            value = nextValue()
        }
    }
}

@available(iOS 13.0, *)
struct FullScreenModifier<V: View>: ViewModifier {
    let isPresented: Binding<Bool>
    let builder: () -> V

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 14.0, *) {
            content.fullScreenCover(isPresented: isPresented, content: builder)
        } else {
            content.sheet(isPresented: isPresented, content: builder)
        }
    }
}

@available(iOS 13.0, *)
extension View {
    func compatibleFullScreen<Content: View>(isPresented: Binding<Bool>,
                                             @ViewBuilder content: @escaping () -> Content) -> some View {
        self.modifier(FullScreenModifier(isPresented: isPresented, builder: content))
    }
}
