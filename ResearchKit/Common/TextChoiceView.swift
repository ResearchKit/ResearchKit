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

import SwiftUI

@available(iOS 13.0, *)
struct TextChoiceView: View {
    @ObservedObject var textChoiceHelper: SwiftUITextChoiceHelper
    
    var answerDidUpdateClosure: ((Any) -> Void)?
    
    private let imageWidth: CGFloat = 115.0
    
    var body: some View {
        VStack {
            ScrollView {
                ForEach(textChoiceHelper.swiftUItextChoices) { textChoice in
                    let selected = textChoiceHelper.selectedIndexes.contains(textChoice.index)
                    let isLast = textChoice.index == textChoiceHelper.size - 1
                    
                    VStack {
                        TextChoiceRow(text: textChoice.text,
                                      image: textChoice.image,
                                      buttonTapped: buttonTapped(_:),
                                      index: textChoice.index,
                                      selected: selected,
                                      isLast: isLast,
                                      imageWidth: imageWidth)
                        
                        if !isLast {
                            Divider()
                                .padding(.leading,
                                         getDividerPadding(imagePresent: textChoice.image != nil))
                        }
                    }
                }
            }
        }
        .background(Color.clear)
    }
    
    private func buttonTapped(_ index: Int) {
        
        if let closure = answerDidUpdateClosure {
            textChoiceHelper.didSelectRowAtIndex(index: index)
            
            closure(textChoiceHelper.answersForSelectedIdexes())
        }
    }
    
    private func getDividerPadding(imagePresent: Bool) -> CGFloat {
        var dividerPadding: CGFloat = 20
        dividerPadding += (imageWidth + 16)
        
        
        return dividerPadding
    }
    
    private struct TextChoiceRow: View {
        var text: String
        var image: UIImage?
        var buttonTapped: (Int) -> Void
        var index: Int
        var selected: Bool
        var isLast: Bool
        var imageWidth: CGFloat

        @State private var isPresented = false
        
        private let rowLeadingPadding: CGFloat = 20
        
        var body: some View {
            HStack {
                
                if let img = image {
                    Image(uiImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.clear,
                                                                          lineWidth: 1))
                        .overlay(ExpandImageOverlay().padding([.leading, .top],
                                                              5),
                                 alignment: .topLeading)
                        .shadow(radius: 6, x: 1, y: 1)
                        .padding([.trailing], 16)
                        .padding([.leading], rowLeadingPadding)
                        .padding([.top, .bottom], 12)
                        .compatibleFullScreen(isPresented: $isPresented) {
                            TextChoiceImageFullView(isPresented: $isPresented,
                                                    text: text,
                                                    image: img)
                        }
                        .onTapGesture {
                            isPresented.toggle()
                        }
                }
                
                Button(action: {
                    buttonTapped(index)
                }) {
                    HStack {
                        
                        Text(text)
                            .foregroundColor(Color(.label))
                            .font(.system(.subheadline))
                            .fontWeight(.light)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Spacer()

                        Image(systemName: selected ?  "checkmark.circle.fill" : "circle")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor( selected ? Color(.systemBlue) : Color(.systemGray3))

                    }
                    .padding([.leading], self.image != nil ? 0 : rowLeadingPadding)
                    .padding([.trailing], 20)
                    .padding([.top, .bottom], 12)
                }
            }
        }
        
    }
    
    private struct ExpandImageOverlay: View {
        var body: some View {
            ZStack {
                Image(systemName: "arrow.up.left.and.arrow.down.right")
                    .resizable()
                    .frame(width: 15, height: 15)
                    .foregroundColor(Color(.gray))
            }
            .padding([.leading, .top, .bottom, .trailing], 5)
            .background(Color(.lightGray).opacity(0.4))
            .cornerRadius(5.0)
        }
    }
    
    private struct TextChoiceImageFullView: View {
        @Binding var isPresented: Bool
        var text: String
        var image: UIImage
        
        var body: some View {
            NavigationView {
                VStack {
                    Spacer()

                    Image(uiImage: image).resizable().aspectRatio(contentMode: .fit)
                    
                    Spacer()
                    
                    Text(text)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 100)
                        .background(
                            Color.gray.opacity(0.23).edgesIgnoringSafeArea(.bottom)
                        )
                }
                .background(Color.black)
                .edgesIgnoringSafeArea([.bottom, .top])
                .modifier(
                    CompatibleNavigationBarItems(
                        trailingContent: {
                            Button(action: {
                                isPresented.toggle()
                            }) {
                                Text("Done")
                            }
                            .foregroundColor(.blue)
                            
                        }
                    )
                )
            }
        }
        
    }
    
}

@available(iOS 13.0, *)
class SwiftUITextChoiceHelper: ObservableObject {
    var answer: Any
    let answerFormat: ORKTextChoiceAnswerFormat
    let textChoices: [ORKTextChoice]
    let size: Int
    fileprivate var swiftUItextChoices = [SwiftUITextChoice]()
    
    @Published var selectedIndexes = [Int]()
    
    init(answer: Any, answerFormat: ORKTextChoiceAnswerFormat) {
        self.answer = answer
        self.answerFormat = answerFormat
        self.textChoices = answerFormat.textChoices
        self.size = textChoices.count
       
        setSwiftUITextChoices()
        updateSelectedIndexes()
    }
    
    func didSelectRowAtIndex(index: Int) {
        
        if !selectedIndexes.contains(index) {
            
            if answerFormat.style == .singleChoice {
                selectedIndexes.removeAll()
            }
            selectedIndexes.append(index)
        } else if answerFormat.style == .multipleChoice {
            selectedIndexes = selectedIndexes.filter { $0 != index }
        }
        
        answer = answersForSelectedIdexes()
    }
    
    func answersForSelectedIdexes() -> Any {
        var answers = [Any]()
        
        for index in selectedIndexes {
            let textChoice = textChoices[index]
            answers.append(textChoice.value)
        }
        
        return answers
    }
    
    private func setSwiftUITextChoices() {
        var arr = [SwiftUITextChoice]()
        
        for (index, textChoice) in textChoices.enumerated() {
            let choiceID = "\(textChoice.text)-\(DateFormatter().string(from: Date()))"
            arr.append(SwiftUITextChoice(id: choiceID,
                                         text: textChoice.text,
                                         image: textChoice.image,
                                         index: index,
                                         value: textChoice.value))
        }
        
        swiftUItextChoices = arr
    }
    
    private func updateSelectedIndexes() {
        var collectedTextChoices = [ORKTextChoice]()
        
        // check to see if any previous answers have been passed through
        if let array = answer as? [Any] {
            
            for answer in array {
                let value = self.textChoices.first(where: { $0.value.isEqual(answer) })
                
                if let val = value {
                    collectedTextChoices.append(val)
                }
            }
        }
        
        // iterate through collectedTextChoices and update the selectedIndexes array
        for textChoice in collectedTextChoices {
            let result = self.swiftUItextChoices.first(where: { $0.value.isEqual(textChoice.value) })
            
            if let swiftUITextChoice = result, !selectedIndexes.contains(swiftUITextChoice.index) {
                self.selectedIndexes.append(swiftUITextChoice.index)
            }
        }
    }
    
}

@available(iOS 13.0, *)
private struct SwiftUITextChoice: Identifiable {
    var id: String
    var text: String
    var image: UIImage?
    var index: Int
    var value: NSCopying & NSSecureCoding & NSObjectProtocol
}

@available(iOS 13.0, *)
private struct CompatibleNavigationBarItems<
    LeadingContent: View,
    TrailingContent: View
>: ViewModifier {

    private let leadingContent: LeadingContent
    private let trailingContent: TrailingContent

    init(
        @ViewBuilder leadingContent: () -> LeadingContent,
        @ViewBuilder trailingContent: () -> TrailingContent
    ) {
        self.leadingContent = leadingContent()
        self.trailingContent = trailingContent()
    }

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 14, *) {
            content.toolbar {
                ToolbarItem(placement: .navigationBarLeading) { leadingContent }
                ToolbarItem(placement: .navigationBarTrailing) { trailingContent }
            }
        } else {
            content.navigationBarItems(leading: leadingContent, trailing: trailingContent)
        }
    }
}

@available(iOS 13.0, *)
extension CompatibleNavigationBarItems where LeadingContent == EmptyView {

    init(@ViewBuilder trailingContent: () -> TrailingContent) {
        self.init(
            leadingContent: { EmptyView() },
            trailingContent: trailingContent
        )
    }
}

@available(iOS 13.0, *)
extension CompatibleNavigationBarItems where TrailingContent == EmptyView {

    init(@ViewBuilder leadingContent: () -> LeadingContent) {
        self.init(
            leadingContent: leadingContent,
            trailingContent: { EmptyView() }
        )
    }
}
