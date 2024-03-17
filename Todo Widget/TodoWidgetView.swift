import SwiftUI


/// Shows all todos for a specific day in a list.
struct TodoWidgetView: View {
    
    var upcomingTodos : [SimpleTodo] = []
    
    init(upcomingTodos: [SimpleTodo]) {
        self.upcomingTodos = upcomingTodos

    }
    
    private static let deeplinkURL = URL(string: "widget-deeplink://")!
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Today").font(.system(size: 12, weight: .bold)).frame(maxWidth: .infinity, alignment: .center).padding(.top, 5)
            
            if upcomingTodos.count < 1 {
                VStack {
                    Image(systemName:"checkmark.circle.fill")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(Color(UIColor.gray))
                    Text("No todos due\nfor today").frame(maxWidth: .infinity, alignment: .center).padding([.leading, .trailing, .bottom],10).font(.system(size: 12, weight: .bold)).multilineTextAlignment(.center)
                }.frame(maxHeight: .infinity)
                
                
                
            }
            else {
                LazyVGrid(
                    
                    columns: [GridItem(.adaptive(minimum: 170))],
                    alignment: .leading,
                    spacing: 5)
                {
                    
                    ForEach((0 ..< upcomingTodos.count), id: \.self) {i in
                        
                        VStack {
                            VStack {
                                HStack {
                                    Image(systemName: upcomingTodos[i].isCompleted ? "checkmark.circle.fill" : "circle")
                                        .resizable()
                                        .frame(width: 18, height: 18)
                                        .foregroundColor(Color(hexStringToUIColor(hex: upcomingTodos[i].color)))
                                    
                                    
                                    
                                    
                                    HStack {
                                        Text(upcomingTodos[i].task).font(.system(size: 12, weight: .bold)).lineLimit(1).truncationMode(.tail)
                                    }
                                    
                                }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading).padding(5)
                            }
                            .frame(minWidth: 130)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(100)
                            .padding(.horizontal, 10)
                            
                            
                            
                        }
                        
                        
                    }
                }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading).padding([.leading, .trailing, .bottom] ,4)
            }
            
        }.widgetURL(Self.deeplinkURL)
    }
}


/// Calculates the UIColor to a given hex rgb color code. Taken from: https://stackoverflow.com/questions/24263007/how-to-use-hex-color-values
/// - Parameter hex: the hex value of the color
/// - Returns: the corresponding uicolor
func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }

    if ((cString.count) != 6) {
        return UIColor.gray
    }

    var rgbValue:UInt64 = 0
    Scanner(string: cString).scanHexInt64(&rgbValue)

    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

