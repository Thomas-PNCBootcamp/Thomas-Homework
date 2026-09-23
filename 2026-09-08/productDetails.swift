//
//  EmployeeDetails.swift
//  swiftUIDemo
//
//  Created by user302999 on 9/8/26.
//

import SwiftUI

struct productDetails: View {
    
    @State  var product:Product
    
    var body: some View {
        
        @Bindable var prodBinding = product
        VStack {
            Text("product ID: \(product.id)")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("product name: \(product.name)")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("product #\(product.productNumber)")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("product Color: \(product.color)")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("product Price: $\(String(format: "%.2f",product.listPrice))")
                .font(.largeTitle)
                .fontWeight(.bold)
            
        }
        .padding()
        
    }
    
    
  
}
#Preview{
    ContentView()
}
